#include "nvs.h"
#include "nvs_flash.h"
#include "common_types.h"
#include "esp_log.h"

#define PID_NAMESPACE "pid_config"
#define PID_KP_KEY "kp"
#define PID_KI_KEY "ki"
#define PID_KD_KEY "kd"

const pid_constants_t PID_DEFAULTS = {1.0f, 0.0f, 0.0f};

esp_err_t save_pid_settings(const pid_constants_t *pid)
{
    nvs_handle_t handle;
    esp_err_t err;

    err = nvs_open(PID_NAMESPACE, NVS_READWRITE, &handle);
    if (err != ESP_OK)
        return err;

    // Store each value as U32 (float32 and uint32 have same size)
    err |= nvs_set_u32(handle, PID_KP_KEY, *(uint32_t *)&pid->proportional);
    err |= nvs_set_u32(handle, PID_KI_KEY, *(uint32_t *)&pid->integral);
    err |= nvs_set_u32(handle, PID_KD_KEY, *(uint32_t *)&pid->derivative);

    if (err == ESP_OK)
    {
        err = nvs_commit(handle);
    }

    nvs_close(handle);
    return err;
}

esp_err_t load_pid_settings(pid_constants_t *pid)
{
    nvs_handle_t handle;
    esp_err_t err;

    *pid = PID_DEFAULTS; // Start with defaults

    err = nvs_open(PID_NAMESPACE, NVS_READONLY, &handle);
    if (err != ESP_OK)
        return err;

    // Try to load each value, keep default if not found
    nvs_get_u32(handle, PID_KP_KEY, (uint32_t *)&pid->proportional);
    nvs_get_u32(handle, PID_KI_KEY, (uint32_t *)&pid->integral);
    nvs_get_u32(handle, PID_KD_KEY, (uint32_t *)&pid->derivative);

    nvs_close(handle);
    return ESP_OK;
}