idf_component_register(SRCS "main.c" "uart_messaging.c" "state.c"
                    REQUIRES uart_communication temperature_sensor pid
                    INCLUDE_DIRS ".")
