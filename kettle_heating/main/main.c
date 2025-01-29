#include "uart_communication.h"
#include "uart_messaging.h"
#include "configuration.h"
#include "esp_log.h"
#include "temperature_sensor.h"

static const char *TAG = "MAIN";

void app_main(void)
{
    ESP_LOGI(TAG, "Hello, World!");
    
    // ================ Temperature Sensor ===================
    ds18b20_device_handle_t ds18b20_handle = initialize_temperature_sensor();
    ds18b20_set_resolution(ds18b20_handle, DS18B20_RESOLUTION_11B);
    // =======================================================

    // ================ UART ===================
    initialize_uart(uart_config, UART_TX_PIN, UART_RX_PIN);
    start_uart_task((rx_task_callback_t)&uart_message_handling);
    // ==========================================

    float temp = -55.0f;
    while (1)
    {

        esp_err_t ret = get_temperature(ds18b20_handle, &temp);
        if (ret == ESP_OK)
        {
            send_temperature_data(temp);
            ESP_LOGI(TAG, "Temperature: %.2f", temp);
        }
        else
        {
            ESP_LOGE(TAG, "Failed to read temperature");
        }
        vTaskDelay(pdMS_TO_TICKS(5 * 1000)); // Delay for 2000 milliseconds (2 seconds)
    }
}
