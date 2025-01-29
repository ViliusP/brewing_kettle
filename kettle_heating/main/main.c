#include "uart_communication.h"
#include "uart_messaging.h"
#include "configuration.h"
#include "esp_log.h"
#include "temperature_sensor.h"
#include "state.h"

static const char *TAG = "MAIN";

void app_main(void)
{
    ESP_LOGI(TAG, "Hello, World!");
    
    app_state_t app_state = init_state();

    // ================ Temperature Sensor ===================================
    ds18b20_device_handle_t ds18b20_handle = initialize_temperature_sensor();
    ds18b20_set_resolution(ds18b20_handle, DS18B20_RESOLUTION_10B);
    // =======================================================================

    // ================ UART ====================================
    rx_task_callback_t uart_message_handler = init_uart_message_handler(&app_state);
    initialize_uart(uart_config, UART_TX_PIN, UART_RX_PIN);
    start_uart_task(uart_message_handler);
    // ==========================================================

    while (1)
    {

        esp_err_t ret = get_temperature(ds18b20_handle, &app_state.current_temp);
        if (ret == ESP_OK)
        {
            send_temperature_data(app_state.current_temp);
            ESP_LOGI(TAG, "Temperature: %.2f", app_state.current_temp);
        }
        else
        {
            ESP_LOGE(TAG, "Failed to read temperature");
        }
        vTaskDelay(pdMS_TO_TICKS(2 * 1000)); // Delay for 2000 milliseconds (2 seconds)
    }
}
