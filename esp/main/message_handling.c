#include <esp_log.h>
#include <esp_http_server.h>
#include "cJSON.h"

#define COMMON_FIELD_ID "id"
#define COMMON_FIELD_TYPE "type"
#define COMMON_FIELD_PAYLOAD "payload"

#define MESSAGE_OUT_CONFIGURATION "configuration"
#define MESSAGE_OUT_ERROR "error"

#define MESSAGE_IN_GET_CONFIGURATION_STR "configuration_get"
#define MESSAGE_IN_EXAMPLE_STR "example"

static const char *TAG = "WS_SERVER_HANDLER";

typedef enum {
  HTTP_STATUS_CONTINUE = 100,
  HTTP_STATUS_SWITCHING_PROTOCOLS = 101,
  HTTP_STATUS_OK = 200,
  HTTP_STATUS_CREATED = 201,
  HTTP_STATUS_ACCEPTED = 202,
  HTTP_STATUS_NO_CONTENT = 204,
  HTTP_STATUS_NOT_MODIFIED = 304,
  HTTP_STATUS_BAD_REQUEST = 400,
  HTTP_STATUS_UNAUTHORIZED = 401,
  HTTP_STATUS_FORBIDDEN = 403,
  HTTP_STATUS_NOT_FOUND = 404,
  HTTP_STATUS_METHOD_NOT_ALLOWED = 405,
  HTTP_STATUS_INTERNAL_SERVER_ERROR = 500,
  HTTP_STATUS_SERVICE_UNAVAILABLE = 503,
  HTTP_STATUS_GATEWAY_TIMEOUT = 504,
} http_status_code_t;

const char* http_status(http_status_code_t code) {
  switch (code) {
    case HTTP_STATUS_CONTINUE:
      return "100 Continue";
    case HTTP_STATUS_SWITCHING_PROTOCOLS:
      return "101 Switching Protocols";
    case HTTP_STATUS_OK:
      return "200 OK";
    case HTTP_STATUS_CREATED:
      return "201 Created";
    case HTTP_STATUS_ACCEPTED:
      return "202 Accepted";
    case HTTP_STATUS_NO_CONTENT:
      return "204 No Content";
    case HTTP_STATUS_NOT_MODIFIED:
      return "304 Not Modified";
    case HTTP_STATUS_BAD_REQUEST:
      return "400 Bad Request";
    case HTTP_STATUS_UNAUTHORIZED:
      return "401 Unauthorized";
    case HTTP_STATUS_FORBIDDEN:
      return "403 Forbidden";
    case HTTP_STATUS_NOT_FOUND:
      return "404 Not Found";
    case HTTP_STATUS_METHOD_NOT_ALLOWED:
      return "405 Method Not Allowed";
    case HTTP_STATUS_INTERNAL_SERVER_ERROR:
      return "500 Internal Server Error";
    case HTTP_STATUS_SERVICE_UNAVAILABLE:
      return "503 Service Unavailable";
    case HTTP_STATUS_GATEWAY_TIMEOUT:
      return "504 Gateway Timeout";
    default:
      return "-000 Unknown Status Code";
  }
}

typedef enum
{
    MESSAGE_UNKNOWN = -1,
    MESSAGE_GET_CONFIGURATION = 0,
    MESSAGE_EXAMPLE = 1,
} message_in_type_t;

message_in_type_t get_message_type(const char *type_str)
{
    if (strcmp(type_str, MESSAGE_IN_GET_CONFIGURATION_STR) == 0)
    {
        return MESSAGE_GET_CONFIGURATION;
    }
    return MESSAGE_UNKNOWN;
}

static esp_err_t get_configuration_response(cJSON *root, char **data)
{
    cJSON *response_root = cJSON_CreateObject();

    cJSON *id_item = cJSON_GetObjectItem(root, COMMON_FIELD_ID);
    char *id_str = NULL;
    if (id_item != NULL && cJSON_IsString(id_item))
    {
        id_str = id_item->valuestring;
        cJSON_AddStringToObject(response_root, COMMON_FIELD_ID, id_str);
    }

    cJSON_AddStringToObject(response_root, COMMON_FIELD_TYPE, MESSAGE_OUT_CONFIGURATION);

    *data = cJSON_Print(response_root);
    ESP_LOGD(TAG, "Composed get_configuration response message:\n%s", *data);

    cJSON_Delete(response_root);

    return ESP_OK;
}

static esp_err_t error_response(char **data)
{
    cJSON *response_root = cJSON_CreateObject();

    cJSON_AddStringToObject(response_root, COMMON_FIELD_TYPE, MESSAGE_OUT_ERROR);
    
    cJSON *payload = cJSON_CreateObject();
    cJSON_AddItemToObject(response_root, COMMON_FIELD_PAYLOAD, payload); 
    cJSON_AddNumberToObject(payload, "code", HTTP_STATUS_BAD_REQUEST);
    cJSON_AddStringToObject(payload, "reason", "Bad message, couldn't sent parse message as JSON");
    
    *data = cJSON_Print(response_root);
    ESP_LOGD(TAG, "Composed error message:\n%s", *data);

    cJSON_Delete(response_root);

    return ESP_OK;
}

esp_err_t handle_message(httpd_ws_frame_t *frame, char **data)
{
    if (frame->type != HTTPD_WS_TYPE_TEXT)
    {
        *data = NULL;
        return ESP_OK;
    }

    cJSON *root = cJSON_Parse((char *)frame->payload);
    if (root == NULL)
    {
        ESP_LOGW(TAG, "Failed to parse JSON");
        error_response(data);
        return ESP_OK;
    }

    char *type_str = cJSON_GetObjectItem(root, COMMON_FIELD_TYPE)->valuestring;
    message_in_type_t message_type = get_message_type(type_str);

    switch (message_type)
    {
    case MESSAGE_GET_CONFIGURATION:
        if (get_configuration_response(root, data) != ESP_OK)
        {
            ESP_LOGE(TAG, "Failed to create configuration response");
            cJSON_Delete(root);
            return ESP_FAIL;
        }
        break;
    default:
        ESP_LOGD(TAG, "Unknown type");
        cJSON_Delete(root);
        return ESP_OK;
    }

    cJSON_Delete(root);
    return ESP_OK;
}