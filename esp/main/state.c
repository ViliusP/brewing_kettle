#include "lvgl.h"
#include "ws_server.h"
#include "esp_log.h"
#include "display.h"
#include "uart_communication.h"
#include "utilities.h"
#include "cbor.h"

#define DS18B20_LOWEST_POSSIBLE_TEMP -55.0f
#define ENTITY_BUFFER_SIZE 64

static const char *TAG = "STATE";

static char entity_buffer[ENTITY_BUFFER_SIZE];

typedef void (*entity_handler_t)(CborValue *);

typedef struct
{
    const char *entity_name;
    entity_handler_t handler_function;
} entity_handler_map_t;

void handle_current_temperature_data(CborValue *value);
void handle_target_temperature_data(CborValue *value);

// Array of entity handler mappings
entity_handler_map_t entity_handlers[] = {
    {"current_temperature", handle_current_temperature_data},
    {"target_temperature", handle_target_temperature_data},
    // ... more entities
};

typedef enum
{
    HEATER_STATE_IDLE,
    HEATER_STATE_COOLING,
    HEATER_STATE_HEATING,
} heater_state_t;

typedef struct
{
    heater_state_t heater_state;
    float current_temp;
    float target_temp;
    client_info_data_t *connected_clients;
} app_state_t;

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

static void print_client_info(client_info_data_t client_data)
{
    ESP_LOGI(TAG, "Number of clients: %d", client_data.client_count);
    for (size_t i = 0; i < client_data.client_count; i++)
    {
        printf("Client %zu:\n", i);
        printf("  IP: %s\n", client_data.clients_info[i].ip);
        printf("  Port: %d\n", client_data.clients_info[i].port);
        printf("  Bytes Sent: %zu\n", client_data.clients_info[i].bytes_sent);
        printf("  Bytes Received: %zu\n", client_data.clients_info[i].bytes_received);
        printf("\n");
    }
}

void connected_client_data_notify(client_info_data_t client_data)
{
    if (client_data.clients_info == NULL)
    {
        return;
    }
    lv_subject_set_pointer(&state_subjects.connected_clients, &client_data);
}

state_subjects_t *init_state_subjects()
{
    lv_subject_init_int(&state_subjects.current_temp, temp_to_int(DS18B20_LOWEST_POSSIBLE_TEMP));
    lv_subject_init_int(&state_subjects.target_temp, temp_to_int(DS18B20_LOWEST_POSSIBLE_TEMP));
    lv_subject_init_int(&state_subjects.heater_state, HEATER_STATE_IDLE);

    lv_subject_init_pointer(&state_subjects.connected_clients, NULL);

    return &state_subjects;
}

void handle_current_temperature_data(CborValue *value)
{
    if (!cbor_value_is_float(value) && !cbor_value_is_double(value))
    {
        ESP_LOGE("TEMP", "CBOR: value is not a float or double");
        return;
    }

    double temperature;
    if (cbor_value_is_float(value))
    {
        float temp_f;
        cbor_value_get_float(value, &temp_f);
        temperature = (double)temp_f;
    }
    else
    {
        cbor_value_get_double(value, &temperature);
    }

    ESP_LOGI("TEMP", "Temperature: %.2f", temperature);
}

void handle_target_temperature_data(CborValue *value)
{
    if (!cbor_value_is_float(value) && !cbor_value_is_double(value))
    {
        ESP_LOGE("TEMP", "CBOR: value is not a float or double");
        return;
    }

    double temperature;
    if (cbor_value_is_float(value))
    {
        float temp_f;
        cbor_value_get_float(value, &temp_f);
        temperature = (double)temp_f;
    }
    else
    {
        cbor_value_get_double(value, &temperature);
    }

    ESP_LOGI("TEMP", "Temperature: %.2f", temperature);
}

void uart_message_handling(const uint8_t *data, int len)
{
    if (len == 0)
    {
        ESP_LOGW("APP", "Received empty message");
        return;
    }

    CborParser parser;
    CborValue root, entity_value, payload_value;

    // Initialize CBOR parser
    CborError err = cbor_parser_init(data, len, 0, &parser, &root);
    if (err != CborNoError)
    {
        ESP_LOGE("APP", "CBOR parsing error: %s", cbor_error_string(err));
        return;
    }

    // Verify root is a map
    if (!cbor_value_is_map(&root))
    {
        ESP_LOGE("APP", "CBOR root is not a map");
        return;
    }

    // Find "entity" key in root map
    err = cbor_value_map_find_value(&root, "entity", &entity_value);
    if (err != CborNoError)
    {
        ESP_LOGE("APP", "CBOR: entity not found: %s", cbor_error_string(err));
        return;
    }

    // Verify entity is a text string
    if (!cbor_value_is_text_string(&entity_value))
    {
        ESP_LOGE("APP", "CBOR: entity is not a text string");
        return;
    }

    // Extract entity string
    size_t entity_len;
    err = cbor_value_get_string_length(&entity_value, &entity_len);
    if (err != CborNoError || entity_len >= ENTITY_BUFFER_SIZE)
    {
        ESP_LOGE("APP", "CBOR: invalid entity length");
        return;
    }

    err = cbor_value_copy_text_string(&entity_value, entity_buffer, &entity_len, NULL);
    if (err != CborNoError)
    {
        ESP_LOGE("APP", "CBOR: failed to copy entity: %s", cbor_error_string(err));
        return;
    }
    entity_buffer[entity_len] = '\0'; // Ensure null-termination

    for (size_t i = 0; i < sizeof(entity_handlers) / sizeof(entity_handlers[0]); i++)
    {
        if (strcmp(entity_buffer, entity_handlers[i].entity_name) == 0)
        {
            ESP_LOGI("APP", "Calling handler for entity: %s", entity_buffer);

            CborValue payload_value; // No longer const

            // Get the payload
            CborError err = cbor_value_map_find_value(&root, "payload", &payload_value);
            if (err != CborNoError)
            {
                ESP_LOGE("APP", "CBOR: payload not found: %s", cbor_error_string(err));
                return;
            }

            CborValue value_value; // Get the "value" from the payload

            err = cbor_value_map_find_value(&payload_value, "value", &value_value);
            if (err != CborNoError)
            {
                ESP_LOGE("APP", "CBOR: value not found: %s", cbor_error_string(err));
                return;
            }

            entity_handlers[i].handler_function(&value_value); // Pass the "value" CborValue
            return;                                            // Found and handled, exit the loop
        }
    }

    ESP_LOGW("APP", "No handler found for entity: %s", entity_buffer);
}
