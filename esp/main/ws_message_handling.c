#include <esp_log.h>
#include <esp_http_server.h>
#include "cJSON.h"
#include "http_server.h"
#include "lvgl.h"
#include <mbedtls/base64.h>
#include "utilities.h"
#include "http_server.h"
#include "uart_communication.h"
#include "uart_messaging.h"
#include "state.h"
#include "esp_app_desc.h"

#define COMMON_FIELD_ID "id"
#define COMMON_FIELD_TYPE "type"
#define COMMON_FIELD_PAYLOAD "payload"

#define MESSAGE_OUT_SNAPSHOT "snapshot"
#define MESSAGE_OUT_ERROR "error"

#define MESSAGE_IN_GET_SNAPSHOT_STR "snapshot_get"
#define MESSAGE_IN_SET_TARGET_TEMPERATURE_STR "temperature_set"
#define MESSAGE_IN_SET_HEATER_MODE_STR "heater_mode_set"
#define MESSAGE_IN_MESSAGE_SET_POWER_STR "power_set"

#define MESSAGE_IN_EXAMPLE_STR "example"

#define HEATER_MODE_IDLE_JSON "idle"
#define HEATER_MODE_PID_JSON "heating_pid"
#define HEATER_MODE_MANUAL_JSON "heating_manual"

static const char *TAG = "WS_MESSAGE_HANDLER";

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
  MESSAGE_GET_SNAPSHOT,
  MESSAGE_SET_TARGET_TEMP,
  MESSAGE_SET_HEATER_MODE,
  MESSAGE_SET_POWER,
  MESSAGE_EXAMPLE = 99,
} message_in_type_t;

message_in_type_t get_message_type(const char *type_str)
{
  if (strcmp(type_str, MESSAGE_IN_GET_SNAPSHOT_STR) == 0)
  {
    return MESSAGE_GET_SNAPSHOT;
  }
  if (strcmp(type_str, MESSAGE_IN_SET_TARGET_TEMPERATURE_STR) == 0)
  {
    return MESSAGE_SET_TARGET_TEMP;
  }
  if (strcmp(type_str, MESSAGE_IN_SET_HEATER_MODE_STR) == 0)
  {
    return MESSAGE_SET_HEATER_MODE;
  }
  if (strcmp(type_str, MESSAGE_IN_MESSAGE_SET_POWER_STR) == 0)
  {
    return MESSAGE_SET_POWER;
  }
  return MESSAGE_UNKNOWN;
}

heater_status_t heater_status_by_str(const char *value)
{
  if (strcmp(value, HEATER_MODE_IDLE_JSON) == 0)
  {
    return HEATER_STATUS_IDLE;
  }
  if (strcmp(value, HEATER_MODE_PID_JSON) == 0)
  {
    return HEATER_STATUS_HEATING_PID;
  }
  if (strcmp(value, HEATER_MODE_MANUAL_JSON) == 0)
  {
    return HEATER_STATUS_HEATING_MANUAL;
  }
  return HEATER_STATUS_UNKNOWN;
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

static int32_t calc_base64_encoded_size(int input_length)
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
    int32_t encoded_size = calc_base64_encoded_size(raw_data_size);
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

// EXAMPLE:
// "{"id":"e23275a7-d9f4-4553-903f-bb77d573e55d","type":"power_set","time":1738785222171,"payload":{"value":5.0}}"
double parse_power_value(cJSON *root)
{
  cJSON *payload = cJSON_GetObjectItem(root, COMMON_FIELD_PAYLOAD);
  if (payload == NULL)
  {
    ESP_LOGW(TAG, "Payload not found");
    return NEGATIVE_POWER_VALUE;
  }

  cJSON *value = cJSON_GetObjectItem(payload, "value");
  if (value == NULL)
  {
    ESP_LOGW(TAG, "Value not found");
    return NEGATIVE_POWER_VALUE;
  }
  if (value->type != cJSON_Number)
  {
    ESP_LOGW(TAG, "Given JSON's value isn't number");
    return NEGATIVE_POWER_VALUE;
  }

  return value->valuedouble;
}

// EXAMPLE:
// "{"id":"0ea777fc-f079-4ba8-b3f5-a890df475625","type":"temperature_set","time":1738153122695,"payload":{"value":21.5}}"
double parse_target_temperature(cJSON *root)
{
  cJSON *payload = cJSON_GetObjectItem(root, COMMON_FIELD_PAYLOAD);
  if (payload == NULL)
  {
    ESP_LOGW(TAG, "Payload not found");
    return ABSOLUTE_ZERO_FLOAT;
  }

  cJSON *value = cJSON_GetObjectItem(payload, "value");
  if (value == NULL)
  {
    ESP_LOGW(TAG, "Value not found");
    return ABSOLUTE_ZERO_FLOAT;
  }
  if (value->type != cJSON_Number)
  {
    ESP_LOGW(TAG, "Given JSON's value isn't number");
    return ABSOLUTE_ZERO_FLOAT;
  }

  return value->valuedouble;
}

// EXAMPLE:
// "{"id":"89573144-d4df-4415-9805-dc1d7eaf9897","type":"heater_mode_set","time":1738780934060,"payload":{"value":"heating_manual"}}"
heater_status_t parse_heater_mode(cJSON *root)
{
  cJSON *payload = cJSON_GetObjectItem(root, COMMON_FIELD_PAYLOAD);
  if (payload == NULL)
  {
    ESP_LOGW(TAG, "Payload not found");
    return HEATER_STATUS_UNKNOWN;
  }

  cJSON *value = cJSON_GetObjectItem(payload, "value");
  if (value == NULL)
  {
    ESP_LOGW(TAG, "Value not found");
    return HEATER_STATUS_UNKNOWN;
  }
  if (value->type != cJSON_String)
  {
    ESP_LOGW(TAG, "Given JSON's value isn't string");
    return HEATER_STATUS_UNKNOWN;
  }

  return heater_status_by_str(value->valuestring);
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
  case MESSAGE_GET_SNAPSHOT:
    if (get_snapshot_response(root, data) != ESP_OK)
    {
      ESP_LOGE(TAG, "Failed to create configuration response");
      cJSON_Delete(root);
      return ESP_FAIL;
    }
    break;
  case MESSAGE_SET_TARGET_TEMP:
    double message_temp = parse_target_temperature(root);
    if (message_temp == ABSOLUTE_ZERO_FLOAT)
    {
      ESP_LOGW(TAG, "Couldn't parse temperature from message");
      cJSON_Delete(root);
      return ESP_OK;
    }
    send_set_target_temperature(message_temp);
    cJSON_Delete(root);
    return ESP_OK;
    break;
  case MESSAGE_SET_POWER:
    double power = parse_power_value(root);
    if (power == NEGATIVE_POWER_VALUE)
    {
      ESP_LOGW(TAG, "Couldn't parse power value from message");
      cJSON_Delete(root);
      return ESP_OK;
    }
    send_power_value(power);
    cJSON_Delete(root);
    return ESP_OK;
    break;
  case MESSAGE_SET_HEATER_MODE:
    heater_status_t heater_status = parse_heater_mode(root);
    if (heater_status == HEATER_STATUS_UNKNOWN)
    {
      ESP_LOGW(TAG, "Couldn't parse heater status from 'MESSAGE_SET_HEATER_MODE'");
      cJSON_Delete(root);
      return ESP_OK;
    }
    send_set_heater_mode(heater_status);
    cJSON_Delete(root);
    return ESP_OK;
    break;
  default:
    ESP_LOGW(TAG, "Unknown message type from WS client");
    cJSON_Delete(root);
    return ESP_OK;
  }

  cJSON_Delete(root);
  return ESP_OK;
}

void current_temp_handler(lv_observer_t *observer, lv_subject_t *subject)
{
  httpd_handle_t httpd_handle = (httpd_handle_t)lv_observer_get_user_data(observer);
  if (httpd_handle == NULL)
  {
    ESP_LOGW(TAG, "httpd_handle is NULL, can't send message about current temperature change");
    return;
  }

  float *current_temperature_ptr = (float *)lv_subject_get_pointer(subject);
  if (current_temperature_ptr == NULL)
  {
    return;
  }
  float current_temp = *current_temperature_ptr;

  cJSON *response_root = cJSON_CreateObject();
  if (response_root == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON root object");
    return;
  }

  cJSON_AddStringToObject(response_root, COMMON_FIELD_TYPE, "current_temperature");

  cJSON *payload = cJSON_CreateObject();
  if (payload == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON payload object");
    cJSON_Delete(response_root);
    return;
  }
  cJSON_AddItemToObject(response_root, COMMON_FIELD_PAYLOAD, payload);

  time_t now;
  time(&now);
  cJSON_AddNumberToObject(payload, "timestamp", now);

  cJSON *value = cJSON_CreateNumber((double)current_temp); // Use cJSON_CreateNumber()
  if (value == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON number");
    cJSON_Delete(response_root);
    return;
  }
  cJSON_AddItemToObject(payload, "value", value);

  char *data = cJSON_Print(response_root);
  cJSON_Delete(response_root);

  esp_err_t ret = send_ws_message(httpd_handle, data);
  if (ret)
  {
    ESP_LOGW(TAG, "Failed to send message about current temperature change");
  }
  free(data);
}

static void heater_controller_state_handler(lv_observer_t *observer, lv_subject_t *subject)
{
  httpd_handle_t httpd_handle = (httpd_handle_t)lv_observer_get_user_data(observer);
  if (httpd_handle == NULL)
  {
    ESP_LOGW(TAG, "httpd_handle is NULL, can't send message about target temperature");
    return;
  }

  const heater_controller_state_t *heater_controller_state_ptr = (const heater_controller_state_t *)lv_subject_get_pointer(subject);
  if (heater_controller_state_ptr == NULL)
  {
    ESP_LOGW(TAG, "heater_controller_state pointer is NULL, in heater_controller_state_handler");
    return;
  }

  cJSON *response_root = cJSON_CreateObject();
  if (response_root == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON root object");
    return;
  }

  cJSON_AddStringToObject(response_root, COMMON_FIELD_TYPE, "heater_controller_state");

  cJSON *payload = cJSON_CreateObject();
  if (payload == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON payload object");
    cJSON_Delete(response_root);
    return;
  }
  cJSON_AddItemToObject(response_root, COMMON_FIELD_PAYLOAD, payload);

  time_t now;
  time(&now);
  cJSON_AddNumberToObject(payload, "timestamp", now);

  // --------------------
  // target_temperature
  // --------------------
  float target_temp = heater_controller_state_ptr->target_temp;
  cJSON *target_temp_cjson = cJSON_CreateNumber((double)target_temp); // Use cJSON_CreateNumber()
  if (target_temp_cjson == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON number (target_temperature)");
    cJSON_Delete(response_root);
    return;
  }
  cJSON_AddItemToObject(payload, "target_temperature", target_temp_cjson);

  // --------------------
  // current_temperature
  // --------------------
  float current_temperature = heater_controller_state_ptr->current_temp;
  cJSON *current_temperature_cjson = cJSON_CreateNumber((double)current_temperature); // Use cJSON_CreateNumber()
  if (current_temperature_cjson == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON number (current_temperature)");
    cJSON_Delete(response_root);
    return;
  }
  cJSON_AddItemToObject(payload, "current_temperature", current_temperature_cjson);

  // --------------------
  // power
  // --------------------
  float power = heater_controller_state_ptr->power;
  cJSON *power_cjson = cJSON_CreateNumber((double)power); // Use cJSON_CreateNumber()
  if (power_cjson == NULL)
  {
    ESP_LOGE(TAG, "Failed to create JSON number (power)");
    cJSON_Delete(response_root);
    return;
  }
  cJSON_AddItemToObject(payload, "power", power_cjson);

  // --------------------
  // heater_state
  // --------------------
  heater_status_t status = heater_controller_state_ptr->status;
  cJSON_AddStringToObject(payload, "status", heater_status_json_string(status));

  char *data = cJSON_Print(response_root);
  cJSON_Delete(response_root);

  esp_err_t ret = send_ws_message(httpd_handle, data);
  if (ret)
  {
    ESP_LOGW(TAG, "Failed to send message about current temperature change");
  }
  free(data);
}

void init_ws_observer(state_subjects_t *state_subjects, httpd_handle_t httpd_handle)
{
  lv_subject_add_observer(&state_subjects->heater_controller_state, heater_controller_state_handler, httpd_handle);
}

ws_message_handler_t create_ws_handler(void)
{
  return (ws_message_handler_t)&handle_message;
}