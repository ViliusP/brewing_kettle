/*
 * SPDX-FileCopyrightText: 2021-2024 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: CC0-1.0
 */
#include <stdio.h>
#include "esp_log.h"
#include "matrix_keyboard.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "lvgl.h"
#include "display.h"
#include "http_server.h"
#include "uart_communication.h"
#include "esp_system.h"
#include "ws_message_handling.h"
#include "uart_messaging.h"
#include "state.h"
#include "configuration.h"
#include <esp_sntp.h>
#include "sd_card.h"
#include "http_handlers.h"

static const char *TAG = "MAIN";

/* Variable holding number of times ESP32 restarted since first boot.
 * It is placed into RTC memory using RTC_DATA_ATTR and
 * maintains its value when ESP32 wakes from deep sleep.
 */

RTC_DATA_ATTR static int boot_count = 0;

/**
 * @brief Matrix keyboard event handler
 * @note This function is run under OS timer task context
 */
esp_err_t example_matrix_kbd_event_handler(matrix_kbd_handle_t mkbd_handle, matrix_kbd_event_id_t event, void *event_data, void *handler_args)
{
    ESP_LOGI(TAG, "HELOOOOOOOOOOOOOOOO");
    uint32_t key_code = (uint32_t)event_data;
    switch (event)
    {
    case MATRIX_KBD_EVENT_DOWN:
        ESP_LOGI(TAG, "press event, key code = %04" PRIx32, key_code);
        break;
    case MATRIX_KBD_EVENT_UP:
        ESP_LOGI(TAG, "release event, key code = %04" PRIx32, key_code);
        break;
    }
    return ESP_OK;
}

// Mapping of your key codes to LVGL key codes
typedef struct
{
    uint16_t key_code;
    lv_key_t lvgl_key;
    // ... other properties
} key_map_t;

static const key_map_t key_mappings[] = {
    {MAKE_KEY_CODE(1, 2), LV_KEY_UP},
    {MAKE_KEY_CODE(2, 0), LV_KEY_DOWN},
    {MAKE_KEY_CODE(2, 1), LV_KEY_RIGHT},
    {MAKE_KEY_CODE(1, 1), LV_KEY_LEFT},
    {MAKE_KEY_CODE(2, 2), LV_KEY_ENTER},
    {MAKE_KEY_CODE(0, 2), LV_KEY_NEXT},

    // ... other mappings
};

// Lookup utility function
static lv_key_t map_key_code(uint16_t key_code)
{
    for (size_t i = 0; i < sizeof(key_mappings) / sizeof(key_mappings[0]); i++)
    {
        if (key_code == key_mappings[i].key_code)
        {
            return key_mappings[i].lvgl_key;
        }
    }
    return 0; // Return 0 if no mapping is found
}
static void keypad_read(lv_indev_t *indev_drv, lv_indev_data_t *data)
{
    matrix_kbd_handle_t kbd = (matrix_kbd_handle_t)lv_indev_get_user_data(indev_drv); // Get kbd

    if (kbd == NULL)
    {
        ESP_LOGE(TAG, "Keyboard handle is NULL in keypad_read!");
        data->state = LV_INDEV_STATE_REL;
        return; // Important: Return to avoid crashes
    }
    key_event_t *all_events = NULL;
    int total_events = matrix_kbd_get_all_events(kbd, &all_events); // Use the global kbd

    if (total_events == -1)
    {
        ESP_LOGE(TAG, "Error getting events.");
        return;
    }
    if (total_events == 0)
    {
        data->state = LV_INDEV_STATE_REL;
    }

    data->state = LV_INDEV_STATE_REL; // Default state: RELEASED

    for (int i = 0; i < total_events; i++)
    {
        lv_key_t mapped_key = map_key_code(all_events[i].key_code);
        ESP_LOGD(TAG, "Handling raw key code %04" PRIx32 " | row %d, col %d", all_events[i].key_code, all_events[i].row, all_events[i].col);
        if (mapped_key != 0)
        { // Check if a mapping was found
            ESP_LOGD(TAG, "Sending LVGL key code %d", mapped_key);
            data->key = mapped_key;
            data->state = (all_events[i].event == MATRIX_KBD_EVENT_DOWN) ? LV_INDEV_STATE_PR : LV_INDEV_STATE_REL;
            break; // Process only one event per call
        }
        else
        {
            ESP_LOGW(TAG, "No mapping found for key code %04" PRIx32, all_events[i].key_code);
        }
    }
    free(all_events);
}

void app_main(void)
{
    ++boot_count;
    ESP_LOGI(TAG, "Hello, World!");
    ESP_LOGI(TAG, "Boot count: %d", boot_count);

    init_sdcard();
    initialize_display();


    // ================ state ===================
    app_state_t *app_state = app_state_init();
    state_subjects_t *state_subjects = init_state_subjects(app_state);
    // ==========================================

    // ================ UART ===================
    rx_task_callback_t uart_message_handler = init_uart_message_handler(state_subjects);
    initialize_uart(uart_config, UART_TX_PIN, UART_RX_PIN);
    start_uart_task(uart_message_handler);
    // ==========================================

    // ================ keyboard ===================
    // Install matrix keyboard driver
    matrix_kbd_handle_t kbd = NULL;
    matrix_kbd_install(&kbd_config, &kbd);
    // Register keyboard input event handler
    // matrix_kbd_register_event_handler(kbd, example_matrix_kbd_event_handler, NULL);
    // // // Keyboard start to work
    // matrix_kbd_start(kbd);
    // ==========================================

    // ================= UI =====================
    add_keypad_input(keypad_read, kbd);
    start_rendering(state_subjects);
    // ==========================================

    // ============== HTTP_SERVER =================
    const size_t count = http_handlers_get_count();
    const httpd_uri_t *handlers = http_handlers_get_array();

    ws_message_handler_t ws_messages_handler = create_ws_handler();
    ws_client_changed_cb_t ws_client_change_cb = (ws_client_changed_cb_t)&connected_client_data_notify;
    httpd_handle_t httpd_handle = initialize_http_server(ws_messages_handler, ws_client_change_cb);
    init_ws_observer(state_subjects, httpd_handle);
    // ==========================================

    /// DO NOT DELETE
    for (int i = 720 * 1000; i >= 0; i--)
    {
        if (i % 60 == 0)
        {
            printf("Restarting in %d seconds...\n", i);
        }
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
    printf("Restarting now.\n");
    fflush(stdout);
    esp_restart();
}