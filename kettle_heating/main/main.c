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
const uint16_t AUTOTUNE_DURATION = 20000;


void app_main(void)
{
    ESP_LOGI(TAG, "Hello, World!");

    app_state_t app_state = init_state();
    float current_ssr_power = 0.0f;
    bool auto_tune_in_progress = false;
    uint32_t tune_start_time = 0;
    // ================ SSR ====================================
    init_ssr(SSR_GPIO);
    // =========================================================

    // ================ Temperature Sensor ===================================
    ds18b20_device_handle_t ds18b20_handle = initialize_temperature_sensor();
    ds18b20_set_resolution(ds18b20_handle, DS18B20_RESOLUTION_12B);
    // =======================================================================

    // ================ UART ====================================
    rx_task_callback_t uart_message_handler = init_uart_message_handler(&app_state);
    initialize_uart(uart_config, UART_TX_PIN, UART_RX_PIN);
    start_uart_task(uart_message_handler);
    uart_send_state(app_state);
    // ==========================================================

    // ================ PID ===================================
    pid_controller_t pid;
    pid_auto_tune_t tuner = {
        .output_high = 100.0f,
        .output_low = 0.0f,
        .hysteresis = M_PI,
        .setpoint = 50.0f,
        .sample_time_sec = 1.0f,
        .output = 0.0f,
    };

    pid_init(&pid, pid.Kp, pid.Ki, pid.Kd, tuner.setpoint, 0.1f, 0.0f, 100.0f);
    
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
            if(app_state.requested_power != current_ssr_power) {
                esp_err_t err = set_ssr_duty(app_state.requested_power);
                if(err == ESP_OK) {
                    current_ssr_power = app_state.requested_power;
                    app_state.power = app_state.requested_power;
                } else {
                    ESP_LOGW(TAG, "Failed to set SSR duty: %s", esp_err_to_name(err));
                }
            }
            ESP_LOGI(TAG, "| manual | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty %lu", app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }

        if (app_state.status == HEATER_STATUS_HEATING_PID)
        {
            float pid_power = 0; // pid_update(&pid, app_state.current_temp);
            app_state.power = pid_power;
            esp_err_t err = set_ssr_duty(pid_power);
            ESP_LOGI(TAG, "| pid | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu", app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }

        if (app_state.status == HEATER_STATUS_IDLE || app_state.status == HEATER_STATUS_ERROR || app_state.status == HEATER_STATUS_UNKNOWN)
        {
            if(current_ssr_power != 0.0f) {
                esp_err_t err = set_ssr_duty(0.0f);
                if(err == ESP_OK) {
                    current_ssr_power = 0.0f;
                    app_state.power = current_ssr_power;
                } else {
                    ESP_LOGW(TAG, "Failed to set SSR duty: %s", esp_err_to_name(err));
                }
            }
            ESP_LOGI(TAG, "| idle (%d) | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu", app_state.status, app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }

        if (app_state.status == HEATER_STATUS_AUTOTUNE_PID) {
            if(!auto_tune_in_progress) {
                ESP_LOGI("TUNE", "Starting auto-tuning...");
                auto_tune_in_progress = true;
                uint32_t tune_start_time = xTaskGetTickCount();
            }
            pid_auto_tune(&tuner, app_state.current_temp);
            set_ssr_duty(tuner.output);

            if (xTaskGetTickCount() - tune_start_time > pdMS_TO_TICKS(AUTOTUNE_DURATION)) {
                apply_ziegler_nichols(&pid, &tuner);
                app_state.status = HEATER_STATUS_IDLE;
                auto_tune_in_progress = false;
            }
        } else {
            auto_tune_in_progress = false;
        }
        
        vTaskDelay(pdMS_TO_TICKS(pid.sample_time_sec * 1000));
    }
}
