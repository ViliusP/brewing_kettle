idf_component_register(SRCS "main.c" "ui/screen_init.c" "ui/lvgl_demo_ui.c"
                       PRIV_REQUIRES matrix_keyboard
                       INCLUDE_DIRS "." "ui")

