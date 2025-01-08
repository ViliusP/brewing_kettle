#pragma once

#include "sdkconfig.h"
#include "esp_err.h"
#if !CONFIG_IDF_TARGET_LINUX
#include "esp_netif.h"
#endif // !CONFIG_IDF_TARGET_LINUX

#ifdef __cplusplus
extern "C" {
#endif

#if !CONFIG_IDF_TARGET_LINUX
#define NETIF_DESC_STA "netif_sta"

/* Example default interface, prefer the ethernet one if running in example-test (CI) configuration */
#define INTERFACE get_example_netif_from_desc(NETIF_DESC_STA)
#define get_example_netif() get_example_netif_from_desc(NETIF_DESC_STA)

#endif // !CONFIG_IDF_TARGET_LINUX

#ifdef __cplusplus
}
#endif
