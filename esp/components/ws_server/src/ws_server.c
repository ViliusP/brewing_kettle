#include <esp_wifi.h>
#include <esp_event.h>
#include <esp_log.h>
#include <esp_system.h>
#include <nvs_flash.h>
#include <sys/param.h>
#include "esp_netif.h"
#include "keep_alive.h"
#include "mdns_service.h"
#include "wifi_connect.h"
#include <stdlib.h>
#include <string.h>
#include <lwip/sockets.h>
#include "ws_server.h"
#include <esp_http_server.h>

static const char *TAG = "WS_SERVER";
static const size_t max_clients = 4;

/*
 * Structure holding server handle
 * and internal socket fd in order
 * to use out of request send
 */
struct async_resp_arg
{
    httpd_handle_t hd;
    int fd;
};

typedef struct
{
    httpd_handle_t *server; // Pointer to server handle
    ws_message_handler_t message_handler;
} esp_connect_event_args_t;

typedef struct
{
    httpd_handle_t *server; // Pointer to server handle
    ws_client_changed_cb_t ws_client_changed_cb;
} http_event_args_t;

/*
 * async send function, which we put into the httpd work queue
 */
static void ws_async_send(void *arg)
{
    static const char *data = "Async data";
    struct async_resp_arg *resp_arg = arg;
    httpd_handle_t hd = resp_arg->hd;
    int fd = resp_arg->fd;
    httpd_ws_frame_t ws_pkt;
    memset(&ws_pkt, 0, sizeof(httpd_ws_frame_t));
    ws_pkt.payload = (uint8_t *)data;
    ws_pkt.len = strlen(data);
    ws_pkt.type = HTTPD_WS_TYPE_TEXT;

    httpd_ws_send_frame_async(hd, fd, &ws_pkt);
    free(resp_arg);
}

static esp_err_t trigger_async_send(httpd_handle_t handle, httpd_req_t *req)
{
    struct async_resp_arg *resp_arg = malloc(sizeof(struct async_resp_arg));
    if (resp_arg == NULL)
    {
        return ESP_ERR_NO_MEM;
    }
    resp_arg->hd = req->handle;
    resp_arg->fd = httpd_req_to_sockfd(req);
    esp_err_t ret = httpd_queue_work(handle, ws_async_send, resp_arg);
    if (ret != ESP_OK)
    {
        free(resp_arg);
    }
    return ret;
}

static esp_err_t create_ws_frame(const char *data, httpd_ws_frame_t *frame)
{
    if (data == NULL || frame == NULL)
    {
        return ESP_ERR_INVALID_ARG;
    }

    frame->final = 1; // Set final flag for a single-frame message
    frame->len = strlen(data);
    frame->payload = (uint8_t *)data;
    frame->type = HTTPD_WS_TYPE_TEXT; // Assuming you want to send text data

    return ESP_OK;
}

/*
 * This handler echos back the received ws data
 * and triggers an async send if certain message received
 */
static esp_err_t ws_handler(httpd_req_t *req)
{
    ws_message_handler_t message_handler = (ws_message_handler_t)req->user_ctx;

    if (req->method == HTTP_GET)
    {
        ESP_LOGI(TAG, "Handshake done, the new connection was opened");
        return ESP_OK;
    }
    httpd_ws_frame_t ws_pkt;
    uint8_t *buf = NULL;
    memset(&ws_pkt, 0, sizeof(httpd_ws_frame_t));
    ws_pkt.type = HTTPD_WS_TYPE_TEXT;
    /* Set max_len = 0 to get the frame len */
    esp_err_t ret = httpd_ws_recv_frame(req, &ws_pkt, 0);
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "httpd_ws_recv_frame failed to get frame len with %d", ret);
        return ret;
    }
    ESP_LOGI(TAG, "frame len is %d", ws_pkt.len);
    if (ws_pkt.len)
    {
        /* ws_pkt.len + 1 is for NULL termination as we are expecting a string */
        buf = calloc(1, ws_pkt.len + 1);
        if (buf == NULL)
        {
            ESP_LOGE(TAG, "Failed to calloc memory for buf");
            return ESP_ERR_NO_MEM;
        }
        ws_pkt.payload = buf;
        /* Set max_len = ws_pkt.len to get the frame payload */
        ret = httpd_ws_recv_frame(req, &ws_pkt, ws_pkt.len);
        if (ret != ESP_OK)
        {
            ESP_LOGE(TAG, "httpd_ws_recv_frame failed with %d", ret);
            free(buf);
            return ret;
        }
        ESP_LOGI(TAG, "Got packet with message: %s", ws_pkt.payload);
    }
    ESP_LOGI(TAG, "Packet type: %d", ws_pkt.type);
    if (ws_pkt.type == HTTPD_WS_TYPE_TEXT &&
        strcmp((char *)ws_pkt.payload, "Trigger async") == 0)
    {
        free(buf);
        return trigger_async_send(req->handle, req);
    }
    if (message_handler == NULL)
    {
        ESP_LOGW(TAG, "No message handler passed to WS server, no response will be sent");
        free(buf);
        return ret;
    }
    char *data = NULL;
    ret = message_handler(&ws_pkt, &data);
    if (data == NULL && ret == ESP_OK)
    {
        ESP_LOGI(TAG, "No message to be sent back");
        free(buf);
        return ret;
    }
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "Failed to generate response %d", ret);
        free(buf);
        free(data);
        return ret;
    }
    httpd_ws_frame_t ws_response_frame;
    ret = create_ws_frame(data, &ws_response_frame);
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "Failed to generate response %d", ret);
        free(buf);
        free(data);
        return ret;
    }

    ret = httpd_ws_send_frame(req, &ws_response_frame);
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "httpd_ws_send_frame failed with %d", ret);
    }
    free(data);
    free(buf);
    return ret;
}

static void send_ping(void *arg)
{
    struct async_resp_arg *resp_arg = arg;
    httpd_handle_t hd = resp_arg->hd;
    int fd = resp_arg->fd;
    httpd_ws_frame_t ws_pkt;
    memset(&ws_pkt, 0, sizeof(httpd_ws_frame_t));
    ws_pkt.payload = NULL;
    ws_pkt.len = 0;
    ws_pkt.type = HTTPD_WS_TYPE_PING;

    httpd_ws_send_frame_async(hd, fd, &ws_pkt);
    free(resp_arg);
}

bool client_not_alive_cb(wss_keep_alive_t h, int fd)
{
    ESP_LOGE(TAG, "Client not alive, closing fd %d", fd);
    httpd_sess_trigger_close(wss_keep_alive_get_user_ctx(h), fd);
    return true;
}

bool check_client_alive_cb(wss_keep_alive_t h, int fd)
{
    ESP_LOGD(TAG, "Checking if client (fd=%d) is alive", fd);
    struct async_resp_arg *resp_arg = malloc(sizeof(struct async_resp_arg));
    assert(resp_arg != NULL);
    resp_arg->hd = wss_keep_alive_get_user_ctx(h);
    resp_arg->fd = fd;

    if (httpd_queue_work(resp_arg->hd, send_ping, resp_arg) == ESP_OK)
    {
        return true;
    }
    return false;
}

static httpd_handle_t start_ws_server(ws_message_handler_t message_handler)
{
    // Prepare keep-alive engine
    wss_keep_alive_config_t keep_alive_config = KEEP_ALIVE_CONFIG_DEFAULT();
    keep_alive_config.max_clients = max_clients;
    keep_alive_config.client_not_alive_cb = client_not_alive_cb;
    keep_alive_config.check_client_alive_cb = check_client_alive_cb;
    wss_keep_alive_t keep_alive = wss_keep_alive_start(&keep_alive_config);

    // Start the httpd server
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    httpd_handle_t server = NULL;

    if (httpd_start(&server, &config) != ESP_OK)
    {
        ESP_LOGE(TAG, "Error starting WebSocket server!");
        return NULL;
    }

    httpd_uri_t ws = {
        .uri = "/ws",
        .method = HTTP_GET,
        .handler = ws_handler,
        .user_ctx = message_handler,
        .is_websocket = true};

    // Set URI handlers
    httpd_register_uri_handler(server, &ws);
    wss_keep_alive_set_user_ctx(keep_alive, server);

    return server;
}

static esp_err_t stop_ws_server(httpd_handle_t server)
{
    // Stop the httpd server
    return httpd_stop(server);
}

static void disconnect_handler(void *arg, esp_event_base_t event_base,
                               int32_t event_id, void *event_data)
{
    httpd_handle_t *server = (httpd_handle_t *)arg;
    if (*server)
    {
        ESP_LOGI(TAG, "Stopping webserver");
        if (stop_ws_server(*server) == ESP_OK)
        {
            *server = NULL;
        }
        else
        {
            ESP_LOGE(TAG, "Failed to stop http server");
        }
    }
}

static void connect_handler(void *arg, esp_event_base_t event_base,
                            int32_t event_id, void *event_data)
{
    ESP_LOGI(TAG, "Succesfully connected to AP");
    esp_connect_event_args_t *args = (esp_connect_event_args_t *)arg;

    if (args && args->server == NULL)
    {
        ESP_LOGI(TAG, "Starting WebSocket server");
        args->server = start_ws_server(args->message_handler);
    }
}

// Get WebSocket client information
static esp_err_t httpd_client_infos(httpd_handle_t server_handle, ws_client_info_t **clients_info, size_t *client_count)
{
    const size_t max_clients = CONFIG_LWIP_MAX_LISTENING_TCP;
    int client_fds[max_clients];
    size_t fds = max_clients;

    esp_err_t ret = httpd_get_client_list(server_handle, &fds, client_fds);
    if (ret != ESP_OK)
    {
        return ret;
    }

    *clients_info = calloc(fds, sizeof(ws_client_info_t));
    if (!*clients_info)
    {
        return ESP_ERR_NO_MEM;
    }

    size_t count = 0;

    for (size_t i = 0; i < fds; i++)
    {
        httpd_ws_client_info_t client_info = httpd_ws_get_fd_info(server_handle, client_fds[i]);
        if (client_info == HTTPD_WS_CLIENT_WEBSOCKET)
        {
            struct sockaddr_in6 client_addr;
            socklen_t addr_len = sizeof(client_addr);
            if (getpeername(client_fds[i], (struct sockaddr *)&client_addr, &addr_len) == 0)
            {
                inet_ntop(client_addr.sin6_family, &client_addr.sin6_addr,
                          (*clients_info)[count].ip, sizeof((*clients_info)[count].ip));
                (*clients_info)[count].port = ntohs(client_addr.sin6_port);
            }
            else
            {
                strncpy((*clients_info)[count].ip, "Unknown", sizeof((*clients_info)[count].ip));
                (*clients_info)[count].port = 0;
            }
            (*clients_info)[count].bytes_sent = 0;
            (*clients_info)[count].bytes_received = 0;
            count++;
        }
    }
    *client_count = count;
    return ESP_OK;
}

static void http_connections_changed_handler(void *arg, esp_event_base_t event_base,
                                             int32_t event_id, void *event_data)
{
    if (arg == NULL)
    {
        ESP_LOGE(TAG, "http_connections_changed_handler: NULL argument received!");
        return;
    }

    http_event_args_t *args = (http_event_args_t *)arg;
    if (args->server == NULL)
    {
        ESP_LOGE(TAG, "http_connections_changed_handler: Invalid server handle");
        return;
    }
    if (args->ws_client_changed_cb == NULL)
    {
        ESP_LOGE(TAG, "http_connections_changed_handler: ws_client_changed_cb is NULL");
        return;
    }

    ws_client_info_t *clients_info = NULL;
    size_t client_count = 0;

    if (args->ws_client_changed_cb == NULL)
    {
        return;
    }
    esp_err_t err = httpd_client_infos(args->server, &clients_info, &client_count);
    ESP_LOGI(TAG, "http_on_connected_handler: Found %d clients", client_count);

    client_info_data_t client_info_data = {
        .clients_info = clients_info,
        .client_count = client_count};

    args->ws_client_changed_cb(&client_info_data);

    free(clients_info);
}

static httpd_handle_t server = NULL; // Declare server handle as static

void initialize_ws_server(ws_message_handler_t message_handler, ws_client_changed_cb_t ws_client_changed_cb)
{

    ESP_LOGI(TAG, "Initializing NVC and TCP/IP stack");
    ESP_ERROR_CHECK(nvs_flash_init());
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    /* This helper function configures Wi-Fi or Ethernet, as selected in menuconfig.
     * Read "Establishing Wi-Fi or Ethernet Connection" section in
     * examples/protocols/README.md for more information about this function.
     */
    ESP_LOGI(TAG, "Connecting to WIFI");
    ESP_ERROR_CHECK(wifi_connect());

    ESP_LOGI(TAG, "Start MDNS service");
    start_mdns_service();

    /* Start the server for the first time */
    server = start_ws_server(message_handler);

    esp_connect_event_args_t connect_event_args = {
        .server = &server,
        .message_handler = message_handler,
    };

    /* Register event handlers to stop the server when Wi-Fi is disconnected,
     * and re-start it upon connection.
     */
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, connect_handler, &server));
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, WIFI_EVENT_STA_DISCONNECTED, disconnect_handler, &connect_event_args));

    http_event_args_t *http_event_args = malloc(sizeof(http_event_args_t)); // Correct declaration!

    if (http_event_args == NULL)
    {
        return;
    }
    http_event_args->server = server;                         
    http_event_args->ws_client_changed_cb = ws_client_changed_cb; 

    ESP_ERROR_CHECK(esp_event_handler_register(ESP_HTTP_SERVER_EVENT, HTTP_SERVER_EVENT_ON_CONNECTED, &http_connections_changed_handler, http_event_args));
    ESP_ERROR_CHECK(esp_event_handler_register(ESP_HTTP_SERVER_EVENT, HTTP_SERVER_EVENT_DISCONNECTED, &http_connections_changed_handler, http_event_args));
}