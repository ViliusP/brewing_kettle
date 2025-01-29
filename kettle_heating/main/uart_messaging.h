#ifndef UART_MESSAGING_H_
#define UART_MESSAGING_H_

#include "uart_communication.h"
#include "state.h"
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
#define CURRENT_TEMP_ENTITY "current_temperature"
#define TARGET_TEMP_ENTITY "target_temperature"

int send_entity_data(const char *entity, float value);
rx_task_callback_t init_uart_message_handler(app_state_t *arg_app_state);

#endif