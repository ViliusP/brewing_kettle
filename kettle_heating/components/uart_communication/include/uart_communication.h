#ifndef UART_COMMUNICATION_H_
#define UART_COMMUNICATION_H_

#include "driver/uart.h"

// Define the size for the persistent buffer (adjust based on expected message size)
#define PERSISTENT_BUFFER_SIZE 2048
// Define the size of the message header (command + data_len)
#define MIN_MESSAGE_LENGTH 5  // STX (1) + command (1) + data_len (1) + CRC (1) + ETX (1)
#define RX_BUF_SIZE 3072
#define MESSAGE_START_BYTE 0x02 // STX
#define MESSAGE_END_BYTE 0x03   // ETX
#define MAX_MESSAGE_LENGTH 256

// Define message commands using an enum
typedef enum
{
    CMD_SEND_SENSOR_DATA = 0x01,
    CMD_SET_VALUE = 0x02,
} uart_message_command_t;

// Define message structure
typedef struct
{
    uart_message_command_t command;
    uint8_t data[MAX_MESSAGE_LENGTH];
    uint8_t data_len;
} uart_message_t;

// Callback function type for processing received UART messages
typedef void (*rx_task_callback_t)(const char *data, int len);

int uart_send_message(uart_message_t *msg);

void initialize_uart(uart_config_t uart_config, int tx_pin, int rx_pin);
void start_uart_task(rx_task_callback_t rx_task_callback);

#endif