#include "ds18b20.h"
#include "onewire_device.h"
#include "onewire_bus.h"
#include "esp_log.h"
#include "temperature_sensor.h"
#include "esp_check.h"

static const char *TAG = "DS18B20";

#define ONEWIRE_BUS_GPIO 18

ds18b20_device_handle_t initialize_temperature_sensor(void)
{
    // install 1-wire bus
    onewire_bus_handle_t bus = NULL;
    onewire_bus_config_t bus_config = {
        .bus_gpio_num = ONEWIRE_BUS_GPIO,
    };
    onewire_bus_rmt_config_t rmt_config = {
        .max_rx_bytes = 10, // 1byte ROM command + 8byte ROM number + 1byte device command
    };
    ESP_ERROR_CHECK(onewire_new_bus_rmt(&bus_config, &rmt_config, &bus));

    int ds18b20_device_num = 0;
    ds18b20_device_handle_t ds18b20s[NEWIRE_MAX_DS18B20];
    onewire_device_iter_handle_t iter = NULL;
    onewire_device_t next_onewire_device;
    esp_err_t search_result = ESP_OK;

    // create 1-wire device iterator, which is used for device search
    ESP_ERROR_CHECK(onewire_new_device_iter(bus, &iter));
    ESP_LOGI(TAG, "Device iterator created, start searching...");
    do
    {
        search_result = onewire_device_iter_get_next(iter, &next_onewire_device);
        if (search_result == ESP_OK)
        { // found a new device, let's check if we can upgrade it to a DS18B20
            ds18b20_config_t ds_cfg = {};
            // check if the device is a DS18B20, if so, return the ds18b20 handle
            if (ds18b20_new_device(&next_onewire_device, &ds_cfg, &ds18b20s[ds18b20_device_num]) == ESP_OK)
            {
                ESP_LOGI(TAG, "Found a DS18B20[%d], address: %016llX", ds18b20_device_num, next_onewire_device.address);
                ds18b20_device_num++;
                if (ds18b20_device_num == 1)
                {
                    ESP_ERROR_CHECK(onewire_del_device_iter(iter));
                    ESP_LOGI(TAG, "Returning first DS18B20 device handle");
                    return ds18b20s[0];
                }
            }
            else
            {
                ESP_LOGI(TAG, "Found an unknown device, address: %016llX", next_onewire_device.address);
            }
        }
    } while (search_result != ESP_ERR_NOT_FOUND);
    ESP_ERROR_CHECK(onewire_del_device_iter(iter));
    ESP_LOGI(TAG, "Searching done, %d DS18B20 device(s) found", ds18b20_device_num);

    return NULL; // Return NULL if no DS18B20 device is found
}


float get_temperature(ds18b20_device_handle_t device_handle)
{
    if(device_handle == NULL) {
        ESP_LOGW(TAG, "DS18B20 device handle is NULL");
        return -55.0f; 
    }
    float temperature;
   
    ESP_ERROR_CHECK(ds18b20_trigger_temperature_conversion(device_handle));
    ESP_ERROR_CHECK(ds18b20_get_temperature(device_handle, &temperature));
    ESP_LOGI(TAG, "temperature read from DS18B20: %.2fC", temperature);

    return temperature;
}