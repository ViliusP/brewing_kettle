#ifndef STATE_H_
#define STATE_H_

#include "common_types.h"

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

app_state_t *app_state_init();
state_subjects_t *init_state_subjects(app_state_t *app_state);
void connected_client_data_notify(client_info_data_t client_data);

#endif