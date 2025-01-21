idf_component_register(SRCS "ws_message_handling.c" "main.c" "state.c"
                       INCLUDE_DIRS "."
                       REQUIRES shared matrix_keyboard ui ws_server spi_flash mbedtls uart_communication
                       )

