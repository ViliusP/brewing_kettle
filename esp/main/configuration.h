#include "driver/uart.h"
#include "driver/gpio.h"

// UART
#define UART_BAUD_RATE 115200
#define UART_RX_PIN (GPIO_NUM_17)
#define UART_TX_PIN (GPIO_NUM_16)

const uart_config_t uart_config = {
    .baud_rate = UART_BAUD_RATE,
    .data_bits = UART_DATA_8_BITS,
    .parity = UART_PARITY_DISABLE,
    .stop_bits = UART_STOP_BITS_1,
    .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    .source_clk = UART_SCLK_DEFAULT,
};

// KEYBOARD
const matrix_kbd_config_t kbd_config = {
    .row_gpios = (int[]){18, 19, 20},
    .col_gpios = (int[]){21, 10, 11},
    .nr_row_gpios = 3,
    .nr_col_gpios = 3,
    .debounce_ms = 20,
};
