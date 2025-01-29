#include "ws_server.h"

void uart_message_handling(const uint8_t *data, int len);
state_subjects_t* init_state_subjects();
void connected_client_data_notify(client_info_data_t client_data);