file(GLOB component_srcs "src/*.c" "src/pages/*.c")
file(GLOB component_fonts "font/*.c")

idf_component_register(SRCS ${component_srcs} ${component_fonts}
                       INCLUDE_DIRS "include" "font"
                       REQUIRES driver lvgl esp_lcd shared)