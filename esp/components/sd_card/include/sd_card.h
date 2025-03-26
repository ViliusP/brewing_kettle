#pragma once

#include "driver/spi_common.h"
#include "sdmmc_cmd.h"

#ifdef __cplusplus
extern "C" {
#endif


/**
 * @brief Type defined for matrix keyboard handle
 *
 */
// typedef struct matrix_kbd_t *matrix_kbd_handle_t;



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

#ifdef __cplusplus
}
#endif