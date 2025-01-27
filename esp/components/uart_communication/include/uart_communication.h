#ifndef UART_COMMUNICATION_H
#define UART_COMMUNICATION_H

#include "driver/uart.h"

#define RX_BUF_SIZE 2048

typedef enum {
    MESSAGE_TYPE_SET = 1,
    MESSAGE_TYPE_DEBUG = 99,
} out_message_type_t;


typedef enum {
    MESSAGE_ENTITY_TARGET_TEMPERATURE = 1,
} out_message_entity_t;

static uint32_t compose_message(out_message_type_t type, out_message_entity_t entity, uint32_t content);


typedef void (*rx_task_callback_t)(const char *, const int);

int uart_send_data(const char *data);
void initialize_uart(uart_config_t uart_config, int tx_pin, int rx_pin);
void start_uart_task(rx_task_callback_t rx_task_callback);

#endif