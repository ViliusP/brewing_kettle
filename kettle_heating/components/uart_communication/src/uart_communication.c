#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "string.h"
#include "driver/gpio.h"
#include "uart_communication.h"

static const char *TAG = "UART";

// CRC8 calculation (Polynomial: x^8 + x^2 + x + 1)
static uint8_t crc8(const uint8_t *data, int len)
{
    uint8_t crc = 0x00;
    for (int i = 0; i < len; i++)
    {
        uint8_t byte = data[i];
        for (int j = 0; j < 8; j++)
        {
            if ((crc ^ byte) & 0x80)
            {
                crc = (crc << 1) ^ 0x07;
            }
            else
            {
                crc <<= 1;
            }
            byte <<= 1;
        }
    }
    return crc;
}

// Function to encode a message
static int encode_message(uart_message_t *msg, uint8_t *buffer, int buffer_len)
{
    if (buffer_len < msg->data_len + 4)
    { // +4 for STX, command, data_len, CRC, ETX
        ESP_LOGE(TAG, "Buffer too small for message");
        return -1;
    }

    int index = 0;
    buffer[index++] = MESSAGE_START_BYTE;
    buffer[index++] = (uint8_t)msg->command; // Cast the enum to uint8_t
    buffer[index++] = msg->data_len;
    memcpy(&buffer[index], msg->data, msg->data_len);
    index += msg->data_len;

    uint8_t crc = crc8(&buffer[1], msg->data_len + 2); // CRC over command, length, and data
    buffer[index++] = crc;
    buffer[index++] = MESSAGE_END_BYTE;

    return index;
}

// Function to decode a message
static int decode_message(uint8_t *buffer, int buffer_len, uart_message_t *msg)
{
    if (buffer_len < 5)
    {              // Minimum: STX, command, length, CRC, ETX
        return -1; // Not enough data
    }

    int index = 0;

    if (buffer[index++] != MESSAGE_START_BYTE)
    {
        ESP_LOGE(TAG, "Invalid start byte");
        return -1;
    }

    msg->command = (uart_message_command_t)buffer[index++]; // Cast back to enum
    msg->data_len = buffer[index++];

    if (msg->data_len > MAX_MESSAGE_LENGTH || buffer_len < msg->data_len + 5)
    {
        ESP_LOGE(TAG, "Invalid data length or buffer too short");
        return -1;
    }

    memcpy(msg->data, &buffer[index], msg->data_len);
    index += msg->data_len;

    uint8_t received_crc = buffer[index++];
    uint8_t calculated_crc = crc8(&buffer[1], msg->data_len + 2);

    if (received_crc != calculated_crc)
    {
        ESP_LOGE(TAG, "CRC mismatch! Received: 0x%02X, Calculated: 0x%02X", received_crc, calculated_crc);
        return -1;
    }

    if (buffer[index++] != MESSAGE_END_BYTE)
    {
        ESP_LOGE(TAG, "Invalid end byte");
        return -1;
    }

    return 0;
}

// RX task (modified to use decode_message)
static void rx_task(void *arg)
{
    static const char *RX_TASK_TAG = "RX_TASK";
    rx_task_callback_t callback = (rx_task_callback_t)arg;
    uint8_t *buffer = (uint8_t *)malloc(RX_BUF_SIZE + 1); // Use uint8_t for raw bytes
    uart_message_t received_msg;

    while (1)
    {
        const int rx_bytes = uart_read_bytes(UART_NUM_1, buffer, RX_BUF_SIZE, 1000 / portTICK_PERIOD_MS);
        if (rx_bytes > 0)
        {
            ESP_LOGI(RX_TASK_TAG, "Received %d bytes", rx_bytes);

            if (decode_message(buffer, rx_bytes, &received_msg) == 0)
            {
                ESP_LOGI(RX_TASK_TAG, "Decoded message: Command: %d, Data Length: %d", received_msg.command, received_msg.data_len);

                // Now you have the decoded message in received_msg.  Call the callback or process it directly.
                if (callback)
                {
                    // Important: Pass only the data part to the callback as a C string.
                    // Make sure data is null-terminated if it's a string!
                    if (received_msg.data_len < MAX_MESSAGE_LENGTH)
                    {
                        received_msg.data[received_msg.data_len] = 0; // Null-terminate
                    }
                    else
                    {
                        ESP_LOGW(RX_TASK_TAG, "Received data too long to null-terminate safely.");
                    }
                    callback((const char *)received_msg.data, received_msg.data_len);
                }
                else
                {
                    // Default handling (if no callback is provided)
                    ESP_LOGI(RX_TASK_TAG, "Data: %.*s", received_msg.data_len, received_msg.data);
                }
            }
            else
            {
                ESP_LOGE(RX_TASK_TAG, "Failed to decode message");
                // Handle decoding errors (e.g., resend request, discard data)
            }
        }
    }
    free(buffer);
}

// Modified uart_send_data to use encode_message
int uart_send_message(uart_message_t *msg)
{
    uint8_t send_buffer[1024]; // Make sure this is large enough
    int encoded_len = encode_message(msg, send_buffer, sizeof(send_buffer));

    if (encoded_len > 0)
    {
        int tx_bytes = uart_write_bytes(UART_NUM_1, (const char *)send_buffer, encoded_len);
        ESP_LOGI(TAG, "Sent message (encoded %d bytes)", encoded_len);
        return tx_bytes;
    }
    else
    {
        ESP_LOGE(TAG, "Failed to encode message");
        return -1; // Return error code
    }
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