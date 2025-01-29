#include <float.h>
#include "state.h"

app_state_t init_state()
{
    app_state_t state = {
        .heater_state = HEATER_STATE_IDLE,
        .current_temp = ABSOLUTE_ZERO,
        .target_temp = ABSOLUTE_ZERO,
    };
    return state;
}
