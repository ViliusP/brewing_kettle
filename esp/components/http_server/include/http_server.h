#include <esp_http_server.h>
#include "common_types.h"

typedef void (*ws_client_changed_cb_t)(client_info_data_t client_data);

typedef esp_err_t (*ws_message_handler_t)(httpd_ws_frame_t *frame, char **data);

esp_err_t send_ws_message(httpd_handle_t server_handle, const char *message);

httpd_handle_t initialize_http_server(ws_message_handler_t message_handler, ws_client_changed_cb_t ws_client_changed_cb);


