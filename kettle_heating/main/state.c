#include <float.h>
#include "state.h"

app_state_t init_state()
{
    app_state_t state = {
        .heater_state = HEATER_STATE_IDLE,
        .current_temp = FLT_MIN,
        .target_temp = FLT_MIN,
    };
    return state;
}
