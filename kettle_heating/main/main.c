#include "uart_communication.h"
#include "configuration.h"
#include "esp_log.h"
#include "temperature_sensor.h"

static const char *TAG = "MAIN";

void uart_message_handling(const char *data, const int bytes)
{
    ESP_LOGW(TAG, "Message content in string: %.*s", (int)bytes, data);
}

void app_main(void)
{
    ESP_LOGI(TAG, "Hello, World!");
    
    ds18b20_device_handle_t ds18b20_handle = initialize_temperature_sensor();
    get_temperature(ds18b20_handle);
    
    // ================ UART ===================
    initialize_uart(uart_config, UART_TX_PIN, UART_RX_PIN);
    start_uart_task((rx_task_callback_t)&uart_message_handling);
    // ==========================================
}
