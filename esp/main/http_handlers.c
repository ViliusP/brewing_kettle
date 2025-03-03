#include <esp_http_server.h>

static const char *TAG = "HTTP_HANDLERS";

static esp_err_t hello_world_handler(httpd_req_t *req)
{
    return ESP_OK;
}

static esp_err_t get_configuration_handler(httpd_req_t *req)
{
    return ESP_OK;
}



// Static const ensures data stays in ROM and is thread-safe
static const httpd_uri_t handlers[] = {
    {
        .uri = "/hello-world",
        .method = HTTP_GET,
        .handler = hello_world_handler,
        .user_ctx = NULL,
        .is_websocket = false
    },
    {
        .uri = "/configuration",
        .method = HTTP_GET,
        .handler = get_configuration_handler,
        .user_ctx = NULL,
        .is_websocket = false
    }
};

const httpd_uri_t *http_handlers_get_array(void) {
    return handlers;
}

size_t http_handlers_get_count(void) {
    return sizeof(handlers) / sizeof(handlers[0]);
}