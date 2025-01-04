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

// Define a struct to hold multiple arguments
typedef struct
{
    dedic_gpio_bundle_handle_t row_bundle;
    uint32_t row_index;
    matrix_kbd_t *mkbd;
} isr_callback_args_t;


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
        ESP_RETURN_ON_ERROR(gpio_intr_disable(gpio_array[i]), TAG, "Failed to disable interrupt on GPIO %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_set_intr_type(gpio_array[i], GPIO_INTR_DISABLE), TAG, "Failed to set GPIO_INTR_DISABLE on GPIO %d", gpio_array[i]);
        // ESP_RETURN_ON_ERROR(gpio_isr_handler_remove(gpio_array[i]), TAG, "Failed to disable isr hander %d", gpio_array[i]);
    }
    return ESP_OK;
}

esp_err_t enable_bundle_interrupt(int gpio_array[], size_t nr_gpio, gpio_int_type_t interrupt_type, gpio_isr_t cb_isr, void *cb_args);

esp_err_t enable_bundle_interrupt(int gpio_array[], size_t nr_gpio, gpio_int_type_t interrupt_type, gpio_isr_t cb_isr, void *cb_args)
{
    for (int i = 0; i < nr_gpio; i++)
    {
        ESP_LOGI(TAG, "Enabling interrupt on %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_intr_enable(gpio_array[i]), TAG, "Failed to enable interrupt on GPIO %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_set_intr_type(gpio_array[i], interrupt_type), TAG, "Failed to set interrupt type on GPIO %d", gpio_array[i]);
        ESP_RETURN_ON_ERROR(gpio_isr_handler_add(gpio_array[i], gpio_isr_handler, (void *)gpio_array[i]), TAG, "Failed to disable isr hander %d", gpio_array[i]);
    }
    ESP_LOGI(TAG, "Interrupts enabled successfully");
    return ESP_OK;
}

static void gpio_task_example(void *arg)
{
    ESP_LOGI(TAG, "PAPAPPAPAPAPAPAP");
    uint32_t io_num;
    for (;;)
    {
        if (xQueueReceive(gpio_evt_queue, &io_num, portMAX_DELAY))
        {
            printf("GPIO[%" PRIu32 "] intr, val: %d\n", io_num, gpio_get_level(io_num));
        }
    }
}

// static void IRAM_ATTR matrix_kbd_row_isr_callback(void *arg)
// {
//     ESP_LOGI(TAG,"ISR callback -> HELLO");
//     uint32_t gpio_num = (uint32_t) arg;
//     xQueueSendFromISR(gpio_evt_queue, &gpio_num, NULL);
//     // BaseType_t high_task_wakeup = pdFALSE;
//     // isr_callback_args_t *isr_args = (isr_callback_args_t *)args;
//     // matrix_kbd_t *mkbd = isr_args->mkbd;

//     // ESP_LOGI(TAG,"ISR callback -> nr_row_gpios %lu", mkbd->nr_row_gpios);
//     // disable_bundle_interrupt(mkbd->row_gpios, mkbd->nr_row_gpios);

//     // // get row id, start to check the col id
//     // dedic_gpio_bundle_write(isr_args->row_bundle, 1 << isr_args->row_index, 0);
//     // dedic_gpio_bundle_write(mkbd->col_bundle, (1 << mkbd->nr_col_gpios) - 1, (1 << mkbd->nr_col_gpios) - 1);
//     // xTimerStartFromISR(mkbd->debounce_timer, &high_task_wakeup);
//     return;
// }

static void matrix_kbd_debounce_timer_callback(TimerHandle_t xTimer)
{
    ESP_LOGI(TAG, "HELLO THERE");

    matrix_kbd_t *mkbd = (matrix_kbd_t *)pvTimerGetTimerID(xTimer);

    uint32_t row_out = dedic_gpio_bundle_read_out(mkbd->row_bundle);
    uint32_t col_in = dedic_gpio_bundle_read_in(mkbd->col_bundle);
    row_out = (~row_out) & ((1 << mkbd->nr_row_gpios) - 1);
    ESP_LOGD(TAG, "row_out=%" PRIx32 ", col_in=%" PRIx32, row_out, col_in);
    int row = -1;
    int col = -1;
    uint32_t key_code = 0;
    // while (row_out) {
    //     row = __builtin_ffs(row_out) - 1;
    //     uint32_t changed_col_bits = mkbd->row_state[row] ^ col_in;
    //     while (changed_col_bits) {
    //         col = __builtin_ffs(changed_col_bits) - 1;
    //         ESP_LOGD(TAG, "row=%d, col=%d", row, col);
    //         key_code = MAKE_KEY_CODE(row, col);
    //         if (col_in & (1 << col)) {
    //             mkbd->event_handler(mkbd, MATRIX_KBD_EVENT_UP, (void *)key_code, mkbd->event_handler_args);
    //         } else {
    //             mkbd->event_handler(mkbd, MATRIX_KBD_EVENT_DOWN, (void *)key_code, mkbd->event_handler_args);
    //         }
    //         changed_col_bits = changed_col_bits & (changed_col_bits - 1);
    //     }
    //     mkbd->row_state[row] = col_in;
    //     row_out = row_out & (row_out - 1);
    // }

    // // row lines set to high level
    // dedic_gpio_bundle_write(mkbd->row_bundle, (1 << mkbd->nr_row_gpios) - 1, (1 << mkbd->nr_row_gpios) - 1);
    // // col lines set to low level
    // dedic_gpio_bundle_write(mkbd->col_bundle, (1 << mkbd->nr_col_gpios) - 1, 0);
    // dedic_gpio_bundle_set_interrupt_and_callback(mkbd->row_bundle, (1 << mkbd->nr_row_gpios) - 1,
    //  DEDIC_GPIO_INTR_BOTH_EDGE, matrix_kbd_row_isr_callback, mkbd);
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

    // Create a one-shot os timer, used for key debounce
    // mkbd->debounce_timer = xTimerCreate("kb_debounce", pdMS_TO_TICKS(config->debounce_ms), pdFALSE, mkbd, matrix_kbd_debounce_timer_callback);
    // ESP_GOTO_ON_FALSE(mkbd->debounce_timer, ESP_FAIL, err, TAG, "create debounce timer failed");

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
        gpio_od_enable(config->row_gpios[i]);
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

    for (int i = 0; i < config->nr_col_gpios; i++)
    {
        ESP_LOGI(TAG, "Configuring col pin: %d", config->col_gpios[i]);
        gpio_pullup_en(config->col_gpios[i]);
        gpio_od_enable(config->col_gpios[i]);
    }

    ESP_GOTO_ON_ERROR(gpio_install_isr_service(0), err, TAG, "Failed to install isr service");
    ESP_GOTO_ON_ERROR(disable_bundle_interrupt(config->col_gpios, config->nr_col_gpios), err, TAG, "Failed to disable interrupts on row GPIOs");
    ESP_GOTO_ON_ERROR(disable_bundle_interrupt(config->row_gpios, config->nr_row_gpios), err, TAG, "Failed to disable interrupts on col GPIOs");
    ESP_GOTO_ON_ERROR(disable_bundle_interrupt(mkbd->led_gpios, mkbd->led_count), err, TAG, "Failed to disable interrupts on col GPIOs");

    gpio_evt_queue = xQueueCreate(10, sizeof(uint32_t));

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

    // dedic_gpio_bundle_write(mkbd_handle->led_bundle, 0x07, 0x00);
    dedic_gpio_bundle_write(mkbd_handle->led_bundle, 0x04, 0x04); // Assuming all three GPIOs are in the bundle

    dedic_gpio_bundle_write(mkbd_handle->row_bundle, (1 << mkbd_handle->nr_row_gpios) - 1, (1 << mkbd_handle->nr_row_gpios) - 1);
    // col lines set to low level
    // dedic_gpio_bundle_write(mkbd_handle->col_bundle, (1 << mkbd_handle->nr_col_gpios) - 1, 0);

    for (int i = 0; i < mkbd_handle->nr_row_gpios; i++)
    {
        mkbd_handle->row_state[i] = (1 << mkbd_handle->nr_col_gpios) - 1;
    }


    // // // only enable row line interrupt
    enable_bundle_interrupt(mkbd_handle->row_gpios, mkbd_handle->nr_row_gpios, GPIO_INTR_ANYEDGE, NULL, NULL);
    xTaskCreate(gpio_task_example, "gpio_task_example", 2048, NULL, 10, NULL);
    ESP_LOGI(TAG, "gpio_task_example created ");
    return ESP_OK;
}

esp_err_t matrix_kbd_stop(matrix_kbd_handle_t mkbd_handle)
{
    ESP_RETURN_ON_FALSE(mkbd_handle, ESP_ERR_INVALID_ARG, TAG, "invalid argument");
    xTimerStop(mkbd_handle->debounce_timer, 0);

    // Disable interrupt
    // dedic_gpio_bundle_set_interrupt_and_callback(mkbd_handle->row_bundle, (1 << mkbd_handle->nr_row_gpios) - 1,
    //                                              DEDIC_GPIO_INTR_NONE, NULL, NULL);
    // dedic_gpio_bundle_set_interrupt_and_callback(mkbd_handle->col_bundle, (1 << mkbd_handle->nr_col_gpios) - 1,
    //                                              DEDIC_GPIO_INTR_NONE, NULL, NULL);

    return ESP_OK;
}

esp_err_t matrix_kbd_register_event_handler(matrix_kbd_handle_t mkbd_handle, matrix_kbd_event_handler handler, void *args)
{
    ESP_RETURN_ON_FALSE(mkbd_handle, ESP_ERR_INVALID_ARG, TAG, "invalid argument");
    mkbd_handle->event_handler = handler;
    mkbd_handle->event_handler_args = args;
    return ESP_OK;
}