#include "esp_log.h"
#include "esp_check.h"
#include "pid.h"
#include <stdbool.h>
#include <math.h>
#include "freertos/FreeRTOS.h"

static const char *TAG = "PID";

void pid_init(pid_controller_t *pid, float Kp, float Ki, float Kd, float setpoint, float sample_time_sec, float output_min, float output_max)
{
    pid->Kp = Kp;
    pid->Ki = Ki;
    pid->Kd = Kd;
    pid->setpoint = setpoint;
    pid->integral = 0.0f;
    pid->prev_error = 0.0f;
    pid->output_min = output_min;
    pid->output_max = output_max;
    pid->sample_time_sec = sample_time_sec;
    pid->integral_anti_windup=0.1f;
}


void pid_update_setpoint(pid_controller_t *pid, float setpoint)
{
    pid->setpoint = setpoint;
}

float pid_update(pid_controller_t *pid, float process_variable)
{
    float error = pid->setpoint - process_variable;

    // Proportional term
    float proportional = pid->Kp * error;

    // Integral term (before clamping)
    pid->integral += error * pid->sample_time_sec;
    float integral = pid->Ki * pid->integral;

    // Derivative term
    float derivative = pid->Kd * (error - pid->prev_error) / pid->sample_time_sec;

    // Calculate raw output
    float output = proportional + integral + derivative;
    pid->last_output = output; // Store unclamped value

    // Apply clamping
    output = fmaxf(pid->output_min, fminf(output, pid->output_max));

    // Anti-windup (back-calculation)
    pid->integral += (output - pid->last_output) * pid->integral_anti_windup;

    pid->prev_error = error;
    return output;
}

void apply_ziegler_nichols(pid_controller_t *pid, pid_auto_tune_t *tuner)
{
    pid->Kp = fmaxf(0.6f * tuner->Ku, 0);
    pid->Ki = fmaxf(1.2f * tuner->Ku / tuner->Tu, 0);
    pid->Kd = fmaxf(0.075f * tuner->Ku * tuner->Tu, 0);
}

void pid_auto_tune_init(pid_auto_tune_t *tuner)
{
    tuner->relay_state = false;
    tuner->last_pv = 0.0f;
    tuner->peak_count = 0;
    tuner->peak_times[0] = 0.0f;
    tuner->peak_times[1] = 0.0f;
    tuner->amplitude_sum = 0.0f;
    tuner->slope_sign = 0;
    tuner->tuning_complete = false;
    tuner->Ku = 0.0f;
    tuner->Tu = 0.0f;
}

void pid_auto_tune(pid_auto_tune_t *tuner, float process_variable)
{
    // Hysteresis-based relay control
    if (process_variable > tuner->setpoint + tuner->hysteresis)
    {
        tuner->relay_state = false;
    }
    else if (process_variable < tuner->setpoint - tuner->hysteresis)
    {
        tuner->relay_state = true;
    }

    // Apply relay output
    tuner->output = tuner->relay_state ? tuner->output_high : tuner->output_low;

    // Slope detection for peak finding
    const float epsilon = 0.001f; // Noise threshold
    int new_slope = (process_variable - tuner->last_pv > epsilon) ? 1 : (process_variable - tuner->last_pv < -epsilon) ? -1
                                                                                                                       : 0;

    // Detect slope direction changes (peaks/valleys)
    if (new_slope != tuner->slope_sign && new_slope != 0)
    {
        // Valid peak detection requires crossing the setpoint
        if ((tuner->slope_sign == 1 && process_variable > tuner->setpoint) ||
            (tuner->slope_sign == -1 && process_variable < tuner->setpoint))
        {
            if (tuner->peak_count < 2)
            {
                const float current_time = xTaskGetTickCount() * portTICK_PERIOD_MS / 1000.0f;
                // Store peak time and amplitude
                tuner->peak_times[tuner->peak_count] = current_time;
                tuner->amplitude_sum += fabsf(process_variable - tuner->setpoint);
                tuner->peak_count++;
                ESP_LOGI("AUTO_TUNE", "Peak %lu detected at %.2f sec (PV: %.2f)",
                         tuner->peak_count, current_time, process_variable);
            }
        }
        tuner->slope_sign = new_slope;
    }

    // Calculate Ku and Tu after detecting 2 full oscillations
    if (tuner->peak_count >= 2 && !tuner->tuning_complete)
    {
        tuner->Tu = tuner->peak_times[1] - tuner->peak_times[0];
        const float avg_amplitude = tuner->amplitude_sum / 2.0f;
        // Ziegler-Nichols formula for relay tuning
        tuner->Ku = (4.0f * (tuner->output_high - tuner->output_low)) / (M_PI * avg_amplitude);
        ESP_LOGI("AUTO_TUNE", "Tuning complete: Ku=%.2f, Tu=%.2f", tuner->Ku, tuner->Tu);
        tuner->tuning_complete = true;
    }
    tuner->last_pv = process_variable;
}
