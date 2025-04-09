#ifndef UART_MESSAGING_H_
#define UART_MESSAGING_H_

#include "uart_communication.h"
#include "common_types.h"

rx_task_callback_t init_uart_message_handler(state_subjects_t* state_subjects);

int send_power_value(float value);
int send_pid_constants(pid_constants_t* constants);
int send_set_target_temperature(float value);
int send_set_heater_mode(heater_status_t mode);

#endif