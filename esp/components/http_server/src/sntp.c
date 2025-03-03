/* LwIP SNTP example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "esp_system.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_attr.h"
#include "esp_sleep.h"
#include "nvs_flash.h"
#include "esp_netif_sntp.h"
#include "lwip/ip_addr.h"
#include "esp_sntp.h"
#include "sntp.h"

static const char *TAG = "SNTP";


#ifndef INET6_ADDRSTRLEN
#define INET6_ADDRSTRLEN 48
#endif

void time_sync_notification_cb(struct timeval *tv)
{
   char strftime_buf[64];
    time_t now;
    struct tm timeinfo;

    setenv("TZ", SNTP_TZ, 1);
    tzset();
    time(&now);
    localtime_r(&now, &timeinfo);
    strftime(strftime_buf, sizeof(strftime_buf), "%c", &timeinfo);
    ESP_LOGI(TAG, "The current date/time in Lithuania is: %s", strftime_buf);
}

static void print_servers(void)
{
    ESP_LOGI(TAG, "List of configured NTP servers:");

    for (uint8_t i = 0; i < SNTP_MAX_SERVERS; ++i)
    {
        if (esp_sntp_getservername(i))
        {
            ESP_LOGI(TAG, "server %d: %s", i, esp_sntp_getservername(i));
        }
        else
        {
            // we have either IPv4 or IPv6 address, let's print it
            char buff[INET6_ADDRSTRLEN];
            ip_addr_t const *ip = esp_sntp_getserver(i);
            if (ipaddr_ntoa_r(ip, buff, INET6_ADDRSTRLEN) != NULL)
                ESP_LOGI(TAG, "server %d: %s", i, buff);
        }
    }
}

void initialize_sntp(void)
{
    ESP_LOGI(TAG, "Initializing and starting SNTP");
    esp_sntp_config_t config = ESP_NETIF_SNTP_DEFAULT_CONFIG_MULTIPLE(5,
                                                                      ESP_SNTP_SERVER_LIST("pool.ntp.org",
                                                                                           "europe.pool.ntp.org",
                                                                                           "uk.pool.ntp.org",
                                                                                           "us.pool.ntp.org",
                                                                                           "time1.google.com"));

    config.sync_cb = time_sync_notification_cb; // Enable time sync notification callback
    esp_netif_sntp_init(&config);
    print_servers();

    // wait for time to be set
    int retry = 0;
    const int retry_count = SNTP_MAX_SYNC_RETRIES;
    while (esp_netif_sntp_sync_wait(2000 / portTICK_PERIOD_MS) == ESP_ERR_TIMEOUT && ++retry < retry_count)
    {
        ESP_LOGI(TAG, "Waiting for system time to be set... (%d/%d)", retry, retry_count);
    }
    if (retry == retry_count)
    {
        ESP_LOGW(TAG, "Failed to synchronize time after %d attempts", retry_count);
    }
}
