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

const char *heater_state_string(heater_state_t state)
{
    switch (state)
    {
    case HEATER_STATE_IDLE:
        return "Heater is in idle state";

    case HEATER_STATE_HEATING_MANUAL:
        return "Heater works in manual mode";

    case HEATER_STATE_HEATING_PID:
        return "Heater works in PID mode";

    case HEATER_STATE_ERROR:
        return "Heater controller has error(s)";
    }
    return "state unknown";
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

app_state_t *app_state_init(void) {
    // Allocate heater state on the heap
    heater_controller_state_t *heater_state = malloc(sizeof(heater_controller_state_t));
    if (!heater_state) {
        ESP_LOGE(TAG, "Failed to allocate heater state");
        return NULL;
    }
    
    // Initialize heater state
    *heater_state = (heater_controller_state_t) {
        .heater_state = HEATER_STATE_IDLE,
        .current_temp = ABSOLUTE_ZERO_FLOAT,
        .target_temp = ABSOLUTE_ZERO_FLOAT,
        .current_power = 0.0f
    };

    // Allocate connected clients structure
    client_info_data_t *clients = malloc(sizeof(client_info_data_t));
    if (!clients) {
        free(heater_state);
        ESP_LOGE(TAG, "Failed to allocate client info");
        return NULL;
    }
    
    // Initialize client info
    *clients = (client_info_data_t) {
        .clients_info = NULL,
        .client_count = 0
    };

    // Initialize global app state
    app_state = (app_state_t) {
        .heater_controller_state = heater_state,
        .connected_clients = clients
    };

    return &app_state;
}

void app_state_deinit(void) {
    if (app_state.heater_controller_state) {
        free(app_state.heater_controller_state);
        app_state.heater_controller_state = NULL;
    }
    
    if (app_state.connected_clients) {
        // Free individual client structs if they exist
        if (app_state.connected_clients->clients_info) {
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
