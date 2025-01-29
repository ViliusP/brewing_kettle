idf_component_register(SRCS "main.c" "uart_messaging.c"
                    REQUIRES uart_communication temperature_sensor
                    INCLUDE_DIRS ".")
