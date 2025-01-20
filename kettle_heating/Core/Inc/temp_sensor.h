/*
 * temp_sensor.h
 *
 *  Created on: Jan 17, 2025
 *      Author: viliusp
 */

#ifndef INC_TEMP_SENSOR_H_
#define INC_TEMP_SENSOR_H_

#include "stm32f4xx_hal.h"

// Constants for DS18B20 timing (in microseconds)

#define DS18B20_CONVERSION_TIMEOUT 1000 // milliseconds
#define DS18B20_RESOLUTION 12 // 9, 10, 11, or 12 bits

// Return codes for better error handling
typedef enum {
    DS18B20_OK = 0,
    DS18B20_ERROR_RESET,
    DS18B20_ERROR_CONVERSION,
    DS18B20_ERROR_READ_SCRATCHPAD,
    DS18B20_ERROR_NO_SENSOR
} DS18B20_StatusTypeDef;

// Function prototypes
// Initialization
DS18B20_StatusTypeDef ds18b20_init(GPIO_TypeDef* port, uint16_t pin);

// 1-Wire communication functions
DS18B20_StatusTypeDef ds18b20_reset(void);
void ds18b20_write_bit(uint8_t bit);
uint8_t ds18b20_read_bit(void);
void ds18b20_write_byte(uint8_t byte);
uint8_t ds18b20_read_byte(void);

// DS18B20 specific functions
DS18B20_StatusTypeDef ds18b20_start_conversion(void);
DS18B20_StatusTypeDef ds18b20_read_scratchpad(uint8_t* scratchpad);
DS18B20_StatusTypeDef ds18b20_read_temperature(float* temperature);
DS18B20_StatusTypeDef ds18b20_set_resolution(uint8_t resolution);

#endif /* INC_TEMP_SENSOR_H_ */
