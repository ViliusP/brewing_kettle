#include <esp_http_server.h>
#include "common_types.h"

typedef void (*ws_client_changed_cb_t)(client_info_data_t client_data);

typedef esp_err_t (*ws_message_handler_t)(httpd_ws_frame_t *frame, char **data);

esp_err_t send_ws_message(httpd_handle_t server_handle, const char *message);

esp_err_t start_wifi(const char *ssid, const char *password);
httpd_handle_t initialize_http_server(const httpd_uri_t *http_handlers, size_t handlers_count, ws_message_handler_t ws_message_handler, ws_client_changed_cb_t ws_client_changed_cb);


