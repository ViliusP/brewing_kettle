#ifndef STATE_H_
#define STATE_H_

#define ABSOLUTE_ZERO -273.15f

typedef enum
{
    HEATER_STATE_IDLE,
    HEATER_STATE_HEATING_MANUAL,
    HEATER_STATE_HEATING_PID,
    HEATER_STATE_ERROR,
} heater_state_t;

typedef struct
{
    heater_state_t heater_state;
    float current_temp;
    float current_power;
    float target_temp;
} app_state_t;

app_state_t init_state();

#endif