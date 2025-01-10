#include <esp_log.h>
#include <esp_http_server.h>
#include "cJSON.h"
#include "ws_types.h"
#include "lvgl.h"
#include <mbedtls/base64.h>

#define COMMON_FIELD_ID "id"
#define COMMON_FIELD_TYPE "type"
#define COMMON_FIELD_PAYLOAD "payload"

#define MESSAGE_OUT_CONFIGURATION "configuration"
#define MESSAGE_OUT_SNAPSHOT "snapshot"
#define MESSAGE_OUT_ERROR "error"

#define MESSAGE_IN_GET_CONFIGURATION_STR "configuration_get"
#define MESSAGE_IN_GET_SNAPSHOT_STR "snapshot_get"

#define MESSAGE_IN_EXAMPLE_STR "example"

static const char *TAG = "WS_SERVER_HANDLER";

typedef enum
{
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

const char *http_status(http_status_code_t code)
{
  switch (code)
  {
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
  MESSAGE_GET_SNAPSHOT = 1,
  MESSAGE_EXAMPLE = 99,
} message_in_type_t;

message_in_type_t get_message_type(const char *type_str)
{
  if (strcmp(type_str, MESSAGE_IN_GET_CONFIGURATION_STR) == 0)
  {
    return MESSAGE_GET_CONFIGURATION;
  }
  if (strcmp(type_str, MESSAGE_IN_GET_SNAPSHOT_STR) == 0)
  {
    return MESSAGE_GET_SNAPSHOT;
  }
  return MESSAGE_UNKNOWN;
}

static lv_draw_buf_t *get_snapshot_buffer()
{
  lv_obj_t *root = lv_screen_active();
  if (root)
  {
    return lv_snapshot_take(root, LV_COLOR_FORMAT_RGB888);
  }
  return NULL;
}

static int32_t calcBase64EncodedSize(int input_length)
{
	int32_t output_length = 4 * ((input_length + 2) / 3);
	return output_length;
}


static esp_err_t get_snapshot_response(cJSON *root, char **data)
{
  cJSON *response_root = cJSON_CreateObject();

  cJSON *id_item = cJSON_GetObjectItem(root, COMMON_FIELD_ID);
  char *id_str = NULL;

  if (id_item != NULL && cJSON_IsString(id_item))
  {
    id_str = id_item->valuestring;
    cJSON_AddStringToObject(response_root, COMMON_FIELD_ID, id_str);
  }

  cJSON_AddStringToObject(response_root, COMMON_FIELD_TYPE, MESSAGE_OUT_SNAPSHOT);

  cJSON *payload = cJSON_CreateObject();
  cJSON_AddItemToObject(response_root, COMMON_FIELD_PAYLOAD, payload);

  lv_draw_buf_t *snapshot = get_snapshot_buffer();
  if (snapshot)
  {
    cJSON_AddNumberToObject(payload, "width", snapshot->header.w);
    cJSON_AddNumberToObject(payload, "height", snapshot->header.h);


    // Get the raw data and size from the snapshot buffer
    unsigned char *raw_data = snapshot->data;
    size_t raw_data_size = snapshot->data_size;

    // Calculate the Base64 encoded size
    int32_t encoded_size = calcBase64EncodedSize(raw_data_size);
    unsigned char *encoded_data = malloc(encoded_size + 1); // +1 for null-termination
    if (encoded_data == NULL)
    {
      ESP_LOGE(TAG, "Failed to allocate memory for Base64 encoding");
      lv_draw_buf_destroy(snapshot);
      cJSON_Delete(response_root);
      return ESP_ERR_NO_MEM;
    }

    // Encode the raw data to Base64
    size_t encoded_len = 0;
    int ret = mbedtls_base64_encode(encoded_data, encoded_size + 1, &encoded_len, raw_data, raw_data_size);
    if (ret != 0)
    {
      ESP_LOGE(TAG, "Error in mbedtls_base64_encode: -0x%x", -ret);
      free(encoded_data);
      lv_draw_buf_destroy(snapshot);
      cJSON_Delete(response_root);
      return ESP_FAIL;
    }

    // Null-terminate the encoded string
    encoded_data[encoded_len] = '\0';

    // Add the Base64 encoded snapshot to the payload
    cJSON_AddStringToObject(payload, "data", (char *)encoded_data);

    // Free resources
    free(encoded_data);
    lv_draw_buf_destroy(snapshot);
  }
  else
  {
    ESP_LOGW(TAG, "Couldn't get snapshot data");
  }

  *data = cJSON_Print(response_root);
  ESP_LOGD(TAG, "Composed get_snapshot response message:\n%.*s...", 150, *data);

  cJSON_Delete(response_root);

  return ESP_OK;
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

static esp_err_t handle_message(httpd_ws_frame_t *frame, char **data)
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
  case MESSAGE_GET_SNAPSHOT:
    if (get_snapshot_response(root, data) != ESP_OK)
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

ws_message_handler_t create_handler()
{
  return (ws_message_handler_t)&handle_message;
}