#ifndef UART_COMMUNICATION_H
#define UART_COMMUNICATION_H

#include "driver/uart.h"

#define RX_BUF_SIZE 2048

typedef void (*rx_task_callback_t)(const char *, const int);

int uart_send_data(const char *data);
int uart_send_uint32(uint32_t value);

void initialize_uart(uart_config_t uart_config, int tx_pin, int rx_pin);
void start_uart_task(rx_task_callback_t rx_task_callback);

#endif