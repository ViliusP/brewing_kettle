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

static const char *TAG = "MAIN";

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
    // // Register keyboard input event handler
    matrix_kbd_register_event_handler(kbd, example_matrix_kbd_event_handler, NULL);
    // // Keyboard start to work
    matrix_kbd_start(kbd);

    initialize_screen();

    for (int i = 240; i >= 0; i--) {
        printf("Restarting in %d seconds...\n", i);
        vTaskDelay(1000 / portTICK_PERIOD_MS * 2);
    }
    printf("Restarting now.\n");
    fflush(stdout);
    esp_restart();
}