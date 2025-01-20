/*
 * temp_sensor.c
 *
 *  Created on: Jan 17, 2025
 *      Author: viliusp
 */
#include "temp_sensor.h"
#include <stdint.h> // For standard integer types
#include "main.h"
#include "utils/timer_delay.h"

extern TIM_HandleTypeDef htim1;

static GPIO_TypeDef *ds18b20_port;
static uint16_t ds18b20_pin;


DS18B20_StatusTypeDef ds18b20_init(GPIO_TypeDef *port, uint16_t pin)
{
    ds18b20_port = port;
    ds18b20_pin = pin;

    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = ds18b20_pin;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_OD;
    GPIO_InitStruct.Pull = GPIO_PULLUP;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(ds18b20_port, &GPIO_InitStruct);

    // Check for sensor presence after initialization
    if (ds18b20_reset() != DS18B20_OK)
    {
        return DS18B20_ERROR_NO_SENSOR;
    }
    return DS18B20_OK;
}

DS18B20_StatusTypeDef ds18b20_reset(void)
{
    uint8_t presence;

    // 1. Pull the bus low for at least 480µs
    HAL_GPIO_WritePin(ds18b20_port, ds18b20_pin, GPIO_PIN_RESET);
    delay_us(htim1, 480);

    // 2. Release the bus (let it float high due to pull-up)
    HAL_GPIO_WritePin(ds18b20_port, ds18b20_pin, GPIO_PIN_SET);
    delay_us(htim1, 70); // Wait 70µs

    // 3. Check for presence pulse (DS18B20 pulls the bus low for 60-240µs)
    presence = !HAL_GPIO_ReadPin(ds18b20_port, ds18b20_pin); // Invert the logic

    delay_us(htim1, 410); // Complete the reset sequence (480 + 70 + 410 = 960µs, which is > 480µs min)

    if (presence)
    {
        return DS18B20_OK; // Presence detected
    }
    else
    {
        return DS18B20_ERROR_RESET; // No presence detected
    }
}

DS18B20_StatusTypeDef ds18b20_set_resolution(uint8_t resolution)
{
    if (resolution < 9 || resolution > 12)
    {
        return DS18B20_ERROR_CONVERSION; // Invalid resolution
    }

    uint8_t config_byte;
    switch (resolution)
    {
    case 9:
        config_byte = 0x00;
        break;
    case 10:
        config_byte = 0x20;
        break;
    case 11:
        config_byte = 0x40;
        break;
    case 12:
        config_byte = 0x60;
        break;
    default:
        return DS18B20_ERROR_CONVERSION; // Should not happen
    }

    if (ds18b20_reset() != DS18B20_OK)
        return DS18B20_ERROR_RESET;
    ds18b20_write_byte(0xCC);        // Skip ROM
    ds18b20_write_byte(0x4E);        // Write Scratchpad
    ds18b20_write_byte(0x00);        // TH Register (not used in this example)
    ds18b20_write_byte(0x00);        // TL Register (not used in this example)
    ds18b20_write_byte(config_byte); // Configuration Register

    if (ds18b20_reset() != DS18B20_OK)
        return DS18B20_ERROR_RESET;
    ds18b20_write_byte(0xCC); // Skip ROM
    ds18b20_write_byte(0x48); // Copy Scratchpad to EEPROM
    HAL_Delay(10);            // Wait for EEPROM write

    return DS18B20_OK;
}

void ds18b20_write_bit(uint8_t bit)
{
    HAL_GPIO_WritePin(ds18b20_port, ds18b20_pin, GPIO_PIN_RESET); // Pull low

    if (bit)
    {
        delay_us(htim1, 6);                                               // Write 1: 6µs
        HAL_GPIO_WritePin(ds18b20_port, ds18b20_pin, GPIO_PIN_SET); // Release the bus
        delay_us(htim1, 64);                                              // Complete the 70us slot (6+64)
    }
    else
    {
        delay_us(htim1, 60);                                              // Write 0: 60µs
        HAL_GPIO_WritePin(ds18b20_port, ds18b20_pin, GPIO_PIN_SET); // Release the bus
        delay_us(htim1, 10);                                              // Complete the 70us slot (60+10)
    }
}

uint8_t ds18b20_read_bit(void)
{
    uint8_t bit = 0;

    // 1. Pull the bus low for 1µs
    HAL_GPIO_WritePin(ds18b20_port, ds18b20_pin, GPIO_PIN_RESET);
    delay_us(htim1, 1);

    // 2. Release the bus (let it float high)
    HAL_GPIO_WritePin(ds18b20_port, ds18b20_pin, GPIO_PIN_SET);

    // 3. Wait for 14µs (to allow the DS18B20 to drive the bus)
    delay_us(htim1, 14);

    // 4. Read the value from the bus
    bit = HAL_GPIO_ReadPin(ds18b20_port, ds18b20_pin);

    // 5. Complete the time slot (60µs total)
    delay_us(htim1, 45); // 1 + 14 + 45 = 60µs

    return bit;
}

void ds18b20_write_byte(uint8_t byte)
{
    for (int i = 0; i < 8; i++)
    {
        ds18b20_write_bit(byte & 0x01); // Write the least significant bit
        byte >>= 1;                     // Shift the byte to the right
    }
}

uint8_t ds18b20_read_byte(void)
{
    uint8_t byte = 0;

    for (int i = 0; i < 8; i++)
    {
        byte |= (ds18b20_read_bit() << i);
    }

    return byte;
}

DS18B20_StatusTypeDef ds18b20_start_conversion(void)
{
    if (ds18b20_reset() != DS18B20_OK)
    {
        return DS18B20_ERROR_RESET;
    }
    ds18b20_write_byte(0xCC);              // Skip ROM
    ds18b20_write_byte(0x44);              // Convert T
    HAL_Delay(DS18B20_CONVERSION_TIMEOUT); // Use defined timeout
    return DS18B20_OK;
}

DS18B20_StatusTypeDef ds18b20_read_scratchpad(uint8_t *scratchpad)
{
    if (ds18b20_reset() != DS18B20_OK)
    {
        return DS18B20_ERROR_RESET;
    }
    ds18b20_write_byte(0xCC); // Skip ROM
    ds18b20_write_byte(0xBE); // Read Scratchpad

    for (int i = 0; i < 9; i++)
    {
        scratchpad[i] = ds18b20_read_byte();
    }
    return DS18B20_OK;
}

DS18B20_StatusTypeDef ds18b20_read_temperature(float *temperature)
{
    uint8_t scratchpad[9];
    DS18B20_StatusTypeDef ret;

    ret = ds18b20_start_conversion();
    if (ret != DS18B20_OK)
    {
        return ret;
    }

    ret = ds18b20_read_scratchpad(scratchpad);
    if (ret != DS18B20_OK)
    {
        return ret;
    }

    // Check for valid data (important!)
    if (scratchpad[4] != 0x7F)
    {
        return DS18B20_ERROR_NO_SENSOR; // Or another appropriate error
    }

    int16_t temp_raw = (scratchpad[1] << 8) | scratchpad[0];
    *temperature = (float)temp_raw / 16.0f;
    return DS18B20_OK;
}