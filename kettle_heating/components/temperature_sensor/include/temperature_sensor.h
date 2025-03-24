#ifndef TEMPERATURE_SENSOR_H_
#define TEMPERATURE_SENSOR_H_

#include "ds18b20.h"

#define NEWIRE_MAX_DS18B20 1

ds18b20_device_handle_t initialize_temperature_sensor(void);
esp_err_t get_temperature(ds18b20_device_handle_t device_handle, float *temperature);

#endif // TEMPERATURE_SENSOR_H_