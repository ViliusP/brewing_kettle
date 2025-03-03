#include <esp_http_server.h>
#include "http_server.h"
#include "lvgl.h"

ws_message_handler_t create_handler();
void init_ws_observer(state_subjects_t* state_subjects, httpd_handle_t httpd_handle);