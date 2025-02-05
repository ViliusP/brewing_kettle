#include "esp_log.h"
#include "esp_check.h"
#include "peripherals.h"
#include "driver/ledc.h"

static const char *TAG = "PERIPHERALS";

void init_ssr(int gpio_num)
{
    // Configure LEDC Timer
    ledc_timer_config_t timer_conf = {
        .speed_mode = LEDC_MODE,
        .duty_resolution = LEDC_RESOLUTION,
        .timer_num = LEDC_TIMER,
        .freq_hz = PWM_FREQUENCY,
        .clk_cfg = LEDC_AUTO_CLK};

    ledc_timer_config(&timer_conf);


    // Configure LEDC Channel
    ledc_channel_config_t channel_conf = {
        .speed_mode = LEDC_MODE,
        .channel = LEDC_CHANNEL,
        .timer_sel = LEDC_TIMER,
        .intr_type = LEDC_INTR_DISABLE,
        .gpio_num = gpio_num,
        .duty = 0, // Initial duty cycle = 0%
        .hpoint = 0};
        
    ledc_channel_config(&channel_conf);
}