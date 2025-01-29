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
}

float pid_update(pid_controller_t *pid, float process_variable)
{
    // Calculate error
    float error = pid->setpoint - process_variable;

    // Proportional term
    float proportional = pid->Kp * error;

    // Integral term (before clamping)
    pid->integral += error * pid->sample_time_sec;
    float integral = pid->Ki * pid->integral;

    // Derivative term
    float derivative = pid->Kd * (error - pid->prev_error) / pid->sample_time_sec;

    // Compute raw output (before clamping)
    pid->last_output = proportional + integral + derivative;

    // Clamp output and apply anti-windup
    float clamped_output = pid->last_output;
    if (clamped_output > pid->output_max)
    {
        clamped_output = pid->output_max;
    }
    else if (clamped_output < pid->output_min)
    {
        clamped_output = pid->output_min;
    }

    // Back-calculation anti-windup: Adjust integral term
    float output_diff = clamped_output - pid->last_output;
    pid->integral += pid->integral_anti_windup * output_diff;

    // Save previous error
    pid->prev_error = error;

    return clamped_output;
}

void apply_ziegler_nichols(pid_controller_t *pid, pid_auto_tune_t *tuner) {
    // Ziegler-Nichols PID tuning rules
    pid->Kp = 0.6f * tuner->Ku;
    pid->Ki = 1.2f * tuner->Ku / tuner->Tu;
    pid->Kd = 0.075f * tuner->Ku * tuner->Tu;
}


void pid_auto_tune(pid_auto_tune_t *tuner, float process_variable) {
    static bool relay_state = false;
    static float last_pv = 0.0f;
    static uint32_t peak_count = 0;
    static float peak_times[2] = {0};
    static float amplitude_sum = 0.0f;

    // Toggle relay based on process variable and hysteresis
    if (process_variable > tuner->setpoint + tuner->hysteresis) {
        relay_state = false;
    } else if (process_variable < tuner->setpoint - tuner->hysteresis) {
        relay_state = true;
    }

    // Apply relay output
    float output = relay_state ? tuner->output_high : tuner->output_low;

    // Detect peaks (simplified logic)
    if ((process_variable > last_pv && process_variable > tuner->setpoint) ||
        (process_variable < last_pv && process_variable < tuner->setpoint)) {
        if (peak_count < 2) {
            peak_times[peak_count] = xTaskGetTickCount() * portTICK_PERIOD_MS / 1000.0f;
            amplitude_sum += fabsf(process_variable - tuner->setpoint);  // Use fabsf for floats
            peak_count++;
        }
    }

    last_pv = process_variable;

    // Calculate Ku and Tu after 2 oscillations
    if (peak_count >= 2) {
        tuner->Tu = peak_times[1] - peak_times[0];
        float avg_amplitude = amplitude_sum / 2.0f;
        tuner->Ku = (4.0f * (tuner->output_high - tuner->output_low)) / (M_PI * avg_amplitude);
    }
}