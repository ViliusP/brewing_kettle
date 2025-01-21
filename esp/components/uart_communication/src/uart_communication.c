#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "string.h"
#include "driver/gpio.h"
#include "uart_communication.h"

static const char *TAG = "UART";

static void rx_task(void *arg)
{
    static const char *RX_TASK_TAG = "RX_TASK";

    rx_task_callback_t callback = (rx_task_callback_t)arg;

    uint8_t *data = (uint8_t *)malloc(RX_BUF_SIZE + 1);
    while (1)
    {

        const int rx_bytes = uart_read_bytes(UART_NUM_1, data, RX_BUF_SIZE, 1000 / portTICK_PERIOD_MS);
        if (rx_bytes > 0)
        {
            data[rx_bytes] = 0;
            if (callback)
            {
                callback((const char *)data, rx_bytes);
            }
            else
            {
                ESP_LOGI(RX_TASK_TAG, "Read %d bytes", rx_bytes);
            }
        }
    }
    free(data);
}

int send_data(const char *log_name, const char *data)
{
    const int len = strlen(data);
    const int tx_bytes = uart_write_bytes(UART_NUM_1, data, len);
    ESP_LOGI(log_name, "Wrote %d bytes", tx_bytes);
    return tx_bytes;
}

void start_uart_task(rx_task_callback_t rx_task_callback)
{
    xTaskCreate(rx_task, "uart_rx_task", RX_BUF_SIZE * 2, rx_task_callback, configMAX_PRIORITIES - 1, NULL);
}

void initialize_uart(uart_config_t uart_config, int tx_pin, int rx_pin)
{
    uart_driver_install(UART_NUM_1, RX_BUF_SIZE * 2, 0, 0, NULL, 0);
    uart_param_config(UART_NUM_1, &uart_config);
    uart_set_pin(UART_NUM_1, tx_pin, rx_pin, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
}