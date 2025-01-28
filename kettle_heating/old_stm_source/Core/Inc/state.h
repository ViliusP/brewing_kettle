/*
 * state.h
 *
 *  Created on: Jan 27, 2025
 *      Author: viliusp
 */

#ifndef INC_STATE_H_
#define INC_STATE_H_

typedef enum {
    HEATER_IDLE = 0,
    HEATER_HEATING,
    HEATER_ERROR,
} heater_status_t;

typedef struct {
    heater_status_t heater_status; // Pointer to the UART handle
    float target_temp;
    float current_temp;
} app_state_t;

app_state_t app_state_init(void);

#endif /* INC_STATE_H_ */
