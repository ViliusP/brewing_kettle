#include "esp_log.h"
#include "esp_check.h"
#include "peripherals.h"
#include "driver/ledc.h"

static const char *TAG = "PERIPHERALS";

esp_err_t set_ssr_duty(float duty_percent)
{
    // Validate input range
    duty_percent = (duty_percent < 0.0f) ? 0.0f : (duty_percent > 100.0f) ? 100.0f
                                                                          : duty_percent;

    // Calculate absolute duty value
    const uint32_t max_duty = (1 << ((uint32_t)LEDC_RESOLUTION)) - 1;
    
    uint32_t duty = (uint32_t)((duty_percent / 100.0f) * max_duty);

    // Set and activate new duty cycle
    esp_err_t err = ledc_set_duty(LEDC_MODE, LEDC_CHANNEL, duty);
    if (err != ESP_OK)
    {
        ESP_LOGE(TAG, "Error occured while setting LEDC duty: %s", esp_err_to_name(err));
        return err;
    }
    err = ledc_update_duty(LEDC_MODE, LEDC_CHANNEL);
    if (err != ESP_OK)
    {
        ESP_LOGE(TAG, "Error occured while updating LEDC duty: %s", esp_err_to_name(err));
    }
    return err;
}

uint32_t get_ssr_duty(void) {
    uint32_t duty = ledc_get_duty(LEDC_MODE, LEDC_CHANNEL);
    return duty;
}

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