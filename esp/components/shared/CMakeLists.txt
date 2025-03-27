set(component_srcs "src/utilities.c" )

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include"
                       PRIV_INCLUDE_DIRS ""
                       REQUIRES json esp_http_server lvgl)