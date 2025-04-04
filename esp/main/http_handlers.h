#ifndef HTTP_HANDLERS_H_
#define HTTP_HANDLERS_H_

#include <esp_http_server.h>

/**
 * @brief Get pointer to HTTP handlers array
 * @param state_subjects Pointer to the state subjects used to initialize the handlers
 * @return Const pointer to statically allocated array of HTTP handlers
 */
const httpd_uri_t *init_http_handlers(state_subjects_t *state_subjects);

/**
 * @brief Get number of HTTP handlers
 * @return Number of handlers in the array
 */
size_t http_handlers_get_count(void);

#endif