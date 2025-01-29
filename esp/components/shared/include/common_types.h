#ifndef COMMON_TYPES_H
#define COMMON_TYPES_H

#include "lwip/inet.h"
#include "lvgl.h"

#define ABSOLUTE_ZERO -273.15f

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


typedef struct {
    ws_client_info_t *clients_info;
    size_t client_count;
} client_info_data_t;


typedef struct
{
    lv_subject_t current_temp;
    lv_subject_t target_temp;
    lv_subject_t heater_state;
    lv_subject_t connected_clients;
} state_subjects_t;

#endif