set(component_srcs "src/uart_communication.c")

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include"
                       REQUIRES esp_driver_gpio esp_driver_uart)