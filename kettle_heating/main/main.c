#include "uart_communication.h"
#include "uart_messaging.h"
#include "configuration.h"
#include "esp_log.h"
#include "temperature_sensor.h"
#include "state.h"
#include "pid.h"
#include "peripherals.h"
#include "math.h"

static const char *TAG = "MAIN";

const uint32_t AUTOTUNE_DURATION_MS = 10 * 60 * 1000;

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
        .output_high = 100.0f,
        .output_low = 0.0f,
        .hysteresis = 1.0f,
        .setpoint = 95.0f,
        .output = 0.0f,
    };
    // 1. Kp=25.0f, Ki=20.0f, Kd=0.0f | 2.5 celsius overshoot (up)
    // 2. Kp=25.0f, Ki=15.0f, Kd=0.5f | 2.2 celsuis overshoot (up)
    // 3. Kp=22.5f, Ki=15.0f, Kd=0.5f | 2.2 celsuis overshoot (up)
    // 4. Kp=22.5f, Ki=15.0f, Kd=0.0f | 2.2 celsuis overshoot (up)
    pid_init(&pid, 15.0f, 30.0f, 0.0f, tuner.setpoint, 1.0f, 0.0f, 100.0f);

    while (1)
    {

        esp_err_t ret = get_temperature(ds18b20_handle, &app_state.current_temp);

        if (ret == ESP_OK)
        {
            uart_send_state(app_state);
        }
        else
        {
            ESP_LOGW(TAG, "Failed to read temperature");
        }

        if (app_state.status == HEATER_STATUS_HEATING_MANUAL)
        {
            if (app_state.requested_power != current_ssr_power)
            {
                esp_err_t err = set_ssr_duty(app_state.requested_power);
                if (err == ESP_OK)
                {
                    current_ssr_power = app_state.requested_power;
                    app_state.power = app_state.requested_power;
                }
                else
                {
                    ESP_LOGW(TAG, "Failed to set SSR duty: %s", esp_err_to_name(err));
                }
            }
            ESP_LOGI(TAG, "| manual | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty %lu", app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }
        if (app_state.status == HEATER_STATUS_HEATING_PID)
        {
            if(app_state.target_temp > 0.0f)
            {
                pid_update_setpoint(&pid, app_state.target_temp);
                float pid_power = pid_update(&pid, app_state.current_temp);
                app_state.power = pid_power;
                current_ssr_power = pid_power;
                esp_err_t err = set_ssr_duty(pid_power);    
            }
            ESP_LOGI(TAG, "| pid | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu", app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());

        }

        if (app_state.status == HEATER_STATUS_IDLE || app_state.status == HEATER_STATUS_ERROR || app_state.status == HEATER_STATUS_UNKNOWN)
        {
            if (current_ssr_power != 0.0f)
            {
                esp_err_t err = set_ssr_duty(0.0f);
                if (err == ESP_OK)
                {
                    current_ssr_power = 0.0f;
                    app_state.target_temp = ABSOLUTE_ZERO;
                    app_state.power = current_ssr_power;
                }
                else
                {
                    ESP_LOGW(TAG, "Failed to set SSR duty: %s", esp_err_to_name(err));
                }
            }
            ESP_LOGI(TAG, "| idle (%d) | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu", app_state.status, app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }
        // EXPERIMENTAL
        if (app_state.status == HEATER_STATUS_AUTOTUNE_PID)
        {
            if (!auto_tune_in_progress)
            {
                ESP_LOGI("TUNE", "Starting auto-tuning for %lu seconds", AUTOTUNE_DURATION_MS / 1000);
                auto_tune_in_progress = true;
                tune_start_time = xTaskGetTickCount();
                pid_auto_tune_init(&tuner);
            }
            pid_auto_tune(&tuner, app_state.current_temp);
            set_ssr_duty(tuner.output);
            app_state.target_temp = tuner.setpoint;
            current_ssr_power = tuner.output;
            TickType_t current_tick = xTaskGetTickCount();
            TickType_t tick_diff = current_tick - tune_start_time;
            if (tick_diff > pdMS_TO_TICKS(AUTOTUNE_DURATION_MS) || tuner.tuning_complete)
            {
                apply_ziegler_nichols(&pid, &tuner);
                app_state.status = HEATER_STATUS_IDLE;
                auto_tune_in_progress = false;
                ESP_LOGI(TAG, "Auto-tune complete: Ku=%.2f, Tu=%.2f", tuner.Ku, tuner.Tu);
                ESP_LOGI(TAG, "PID gains: Kp=%.2f, Ki=%.2f, Kd=%.2f", pid.Kp, pid.Ki, pid.Kd);
            }
            ESP_LOGI(TAG, "| autotune (%lu) |  current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu", ((AUTOTUNE_DURATION_MS - pdTICKS_TO_MS(tick_diff)) / 1000), app_state.current_temp, tuner.setpoint, tuner.output, get_ssr_duty());
        }
        else
        {
            auto_tune_in_progress = false;
        }

        vTaskDelay(pdMS_TO_TICKS(pid.sample_time_sec * 1000));
    }
}
