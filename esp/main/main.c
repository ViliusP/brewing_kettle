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
typedef struct {
    uint16_t key_code;
    lv_key_t lvgl_key;
    // ... other properties
} key_map_t;

static key_map_t key_mappings[] = {
    {MAKE_KEY_CODE(0, 0), LV_KEY_DOWN},
    {MAKE_KEY_CODE(0, 1), LV_KEY_PREV},
    {MAKE_KEY_CODE(1, 1), LV_KEY_UP},
    {MAKE_KEY_CODE(1, 0), LV_KEY_NEXT},
    // ... other mappings
};

// Lookup utility function
static lv_key_t map_key_code(uint16_t key_code) {
    for (size_t i = 0; i < sizeof(key_mappings) / sizeof(key_mappings[0]); i++) {
        if (key_code == key_mappings[i].key_code) {
            return key_mappings[i].lvgl_key;
        }
    }
    return 0; // Return 0 if no mapping is found
}


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

    data->state = LV_INDEV_STATE_REL; // Default state: RELEASED

    for (int i = 0; i < total_events; i++) {
        lv_key_t mapped_key = map_key_code(all_events[i].key_code);
        if (mapped_key != 0) { // Check if a mapping was found
            ESP_LOGI(TAG, "Sending LVGL key code %d", mapped_key);
            data->key = mapped_key;
            data->state = (all_events[i].event == MATRIX_KBD_EVENT_DOWN) ? LV_INDEV_STATE_PR : LV_INDEV_STATE_REL;
            break; // Process only one event per call
        } else {
            ESP_LOGW(TAG, "No mapping found for key code %04"PRIx32, all_events[i].key_code);
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
    // matrix_kbd_register_event_handler(kbd, example_matrix_kbd_event_handler, NULL);
    // // // Keyboard start to work
    // matrix_kbd_start(kbd);


    // =======================================
    initialize_screen();

    lv_indev_t * indev = lv_indev_create();
    

    lv_indev_set_type(indev, LV_INDEV_TYPE_KEYPAD);

    lv_indev_set_user_data(indev, kbd); // Pass kbd to the input device
    lv_indev_set_read_cb(indev, keypad_read);

    lv_group_t * g = lv_group_create();
    lv_indev_set_group(indev, g);



    // =======================================


    /// DO NOT DELETE
    for (int i = 240; i >= 0; i--) {
        printf("Restarting in %d seconds...\n", i);
        vTaskDelay(1000 / portTICK_PERIOD_MS * 2);
    }
    printf("Restarting now.\n");
    fflush(stdout);
    esp_restart();
}