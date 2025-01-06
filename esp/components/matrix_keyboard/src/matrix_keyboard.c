/*
 * SPDX-FileCopyrightText: 2020-2024 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/timers.h"
#include "esp_log.h"
#include "esp_check.h"
#include "driver/dedic_gpio.h"
#include "driver/gpio.h"
#include "esp_private/gpio.h"
#include "matrix_keyboard.h"

#define DEBOUNCE_MS 50 // Debounce time in milliseconds

static const char *TAG = "mkbd";
static QueueHandle_t gpio_evt_queue = NULL;

typedef struct matrix_kbd_t matrix_kbd_t;

/**
 * @brief Type of dedicated GPIO ISR callback function
 *
 * @param bundle Handle of GPIO bundle that returned from "dedic_gpio_new_bundle"
 * @param index Index of the GPIO in its corresponding bundle (count from 0)
 * @param args User defined arguments for the callback function. It's passed through `dedic_gpio_bundle_set_interrupt_and_callback`
 * @return If a high priority task is woken up by the callback function
 */
typedef bool (*gpio_isr_callback)(dedic_gpio_bundle_handle_t bundle, uint32_t index, void *args);

struct matrix_kbd_t
{
    dedic_gpio_bundle_handle_t row_bundle;
    dedic_gpio_bundle_handle_t col_bundle;
    dedic_gpio_bundle_handle_t led_bundle;
    uint32_t led_count;
    uint32_t nr_row_gpios;
    uint32_t nr_col_gpios;
    TimerHandle_t debounce_timer;
    matrix_kbd_event_handler event_handler;
    void *event_handler_args;
    const int *row_gpios;
    const int *col_gpios;
    const int *led_gpios;
    uint32_t row_state[0];
};

static void IRAM_ATTR gpio_isr_handler(void* arg)
{
    uint32_t gpio_num = (uint32_t)arg;
    xQueueSendFromISR(gpio_evt_queue, &gpio_num, NULL);
}

esp_err_t disable_bundle_interrupt(int gpio_array[], size_t nr_gpio);

esp_err_t disable_bundle_interrupt(int gpio_array[], size_t nr_gpio)
{
    for (int i = 0; i < nr_gpio; i++)
    {
        ESP_LOGD(TAG, "Disabling interrupt on %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_intr_disable(gpio_array[i]), TAG, "Failed to disable interrupt on GPIO %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_set_intr_type(gpio_array[i], GPIO_INTR_DISABLE), TAG, "Failed to set GPIO_INTR_DISABLE on GPIO %d", gpio_array[i]);
    }
    return ESP_OK;
}

esp_err_t enable_bundle_interrupt(int gpio_array[], size_t nr_gpio, gpio_int_type_t interrupt_type);

esp_err_t enable_bundle_interrupt(int gpio_array[], size_t nr_gpio, gpio_int_type_t interrupt_type)
{
    for (int i = 0; i < nr_gpio; i++)
    {
        ESP_LOGD(TAG, "Enabling interrupt on %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_intr_enable(gpio_array[i]), TAG, "Failed to enable interrupt on GPIO %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_set_intr_type(gpio_array[i], interrupt_type), TAG, "Failed to set interrupt type on GPIO %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_isr_handler_add(gpio_array[i], gpio_isr_handler, (void *)i), TAG, "Failed to disable isr hander %d", gpio_array[i]);
    }
    ESP_LOGD(TAG, "Interrupts enabled successfully");
    return ESP_OK;
}

static int matrix_kbd_get_row_events(matrix_kbd_t* mkbd, uint32_t row_num, key_event_t** events_ptr) {
    dedic_gpio_bundle_write(mkbd->row_bundle, 1 << row_num, 0); // Activate current row
    dedic_gpio_bundle_write(mkbd->col_bundle, (1 << mkbd->nr_col_gpios) - 1, (1 << mkbd->nr_col_gpios) - 1);

    uint32_t col_in = dedic_gpio_bundle_read_in(mkbd->col_bundle); // Read columns for this row

    uint32_t changed_col_bits = mkbd->row_state[row_num] ^ col_in; // Compare with previous state

    int col = -1;
    uint32_t key_code;
    int event_count = 0;
    *events_ptr = NULL;

    while (changed_col_bits) {
        col = __builtin_ffs(changed_col_bits) - 1;
        key_code = MAKE_KEY_CODE(row_num, col);

        // Allocate memory for the event
        *events_ptr = realloc(*events_ptr, (event_count + 1) * sizeof(key_event_t));
        if (*events_ptr == NULL) {
            ESP_LOGE(TAG, "Memory allocation failed!");
            free(*events_ptr); // Free allocated memory on error
            return -1;
        }

        (*events_ptr)[event_count].row = row_num;
        (*events_ptr)[event_count].col = col;
        (*events_ptr)[event_count].key_code = key_code;
        (*events_ptr)[event_count].event = (col_in & (1 << col)) ? MATRIX_KBD_EVENT_UP : MATRIX_KBD_EVENT_DOWN;
        event_count++;

        changed_col_bits &= (changed_col_bits - 1); // Clear the processed bit
    }

    mkbd->row_state[row_num] = col_in; // Update row state

    dedic_gpio_bundle_write(mkbd->row_bundle, (1 << mkbd->nr_row_gpios) - 1, (1 << mkbd->nr_row_gpios) - 1);
    dedic_gpio_bundle_write(mkbd->col_bundle, (1 << mkbd->nr_col_gpios) - 1, 0);

    return event_count;
}

int matrix_kbd_get_all_events(matrix_kbd_t* mkbd, key_event_t** events_ptr) {
    int total_events = 0;
    *events_ptr = NULL;

    for (uint32_t row_num = 0; row_num < mkbd->nr_row_gpios; row_num++) {
        key_event_t* row_events = NULL;
        int num_row_events = matrix_kbd_get_row_events(mkbd, row_num, &row_events);

        if (num_row_events == -1) {
            // Handle error from matrix_kbd_get_row_events
            ESP_LOGE(TAG, "Error getting events for row %lu. Cleaning up.", row_num);
            if (*events_ptr) {
                free(*events_ptr);
                *events_ptr = NULL; // Important: set to NULL after freeing
            }
            return -1; // Return error code
        }

        if (num_row_events > 0) {
            *events_ptr = realloc(*events_ptr, (total_events + num_row_events) * sizeof(key_event_t));
            if (*events_ptr == NULL) {
                ESP_LOGE(TAG, "Memory allocation failed!");
                if (row_events) free(row_events);
                if (*events_ptr) free(*events_ptr);
                *events_ptr = NULL; // Important: set to NULL after freeing
                return -1;
            }

            for (int i = 0; i < num_row_events; i++) {
                (*events_ptr)[total_events + i] = row_events[i];
            }

            total_events += num_row_events;
        }
        if (row_events) free(row_events); // Free even if num_row_events is 0
    }

    return total_events; // Return total events (can be 0)
}

static void matrix_kbd_callback(matrix_kbd_t* mkbd, uint32_t row_num) {
    key_event_t* events = NULL; // Important: Initialize to NULL
    int num_events = matrix_kbd_get_row_events(mkbd, row_num, &events);
    ESP_LOGI(TAG, "GAGASGFASDASD: row=%lu", row_num);
    for (int i = 0; i < num_events; i++) {
        ESP_LOGI(TAG, "Event: row=%d, col=%d, key_code=%" PRIx32 ", event=%d",
                    events[i].row, events[i].col, events[i].key_code, events[i].event);
        mkbd->event_handler(mkbd, events[i].event, (void*)events[i].key_code, mkbd->event_handler_args); // Call Event handler here
    }

    free(events); // Free the allocated memory
}

static void gpio_queue_handler(void *pvParameters)
{
    matrix_kbd_t* mkbd = (matrix_kbd_t*) pvParameters;
    
    uint32_t io_num;
    uint32_t last_interrupt_time = 0; 
    TickType_t xTicksToWait = pdMS_TO_TICKS(DEBOUNCE_MS); 
    for (;;)
    {
        if (xQueueReceive(gpio_evt_queue, &io_num, portMAX_DELAY))
        {
            if (xTaskGetTickCount() - last_interrupt_time > xTicksToWait) {
                disable_bundle_interrupt(mkbd->row_gpios, mkbd->nr_row_gpios);
                ESP_LOGD(TAG,  "GPOIO interrupt on GPIO[%" PRIu32 "], val: %d", io_num, gpio_get_level(io_num));
                matrix_kbd_callback(mkbd, io_num);
                enable_bundle_interrupt(mkbd->row_gpios, mkbd->nr_row_gpios, GPIO_INTR_ANYEDGE);


                last_interrupt_time = xTaskGetTickCount(); 
            } 
            else {
                ESP_LOGD(TAG, "Debounce time not passed");
            }
        }
    }
}

esp_err_t matrix_kbd_install(const matrix_kbd_config_t *config, matrix_kbd_handle_t *mkbd_handle)
{
    esp_err_t ret = ESP_OK;
    matrix_kbd_t *mkbd = NULL;
    ESP_RETURN_ON_FALSE(config && mkbd_handle, ESP_ERR_INVALID_ARG, TAG, "invalid argument");

    // Calculate total size for allocation
    size_t total_size = sizeof(matrix_kbd_t) + (config->nr_row_gpios * sizeof(uint32_t));

    mkbd = calloc(1, total_size);
    ESP_RETURN_ON_FALSE(mkbd, ESP_ERR_NO_MEM, TAG, "no mem for matrix keyboard context");

    mkbd->row_gpios = config->row_gpios;
    mkbd->col_gpios = config->col_gpios;

    mkbd->nr_col_gpios = config->nr_col_gpios;
    mkbd->nr_row_gpios = config->nr_row_gpios;

    dedic_gpio_bundle_config_t bundle_row_config = {
        .gpio_array = config->row_gpios,
        .array_size = config->nr_row_gpios,
        // Each GPIO used in matrix key board should be able to input and output
        .flags = {
            .in_en = 1,
            .out_en = 1,
        },
    };

    ESP_GOTO_ON_ERROR(dedic_gpio_new_bundle(&bundle_row_config, &mkbd->row_bundle), err, TAG, "create row bundle failed");

    // -------------
    // 4, 10, 11, 8  works
    dedic_gpio_bundle_config_t bundle_led_config = {
        .gpio_array = (int[]){10, 11, 8},
        .array_size = 3,
        // Each GPIO used in matrix key board should be able to input and output
        .flags = {
            // .in_en = 1,
            .out_en = 1,
        },
    };

    ESP_GOTO_ON_ERROR(dedic_gpio_new_bundle(&bundle_led_config, &mkbd->led_bundle), err, TAG, "create LED bundle failed");
    //-------------

    // In case the keyboard doesn't design a resister to pull up row/col line
    // We enable the internal pull up resister, enable Open Drain as well
    for (int i = 0; i < config->nr_row_gpios; i++)
    {
        ESP_LOGI(TAG, "Configuring row pin: %d", config->row_gpios[i]);
        gpio_pullup_en(config->row_gpios[i]);
        gpio_od_disable(config->row_gpios[i]);
    }


    for (int i = 0; i < config->nr_col_gpios; i++)
    {
        ESP_LOGI(TAG, "Configuring col pin: %d", config->col_gpios[i]);
        gpio_pullup_dis(config->col_gpios[i]);
        gpio_pulldown_dis(config->col_gpios[i]);
    }

    dedic_gpio_bundle_config_t bundle_col_config = {
        .gpio_array = config->col_gpios,
        .array_size = config->nr_col_gpios,
        .flags = {
            .in_en = 1,
            .out_en = 1,
        },
    };
    ESP_GOTO_ON_ERROR(dedic_gpio_new_bundle(&bundle_col_config, &mkbd->col_bundle), err, TAG, "create col bundle failed");

    ESP_GOTO_ON_ERROR(gpio_install_isr_service(0), err, TAG, "Failed to install isr service");

    ESP_GOTO_ON_ERROR(disable_bundle_interrupt(config->col_gpios, config->nr_col_gpios), err, TAG, "Failed to disable interrupts on row GPIOs");
    ESP_GOTO_ON_ERROR(disable_bundle_interrupt(config->row_gpios, config->nr_row_gpios), err, TAG, "Failed to disable interrupts on col GPIOs");
    ESP_GOTO_ON_ERROR(disable_bundle_interrupt(mkbd->led_gpios, mkbd->led_count), err, TAG, "Failed to disable interrupts on col GPIOs");

    dedic_gpio_bundle_write(mkbd->row_bundle, (1 << mkbd->nr_row_gpios) - 1, (1 << mkbd->nr_row_gpios) - 1);
    // col lines set to low level
    dedic_gpio_bundle_write(mkbd->col_bundle, (1 << mkbd->nr_col_gpios) - 1, 0);
    for (int i = 0; i < mkbd->nr_row_gpios; i++)
    {
        mkbd->row_state[i] = (1 << mkbd->nr_col_gpios) - 1;
    }

    // LED DEBUG
    dedic_gpio_bundle_write(mkbd->led_bundle, 0x04, 0x04); // Assuming all three GPIOs are in the bundle

    *mkbd_handle = mkbd;
    
    return ESP_OK;
err:
    if (mkbd->debounce_timer)
    {
        xTimerDelete(mkbd->debounce_timer, 0);
    }
    if (mkbd->col_bundle)
    {
        dedic_gpio_del_bundle(mkbd->col_bundle);
    }
    if (mkbd->row_bundle)
    {
        dedic_gpio_del_bundle(mkbd->row_bundle);
    }
    free(mkbd);
    return ret;
}

esp_err_t matrix_kbd_uninstall(matrix_kbd_handle_t mkbd_handle)
{
    ESP_RETURN_ON_FALSE(mkbd_handle, ESP_ERR_INVALID_ARG, TAG, "invalid argument");
    xTimerDelete(mkbd_handle->debounce_timer, 0);
    dedic_gpio_del_bundle(mkbd_handle->col_bundle);
    dedic_gpio_del_bundle(mkbd_handle->row_bundle);
    free(mkbd_handle);
    return ESP_OK;
}

esp_err_t matrix_kbd_start(matrix_kbd_handle_t mkbd_handle)
{
    ESP_RETURN_ON_FALSE(mkbd_handle, ESP_ERR_INVALID_ARG, TAG, "invalid argument");

    gpio_evt_queue = xQueueCreate(10, sizeof(uint32_t));

    enable_bundle_interrupt(mkbd_handle->row_gpios, mkbd_handle->nr_row_gpios, GPIO_INTR_ANYEDGE);
    xTaskCreate(gpio_queue_handler, "gpio_queue_handler", 2048, (void*)mkbd_handle, 10, NULL);
    ESP_LOGI(TAG, "gpio_queue_handler created ");
    return ESP_OK;
}

esp_err_t matrix_kbd_stop(matrix_kbd_handle_t mkbd_handle)
{
    ESP_RETURN_ON_FALSE(mkbd_handle, ESP_ERR_INVALID_ARG, TAG, "invalid argument");
    xTimerStop(mkbd_handle->debounce_timer, 0);

    // Disable interrupt
    ESP_RETURN_ON_FALSE(disable_bundle_interrupt(mkbd_handle->col_gpios, mkbd_handle->nr_col_gpios), ESP_FAIL, TAG, "Failed to disable interrupts on row GPIOs");
    ESP_RETURN_ON_FALSE(disable_bundle_interrupt(mkbd_handle->row_gpios, mkbd_handle->nr_row_gpios), ESP_FAIL, TAG, "Failed to disable interrupts on col GPIOs");

    return ESP_OK;
}

esp_err_t matrix_kbd_register_event_handler(matrix_kbd_handle_t mkbd_handle, matrix_kbd_event_handler handler, void *args)
{
    ESP_RETURN_ON_FALSE(mkbd_handle, ESP_ERR_INVALID_ARG, TAG, "invalid argument");
    mkbd_handle->event_handler = handler;
    mkbd_handle->event_handler_args = args;
    return ESP_OK;
}