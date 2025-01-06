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

static const char *TAG = "MAIN";

// Mapping of your key codes to LVGL key codes
static uint32_t key_mapping[] = {
    [0] = LV_KEY_NEXT,     // Example: Key code 0 maps to LV_KEY_NEXT
    [1] = LV_KEY_PREV,     // Example: Key code 1 maps to LV_KEY_PREV
    [2] = LV_KEY_ENTER,    // Example: Key code 2 maps to LV_KEY_ENTER
    [3] = LV_KEY_UP,       // Example: Key code 3 maps to LV_KEY_UP
    [4] = LV_KEY_DOWN,     // Example: Key code 4 maps to LV_KEY_DOWN
    [5] = LV_KEY_LEFT,     // Example: Key code 5 maps to LV_KEY_LEFT
    [6] = LV_KEY_RIGHT,    // Example: Key code 6 maps to LV_KEY_RIGHT
    // ... map other keys as needed
};

/**
 * @brief Matrix keyboard event handler
 * @note This function is run under OS timer task context
 */
esp_err_t example_matrix_kbd_event_handler(matrix_kbd_handle_t mkbd_handle, matrix_kbd_event_id_t event, void *event_data, void *handler_args)
{
    ESP_LOGI(TAG, "HELOOOOOOOOOOOOOOOO");
    uint32_t key_code = (uint32_t)event_data;
    switch (event) {
    case MATRIX_KBD_EVENT_DOWN:
        ESP_LOGI(TAG, "press event, key code = %04"PRIx32, key_code);
        break;
    case MATRIX_KBD_EVENT_UP:
        ESP_LOGI(TAG, "release event, key code = %04"PRIx32, key_code);
        break;
    }
    return ESP_OK;
}

static void keypad_read(lv_indev_t * indev_drv, lv_indev_data_t* data) {
    matrix_kbd_handle_t kbd = (matrix_kbd_handle_t)lv_indev_get_user_data(indev_drv); // Get kbd

    if (kbd == NULL) {
        ESP_LOGE(TAG, "Keyboard handle is NULL in keypad_read!");
        data->state = LV_INDEV_STATE_REL;
        return; // Important: Return to avoid crashes
    }
    key_event_t* all_events = NULL;
    int total_events = matrix_kbd_get_all_events(kbd, &all_events); // Use the global kbd

    if (total_events == -1) {
        ESP_LOGE(TAG, "Error getting events.");
        return;
    } 
    if (total_events == 0) {
        data->state = LV_INDEV_STATE_REL;
    }
    // Process events and set data->btn_id accordingly.
    // Example (adapt to your key mapping):
    for (int i = 0; i < total_events; i++) {
        ESP_LOGI(TAG, "Event: row=%d, col=%d, key_code=%" PRIx32 ", event=%d",
                    all_events[i].row, all_events[i].col, all_events[i].key_code, all_events[i].event);
        if(all_events[i].event == MATRIX_KBD_EVENT_DOWN){
            data->btn_id = all_events[i].key_code;
            data->state = LV_INDEV_STATE_PR;
            break;
        }
    }
    free(all_events);
    
}

extern void initialize_screen();

void app_main(void)
{
    matrix_kbd_handle_t kbd = NULL;
    // Apply default matrix keyboard configuration
    matrix_kbd_config_t config = MATRIX_KEYBOARD_DEFAULT_CONFIG();
    // Set GPIOs used by row and column line
    config.nr_col_gpios = 2;
    config.col_gpios = (int[]) {
        20, 21
    };
    config.nr_row_gpios = 2;
    config.row_gpios = (int[]) {
        18, 19
    };  

    // Install matrix keyboard driver
    matrix_kbd_install(&config, &kbd);
    // Register keyboard input event handler
    matrix_kbd_register_event_handler(kbd, example_matrix_kbd_event_handler, NULL);
    // // Keyboard start to work
    matrix_kbd_start(kbd);

    initialize_screen();

    // =======================================
    // lv_indev_t * indev = lv_indev_create();
    // lv_indev_set_type(indev, LV_INDEV_TYPE_KEYPAD);
    // lv_indev_set_user_data(indev, kbd); // Pass kbd to the input device
    // lv_indev_set_read_cb(indev, keypad_read);
    // =======================================
}