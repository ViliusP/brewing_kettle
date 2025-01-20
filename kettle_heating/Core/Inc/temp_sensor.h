/*
 * temp_sensor.h
 *
 *  Created on: Jan 17, 2025
 *      Author: viliusp
 */

#ifndef INC_TEMP_SENSOR_H_
#define INC_TEMP_SENSOR_H_

#include "main.h"
#include <stdint.h>
#include <stdbool.h>

// Define the GPIO pin connected to the DS18B20
#define DS18B20_PORT GPIOA
#define DS18B20_PIN GPIO_PIN_1

// Constants for DS18B20 timing (in microseconds)
#define DS18B20_RESET_PULSE     480
#define DS18B20_PRESENCE_WAIT   70
#define DS18B20_BUS_RELEASE     410
#define DS18B20_WRITE_SLOT      60
#define DS18B20_READ_SLOT       14


// Function prototypes
bool ds18b20_reset(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
void ds18b20_write_byte(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, uint8_t data);
uint8_t ds18b20_read_byte(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
bool ds18b20_start_conversion(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
bool ds18b20_read_temperature(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, float *temperature);


#endif /* INC_TEMP_SENSOR_H_ */
