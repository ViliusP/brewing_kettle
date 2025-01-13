set(component_srcs "src/screen.c" "src/ui.c" "font/font_mdi_10.c" "font/font_mdi_12.c" "font/font_mdi_14.c" "font/symbols.h")

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include" "font"
                       REQUIRES driver lvgl esp_lcd shared)