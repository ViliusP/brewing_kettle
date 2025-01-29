#ifndef UART_MESSAGING_H_
#define UART_MESSAGING_H_

int send_temperature_data(float temperature);
void uart_message_handling(const char *data, const int bytes);

#endif