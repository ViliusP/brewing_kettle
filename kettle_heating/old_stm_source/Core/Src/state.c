#include "state.h"
#include <float.h>
#include <math.h>

app_state_t app_state_init(void) {
    app_state_t state = {
        .heater_status = HEATER_IDLE,
        .target_temp = NAN,
        .current_temp = NAN,
    };
    return state;
}