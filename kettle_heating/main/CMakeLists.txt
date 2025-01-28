idf_component_register(SRCS "main.c"
                    REQUIRES uart_communication temperature_sensor
                    INCLUDE_DIRS ".")
