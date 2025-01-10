#include <esp_http_server.h>

typedef esp_err_t (*ws_message_handler_t)(httpd_ws_frame_t *frame, char **data);
