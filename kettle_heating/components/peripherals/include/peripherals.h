#ifndef PERIPHERALS_H_
#define PERIPHERALS_H_

// PWM Configuration
#define LEDC_TIMER LEDC_TIMER_0
#define LEDC_MODE LEDC_LOW_SPEED_MODE
#define LEDC_CHANNEL LEDC_CHANNEL_0
#define LEDC_RESOLUTION LEDC_TIMER_13_BIT    // 8192 steps
#define PWM_FREQUENCY 4000                   // 1Hz (for AC SSR) or higher for DC SSR
#define MAX_DUTY (1 << LEDC_RESOLUTION) - 1; // 8191

void init_ssr(int gpio_num);

#endif // PERIPHERALS_H_