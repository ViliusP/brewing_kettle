#pragma once

#include "sdkconfig.h"
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Configure Wi-Fi, connect, wait for IP
 *
 * @return ESP_OK on successful connection
 */
esp_err_t wifi_connect(const char *ssid, const char *password);

/**
 * De-initializes Wi-Fi
 */
esp_err_t wifi_disconnect(void);

/**
 * @brief Configure stdin and stdout to use blocking I/O
 *
 * This helper function is used in ASIO examples. It wraps installing the
 * UART driver and configuring VFS layer to use UART driver for console I/O.
 */
esp_err_t configure_stdin_stdout(void);

/**
 * @brief Returns esp-netif pointer created by example_connect() described by
 * the supplied desc field
 *
 * @param desc Textual interface of created network interface, for example "sta"
 * indicate default WiFi station, "eth" default Ethernet interface.
 *
 */
esp_netif_t *get_netif_from_desc(const char *desc);

#if CONFIG_EXAMPLE_PROVIDE_WIFI_CONSOLE_CMD
/**
 * @brief Register wifi connect commands
 *
 * Provide a simple wifi_connect command in esp_console.
 * This function can be used after esp_console is initialized.
 */
void register_wifi_connect_commands(void);
#endif

#ifdef __cplusplus
}
#endif
