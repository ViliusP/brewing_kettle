set(component_srcs "src/sd_card.c" "src/spiffs.c" "src/nvs.c")

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include"
                       PRIV_INCLUDE_DIRS ""
                       PRIV_REQUIRES sdmmc fatfs spi_flash spiffs shared nvs_flash
                       REQUIRES "")