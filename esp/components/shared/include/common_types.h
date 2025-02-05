#ifndef COMMON_TYPES_H_
#define COMMON_TYPES_H_

#include "lwip/inet.h"
#include "lvgl.h"

#define ABSOLUTE_ZERO_FLOAT -273.15f

typedef enum
{
    CLEINT_STATUS_UNKNOWN = -1,
    CLIENT_CONNECTED = 0,
    CLIENT_DISCONNECTED = 1,
} client_status_t;

typedef struct ws_client_info_t
{
    char ip[INET6_ADDRSTRLEN];
    uint16_t port;
    client_status_t status;
    size_t bytes_sent;
    size_t bytes_received;
} ws_client_info_t;

typedef enum
{
    HEATER_STATUS_IDLE,
    HEATER_STATUS_HEATING_MANUAL,
    HEATER_STATUS_HEATING_PID,
    HEATER_STATUS_ERROR,
} heater_status_t;

typedef struct
{
    heater_status_t status;
    float current_temp;
    float target_temp;
    float power;
} heater_controller_state_t;

typedef struct
{
    ws_client_info_t *clients_info;
    size_t client_count;
} client_info_data_t;

typedef struct
{
    heater_controller_state_t *heater_controller_state;
    client_info_data_t *connected_clients;
} app_state_t;

typedef struct
{
    lv_subject_t heater_controller_state;
    lv_subject_t connected_clients;
} state_subjects_t;

#endif