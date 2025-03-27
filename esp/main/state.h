#ifndef STATE_H_
#define STATE_H_

#include "common_types.h"


app_state_t *app_state_init();
state_subjects_t *init_state_subjects(app_state_t *app_state);
void change_status(app_state_t *app_state, app_status_t status);
void connected_client_data_notify(client_info_data_t client_data);
const char *heater_status_string(heater_status_t status);
const char *heater_status_json_string(heater_status_t status);
const char *heater_status_human_string(heater_status_t status);

#endif