#include "uart_communication.h"
#include "esp_log.h"

static const char *TAG = "UART_MESSAGING";


int16_t float_to_int16_times10(float float_val) {
    double scaled_val = (double)float_val * 10.0; // Use double for intermediate calculation

    if (scaled_val > INT16_MAX) {
        ESP_LOGW(TAG, "Overflow: Value exceeds INT16_MAX.\n");
        return INT16_MAX;
    } else if (scaled_val < INT16_MIN) {
        ESP_LOGW(TAG, "Underflow: Value is less than INT16_MIN.\n");
        return INT16_MIN;
    } else {
        return (int16_t)scaled_val;
    }
}


uint32_t compose_message(uart_out_message_type_t type, uint32_t content) {
    uint32_t message = 0;
    message |= ((type & 0xF) << 28);    // 4 bits for type
    message |= (content & 0x0FFFFFFF);  // 28 bits for content
    return message;
}

uint32_t compose_set_target_temp_msg(float value) {
    int16_t int_value = float_to_int16_times10(value);
    return compose_message(UART_OUT_MSG_SET_TARGET_TEMP, int_value);
}