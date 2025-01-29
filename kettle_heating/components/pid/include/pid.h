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
    float output_high;       // Relay high output (e.g., 100%)
    float output_low;        // Relay low output (e.g., 0%)
    float hysteresis;        // Hysteresis band (to avoid relay chatter)
    float setpoint;          // Desired setpoint
    float sample_time_sec;   // Tuning loop interval
    float Ku;                // Ultimate gain (from Ziegler-Nichols)
    float Tu;                // Ultimate period (seconds)
} pid_auto_tune_t;

void pid_init(pid_controller_t *pid, float Kp, float Ki, float Kd, float setpoint, float sample_time, float output_min, float output_max);
float pid_update(pid_controller_t *pid, float process_variable);

#endif // PID_H_