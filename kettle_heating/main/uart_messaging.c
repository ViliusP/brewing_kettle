#include "cbor.h"
#include "uart_communication.h"
#include "uart_messaging.h"
#include "esp_log.h"
#include "state.h"

#define ENTITY_BUFFER_SIZE 64

void handle_target_temperature_data(CborValue *payload);
void handle_heater_mode_data(CborValue *payload);
void handle_set_power_data(CborValue *payload);
void handle_pid_constants_data(CborValue *payload);

typedef void (*entity_handler_t)(CborValue *);

typedef struct
{
    const char *entity_name;
    entity_handler_t handler_function;
} entity_handler_map_t;

static const char *TAG = "UART_MESSAGING";
static app_state_t *app_state;
static char entity_buffer[ENTITY_BUFFER_SIZE];

// Array of entity handler mappings
entity_handler_map_t entity_handlers[] = {
    {"target_temperature", handle_target_temperature_data},
    {"heater_mode", handle_heater_mode_data},
    {"power", handle_set_power_data},
    {"pid_constants", handle_pid_constants_data},
    // ... more entities
};

int uart_send_entity_data(const char *entity, float value)
{
    uint8_t cbor_buffer[256]; // Adjust size as needed
    CborEncoder encoder, map_encoder, payload_encoder;

    cbor_encoder_init(&encoder, cbor_buffer, sizeof(cbor_buffer), 0);

    CborError err = CborNoError;

    // Outer map
    err |= cbor_encoder_create_map(&encoder, &map_encoder, 2); // 2 items: entity and payload

    // "entity": entity
    err |= cbor_encode_text_string(&map_encoder, "entity", strlen("entity"));
    err |= cbor_encode_text_string(&map_encoder, entity, strlen(entity));

    // "payload": { "value": value }
    err |= cbor_encode_text_string(&map_encoder, "payload", strlen("payload"));
    err |= cbor_encoder_create_map(&map_encoder, &payload_encoder, 1); // Payload map
    err |= cbor_encode_text_string(&payload_encoder, "value", strlen("value"));
    err |= cbor_encode_float(&payload_encoder, value);
    err |= cbor_encoder_close_container(&map_encoder, &payload_encoder); // Close payload map

    err |= cbor_encoder_close_container(&encoder, &map_encoder); // Close outer map

    if (err != CborNoError)
    {
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

int uart_send_state(app_state_t app_state)
{
    uint8_t cbor_buffer[256]; // Adjust size as needed
    CborEncoder encoder, map_encoder, payload_encoder;

    cbor_encoder_init(&encoder, cbor_buffer, sizeof(cbor_buffer), 0);

    CborError err = CborNoError;

    // Outer map
    err |= cbor_encoder_create_map(&encoder, &map_encoder, 2); // 1 item: entity

    // "entity": entity
    err |= cbor_encode_text_string(&map_encoder, "entity", strlen("entity"));
    err |= cbor_encode_text_string(&map_encoder, "state", strlen("state"));

    // "payload": { "value": value }
    err |= cbor_encode_text_string(&map_encoder, "payload", strlen("payload"));
    err |= cbor_encoder_create_map(&map_encoder, &payload_encoder, 4); // Payload map

    err |= cbor_encode_text_string(&payload_encoder, "power", strlen("power"));
    err |= cbor_encode_float(&payload_encoder, app_state.power);

    err |= cbor_encode_text_string(&payload_encoder, "current_temperature", strlen("current_temperature"));
    err |= cbor_encode_float(&payload_encoder, app_state.current_temp);

    err |= cbor_encode_text_string(&payload_encoder, "target_temperature", strlen("target_temperature"));
    err |= cbor_encode_float(&payload_encoder, app_state.target_temp);

    err |= cbor_encode_text_string(&payload_encoder, "status", strlen("status"));
    err |= cbor_encode_int(&payload_encoder, app_state.status);

    err |= cbor_encoder_close_container(&map_encoder, &payload_encoder); // Close payload map
    err |= cbor_encoder_close_container(&encoder, &map_encoder);         // Close outer map

    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR encoding error: %s", cbor_error_string(err));
        return -1;
    }

    size_t cbor_len = cbor_encoder_get_buffer_size(&encoder, cbor_buffer);

    uart_message_t msg_to_send;
    msg_to_send.command = CMD_SEND_STATE;
    memcpy(msg_to_send.data, cbor_buffer, cbor_len);
    msg_to_send.data_len = cbor_len;

    return uart_send_message(&msg_to_send);
}

void handle_heater_mode_data(CborValue *payload)
{
    CborValue value;

    esp_err_t err = cbor_value_map_find_value(payload, "value", &value);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: value in payload not found: %s", cbor_error_string(err));
        return;
    }

    if (!cbor_value_is_unsigned_integer(&value))
    {
        ESP_LOGE(TAG, "CBOR: value in heater_mode data is not unsigned integer");
        return;
    }

    uint64_t mode;
    cbor_value_get_uint64(&value, &mode);

    if (app_state->status != HEATER_STATUS_WAITING_CONFIG)
    {
        app_state->status = mode;
        app_state->power = 0.0f;
    }

    uart_send_state(*app_state);
}

void handle_pid_constants_data(CborValue *payload) {
    // -------------------- proportional --------------------
    CborValue proportional_value;
    esp_err_t err = cbor_value_map_find_value(payload, "proportional", &proportional_value);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: proportional constant in payload not found: %s", cbor_error_string(err));
        return;
    }
    if (!cbor_value_is_float(&proportional_value) && !cbor_value_is_double(&proportional_value))
    {
        ESP_LOGE(TAG, "CBOR: value in pid constants data not a float or double");
        return;
    }

    float proportional;
    if (cbor_value_is_double(&proportional_value))
    {
        double proportional_d;
        cbor_value_get_double(&proportional_value, &proportional_d);
        proportional = (double)proportional_d;
    }
    else
    {
        cbor_value_get_float(&proportional_value, &proportional);
    }

    // -------------------- integral --------------------
    CborValue integral_value;
    err = cbor_value_map_find_value(payload, "integral", &integral_value);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: integral constant in payload not found: %s", cbor_error_string(err));
        return;
    }
    if (!cbor_value_is_float(&integral_value) && !cbor_value_is_double(&integral_value))
    {
        ESP_LOGE(TAG, "CBOR: value in pid constants data not a float or double");
        return;
    }
    float integral;
    if (cbor_value_is_double(&integral_value))
    {
        double integral_d;
        cbor_value_get_double(&integral_value, &integral_d);
        integral = (double)integral_d;
    }
    else
    {
        cbor_value_get_float(&integral_value, &integral);
    }
    
    // -------------------- derivative --------------------
    CborValue derivative_value;
    err = cbor_value_map_find_value(payload, "derivative", &derivative_value);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: derivative constant in payload not found: %s", cbor_error_string(err));
        return;
    }
    if (!cbor_value_is_float(&derivative_value) && !cbor_value_is_double(&derivative_value))
    {
        ESP_LOGE(TAG, "CBOR: value in pid constants data not a float or double");
        return;
    }
    float derivative;
    if (cbor_value_is_double(&derivative_value))
    {
        double derivative_d;
        cbor_value_get_double(&derivative_value, &derivative_d);
        derivative = (double)derivative_d;
    }
    else
    {
        cbor_value_get_float(&derivative_value, &derivative);
    }
    // -------------------- set pid constants --------------------
    if (app_state->pid_constants == NULL) {
        pid_constants_t *constants = malloc(sizeof(pid_constants_t));
        app_state->pid_constants = constants;
    } {
        app_state->pid_constants->proportional = proportional;
        app_state->pid_constants->integral = integral;
        app_state->pid_constants->derivative = derivative;
        app_state->status = HEATER_STATUS_IDLE;
    }

    ESP_LOGI(TAG, "pid constants updated: P=%.2f, I=%.2f, D=%.2f", proportional, integral, derivative);

    uart_send_state(*app_state);
}

void handle_set_power_data(CborValue *payload)
{
    CborValue value;

    esp_err_t err = cbor_value_map_find_value(payload, "value", &value);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: value in payload not found: %s", cbor_error_string(err));
        return;
    }

    if (!cbor_value_is_float(&value) && !cbor_value_is_double(&value))
    {
        ESP_LOGE(TAG, "CBOR: value in set_power data not a float or double");
        return;
    }

    float power;
    if (cbor_value_is_double(&value))
    {
        double power_d;
        cbor_value_get_double(&value, &power_d);
        power = (double)power_d;
    }
    else
    {
        cbor_value_get_float(&value, &power);
    }

    app_state->requested_power = power;
    app_state->status = HEATER_STATUS_HEATING_MANUAL;
    uart_send_state(*app_state);
}

void handle_target_temperature_data(CborValue *payload)
{
    CborValue value;

    esp_err_t err = cbor_value_map_find_value(payload, "value", &value);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: value in payload not found: %s", cbor_error_string(err));
        return;
    }

    if (!cbor_value_is_float(&value) && !cbor_value_is_double(&value))
    {
        ESP_LOGE(TAG, "CBOR: value is not a float or double");
        return;
    }

    double temperature;
    if (cbor_value_is_float(&value))
    {
        float temp_f;
        cbor_value_get_float(&value, &temp_f);
        temperature = (double)temp_f;
    }
    else
    {
        cbor_value_get_double(&value, &temperature);
    }

    app_state->target_temp = temperature;
    app_state->status = HEATER_STATUS_HEATING_PID;
    uart_send_state(*app_state);
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

            entity_handlers[i].handler_function(&payload_value); // Pass the "value" CborValue
            return;                                              // Found and handled, exit the loop
        }
    }

    ESP_LOGW(TAG, "No handler found for entity: %s", entity_buffer);
}

rx_task_callback_t init_uart_message_handler(app_state_t *arg_app_state)
{
    app_state = arg_app_state;
    return (rx_task_callback_t)&uart_message_handler;
}
