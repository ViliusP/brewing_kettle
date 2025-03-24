#include <float.h>
#include "state.h"
#include "nvs_flash.h"
#include "esp_log.h"

static const char *TAG = "STATE";

app_state_t init_state()
{
    // esp_err_t err = nvs_flash_init();
    // if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND)
    // {
    //     // NVS partition was truncated and needs to be erased
    //     // Retry nvs_flash_init
    //     ESP_ERROR_CHECK(nvs_flash_erase());
    //     err = nvs_flash_init();
    // }

    // ESP_LOGI(TAG, "Opening Non-Volatile Storage (NVS) handle...");
    // nvs_handle_t my_handle;
    // err = nvs_open("storage", NVS_READWRITE, &my_handle);
    // if (err != ESP_OK)
    // {
    //     ESP_LOGW(TAG, "Error (%s) opening NVS handle!\n", esp_err_to_name(err));
    // }
    // else
    // {
    //     ESP_LOGI(TAG, "Done. Reading persistent data from NVS... ");
    //     int32_t restart_counter = 0; // value will default to 0, if not set yet in NVS
    //     err = nvs_get_i32(my_handle, "restart_counter", &restart_counter);
    //     switch (err)
    //     {
    //     case ESP_OK:
    //         printf("Done\n");
    //         printf("Restart counter = %" PRIu32 "\n", restart_counter);
    //         break;
    //     case ESP_ERR_NVS_NOT_FOUND:
    //         ESP_LOGI(TAG, "The value is not initialized yet!");
    //         break;
    //     default:
    //         ESP_LOGW(TAG, "Error (%s) reading!", esp_err_to_name(err));
    //     }

    //     // Write
    //     printf("Updating restart counter in NVS ... ");
    //     restart_counter++;
    //     err = nvs_set_i32(my_handle, "restart_counter", restart_counter);
    //     printf((err != ESP_OK) ? "Failed!\n" : "Done\n");

    //     // Commit written value.
    //     // After setting any values, nvs_commit() must be called to ensure changes are written
    //     // to flash storage. Implementations may write to storage at other times,
    //     // but this is not guaranteed.
    //     printf("Committing updates in NVS ... ");
    //     err = nvs_commit(my_handle);
    //     printf((err != ESP_OK) ? "Failed!\n" : "Done\n");

    //     // Close
    //     nvs_close(my_handle);
    // }

    app_state_t state = {
        .status = HEATER_STATUS_IDLE,
        .current_temp = ABSOLUTE_ZERO,
        .target_temp = ABSOLUTE_ZERO,
        .power = 0,
        .requested_power = 0,
    };
    return state;
}
