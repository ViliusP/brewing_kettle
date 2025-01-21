#include "communication/messaging.h"
#include "stdint.h"
#include "temp_sensor.h"

static uint32_t compose_message(message_type_t type, uint8_t entity, uint32_t content) {
    uint32_t message = 0;
    message |= ((type & 0xF) << 28);    // 4 bits for type
    message |= ((entity & 0xF) << 24);  // 4 bits for entity
    message |= (content & 0xFFFFFF);    // 24 bits for content (excess bits will be truncated)
    return message;
}
uint32_t compose_current_temp_message(float value) {
    int16_t int_value = (int16_t)(value / 0.0625);
    return compose_message(MESSAGE_TYPE_STATE, MESSAGE_ENTITY_TEMPERATURE, int_value);
}

uint32_t compose_temp_sensor_error(DS18B20_status_t error) {
    return compose_message(MESSAGE_TYPE_STATE, ERR_ENTITY_TEMPERATURE_SENSOR, error);
}
