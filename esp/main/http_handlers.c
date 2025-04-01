#include <esp_http_server.h>
#include <esp_log.h>
#include "cJSON.h"
#include "esp_chip_info.h"
#include "esp_flash.h"
#include "utilities.h"
#include <sys/param.h>
#include <esp_system.h>

static const char *TAG = "HTTP_HANDLERS";

static esp_err_t hello_world_handler(httpd_req_t *req)
{
    ESP_LOGI(TAG, "Got request: GET /api/v1/hello-world");
    return ESP_OK;
}

static cJSON *device_configuration_json()
{
  cJSON *payload_json = cJSON_CreateObject();
  cJSON *hardware_info_json = cJSON_CreateObject();
  cJSON *software_info_json = cJSON_CreateObject();

  // ---------
  // HARDWARE
  // ---------
  esp_chip_info_t chip_info;
  uint32_t flash_size;
  esp_chip_info(&chip_info);

  cJSON_AddStringToObject(hardware_info_json, "chip", CONFIG_IDF_TARGET);
  cJSON_AddNumberToObject(hardware_info_json, "cores", chip_info.cores);

  // Create an array to hold the features
  cJSON *features_array = cJSON_CreateArray();

  // Add features to the array
  if (chip_info.features & CHIP_FEATURE_WIFI_BGN)
  {
    cJSON_AddItemToArray(features_array, cJSON_CreateString("wifi"));
  }
  if (chip_info.features & CHIP_FEATURE_BT)
  {
    cJSON_AddItemToArray(features_array, cJSON_CreateString("bt"));
  }
  if (chip_info.features & CHIP_FEATURE_BLE)
  {
    cJSON_AddItemToArray(features_array, cJSON_CreateString("ble"));
  }
  if (chip_info.features & CHIP_FEATURE_IEEE802154)
  {
    cJSON_AddItemToArray(features_array, cJSON_CreateString("ieee802154"));
  }

  cJSON_AddItemToObject(hardware_info_json, "features", features_array);

  unsigned major_rev = chip_info.revision / 100;
  unsigned minor_rev = chip_info.revision % 100;
  cJSON_AddItemToObject(hardware_info_json, "silicon_revision", cJSON_create_formatted_string("%d.%d", major_rev, minor_rev));

  if (esp_flash_get_size(NULL, &flash_size) != ESP_OK)
  {
    ESP_LOGW(TAG, "Get flash size failed");
  }

  cJSON *flash_json = cJSON_CreateObject();
  cJSON_AddNumberToObject(flash_json, "size", flash_size);
  cJSON_AddStringToObject(flash_json, "type", (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "embedded" : "external");
  cJSON_AddItemToObject(hardware_info_json, "flash", flash_json);

  cJSON_AddNumberToObject(hardware_info_json, "heap_size", esp_get_minimum_free_heap_size());

// ---------
// SOFTWARE
// ---------
#ifdef ESP_APP_DESC_MAGIC_WORD
  esp_app_desc_t *app_info = esp_app_get_description();
  cJSON_AddStringToObject(software_info_json, "project_name", app_info->project_name);
  cJSON_AddStringToObject(software_info_json, "compile_time", app_info->time);
  cJSON_AddStringToObject(software_info_json, "compile_date", app_info->date);
  cJSON_AddStringToObject(software_info_json, "version", app_info->version);
  cJSON_AddNumberToObject(software_info_json, "secure_version", app_info->secure_version);
  cJSON_AddStringToObject(software_info_json, "idf_version", app_info->idf_ver);
#endif

  // -------
  // END
  // -------
  cJSON_AddItemToObject(payload_json, "hardware", hardware_info_json);
  cJSON_AddItemToObject(payload_json, "software", software_info_json);

  return payload_json;
}

static cJSON *system_info_json()
{
  cJSON *payload_json = cJSON_CreateObject();
  cJSON *communicator_info_json = device_configuration_json();
  cJSON *heater_info_json = cJSON_CreateObject();

  cJSON_AddItemToObject(payload_json, "communicator", communicator_info_json);
  cJSON_AddItemToObject(payload_json, "heater", heater_info_json);

  return payload_json;
}

static esp_err_t get_system_info_handler(httpd_req_t *req)
{
    ESP_LOGI(TAG, "Got request: GET /api/v1/system-info");
    httpd_resp_set_type(req, "application/json");

    cJSON *response_root = system_info_json();
    const char *sys_info = cJSON_Print(response_root);
    httpd_resp_sendstr(req, sys_info);
    free((void *)sys_info);
    cJSON_Delete(response_root);
    return ESP_OK;
}


    cJSON *response_root = device_configuration_json();
    const char *sys_info = cJSON_Print(response_root);
    httpd_resp_sendstr(req, sys_info);
    free((void *)sys_info);
    cJSON_Delete(response_root);
    return ESP_OK;
}

static esp_err_t any_uri_handler(httpd_req_t *req)
{
    ESP_LOGW(TAG, "Got unexpected request: %d %s", req->method, req->uri);
    return ESP_OK;
}



static const httpd_uri_t handlers[] = {

    {
        .uri = "/api/v1/hello-world",
        .method = HTTP_GET,
        .handler = hello_world_handler,
        .user_ctx = NULL,
        .is_websocket = false
    },
    {
        .uri = "/api/v1/system-info",
        .method = HTTP_GET,
        .handler = get_system_info_handler,
        .user_ctx = NULL,
        .is_websocket = false
    },
    {
        .uri = "/*",
        .method = HTTP_ANY,
        .handler = any_uri_handler,
        .user_ctx = NULL,
        .is_websocket = false
    },
};

const httpd_uri_t *http_handlers_get_array(void) {
    return handlers;
}

size_t http_handlers_get_count(void) {
    return sizeof(handlers) / sizeof(handlers[0]);
}