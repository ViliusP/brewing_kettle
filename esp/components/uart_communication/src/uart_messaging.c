#include "uart_communication.h"

static uint32_t compose_message(out_message_type_t type, out_message_entity_t entity, uint32_t content) {
    uint32_t message = 0;
    message |= ((type & 0xF) << 28);    // 4 bits for type
    message |= ((entity & 0xF) << 24);  // 4 bits for entity
    message |= (content & 0xFFFFFF);    // 24 bits for content (excess bits will be truncated)
    return message;
}
