#include "cbor.h"
#include "esp_log.h"
#include "uart_communication.h"
#include "common_types.h"

#define ENTITY_BUFFER_SIZE 64

void handle_current_temperature_data(CborValue *value);
void handle_target_temperature_data(CborValue *value);

typedef void (*entity_handler_t)(CborValue *);

typedef struct
{
    const char *entity_name;
    entity_handler_t handler_function;
} entity_handler_map_t;

static const char *TAG = "UART_MESSAGING";
static char entity_buffer[ENTITY_BUFFER_SIZE];
static state_subjects_t *state_subjects;

// Array of entity handler mappings
entity_handler_map_t entity_handlers[] = {
    {"current_temperature", handle_current_temperature_data},
    {"target_temperature", handle_target_temperature_data},
    // ... more entities
};

void handle_current_temperature_data(CborValue *value)
{
    if (!cbor_value_is_float(value) && !cbor_value_is_double(value))
    {
        ESP_LOGE(TAG, "CBOR: value is not a float or double");
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
    lv_subject_set_pointer(&state_subjects->current_temp, &temperature);
}

void handle_target_temperature_data(CborValue *value)
{
    if (!cbor_value_is_float(value) && !cbor_value_is_double(value))
    {
        ESP_LOGE(TAG, "CBOR: value is not a float or double");
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

    ESP_LOGI("TEMP", "Target temperature: %.5f", temperature);
}

void uart_message_handler(const uint8_t *data, int len)
{
    if (len == 0)
    {
        ESP_LOGW(TAG, "Received empty message");
        return;
    }

    CborParser parser;
    CborValue root, entity_value;

    // Initialize CBOR parser
    CborError err = cbor_parser_init(data, len, 0, &parser, &root);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR parsing error: %s", cbor_error_string(err));
        return;
    }

    // Verify root is a map
    if (!cbor_value_is_map(&root))
    {
        ESP_LOGE(TAG, "CBOR root is not a map");
        return;
    }

    // Find "entity" key in root map
    err = cbor_value_map_find_value(&root, "entity", &entity_value);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: entity not found: %s", cbor_error_string(err));
        return;
    }

    // Verify entity is a text string
    if (!cbor_value_is_text_string(&entity_value))
    {
        ESP_LOGE(TAG, "CBOR: entity is not a text string");
        return;
    }

    // Extract entity string
    size_t entity_len;
    err = cbor_value_get_string_length(&entity_value, &entity_len);
    if (err != CborNoError || entity_len >= ENTITY_BUFFER_SIZE)
    {
        ESP_LOGE(TAG, "CBOR: invalid entity length");
        return;
    }

    err = cbor_value_copy_text_string(&entity_value, entity_buffer, &entity_len, NULL);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: failed to copy entity: %s", cbor_error_string(err));
        return;
    }
    entity_buffer[entity_len] = '\0'; // Ensure null-termination

    for (size_t i = 0; i < sizeof(entity_handlers) / sizeof(entity_handlers[0]); i++)
    {
        if (strcmp(entity_buffer, entity_handlers[i].entity_name) == 0)
        {
            ESP_LOGD(TAG, "Calling handler for entity: %s", entity_buffer);

            CborValue payload_value; // No longer const

            // Get the payload
            CborError err = cbor_value_map_find_value(&root, "payload", &payload_value);
            if (err != CborNoError)
            {
                ESP_LOGE(TAG, "CBOR: payload not found: %s", cbor_error_string(err));
                return;
            }

            CborValue value_value; // Get the "value" from the payload

            err = cbor_value_map_find_value(&payload_value, "value", &value_value);
            if (err != CborNoError)
            {
                ESP_LOGE(TAG, "CBOR: value not found: %s", cbor_error_string(err));
                return;
            }

            entity_handlers[i].handler_function(&value_value); // Pass the "value" CborValue
            return;                                            // Found and handled, exit the loop
        }
    }

    ESP_LOGW(TAG, "No handler found for entity: %s", entity_buffer);
}


rx_task_callback_t init_uart_message_handler(state_subjects_t *arg_state_subjects)
{
    state_subjects = arg_state_subjects;
    return (rx_task_callback_t)&uart_message_handler;
}