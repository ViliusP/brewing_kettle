#ifndef STATE_H_
#define STATE_H_

#include "common_types.h"

app_state_t *app_state_init();
state_subjects_t *init_state_subjects(app_state_t *app_state);
void connected_client_data_notify(client_info_data_t client_data);
const char *heater_state_string(heater_state_t state);

#endif