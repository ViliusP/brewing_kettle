#include "lvgl.h"
#include "ws_server.h"
#include "esp_log.h"

static const char *TAG = "STATE";

typedef enum
{
    HEATER_STATE_IDLE,
    HEATER_STATE_COOLING,
    HEATER_STATE_HEATING,
} heater_state_t;

static lv_subject_t current_temp_subject;
static lv_subject_t target_temp_subject;
static lv_subject_t heater_state_subject;

static lv_subject_t connected_clients_subject;

void init_state()
{
    lv_subject_init_int(&current_temp_subject, 0);
    lv_subject_init_int(&target_temp_subject, 0);
    lv_subject_init_int(&heater_state_subject, HEATER_STATE_HEATING);

    lv_subject_init_pointer(&connected_clients_subject, NULL);
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
    // lv_subject_set_pointer(&connected_clients_subject, &client_data);
}