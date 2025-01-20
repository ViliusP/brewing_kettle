#include "uart_comm.h"
#include <string.h>

void uart_comm_init(uart_comm_t *uart_comm, UART_HandleTypeDef *huart) {
    uart_comm->huart = huart;
    uart_comm->rx_index = 0;
    memset(uart_comm->rx_buffer, 0, RX_BUFFER_SIZE);

    // Start receiving in interrupt mode. This is very important to have here.
    HAL_UART_Receive_IT(uart_comm->huart, (uint8_t *)&uart_comm->huart->Instance->DR, 1);
}

void uart_comm_process_received_data(uart_comm_t *uart_comm) {
    if (uart_comm->rx_index > 0 && uart_comm->rx_buffer[uart_comm->rx_index - 1] == '\n') {
        char message[RX_BUFFER_SIZE];
        uint32_t message_len = 0;
        for(uint32_t i = 0; i < uart_comm->rx_index; i++){
            if(uart_comm->rx_buffer[i] == '\n'){
                message_len = i;
                break;
            }
        }
        strncpy(message, (char*)uart_comm->rx_buffer, message_len);
        message[message_len] = '\0';
        uart_comm->rx_index = 0;
        memset(uart_comm->rx_buffer, 0, RX_BUFFER_SIZE);

        char print_buffer[100];
        sprintf(print_buffer, "Received: %s\r\n", message);
        uart_comm_send_string(uart_comm, print_buffer);
        // Add your message processing logic here
    }
}

void uart_comm_send_string(uart_comm_t *uart_comm, char *str) {
    HAL_UART_Transmit(uart_comm->huart, (uint8_t*)str, strlen(str), HAL_MAX_DELAY);
}
