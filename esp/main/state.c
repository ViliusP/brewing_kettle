#include "lvgl.h"
#include "ws_server.h"
#include "esp_log.h"
#include "display.h"
#include "uart_communication.h"
#include "utilities.h"
#include "cbor.h"
#include "state.h"

static const char *TAG = "STATE";

state_subjects_t state_subjects;
app_state_t app_state;

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

app_state_t *app_state_init()
{
    app_state.current_temp = ABSOLUTE_ZERO;
    app_state.target_temp = ABSOLUTE_ZERO;
    app_state.heater_state = HEATER_STATE_IDLE;
    app_state.connected_clients = NULL;

    return &app_state;
}


state_subjects_t *init_state_subjects(app_state_t *app_state)
{
    lv_subject_init_pointer(&state_subjects.current_temp, &app_state->current_temp);
    lv_subject_init_pointer(&state_subjects.target_temp, &app_state->target_temp);
    lv_subject_init_int(&state_subjects.heater_state, HEATER_STATE_IDLE);

    lv_subject_init_pointer(&state_subjects.connected_clients, NULL);

    return &state_subjects;
}
