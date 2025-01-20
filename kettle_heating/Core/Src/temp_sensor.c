/*
 * temp_sensor.c
 *
 *  Created on: Jan 17, 2025
 *      Author: viliusp
 */
#include "temp_sensor.h"
#include <stdint.h> // For standard integer types
#include "main.h"

// Delay function (using HAL_Delay is preferred if available)
void ds18b20_delay_us(uint16_t us) {
    // This is a basic delay loop. For more accurate timing, use a timer.
    // Adjust the loop count based on your clock frequency.
	volatile uint32_t delay = (SystemCoreClock / 1000000) * us / 3; // Approximate calibration
	while (delay--);
}

bool ds18b20_reset(void) {
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = DS18B20_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_OD; // Open-drain output
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(DS18B20_PORT, &GPIO_InitStruct);

    HAL_GPIO_WritePin(DS18B20_PORT, DS18B20_PIN, GPIO_PIN_RESET); // Pull low
    ds18b20_delay_us(480); // Reset pulse (min 480us)
    HAL_GPIO_WritePin(DS18B20_PORT, DS18B20_PIN, GPIO_PIN_SET); // Release the bus
    ds18b20_delay_us(70);  // Wait for presence pulse (15-60us)

    GPIO_InitStruct.Mode = GPIO_MODE_INPUT; // Set to input to read presence pulse
    HAL_GPIO_Init(DS18B20_PORT, &GPIO_InitStruct);

    if (HAL_GPIO_ReadPin(DS18B20_PORT, DS18B20_PIN) == GPIO_PIN_RESET) { // Check for presence pulse
        ds18b20_delay_us(410); // Wait for end of presence pulse
        return true; // Presence detected
    } else {
        ds18b20_delay_us(410);
        return false; // No presence detected
    }
}

void ds18b20_write_byte(uint8_t data) {
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = DS18B20_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_OD;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(DS18B20_PORT, &GPIO_InitStruct);
    for (uint8_t i = 0; i < 8; i++) {
        HAL_GPIO_WritePin(DS18B20_PORT, DS18B20_PIN, GPIO_PIN_RESET); // Start time slot
        ds18b20_delay_us(1); // Pull low for 1us
        if (data & (1 << i)) {
            HAL_GPIO_WritePin(DS18B20_PORT, DS18B20_PIN, GPIO_PIN_SET); // Write 1
        }
        ds18b20_delay_us(60); // Keep low for at least 60us (for writing 0)
        HAL_GPIO_WritePin(DS18B20_PORT, DS18B20_PIN, GPIO_PIN_SET);
        ds18b20_delay_us(1);
    }
}

uint8_t ds18b20_read_byte(void) {
    uint8_t data = 0;
	GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = DS18B20_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(DS18B20_PORT, &GPIO_InitStruct);
    for (uint8_t i = 0; i < 8; i++) {
        HAL_GPIO_WritePin(DS18B20_PORT, DS18B20_PIN, GPIO_PIN_RESET);
        ds18b20_delay_us(1);
        HAL_GPIO_WritePin(DS18B20_PORT, DS18B20_PIN, GPIO_PIN_SET);
        ds18b20_delay_us(14);
        if (HAL_GPIO_ReadPin(DS18B20_PORT, DS18B20_PIN)) {
            data |= (1 << i);
        }
        ds18b20_delay_us(45);
    }
    return data;
}

bool ds18b20_start_conversion(void) {
    if (!ds18b20_reset()) return false;
    ds18b20_write_byte(0xCC); // Skip ROM command (for single device)
    ds18b20_write_byte(0x44); // Convert T command
    return true;
}

bool ds18b20_read_temperature(float *temperature) {
    uint8_t temp_LSB, temp_MSB;

    if (!ds18b20_reset()) return false;
    ds18b20_write_byte(0xCC); // Skip ROM command
    ds18b20_write_byte(0xBE); // Read Scratchpad command

    temp_LSB = ds18b20_read_byte();
    temp_MSB = ds18b20_read_byte();

    int16_t temp_raw = (temp_MSB << 8) | temp_LSB;

    *temperature = (float)temp_raw / 16.0f; // Convert to Celsius

    return true;
}
