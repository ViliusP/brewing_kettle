#include <esp_log.h>
#include <esp_http_server.h>

esp_err_t handle_message(httpd_ws_frame_t *frame, char **data);