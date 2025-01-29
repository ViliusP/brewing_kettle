#include "uart_communication.h"
#include "configuration.h"
#include "esp_log.h"
#include "temperature_sensor.h"
#include "cbor.h"

static const char *TAG = "MAIN";

// Example using tinycbor to encode temperature data in the desired format
int send_temperature_data(float temperature) {
    uint8_t cbor_buffer[256]; // Adjust size as needed
    CborEncoder encoder, map_encoder, payload_encoder;

    cbor_encoder_init(&encoder, cbor_buffer, sizeof(cbor_buffer), 0);

    CborError err = CborNoError;

    // Outer map
    err |= cbor_encoder_create_map(&encoder, &map_encoder, 2); // 2 items: type and payload

    // "type": "temperature"
    err |= cbor_encode_text_string(&map_encoder, "entity", strlen("entity"));
    err |= cbor_encode_text_string(&map_encoder, "current_temperature", strlen("current_temperature"));

    // "payload": { "value": temperature }
    err |= cbor_encode_text_string(&map_encoder, "payload", strlen("payload"));
    err |= cbor_encoder_create_map(&map_encoder, &payload_encoder, 1); // Payload map
    err |= cbor_encode_text_string(&payload_encoder, "value", strlen("value"));
    err |= cbor_encode_float(&payload_encoder, temperature);
    err |= cbor_encoder_close_container(&map_encoder, &payload_encoder); // Close payload map

    err |= cbor_encoder_close_container(&encoder, &map_encoder); // Close outer map

    if (err != CborNoError) {
        ESP_LOGE(TAG, "CBOR encoding error: %s", cbor_error_string(err));
        return -1;
    }

    size_t cbor_len = cbor_encoder_get_buffer_size(&encoder, cbor_buffer);

    uart_message_t msg_to_send;
    msg_to_send.command = CMD_SEND_SENSOR_DATA;
    memcpy(msg_to_send.data, cbor_buffer, cbor_len);
    msg_to_send.data_len = cbor_len;

    return uart_send_message(&msg_to_send);
}

void uart_message_handling(const char *data, const int bytes)
{
    ESP_LOGW(TAG, "Message content in string: %.*s", (int)bytes, data);
}

void app_main(void)
{
    ESP_LOGI(TAG, "Hello, World!");

    ds18b20_device_handle_t ds18b20_handle = initialize_temperature_sensor();

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
