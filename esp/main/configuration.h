#include "driver/uart.h"
#include "driver/gpio.h"
#include "driver/spi_common.h"

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

// SD CARD
#define wifi_config_file "/sdcard/wifi.txt"

#define PIN_NUM_MISO GPIO_NUM_6
#define PIN_NUM_MOSI GPIO_NUM_4
#define PIN_NUM_CLK GPIO_NUM_5

const spi_bus_config_t sdcard_bus_cfg = {
    .mosi_io_num = PIN_NUM_MOSI,
    .miso_io_num = PIN_NUM_MISO,
    .sclk_io_num = PIN_NUM_CLK,
    .quadwp_io_num = -1,
    .quadhd_io_num = -1,
    .max_transfer_sz = 4000,
};
