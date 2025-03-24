idf_component_register(SRCS "main.c" "uart_messaging.c" "state.c"
                    PRIV_REQUIRES nvs_flash esp_adc
                    REQUIRES uart_communication temperature_sensor pid peripherals
                    INCLUDE_DIRS ".")
