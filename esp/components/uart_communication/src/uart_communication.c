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

static void rx_task(void *arg)
{
    static const char *RX_TASK_TAG = "RX_TASK";
    rx_task_callback_t callback = (rx_task_callback_t)arg;
    static uint8_t persistent_buffer[PERSISTENT_BUFFER_SIZE];
    static size_t persistent_buffer_len = 0;
    uart_message_t received_msg;

    while (1)
    {
        uint8_t temp_buffer[RX_BUF_SIZE];
        const int rx_bytes = uart_read_bytes(UART_NUM_1, temp_buffer, RX_BUF_SIZE, pdMS_TO_TICKS(250));
        if (rx_bytes > 0)
        {
            // Handle buffer overflow by discarding old data
            if (persistent_buffer_len + rx_bytes > PERSISTENT_BUFFER_SIZE)
            {
                const size_t overflow = persistent_buffer_len + rx_bytes - PERSISTENT_BUFFER_SIZE;
                persistent_buffer_len = (overflow > persistent_buffer_len) ? 0 : persistent_buffer_len - overflow;
                memmove(persistent_buffer, persistent_buffer + overflow, persistent_buffer_len);
                ESP_LOGW(RX_TASK_TAG, "Buffer overflow, discarded %zu bytes", overflow);
            }

            // Append new data to the persistent buffer
            memcpy(persistent_buffer + persistent_buffer_len, temp_buffer, rx_bytes);
            persistent_buffer_len += rx_bytes;

            size_t processed = 0;
            while (processed < persistent_buffer_len)
            {
                // Search for STX to align message boundaries
                size_t stx_pos = processed;
                while (stx_pos < persistent_buffer_len && persistent_buffer[stx_pos] != MESSAGE_START_BYTE)
                {
                    stx_pos++;
                }
                if (stx_pos >= persistent_buffer_len)
                {
                    // No STX found; discard processed data
                    processed = persistent_buffer_len;
                    break;
                }
                processed = stx_pos;

                // Check if minimum message length is available (STX + cmd + len + CRC + ETX = 5 bytes)
                if (persistent_buffer_len - processed < MIN_MESSAGE_LENGTH)
                {
                    break; // Wait for more data
                }

                // Extract data_len (located at processed + 2)
                const uint8_t data_len = persistent_buffer[processed + 2];
                const size_t total_message_length = data_len + 5; // STX + cmd + len + data + CRC + ETX

                // Check if full message is available
                if (persistent_buffer_len - processed < total_message_length)
                {
                    break; // Not enough data yet
                }

                // Validate ETX at the end
                const size_t etx_pos = processed + total_message_length - 1;
                if (persistent_buffer[etx_pos] != MESSAGE_END_BYTE)
                {
                    ESP_LOGE(RX_TASK_TAG, "Invalid ETX at position %zu", etx_pos);
                    processed++; // Skip invalid STX and continue searching
                    continue;
                }

                // Attempt to decode the message
                if (decode_message(persistent_buffer + processed, total_message_length, &received_msg) == 0)
                {
                    ESP_LOGD(RX_TASK_TAG, "Decoded: Command %d, Data Length %d", received_msg.command, received_msg.data_len);

                    // Call callback or handle the message
                    if (callback)
                    {
                        if (received_msg.data_len < MAX_MESSAGE_LENGTH)
                        {
                            received_msg.data[received_msg.data_len] = '\0'; // Null-terminate
                        }
                        else
                        {
                            ESP_LOGW(RX_TASK_TAG, "Data too long to null-terminate");
                        }
                        callback((const char *)received_msg.data, received_msg.data_len);
                    }
                    else
                    {   
                        ESP_LOGW(RX_TASK_TAG, "No callback defined");
                    }

                    processed += total_message_length; // Move to next message
                }
                else
                {
                    // Decode failed; skip this STX and continue searching
                    processed++;
                }
            }

            // Shift remaining data to the start of the buffer
            if (processed > 0)
            {
                persistent_buffer_len -= processed;
                memmove(persistent_buffer, persistent_buffer + processed, persistent_buffer_len);
            }
        }
    }
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
    xTaskCreate(rx_task, "uart_rx_task", RX_BUF_SIZE * 3, rx_task_callback, configMAX_PRIORITIES - 1, NULL);
}

void initialize_uart(uart_config_t uart_config, int tx_pin, int rx_pin)
{
    uart_driver_install(UART_NUM_1, RX_BUF_SIZE * 3, 0, 0, NULL, 0);
    uart_param_config(UART_NUM_1, &uart_config);
    uart_set_pin(UART_NUM_1, tx_pin, rx_pin, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
}