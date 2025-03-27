#ifndef HTTP_HANDLERS_H_
#define HTTP_HANDLERS_H_

#include <esp_http_server.h>

/**
 * @brief Get pointer to HTTP handlers array
 * @return Const pointer to statically allocated array of HTTP handlers
 */
const httpd_uri_t *http_handlers_get_array(void);

/**
 * @brief Get number of HTTP handlers
 * @return Number of handlers in the array
 */
size_t http_handlers_get_count(void);

#endif