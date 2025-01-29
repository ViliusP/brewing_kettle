#ifndef STATE_H_
#define STATE_H_

typedef enum
{
    HEATER_STATE_IDLE,
    HEATER_STATE_HEATING,
    HEATER_STATE_ERROR,
} heater_state_t;

typedef struct
{
    heater_state_t heater_state;
    float current_temp;
    float target_temp;
} app_state_t;

app_state_t init_state();

#endif