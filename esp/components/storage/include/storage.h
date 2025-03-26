#pragma once

#include "driver/spi_common.h"
#include "sdmmc_cmd.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_SSID_LENGTH 256
#define MAX_PASSWORD_LENGTH 256

/**
 * @brief Type defined for matrix keyboard handle
 *
 */
typedef struct {
    char username[MAX_SSID_LENGTH];
    char password[MAX_PASSWORD_LENGTH];
} wifi_credentials_t;

int read_credentials(const char *filename, wifi_credentials_t *credentials);

/**
 * @brief Initialize SD card and mount FAT filesystem
 *
 * @param[in]  bus_cfg   SPI bus configuration structure (MOSI, MISO, SCLK, etc.)
 * @param[out] card      Pointer to receive initialized SD card handle on success
 * @return
 *      - ESP_OK: SD card initialized and filesystem mounted successfully
 *      - ESP_ERR_INVALID_ARG: Invalid bus configuration or other parameters
 *      - ESP_ERR_NO_MEM: Memory allocation failed during initialization
 *      - ESP_FAIL: Filesystem mount failed (card may need formatting)
 *      - Other error codes from underlying SPI/SDMMC drivers
 */
esp_err_t init_sdcard(const spi_bus_config_t *bus_cfg, sdmmc_card_t **card);

esp_err_t init_spiffs();

bool file_exists(const char *path);

#ifdef __cplusplus
}
#endif