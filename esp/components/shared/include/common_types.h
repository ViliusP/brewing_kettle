#ifndef COMMON_TYPES_H
#define COMMON_TYPES_H

#include "lwip/inet.h"

typedef enum
{
    CLEINT_STATUS_UNKNOWN = -1,
    CLIENT_CONNECTED = 0,
    CLIENT_DISCONNECTED = 1,
} client_status_t;

typedef struct ws_client_info_t {
    char ip[INET6_ADDRSTRLEN];
    uint16_t port;
    client_status_t status;
    size_t bytes_sent;
    size_t bytes_received;
} ws_client_info_t;

#endif