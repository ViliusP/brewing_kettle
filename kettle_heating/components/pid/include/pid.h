#include <stdbool.h>
#ifndef PID_H_
#define PID_H_

typedef struct {
    // Existing PID parameters
    float Kp, Ki, Kd;
    float setpoint;
    float integral;
    float prev_error;
    float output_min;
    float output_max;
    float sample_time_sec;
    
    // Anti-windup parameters
    float integral_anti_windup;  // Back-calculation gain (e.g., 0.1)
    float last_output;           // Track unclamped output
} pid_controller_t;

typedef struct {
    // Configuration parameters
    float output_high;
    float output_low;
    float hysteresis;
    float setpoint;
    
    // Tuning results
    float Ku;
    float Tu;
    float output;
    
    // State variables (formerly static)
    bool relay_state;
    float last_pv;
    uint32_t peak_count;
    float peak_times[2];
    float amplitude_sum;
    int slope_sign;          // 1 = rising, -1 = falling
    bool tuning_complete;
} pid_auto_tune_t;

void pid_init(pid_controller_t *pid, float Kp, float Ki, float Kd, float setpoint, float sample_time, float output_min, float output_max);
float pid_update(pid_controller_t *pid, float process_variable);
void pid_update_setpoint(pid_controller_t *pid, float setpoint);
void apply_ziegler_nichols(pid_controller_t *pid, pid_auto_tune_t *tuner);
void pid_auto_tune_init(pid_auto_tune_t *tuner);
void pid_auto_tune(pid_auto_tune_t *tuner, float process_variable);

#endif // PID_H_