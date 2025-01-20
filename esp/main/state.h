#include "ws_server.h"

void uart_message_handling(const char *data, const int bytes);
state_subjects_t* init_state_subjects();
void connected_client_data_notify(client_info_data_t client_data);