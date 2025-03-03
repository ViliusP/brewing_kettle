#include "mdns.h"
#include "esp_err.h"
#include <esp_log.h>

// MDNS servce configuration
#define MDNS_HOSTNAME_NAME "esp32_brewkettle"
#define MDNS_SERVICE_TYPE "_brewkettle"
#define MDNS_SERVICE_PROTO "_tcp"
#define MDNS_SERVICE_PORT 80
#define MDNS_INSTANCE "ESP32_kettle_server"

static const char *TAG = "MDNS";

esp_err_t start_mdns_service()
{
    esp_err_t err = ESP_OK;

    err = mdns_init();
    if (err) {
        ESP_LOGE(TAG, "MDNS initialization failed: %d", err);
        return ESP_FAIL;
    }

    err = mdns_hostname_set(MDNS_HOSTNAME_NAME);
    if (err) {
        ESP_LOGE(TAG, "mDNS hostname set failed: %d", err);
        return ESP_FAIL;
    }
    ESP_LOGI(TAG, "mDNS hostname set to: [%s]", MDNS_HOSTNAME_NAME);

    err = mdns_instance_name_set(MDNS_INSTANCE);
    if (err) {
        ESP_LOGE(TAG, "mDNS instance name set failed: %d", err);
        return ESP_FAIL;
    }
    ESP_LOGI(TAG, "mDNS instance name set to: [%s]", MDNS_INSTANCE);

    //structure with TXT records
    mdns_txt_item_t serviceTxtData[3] = {
        {"k1", "d1"},
        {"k2", "d2"},
        {"k3", "d3"}
    };

    err = mdns_service_add(MDNS_INSTANCE, MDNS_SERVICE_TYPE, "_tcp", MDNS_SERVICE_PORT, serviceTxtData, 3);
    if(err) {
        ESP_LOGE(TAG, "Failed to add mDNS services: %d", err);
        return ESP_FAIL;
    }
    ESP_LOGI(TAG, "Succesfully configured mDNS");


    return ESP_OK;
}
