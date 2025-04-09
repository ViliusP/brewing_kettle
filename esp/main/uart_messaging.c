#include "cbor.h"
#include "esp_log.h"
#include "uart_communication.h"
#include "uart_messaging.h"
#include "common_types.h"
#include "state.h"

#define ENTITY_BUFFER_SIZE 64

void handle_state_data(CborValue *payload);

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
    {"state", handle_state_data},
};

void handle_state_data(CborValue *payload)
{
    CborError err = CborNoError;

    // -------------
    // heater_status
    // -------------
    CborValue heater_status_val;
    err = cbor_value_map_find_value(payload, "status", &heater_status_val);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: (heater) status not found: %s", cbor_error_string(err));
        return;
    }
    int heater_status;
    if (cbor_value_is_integer(&heater_status_val))
    {
        cbor_value_get_int(&heater_status_val, &heater_status);
    }
    else
    {
        ESP_LOGE(TAG, "CBOR: (heater) status is not int");
        return;
    }
    ESP_LOGD(TAG, "State Info | heater_state %s", heater_status_human_string(heater_status));

    // --------------------
    // current_temperature
    // --------------------
    CborValue current_temp_val;
    err = cbor_value_map_find_value(payload, "current_temperature", &current_temp_val);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: current_temperature not found: %s", cbor_error_string(err));
        return;
    }

    if (!cbor_value_is_float(&current_temp_val) && !cbor_value_is_double(&current_temp_val))
    {
        ESP_LOGE(TAG, "CBOR: current_temperature is not a float or double");
        return;
    }

    float current_temp;
    if (cbor_value_is_float(&current_temp_val))
    {
        cbor_value_get_float(&current_temp_val, &current_temp);
    }
    else
    {
        double current_temp_d;
        cbor_value_get_double(&current_temp_val, &current_temp_d);
        current_temp = (float)current_temp_d;
    }
    ESP_LOGD(TAG, "State Info | current_temperature %f", current_temp);

    // --------------------
    // target_temperature
    // --------------------
    CborValue target_temp_val;
    err = cbor_value_map_find_value(payload, "target_temperature", &target_temp_val);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: target_temperature not found: %s", cbor_error_string(err));
        return;
    }

    if (!cbor_value_is_float(&target_temp_val) && !cbor_value_is_double(&target_temp_val))
    {
        ESP_LOGE(TAG, "CBOR: target_temperature is not a float or double");
        return;
    }

    float target_temp;
    if (cbor_value_is_float(&target_temp_val))
    {
        cbor_value_get_float(&target_temp_val, &target_temp);
    }
    else
    {
        double target_temp_d;
        cbor_value_get_double(&target_temp_val, &target_temp_d);
        target_temp = (float)target_temp_d;
    }
    ESP_LOGD(TAG, "State Info | target_temperature %f", target_temp);

    // ---------------
    // power
    // ---------------
    CborValue current_power_val;
    err = cbor_value_map_find_value(payload, "power", &current_power_val);
    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR: power not found: %s", cbor_error_string(err));
        return;
    }

    if (!cbor_value_is_float(&current_power_val) && !cbor_value_is_double(&current_power_val))
    {
        ESP_LOGE(TAG, "CBOR: power is not a float or double");
        return;
    }

    float current_power;
    if (cbor_value_is_float(&current_power_val))
    {
        cbor_value_get_float(&current_power_val, &current_power);
    }
    else
    {
        double current_power_d;
        cbor_value_get_double(&current_power_val, &current_power_d);
        target_temp = (float)current_power_d;
    }
    ESP_LOGD(TAG, "State Info | current_power %f", current_power);

    heater_controller_state_t *heater_controller_state_ptr = (heater_controller_state_t *)lv_subject_get_pointer(&state_subjects->heater_controller_state);
    heater_controller_state_ptr->power = current_power;
    heater_controller_state_ptr->current_temp = current_temp;
    heater_controller_state_ptr->target_temp = target_temp;
    heater_controller_state_ptr->status = heater_status;

    lv_subject_notify(&state_subjects->heater_controller_state);

    pid_constants_t *pid_constants = (pid_constants_t *)lv_subject_get_pointer(&state_subjects->pid_constants);
    if (heater_controller_state_ptr->status == HEATER_STATUS_WAITING_CONFIG && pid_constants != NULL)
    {
        send_pid_constants(pid_constants);
    }
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

            entity_handlers[i].handler_function(&payload_value); // Pass the "payload" CborValue
            return;                                              // Found and handled, exit the loop
        }
    }

    ESP_LOGW(TAG, "No handler found for entity: %s", entity_buffer);
}

int send_pid_constants(pid_constants_t *constants)
{
    uint8_t cbor_buffer[256]; // Adjust size as needed
    CborEncoder encoder, map_encoder, payload_encoder;

    cbor_encoder_init(&encoder, cbor_buffer, sizeof(cbor_buffer), 0);

    CborError err = CborNoError;

    // Outer map
    err |= cbor_encoder_create_map(&encoder, &map_encoder, 2); // 2 items: type and payload

    // "entity": "pid_constants"
    err |= cbor_encode_text_string(&map_encoder, "entity", strlen("entity"));
    err |= cbor_encode_text_string(&map_encoder, "pid_constants", strlen("pid_constants"));

    // "payload": { "proportional": proportional, "integral": integral, "derivative": derivative }
    err |= cbor_encode_text_string(&map_encoder, "payload", strlen("payload"));
    err |= cbor_encoder_create_map(&map_encoder, &payload_encoder, 3); // Payload map

    err |= cbor_encode_text_string(&payload_encoder, "proportional", strlen("proportional"));
    err |= cbor_encode_float(&payload_encoder, constants->proportional);

    err |= cbor_encode_text_string(&payload_encoder, "integral", strlen("integral"));
    err |= cbor_encode_float(&payload_encoder, constants->integral);

    err |= cbor_encode_text_string(&payload_encoder, "derivative", strlen("derivative"));
    err |= cbor_encode_float(&payload_encoder, constants->derivative);

    err |= cbor_encoder_close_container(&map_encoder, &payload_encoder); // Close payload map
    err |= cbor_encoder_close_container(&encoder, &map_encoder);         // Close outer map

    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR encoding error: %s", cbor_error_string(err));
        return -1;
    }

    size_t cbor_len = cbor_encoder_get_buffer_size(&encoder, cbor_buffer);

    uart_message_t msg_to_send;
    msg_to_send.command = CMD_SET_VALUE;
    memcpy(msg_to_send.data, cbor_buffer, cbor_len);
    msg_to_send.data_len = cbor_len;

    return uart_send_message(&msg_to_send);
}

int send_power_value(float value)
{
    uint8_t cbor_buffer[256]; // Adjust size as needed
    CborEncoder encoder, map_encoder, payload_encoder;

    cbor_encoder_init(&encoder, cbor_buffer, sizeof(cbor_buffer), 0);

    CborError err = CborNoError;

    // Outer map
    err |= cbor_encoder_create_map(&encoder, &map_encoder, 2); // 2 items: type and payload

    // "entity": "power"
    err |= cbor_encode_text_string(&map_encoder, "entity", strlen("entity"));
    err |= cbor_encode_text_string(&map_encoder, "power", strlen("power"));

    // "payload": { "value": power }
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
    msg_to_send.command = CMD_SET_VALUE;
    memcpy(msg_to_send.data, cbor_buffer, cbor_len);
    msg_to_send.data_len = cbor_len;

    return uart_send_message(&msg_to_send);
}

int send_set_heater_mode(heater_status_t mode)
{
    uint8_t cbor_buffer[256]; // Adjust size as needed
    CborEncoder encoder, map_encoder, payload_encoder;

    cbor_encoder_init(&encoder, cbor_buffer, sizeof(cbor_buffer), 0);

    CborError err = CborNoError;

    // Outer map
    err |= cbor_encoder_create_map(&encoder, &map_encoder, 2); // 2 items: type and payload

    // "entity": "heater_mode"
    err |= cbor_encode_text_string(&map_encoder, "entity", strlen("entity"));
    err |= cbor_encode_text_string(&map_encoder, "heater_mode", strlen("heater_mode"));

    // "payload": { "value": heater_mode }
    err |= cbor_encode_text_string(&map_encoder, "payload", strlen("payload"));
    err |= cbor_encoder_create_map(&map_encoder, &payload_encoder, 1); // Payload map
    err |= cbor_encode_text_string(&payload_encoder, "value", strlen("value"));
    err |= cbor_encode_uint(&payload_encoder, mode);
    err |= cbor_encoder_close_container(&map_encoder, &payload_encoder); // Close payload map

    err |= cbor_encoder_close_container(&encoder, &map_encoder); // Close outer map

    if (err != CborNoError)
    {
        ESP_LOGE(TAG, "CBOR encoding error: %s", cbor_error_string(err));
        return -1;
    }

    size_t cbor_len = cbor_encoder_get_buffer_size(&encoder, cbor_buffer);

    uart_message_t msg_to_send;
    msg_to_send.command = CMD_SET_VALUE;
    memcpy(msg_to_send.data, cbor_buffer, cbor_len);
    msg_to_send.data_len = cbor_len;

    return uart_send_message(&msg_to_send);
}

int send_set_target_temperature(float value)
{
    uint8_t cbor_buffer[256]; // Adjust size as needed
    CborEncoder encoder, map_encoder, payload_encoder;

    cbor_encoder_init(&encoder, cbor_buffer, sizeof(cbor_buffer), 0);

    CborError err = CborNoError;

    // Outer map
    err |= cbor_encoder_create_map(&encoder, &map_encoder, 2); // 2 items: type and payload

    // "entity": "target_temperature"
    err |= cbor_encode_text_string(&map_encoder, "entity", strlen("entity"));
    err |= cbor_encode_text_string(&map_encoder, "target_temperature", strlen("target_temperature"));

    // "payload": { "value": target_temperature }
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
    msg_to_send.command = CMD_SET_VALUE;
    memcpy(msg_to_send.data, cbor_buffer, cbor_len);
    msg_to_send.data_len = cbor_len;

    return uart_send_message(&msg_to_send);
}

rx_task_callback_t init_uart_message_handler(state_subjects_t *arg_state_subjects)
{
    state_subjects = arg_state_subjects;
    return (rx_task_callback_t)&uart_message_handler;
}