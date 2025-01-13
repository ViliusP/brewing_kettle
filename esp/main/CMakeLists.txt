idf_component_register(SRCS "main.c" "message_handling.c" "state.c"
                       INCLUDE_DIRS "."
                       REQUIRES shared matrix_keyboard ui ws_server spi_flash mbedtls
                       )

