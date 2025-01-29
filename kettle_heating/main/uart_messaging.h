#ifndef UART_MESSAGING_H_
#define UART_MESSAGING_H_

#include "uart_communication.h"
#include "state.h"

int send_temperature_data(float temperature);
rx_task_callback_t init_uart_message_handler(app_state_t *arg_app_state);

#endif