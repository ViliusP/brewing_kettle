#include "uart_communication.h"
#include "uart_messaging.h"
#include "configuration.h"
#include "esp_log.h"
#include "temperature_sensor.h"
#include "state.h"
#include "pid.h"
#include "peripherals.h"

static const char *TAG = "MAIN";

void app_main(void)
{
    ESP_LOGI(TAG, "Hello, World!");

    app_state_t app_state = init_state();
    float current_ssr_power = 0.0f;
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
        .hysteresis = 2.0f,
        .setpoint = 50.0f,
        .sample_time_sec = 1.0f,
        .output = 0.0f,
    };

    // // Step 1: Auto-tuning
    // ESP_LOGI("TUNE", "Starting auto-tuning...");
    // uint32_t tune_start_time = xTaskGetTickCount();
    // uint32_t tune_duration_ms = 20000; // 20 seconds
    // while (xTaskGetTickCount() - tune_start_time < pdMS_TO_TICKS(tune_duration_ms))
    // {
    //     float pv;
    //     get_temperature(ds18b20_handle, &pv); // Takes 800 ms
    //     pid_auto_tune(&tuner, pv);
    //     set_heater_duty(tuner.output);
    // }
    // // Step 2: Apply Ziegler-Nichols gains
    // apply_ziegler_nichols(&pid, &tuner);
    pid_init(&pid, pid.Kp, pid.Ki, pid.Kd, tuner.setpoint, 0.1f, 0.0f, 100.0f);

    // // Step 3: Run PID with anti-windup
    // ESP_LOGI("PID", "Switching to PID control...");
    // =======================================================
    
    while (1)
    {
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
            ESP_LOGI(TAG, "| manual | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu", app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }

        if (app_state.status == HEATER_STATUS_HEATING_PID)
        {
            float pid_power = 0; // pid_update(&pid, app_state.current_temp);
            app_state.power = pid_power;
            esp_err_t err = set_ssr_duty(pid_power);
            ESP_LOGI(TAG, "| pid | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu", app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }

        if (app_state.status == HEATER_STATUS_IDLE)
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
            ESP_LOGI(TAG, "| idle | current_temp: %.2f, target_temp: %.2f, power: %.2f%%, duty: %lu:", app_state.current_temp, app_state.target_temp, app_state.power, get_ssr_duty());
        }

        esp_err_t ret = get_temperature(ds18b20_handle, &app_state.current_temp);

        if (ret == ESP_OK)
        {
            uart_send_state(app_state);
        }
        else
        {
            ESP_LOGW(TAG, "Failed to read temperature");
        }
        vTaskDelay(pdMS_TO_TICKS(pid.sample_time_sec * 2000));
    }
}
