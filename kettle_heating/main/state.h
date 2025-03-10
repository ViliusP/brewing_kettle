#ifndef STATE_H_
#define STATE_H_

#define ABSOLUTE_ZERO -273.15f

typedef enum
{
    HEATER_STATUS_IDLE,
    HEATER_STATUS_HEATING_MANUAL,
    HEATER_STATUS_HEATING_PID,
    HEATER_STATUS_ERROR,
    HEATER_STATUS_UNKNOWN,
} heater_status_t;

typedef struct
{
    heater_status_t status;
    float current_temp;
    float target_temp;
    float power;
    float requested_power;
} app_state_t;

app_state_t init_state();

#endif