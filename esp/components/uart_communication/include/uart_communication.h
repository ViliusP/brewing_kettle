#ifndef UART_COMMUNICATION_H
#define UART_COMMUNICATION_H

#include "driver/uart.h"

#define RX_BUF_SIZE 1024

typedef void (*rx_task_callback_t)(const char *, const int);

int send_data(const char* log_name, const char* data);
void initialize_uart(uart_config_t uart_config, int tx_pin, int rx_pin);
void start_uart_task(rx_task_callback_t rx_task_callback);

#endif