set(component_srcs "src/sd_card.c")

idf_component_register(SRCS "${component_srcs}"
                       INCLUDE_DIRS "include"
                       PRIV_INCLUDE_DIRS ""
                       PRIV_REQUIRES sdmmc fatfs spi_flash
                       REQUIRES "")