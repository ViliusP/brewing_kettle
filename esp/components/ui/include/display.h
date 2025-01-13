#include "lvgl.h"
#include "esp_err.h"

#ifndef SCREEN_H
#define SCREEN_H

typedef struct
{
    lv_subject_t current_temp;
    lv_subject_t target_temp;
    lv_subject_t heater_state;
    lv_subject_t connected_clients;
} state_subjects_t;

#endif

esp_err_t start_rendering(state_subjects_t* state_subjects);
esp_err_t add_keypad_input(lv_indev_read_cb_t read_cb, void* args);
esp_err_t initialize_display(void);
