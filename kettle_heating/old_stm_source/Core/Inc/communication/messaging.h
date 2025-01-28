
#ifndef COMM_MESSAGING_H // Include guard to prevent multiple inclusions
#define COMM_MESSAGING_H

#include "stdint.h"
#include "temp_sensor.h"

#define MESSAGE_HEADER_SIZE 8
#define MESSAGE_CONTENT_SIZE 16

// OUTBOUND MESSAGGING
typedef enum {
    MESSAGE_TYPE_STATE = 1,
    MESSAGE_TYPE_ERROR,
    MESSAGE_TYPE_DEBUG,
} message_type_t;

typedef enum {
    ERR_ENTITY_TEMPERATURE_SENSOR = 1,
} error_entity_t;


typedef enum {
    MESSAGE_ENTITY_TEMPERATURE = 1,
} state_entity_t;

// INBOUND MESSAGING

uint32_t compose_current_temp_message(float value);
uint32_t compose_temp_sensor_error(DS18B20_status_t error);

#endif // COMM_MESSAGING_H