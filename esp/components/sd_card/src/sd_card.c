#include <string.h>
#include <sys/unistd.h>
#include <sys/stat.h>
#include "esp_vfs_fat.h"
#include "sdmmc_cmd.h"

#define EXAMPLE_MAX_CHAR_SIZE 64

static const char *TAG = "SD_CARD";

#define MOUNT_POINT "/sdcard"

// Pin assignments of sd card module
#define PIN_NUM_CS GPIO_NUM_1

static esp_err_t sd_write_file(const char *path, char *data)
{
    ESP_LOGI(TAG, "Opening file %s", path);
    FILE *f = fopen(path, "w");
    if (f == NULL)
    {
        ESP_LOGE(TAG, "Failed to open file for writing");
        return ESP_FAIL;
    }
    fprintf(f, data);
    fclose(f);
    ESP_LOGI(TAG, "File written");

    return ESP_OK;
}

static esp_err_t sd_read_file(const char *path)
{
    ESP_LOGI(TAG, "Reading file %s", path);
    FILE *f = fopen(path, "r");
    if (f == NULL)
    {
        ESP_LOGE(TAG, "Failed to open file for reading");
        return ESP_FAIL;
    }
    char line[EXAMPLE_MAX_CHAR_SIZE];
    fgets(line, sizeof(line), f);
    fclose(f);

    // strip newline
    char *pos = strchr(line, '\n');
    if (pos)
    {
        *pos = '\0';
    }
    ESP_LOGI(TAG, "Read from file: '%s'", line);

    return ESP_OK;
}

void unmount_sdcard(sdmmc_card_t *card)
{
    if (card == NULL)
    {
        ESP_LOGW(TAG, "Cannot unmount provided card, card is NULL");
        return;
    }

    // All done, unmount partition and disable SPI peripheral
    esp_err_t ret = esp_vfs_fat_sdcard_unmount(MOUNT_POINT, card);
    if (ret != ESP_OK)
    {
        ESP_LOGW(TAG, "Failed to unmount filesystem. %s", esp_err_to_name(ret));
        return;
    }
    ESP_LOGD(TAG, "Card unmounted");
}

esp_err_t init_sdcard(const spi_bus_config_t *bus_cfg, sdmmc_card_t **card)
{
    esp_err_t ret;

    esp_vfs_fat_sdmmc_mount_config_t mount_config = {
        .format_if_mount_failed = false,
        .max_files = 5,
        .allocation_unit_size = 16 * 1024};

    const char mount_point[] = MOUNT_POINT;
    ESP_LOGI(TAG, "Initializing SD card");

    ESP_LOGI(TAG, "Using SPI peripheral");

    sdmmc_host_t host = SDSPI_HOST_DEFAULT();

    ret = spi_bus_initialize(host.slot, bus_cfg, SDSPI_DEFAULT_DMA);
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "Failed to initialize bus.");
        return ret;
    }

    sdspi_device_config_t slot_config = SDSPI_DEVICE_CONFIG_DEFAULT();
    slot_config.gpio_cs = PIN_NUM_CS;
    slot_config.host_id = host.slot;

    ESP_LOGI(TAG, "Mounting filesystem");
    ret = esp_vfs_fat_sdspi_mount(mount_point, &host, &slot_config, &mount_config, card);

    if (ret != ESP_OK)
    {
        if (ret == ESP_FAIL)
        {
            ESP_LOGE(TAG, "Failed to mount filesystem. "
                          "If you want the card to be formatted, set the CONFIG_EXAMPLE_FORMAT_IF_MOUNT_FAILED menuconfig option.");
        }
        else
        {
            ESP_LOGE(TAG, "Failed to initialize the card (%s). "
                          "Make sure SD card lines have pull-up resistors in place.",
                     esp_err_to_name(ret));
        }
        return ret;
    }
    ESP_LOGI(TAG, "Filesystem mounted successfully");

    // Card has been initialized, print its properties
    sdmmc_card_print_info(stdout, *card);

    return ESP_OK;
}

//     // Use POSIX and C standard library functions to work with files.

//     // First create a file.
//     const char *file_hello = MOUNT_POINT "/hello.txt";
//     char data[EXAMPLE_MAX_CHAR_SIZE];
//     snprintf(data, EXAMPLE_MAX_CHAR_SIZE, "%s %s!\n", "Hello", card->cid.name);
//     ret = sd_write_file(file_hello, data);
//     if (ret != ESP_OK)
//     {
//         return;
//     }

//     const char *file_foo = MOUNT_POINT "/foo.txt";

//     // Check if destination file exists before renaming
//     struct stat st;
//     if (stat(file_foo, &st) == 0)
//     {
//         // Delete it if it exists
//         unlink(file_foo);
//     }

//     // Rename original file
//     ESP_LOGI(TAG, "Renaming file %s to %s", file_hello, file_foo);
//     if (rename(file_hello, file_foo) != 0)
//     {
//         ESP_LOGE(TAG, "Rename failed");
//         return;
//     }

//     ret = sd_read_file(file_foo);
//     if (ret != ESP_OK)
//     {
//         return;
//     }

//     // Format FATFS
// #ifdef CONFIG_EXAMPLE_FORMAT_SD_CARD
//     ret = esp_vfs_fat_sdcard_format(mount_point, card);
//     if (ret != ESP_OK)
//     {
//         ESP_LOGE(TAG, "Failed to format FATFS (%s)", esp_err_to_name(ret));
//         return;
//     }

//     if (stat(file_foo, &st) == 0)
//     {
//         ESP_LOGI(TAG, "file still exists");
//         return;
//     }
//     else
//     {
//         ESP_LOGI(TAG, "file doesnt exist, format done");
//     }
// #endif // CONFIG_EXAMPLE_FORMAT_SD_CARD

//     const char *file_nihao = MOUNT_POINT "/nihao.txt";
//     memset(data, 0, EXAMPLE_MAX_CHAR_SIZE);
//     snprintf(data, EXAMPLE_MAX_CHAR_SIZE, "%s %s!\n", "Nihao", card->cid.name);
//     ret = sd_write_file(file_nihao, data);
//     if (ret != ESP_OK)
//     {
//         return;
//     }

//     // Open file for reading
//     ret = sd_read_file(file_nihao);
//     if (ret != ESP_OK)
//     {
//         return;
//     }