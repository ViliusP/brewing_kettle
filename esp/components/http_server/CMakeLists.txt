set(component_srcs "src/http_server.c" "src/wifi_connect.c" "src/keep_alive.c" "src/mdns_service.c" "src/sntp.c")

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include"
                       REQUIRES esp_http_server esp_wifi nvs_flash esp_timer mdns json shared)