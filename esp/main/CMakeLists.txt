idf_component_register(SRCS "ws_message_handling.c" "uart_messaging.c" "main.c" "state.c" "http_handlers.c"
                       INCLUDE_DIRS "."
                       REQUIRES shared ui matrix_keyboard http_server sd_card uart_communication spi_flash mbedtls  esp_app_format
                       )

