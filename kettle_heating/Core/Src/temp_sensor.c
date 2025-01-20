/*
 * temp_sensor.c
 *
 *  Created on: Jan 17, 2025
 *      Author: viliusp
 */
#include "temp_sensor.h"
#include <stdint.h> // For standard integer types
#include "main.h"

extern TIM_HandleTypeDef htim1;

static void DS18B20_set_pin_mode(GPIO_TypeDef *gpiox, uint16_t gpio_pin, uint32_t mode)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = gpio_pin;
    GPIO_InitStruct.Mode = mode;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(gpiox, &GPIO_InitStruct);
}

// Microsecond delay function using HAL
void ds18b20_delay_us(uint16_t us)
{
    if ((htim1.Instance->CR1 & TIM_CR1_CEN) == 0)
    {
        HAL_TIM_Base_Start(&htim1);
    }
    __HAL_TIM_SET_COUNTER(&htim1, 0); // Reset the counter

    // Use a volatile variable to prevent compiler optimizations
    volatile uint16_t counter_start = __HAL_TIM_GET_COUNTER(&htim1);
    while ((__HAL_TIM_GET_COUNTER(&htim1) - counter_start) < us)
        ; // Wait until counter reaches the desired delay}
}

bool ds18b20_reset(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin)
{
    bool presence = false;
    HAL_GPIO_WritePin(GPIOx, GPIO_Pin, GPIO_PIN_RESET); // Pull the line low
    ds18b20_delay_us(DS18B20_RESET_PULSE);                              // Wait for the reset pulse
    HAL_GPIO_WritePin(GPIOx, GPIO_Pin, GPIO_PIN_SET);   // Release the line
    ds18b20_delay_us(DS18B20_PRESENCE_WAIT);                               // Wait for presence pulse
    
    DS18B20_set_pin_mode(GPIOx, GPIO_Pin, GPIO_MODE_INPUT);
    
    presence = (HAL_GPIO_ReadPin(GPIOx, GPIO_Pin) == GPIO_PIN_RESET);
    ds18b20_delay_us(DS18B20_BUS_RELEASE); // Wait for the rest of the presence pulse duration
    
    return presence;
}

// Write a single bit to the DS18B20
void ds18b20_write_bit(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, bool bit)
{
    DS18B20_set_pin_mode(GPIOx, GPIO_Pin, GPIO_MODE_OUTPUT_OD);
    HAL_GPIO_WritePin(GPIOx, GPIO_Pin, GPIO_PIN_RESET);
    ds18b20_delay_us(1); // Start slot

    if (bit)
        HAL_GPIO_WritePin(GPIOx, GPIO_Pin, GPIO_PIN_SET);

    ds18b20_delay_us(DS18B20_WRITE_SLOT);
    HAL_GPIO_WritePin(GPIOx, GPIO_Pin, GPIO_PIN_SET);
    ds18b20_delay_us(1); // Recovery time
}

// Read a single bit from the DS18B20
bool ds18b20_read_bit(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin)
{
    bool bit;

    DS18B20_set_pin_mode(GPIOx, GPIO_Pin, GPIO_MODE_OUTPUT_OD);
    HAL_GPIO_WritePin(GPIOx, GPIO_Pin, GPIO_PIN_RESET);
    ds18b20_delay_us(1); // Start slot

    DS18B20_set_pin_mode(GPIOx, GPIO_Pin, GPIO_MODE_INPUT);
    ds18b20_delay_us(DS18B20_READ_SLOT);

    bit = (HAL_GPIO_ReadPin(GPIOx, GPIO_Pin) == GPIO_PIN_SET);
    ds18b20_delay_us(DS18B20_WRITE_SLOT - DS18B20_READ_SLOT);

    return bit;
}

// Write a byte to the DS18B20
void ds18b20_write_byte(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, uint8_t data)
{
    for (uint8_t i = 0; i < 8; i++)
    {
        ds18b20_write_bit(GPIOx, GPIO_Pin, data & (1 << i));
    }
}

// Read a byte from the DS18B20
uint8_t ds18b20_read_byte(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin)
{
    uint8_t data = 0;

    for (uint8_t i = 0; i < 8; i++)
    {
        if (ds18b20_read_bit(GPIOx, GPIO_Pin))
            data |= (1 << i);
    }

    return data;
}

// Start temperature conversion
bool ds18b20_start_conversion(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin)
{
    if (!ds18b20_reset(GPIOx, GPIO_Pin))
        return false;

    ds18b20_write_byte(GPIOx, GPIO_Pin, 0xCC); // Skip ROM
    ds18b20_write_byte(GPIOx, GPIO_Pin, 0x44); // Start temperature conversion

    return true;
}

// Read temperature
bool ds18b20_read_temperature(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, float *temperature)
{
    uint8_t temp_LSB, temp_MSB;

    if (!ds18b20_reset(GPIOx, GPIO_Pin))
        return false;

    ds18b20_write_byte(GPIOx, GPIO_Pin, 0xCC); // Skip ROM
    ds18b20_write_byte(GPIOx, GPIO_Pin, 0xBE); // Read Scratchpad

    temp_LSB = ds18b20_read_byte(GPIOx, GPIO_Pin);
    temp_MSB = ds18b20_read_byte(GPIOx, GPIO_Pin);

    if (temp_LSB == 0xFF && temp_MSB == 0xFF)
    {
        return false;
    }

    int16_t temp_raw = (temp_MSB << 8) | temp_LSB;

    *temperature = (float)temp_raw / 16.0f; // Convert to Celsius
    return true;
}