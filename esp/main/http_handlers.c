#include <esp_http_server.h>
#include <esp_log.h>
#include "cJSON.h"
#include "esp_chip_info.h"
#include "esp_flash.h"
#include "utilities.h"
#include <sys/param.h>
#include <esp_system.h>
#include "nvs.h"
#include "nvs_flash.h"
#include "common_types.h"
#include "storage.h"

static const char *TAG = "HTTP_HANDLERS";

typedef struct {
  lv_subject_t *pid_constants;
} HttpHandlerContext;

static HttpHandlerContext context = {
  .pid_constants = NULL // To be initialized
};

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
  httpd_resp_send_404(req);
  return ESP_OK;
}

static esp_err_t get_pid_constants_handler(httpd_req_t *req)
{
  ESP_LOGI(TAG, "Got request: GET /api/v1/pid");
  httpd_resp_set_type(req, "application/json");

  // cJSON *response_root = device_configuration_json();
  // const char *sys_info = cJSON_Print(response_root);
  // httpd_resp_sendstr(req, sys_info);
  // free((void *)sys_info);
  // cJSON_Delete(response_root);
  httpd_resp_send_404(req);
  return ESP_OK;
}

static esp_err_t patch_pid_constants_handler(httpd_req_t *req)
{
  ESP_LOGI(TAG, "Got request: PATCH /api/v1/pid");
  httpd_resp_set_type(req, "application/json");

  // Get PID subject from user context
  lv_subject_t *pid_subject = (lv_subject_t *)req->user_ctx;
  if (!pid_subject)
  {
    ESP_LOGE(TAG, "No PID subject provided in user context");
    httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Internal error, no PID lv_subject was provided");
    return ESP_OK;
  }

  pid_constants_t* current = (const pid_constants_t *)lv_subject_get_pointer(pid_subject);
  if(!current)
  {
    ESP_LOGE(TAG, "No PID constants found, initialize the PID constants first");
    httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Internal error, no PID constants found");
    return ESP_OK;
  }

  // Get content length
  size_t content_len = req->content_len;
  if (content_len == 0 || content_len > 1024)
  {
    httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, "Invalid content length");
    return ESP_OK;
  }

  // Read request body
  char *buffer = malloc(content_len + 1);
  if (!buffer)
  {
    ESP_LOGE(TAG, "Memory allocation failed");
    httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Memory allocation failed");
    return ESP_OK;
  }

  int ret = httpd_req_recv(req, buffer, content_len);
  if (ret <= 0)
  {
    free(buffer);
    ESP_LOGE(TAG, "Failed to read request body");
    httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to read request body");
    return ESP_OK;
  }
  buffer[content_len] = '\0';

  // Parse JSON
  cJSON *root = cJSON_Parse(buffer);
  free(buffer);

  if (!root)
  {
    const char *error_ptr = cJSON_GetErrorPtr();
    ESP_LOGE(TAG, "JSON parse error: %s", error_ptr ? error_ptr : "unknown");
    httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, "Invalid JSON format");
    return ESP_OK;
  }

  // Get fields
  cJSON *proportional = cJSON_GetObjectItemCaseSensitive(root, "proportional");
  cJSON *integral = cJSON_GetObjectItemCaseSensitive(root, "integral");
  cJSON *derivative = cJSON_GetObjectItemCaseSensitive(root, "derivative");

  // Validate at least one field exists
  if (!proportional && !integral && !derivative)
  {
    cJSON_Delete(root);
    httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST,
                        "At least one PID constant must be provided");
    return ESP_OK;
  }

  // Validate each provided field
  char error_msg[128] = {0};
  bool has_errors = false;

  if (proportional)
  {
    if (!cJSON_IsNumber(proportional))
    {
      snprintf(error_msg, sizeof(error_msg), "Proportional must be a number");
      has_errors = true;
    }
    else if (cJSON_GetNumberValue(proportional) <= 0)
    {
      snprintf(error_msg, sizeof(error_msg), "Proportional must be positive");
      has_errors = true;
    }
  }

  if (!has_errors && integral)
  {
    if (!cJSON_IsNumber(integral))
    {
      snprintf(error_msg, sizeof(error_msg), "Integral must be a number");
      has_errors = true;
    }
    else if (cJSON_GetNumberValue(integral) <= 0)
    {
      snprintf(error_msg, sizeof(error_msg), "Integral must be positive");
      has_errors = true;
    }
  }

  if (!has_errors && derivative)
  {
    if (!cJSON_IsNumber(derivative))
    {
      snprintf(error_msg, sizeof(error_msg), "Derivative must be a number");
      has_errors = true;
    }
    else if (cJSON_GetNumberValue(derivative) <= 0)
    {
      snprintf(error_msg, sizeof(error_msg), "Derivative must be positive");
      has_errors = true;
    }
  }

  if (has_errors)
  {
    cJSON_Delete(root);
    httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, error_msg);
    return ESP_OK;
  }

  // Apply partial updates
  if (proportional)
    current->proportional = (float)cJSON_GetNumberValue(proportional);
  if (integral)
    current->integral = (float)cJSON_GetNumberValue(integral);
  if (derivative)
    current->derivative = (float)cJSON_GetNumberValue(derivative);

  cJSON_Delete(root);

  // Save updated values
  if (save_pid_settings(current) != ESP_OK)
  {
    httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to save PID settings");
    return ESP_OK;
  }

  // Success response
  cJSON *response = cJSON_CreateObject();
  cJSON_AddStringToObject(response, "status", "success");
  cJSON_AddStringToObject(response, "message", "PID constants updated");

  const char *response_str = cJSON_PrintUnformatted(response);
  httpd_resp_sendstr(req, response_str);
  free((void *)response_str);
  cJSON_Delete(response);

  lv_subject_notify(pid_subject);

  return ESP_OK;
}

static const httpd_uri_t handlers[] = {
    {.uri = "/api/v1/hello-world",
     .method = HTTP_GET,
     .handler = hello_world_handler,
     .user_ctx = NULL,
     .is_websocket = false},
    {.uri = "/api/v1/system-info",
     .method = HTTP_GET,
     .handler = get_system_info_handler,
     .user_ctx = NULL,
     .is_websocket = false},
    {.uri = "/api/v1/pid",
     .method = HTTP_GET,
     .handler = get_pid_constants_handler,
     .user_ctx = (void*)&context,
     .is_websocket = false},
    {.uri = "/api/v1/pid",
     .method = HTTP_PATCH,
     .handler = patch_pid_constants_handler,
     .user_ctx = (void*)&context,
     .is_websocket = false},
    {.uri = "/api/v1/history",
     .method = HTTP_GET,
     .handler = get_history_handler,
     .user_ctx = NULL,
     .is_websocket = false},
    {.uri = "/*",
     .method = HTTP_ANY,
     .handler = any_uri_handler,
     .user_ctx = NULL,
     .is_websocket = false},
};

const httpd_uri_t *init_http_handlers(state_subjects_t *state_subjects)
{
  HttpHandlerContext *ctx = (HttpHandlerContext*)&context;
  ctx->pid_constants = &state_subjects->pid_constants;
  return handlers;
}

size_t http_handlers_get_count(void)
{
  return sizeof(handlers) / sizeof(handlers[0]);
}