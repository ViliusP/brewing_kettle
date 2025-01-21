#include "lvgl.h"
#include "ws_server.h"
#include "esp_log.h"
#include "display.h"
#include "uart_communication.h"
#include "utilities.h"

static const char *TAG = "STATE";

typedef enum
{
    HEATER_STATE_IDLE,
    HEATER_STATE_COOLING,
    HEATER_STATE_HEATING,
} heater_state_t;

typedef enum
{
    MESSAGE_TYPE_STATE = 1,
    MESSAGE_TYPE_ERROR,
    MESSAGE_TYPE_DEBUG,
} message_type_t;

typedef enum
{
    ERR_ENTITY_TEMPERATURE_SENSOR = 1,
} error_entity_t;

typedef enum
{
    MESSAGE_ENTITY_TEMPERATURE = 1,
} state_entity_t;

state_subjects_t state_subjects;

static void test_observer_cb(lv_observer_t *observer, lv_subject_t *subject)
{
    int32_t v = lv_subject_get_int(subject);
    ESP_LOGI(TAG, "value %lu", v);
}

void connected_client_data_notify(client_info_data_t client_data)
{
    if (client_data.clients_info == NULL)
    {
        printf("No client information available.\n");
        return;
    }

    // ESP_LOGI(TAG, "Number of clients: %d", client_data.client_count);
    // for (size_t i = 0; i < client_data.client_count; i++)
    // {
    //     printf("Client %zu:\n", i);
    //     printf("  IP: %s\n", client_data.clients_info[i].ip);
    //     printf("  Port: %d\n", client_data.clients_info[i].port);
    //     printf("  Bytes Sent: %zu\n", client_data.clients_info[i].bytes_sent);
    //     printf("  Bytes Received: %zu\n", client_data.clients_info[i].bytes_received);
    //     printf("\n");
    // }
    lv_subject_set_pointer(&state_subjects.connected_clients, &client_data);
}

state_subjects_t *init_state_subjects()
{
    lv_subject_init_int(&state_subjects.current_temp, 0);
    lv_subject_init_int(&state_subjects.target_temp, 0);
    lv_subject_init_int(&state_subjects.heater_state, HEATER_STATE_HEATING);

    lv_subject_init_pointer(&state_subjects.connected_clients, NULL);

    return &state_subjects;
}

void uart_message_handling(const char *data, const int bytes)
{
    if (bytes != 4)
    {
        ESP_LOGW(TAG, "Unexpected message size: %d bytes", bytes);
        char bit_str[33] = {0};
        for (int i = 0; i < bytes; i++)
        {
            for (int bit = 7; bit >= 0; bit--)
            {
                bit_str[7 - bit + (i * 8)] = ((data[i] >> bit) & 1) ? '1' : '0';
            }
        }
        bit_str[bytes * 8] = '\0'; // Null-terminate the string
        ESP_LOGW(TAG, "Message content in bits: %s", bit_str);
        ESP_LOGW(TAG, "Message content in string: %.*s", bytes, data);
        return;
    }

    uint32_t value = 0;
    for (int i = 0; i < 4; i++)
    {
        value |= (uint8_t)data[i] << (8 * (3 - i));
    }
    uint8_t type = (value >> 28) & 0x0F;
    uint8_t entity = (value >> 24) & 0x0F;
    int32_t content = (int32_t)(value & 0x00FFFFFF);
    if (content & 0x00800000) // Check if the sign bit is set
    {
        content |= 0xFF000000; // Set the upper bits to maintain the negative value
    }
    switch (type)
    {
    case MESSAGE_TYPE_STATE:
        switch (entity)
        {
        case MESSAGE_ENTITY_TEMPERATURE:
            lv_subject_set_int(&state_subjects.current_temp, content);
            ESP_LOGD(TAG, "state message 'Temperature': %.2f°C", temp_to_float(content));
            break;
        default:
            ESP_LOGW(TAG, "Unknown state entity: %d", entity);
            break;
        }
        break;
    case MESSAGE_TYPE_ERROR:
        switch (entity)
        {
        case ERR_ENTITY_TEMPERATURE_SENSOR:
            ESP_LOGW(TAG, "Error Message - Temperature Sensor: %lu", content);
            break;
        default:
            ESP_LOGW(TAG, "Unknown error entity: %d", entity);
            break;
        }
        break;
    case MESSAGE_TYPE_DEBUG:
        ESP_LOGD(TAG, "Debug Message: %lu", content);
        break;
    default:
        ESP_LOGW(TAG, "Unknown message type: %d", type);
        break;
    }
}
