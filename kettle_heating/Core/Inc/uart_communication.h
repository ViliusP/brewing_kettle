/*
 * uart_comm.h
 *
 *  Created on: Jan 17, 2025
 *      Author: viliusp
 */

#ifndef UART_COMM_H // Include guard to prevent multiple inclusions
#define UART_COMM_H

#include "main.h" // Include main.h for HAL definitions and other project-specific includes
#include <stdint.h> // For standard integer types
#include <stdio.h>

#define RX_BUFFER_SIZE 64

// Structure to hold UART communication data (optional but recommended)
typedef struct {
    UART_HandleTypeDef *huart; // Pointer to the UART handle
    uint8_t rx_buffer[RX_BUFFER_SIZE];
    uint32_t rx_index;
} uart_comm_t;

// Function prototypes
void uart_comm_init(uart_comm_t *uart_comm, UART_HandleTypeDef *huart);
void uart_comm_process_received_data(uart_comm_t *uart_comm);
void uart_comm_send_string(uart_comm_t *uart_comm, char *str);

#endif // UART_COMM_H
