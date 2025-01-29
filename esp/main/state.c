#include "lvgl.h"
#include "ws_server.h"
#include "esp_log.h"
#include "display.h"
#include "uart_communication.h"
#include "utilities.h"
#include "cbor.h"

#define DS18B20_LOWEST_POSSIBLE_TEMP -55.0f

static const char *TAG = "STATE";


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
    lv_subject_init_pointer(&state_subjects.current_temp, NULL);
    lv_subject_init_pointer(&state_subjects.target_temp, NULL);
    lv_subject_init_int(&state_subjects.heater_state, HEATER_STATE_IDLE);

    lv_subject_init_pointer(&state_subjects.connected_clients, NULL);

    return &state_subjects;
}
