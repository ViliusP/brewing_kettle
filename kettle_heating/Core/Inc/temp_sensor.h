/*
 * temp_sensor.h
 *
 *  Created on: Jan 17, 2025
 *      Author: viliusp
 */

#ifndef INC_TEMP_SENSOR_H_
#define INC_TEMP_SENSOR_H_

#include <stdint.h>
#include <stdbool.h>

// Define the GPIO pin connected to the DS18B20
#define DS18B20_PORT GPIOA
#define DS18B20_PIN GPIO_PIN_1

// Function prototypes
bool ds18b20_reset(void);
void ds18b20_write_byte(uint8_t data);
uint8_t ds18b20_read_byte(void);
bool ds18b20_start_conversion(void);
bool ds18b20_read_temperature(float *temperature);


#endif /* INC_TEMP_SENSOR_H_ */
