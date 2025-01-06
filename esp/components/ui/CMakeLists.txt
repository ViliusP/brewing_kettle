set(component_srcs "src/screen.c" "src/lvgl_demo_ui.c" "src/ui.c")

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include"
                       REQUIRES driver lvgl esp_lcd)