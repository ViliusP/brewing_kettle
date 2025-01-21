#include "lvgl.h"
#include "esp_err.h"
#include "common_types.h"

#ifndef SCREEN_H
#define SCREEN_H

esp_err_t start_rendering(state_subjects_t* state_subjects);
esp_err_t add_keypad_input(lv_indev_read_cb_t read_cb, void* args);
esp_err_t initialize_display(void);

#endif