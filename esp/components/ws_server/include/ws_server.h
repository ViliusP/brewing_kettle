#include <esp_http_server.h>

#ifndef WS_SERVER_H
#define WS_SERVER_H

#include "lwip/inet.h"

typedef struct ws_client_info_t {
    char ip[INET6_ADDRSTRLEN];
    uint16_t port;
    size_t bytes_sent;
    size_t bytes_received;
} ws_client_info_t;


typedef struct {
    ws_client_info_t *clients_info;
    size_t client_count;
} client_info_data_t;
#endif

typedef void (*ws_client_changed_cb_t)(client_info_data_t *client_data);

typedef esp_err_t (*ws_message_handler_t)(httpd_ws_frame_t *frame, char **data);

void initialize_ws_server(ws_message_handler_t message_handler, ws_client_changed_cb_t ws_client_change_cb);



