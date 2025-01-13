#include "lvgl.h"
#include "ws_server.h"
#include "esp_log.h"
#include "screen.h"

static const char *TAG = "STATE";

typedef enum
{
    HEATER_STATE_IDLE,
    HEATER_STATE_COOLING,
    HEATER_STATE_HEATING,
} heater_state_t;

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
    lv_subject_set_pointer(&state_subjects.connected_clients, &client_data);
}

state_subjects_t* init_state()
{
    lv_subject_init_int(&state_subjects.current_temp, 0);
    lv_subject_init_int(&state_subjects.target_temp, 0);
    lv_subject_init_int(&state_subjects.heater_state, HEATER_STATE_HEATING);

    lv_subject_init_pointer(&state_subjects.connected_clients, NULL);

    return &state_subjects;
}
