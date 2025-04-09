#include "uart_communication.h"
#include "uart_messaging.h"
#include "configuration.h"
#include "esp_log.h"
#include "temperature_sensor.h"
#include "state.h"
#include "pid.h"
#include "peripherals.h"
#include "math.h"
#include "float.h"

static const char *TAG = "MAIN";

// Configuration constants
static const uint32_t AUTOTUNE_DURATION_MS = 10 * 60 * 1000;
static const float AUTOTUNE_HYSTERESIS = 1.0f;
static const float AUTOTUNE_SETPOINT = 95.0f;
static const float AUTOTUNE_OUTPUT_HIGH = 100.0f;
static const float AUTOTUNE_OUTPUT_LOW = 0.0f;
static const TickType_t PID_SAMPLE_TIME_TICKS = pdMS_TO_TICKS(1000); // 1 second sample time

// Function prototypes
static void update_ssr_power(float new_power, float *current_power, app_state_t *state);
static void handle_manual_mode(app_state_t *state, float *current_ssr_power);
static void handle_pid_mode(pid_controller_t *pid, app_state_t *state, float *current_ssr_power);
static void handle_idle_mode(app_state_t *state, float *current_ssr_power);
static void handle_waiting_configuration_mode(app_state_t *state, pid_controller_t *pid);
static void handle_autotune_mode(pid_controller_t *pid, pid_auto_tune_t *tuner,
                                 app_state_t *state, bool *auto_tune_in_progress,
                                 TickType_t *tune_start_time);

void app_main(void)
{
    ESP_LOGI(TAG, "Hello, World!");

    app_state_t app_state = init_state();
    float current_ssr_power = 0.0f;
    bool auto_tune_in_progress = false;
    TickType_t tune_start_time = 0;

    // ================ SSR ====================================
    init_ssr(SSR_GPIO);
    // =========================================================

    // ================ Temperature Sensor ===================================
    // TODO: Check if the DS18B20 is connected and send a error message if not.
    ds18b20_device_handle_t ds18b20_handle = initialize_temperature_sensor();
    ds18b20_set_resolution(ds18b20_handle, DS18B20_RESOLUTION_12B);
    // =======================================================================

    // ================ UART ====================================
    rx_task_callback_t uart_message_handler = init_uart_message_handler(&app_state);
    initialize_uart(uart_config, UART_TX_PIN, UART_RX_PIN);
    start_uart_task(uart_message_handler);
    // ==========================================================

    // ================ PID ===================================
    pid_controller_t pid;
    pid_auto_tune_t tuner = {
        .output_high = AUTOTUNE_OUTPUT_HIGH,
        .output_low = AUTOTUNE_OUTPUT_LOW,
        .hysteresis = AUTOTUNE_HYSTERESIS,
        .setpoint = AUTOTUNE_SETPOINT,
        .output = 0.0f,
    };
    while (1)
    {

        esp_err_t temp_read_err = get_temperature(ds18b20_handle, &app_state.current_temp);

        if (temp_read_err == ESP_OK)
        {
            uart_send_state(app_state);
        }
        else
        {
            ESP_LOGW(TAG, "Failed to read temperature");
        }

        // State machine
        switch (app_state.status)
        {
        case HEATER_STATUS_WAITING_CONFIG:
            handle_waiting_configuration_mode(&app_state, &pid);
            break;
        case HEATER_STATUS_HEATING_MANUAL:
            handle_manual_mode(&app_state, &current_ssr_power);
            break;

        case HEATER_STATUS_HEATING_PID:
            handle_pid_mode(&pid, &app_state, &current_ssr_power);
            break;

        case HEATER_STATUS_AUTOTUNE_PID:
            handle_autotune_mode(&pid, &tuner, &app_state,
                                 &auto_tune_in_progress, &tune_start_time);
            break;

        case HEATER_STATUS_IDLE:
        case HEATER_STATUS_ERROR:
        case HEATER_STATUS_UNKNOWN:
            handle_idle_mode(&app_state, &current_ssr_power);
            break;

        default:
            ESP_LOGW(TAG, "Unknown state: %d", app_state.status);
            app_state.status = HEATER_STATUS_UNKNOWN;
            break;
        }

        vTaskDelay(PID_SAMPLE_TIME_TICKS);
    }
}

static void update_ssr_power(float new_power, float *current_power, app_state_t *state)
{
    if (fabsf(new_power - *current_power) > FLT_EPSILON)
    {
        esp_err_t err = set_ssr_duty(new_power);
        if (err == ESP_OK)
        {
            *current_power = new_power;
            state->power = new_power;
        }
        else
        {
            ESP_LOGW(TAG, "SSR update failed: %s", esp_err_to_name(err));
        }
    }
}

static void handle_manual_mode(app_state_t *state, float *current_ssr_power)
{
    update_ssr_power(state->requested_power, current_ssr_power, state);
    ESP_LOGI(TAG, "| MANUAL | Temp: %.2f°C, Target: %.2f°C, Power: %.2f%%",
             state->current_temp, state->target_temp, state->power);
}

static void handle_pid_mode(pid_controller_t *pid, app_state_t *state, float *current_ssr_power)
{
    if (pid->Kp != state->pid_constants->proportional || pid->Ki != state->pid_constants->integral ||
        pid->Kd != state->pid_constants->derivative)
    {
        ESP_LOGI(TAG, "PID coefficients changed, reinitializing PID controller");
        pid_init(pid, state->pid_constants->proportional, state->pid_constants->integral,
                 state->pid_constants->derivative, 0.0f, 1.0f, 0.0f, 100.0f);
    }

    if (state->target_temp > 0.0f)
    {
        pid_update_setpoint(pid, state->target_temp);
        float pid_power = pid_update(pid, state->current_temp);
        update_ssr_power(pid_power, current_ssr_power, state);
    }
    ESP_LOGI(TAG, "| PID | Temp: %.2f°C, Target: %.2f°C, Power: %.2f%%",
             state->current_temp, state->target_temp, state->power);
}

static void handle_idle_mode(app_state_t *state, float *current_ssr_power)
{
    update_ssr_power(0.0f, current_ssr_power, state);
    ESP_LOGI(TAG, "| IDLE (%d) | Temp: %.2f°C, Power: %.2f%%",
             state->status, state->current_temp, state->power);
}

static void handle_autotune_mode(pid_controller_t *pid, pid_auto_tune_t *tuner,
                                 app_state_t *state, bool *auto_tune_in_progress,
                                 TickType_t *tune_start_time)
{
    if (!*auto_tune_in_progress)
    {
        ESP_LOGI(TAG, "Starting PID auto-tune for %lu seconds", AUTOTUNE_DURATION_MS / 1000);
        *auto_tune_in_progress = true;
        *tune_start_time = xTaskGetTickCount();
        pid_auto_tune_init(tuner);
    }

    pid_auto_tune(tuner, state->current_temp);
    update_ssr_power(tuner->output, &state->power, state);
    state->target_temp = tuner->setpoint;

    TickType_t elapsed_ticks = xTaskGetTickCount() - *tune_start_time;
    if ((elapsed_ticks > pdMS_TO_TICKS(AUTOTUNE_DURATION_MS)) || tuner->tuning_complete)
    {
        apply_ziegler_nichols(pid, tuner);
        state->status = HEATER_STATUS_HEATING_PID; // Transition to PID mode
        *auto_tune_in_progress = false;
        ESP_LOGI(TAG, "Auto-tune complete. New PID: Kp=%.2f, Ki=%.2f, Kd=%.2f",
                 pid->Kp, pid->Ki, pid->Kd);
    }

    ESP_LOGI(TAG, "| AUTOTUNE | Remaining: %lus | Temp: %.2f°C, Power: %.2f%%",
             (AUTOTUNE_DURATION_MS - pdTICKS_TO_MS(elapsed_ticks)) / 1000,
             state->current_temp, state->power);
}

static void handle_waiting_configuration_mode(app_state_t *state, pid_controller_t *pid)
{
    ESP_LOGI(TAG, "| WAITING CONFIG | Temp: %.2f°C, Power: %.2f%%",
             state->current_temp, state->power);
    if (state->pid_constants != NULL)
    {
        pid_init(pid, state->pid_constants->proportional, state->pid_constants->integral, state->pid_constants->derivative, 0.0f, 1.0f, 0.0f, 100.0f);
        // Configuration received, transition to idle.
        state->status = HEATER_STATUS_IDLE;
        ESP_LOGI(TAG, "Configuration loaded!");
    }
}