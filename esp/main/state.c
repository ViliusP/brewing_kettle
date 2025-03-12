#include "lvgl.h"
#include "http_server.h"
#include "esp_log.h"
#include "display.h"
#include "uart_communication.h"
#include "utilities.h"
#include "cbor.h"
#include "state.h"

static const char *TAG = "STATE";

state_subjects_t state_subjects;
app_state_t app_state;

const char *heater_status_human_string(heater_status_t state)
{
    switch (state)
    {
    case HEATER_STATUS_IDLE:
        return "Heater is in idle state";

    case HEATER_STATUS_HEATING_MANUAL:
        return "Heater works in manual mode";

    case HEATER_STATUS_HEATING_PID:
        return "Heater works in PID mode";

    case HEATER_STATUS_AUTOTUNE_PID:
        return "Heater works in PID autotune mode";

    case HEATER_STATUS_ERROR:
        return "Heater controller has error(s)";
    
    case HEATER_STATUS_UNKNOWN:
        return "Probably parsing error occured: heater status unknown";
    }
    return "Probably parsing error occured: heater status unknown";
}

const char *heater_status_string(heater_status_t state)
{
    switch (state)
    {
    case HEATER_STATUS_IDLE:
        return "HEATER_STATUS_IDLE";

    case HEATER_STATUS_HEATING_MANUAL:
        return "HEATER_STATUS_HEATING_MANUAL";

    case HEATER_STATUS_HEATING_PID:
        return "HEATER_STATUS_HEATING_PID";

    case HEATER_STATUS_AUTOTUNE_PID:
        return "HEATER_STATUS_AUTOTUNE_PID";

    case HEATER_STATUS_ERROR:
        return "HEATER_STATUS_ERROR";

    case HEATER_STATUS_UNKNOWN:
        return "HEATER_STATUS_UNKNOWN";
    }
    return "HEATER_STATUS_UNKNOWN";
}

const char *heater_status_json_string(heater_status_t state)
{
    switch (state)
    {
    case HEATER_STATUS_IDLE:
        return "idle";

    case HEATER_STATUS_HEATING_MANUAL:
        return "heating_manual";

    case HEATER_STATUS_HEATING_PID:
        return "heating_pid";

    case HEATER_STATUS_AUTOTUNE_PID:
        return "autotune_pid";

    case HEATER_STATUS_ERROR:
        return "error";

    case HEATER_STATUS_UNKNOWN:
        return "unknown";
    }
    return "unknown";
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

app_state_t app_state;

app_state_t *app_state_init(void)
{
    // Allocate heater state on the heap
    heater_controller_state_t *heater_state = malloc(sizeof(heater_controller_state_t));
    if (!heater_state)
    {
        ESP_LOGE(TAG, "Failed to allocate heater state");
        return NULL;
    }

    // Initialize heater state
    *heater_state = (heater_controller_state_t){
        .status = HEATER_STATUS_IDLE,
        .current_temp = ABSOLUTE_ZERO_FLOAT,
        .target_temp = ABSOLUTE_ZERO_FLOAT,
        .power = 0.0f};

    // Allocate connected clients structure
    client_info_data_t *clients = malloc(sizeof(client_info_data_t));
    if (!clients)
    {
        free(heater_state);
        ESP_LOGE(TAG, "Failed to allocate client info");
        return NULL;
    }

    // Initialize client info
    *clients = (client_info_data_t){
        .clients_info = NULL,
        .client_count = 0};

    // Initialize global app state
    app_state = (app_state_t){
        .heater_controller_state = heater_state,
        .connected_clients = clients};

    return &app_state;
}

void app_state_deinit(void)
{
    if (app_state.heater_controller_state)
    {
        free(app_state.heater_controller_state);
        app_state.heater_controller_state = NULL;
    }

    if (app_state.connected_clients)
    {
        // Free individual client structs if they exist
        if (app_state.connected_clients->clients_info)
        {
            free(app_state.connected_clients->clients_info);
        }
        free(app_state.connected_clients);
        app_state.connected_clients = NULL;
    }
}

state_subjects_t *init_state_subjects(app_state_t *app_state)
{
    ESP_LOGI(TAG, "Initializing state subjects with heater controller state at address: %p", (void *)app_state->heater_controller_state);
    lv_subject_init_pointer(&state_subjects.heater_controller_state, app_state->heater_controller_state);
    lv_subject_init_pointer(&state_subjects.connected_clients, NULL);

    return &state_subjects;
}
