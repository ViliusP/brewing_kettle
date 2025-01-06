#include "lvgl.h"
#include "esp_err.h"

esp_err_t start_rendering(void);
esp_err_t add_keypad_input(lv_indev_read_cb_t read_cb, void* args);
esp_err_t initialize_display(void);
