#include <float.h>
#include "state.h"
#include "nvs_flash.h"
#include "esp_log.h"

static const char *TAG = "STATE";

app_state_t init_state()
{
    app_state_t state = {
        .status = HEATER_STATUS_WAITING_CONFIG,
        .current_temp = ABSOLUTE_ZERO,
        .target_temp = ABSOLUTE_ZERO,
        .power = 0,
        .pid_constants = NULL,
        .requested_power = 0,
    };
    return state;
}
