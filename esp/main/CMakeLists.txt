idf_component_register(SRCS "main.c" "message_handling.c"
                       INCLUDE_DIRS "."
                       REQUIRES matrix_keyboard ui ws_server spi_flash mbedtls
                       )

