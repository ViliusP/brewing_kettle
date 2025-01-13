set(component_srcs "src/screen.c" "src/ui.c" "font/font_10_mdi.c" "font/font_12_mdi.c" "font/font_14_mdi.c" "font/symbols.h")

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include" "font"
                       REQUIRES driver lvgl esp_lcd shared)