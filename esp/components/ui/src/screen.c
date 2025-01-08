
#include <stdio.h>
#include <unistd.h>
#include <sys/lock.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_timer.h"
#include "esp_lcd_panel_io.h"
#include "esp_lcd_panel_ops.h"
#include "esp_err.h"
#include "esp_log.h"
#include "driver/i2c_master.h"
#include "lvgl.h"

#if CONFIG_LCD_CONTROLLER_SH1107
#include "esp_lcd_sh1107.h"
#else
#include "esp_lcd_panel_vendor.h"
#endif

static const char *TAG = "SCREEN";

#define I2C_BUS_PORT  0

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////// Please update the following configuration according to your LCD spec //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define LCD_PIXEL_CLOCK_HZ    (400 * 1000)
#define PIN_NUM_SDA           6
#define PIN_NUM_SCL           7
#define PIN_NUM_RST           -1
#define I2C_HW_ADDR           0x3C

// The pixel number in horizontal and vertical
#define LCD_H_RES              128
#define LCD_V_RES              64

// Bit number used to represent command and parameter
#define LCD_CMD_BITS           8
#define LCD_PARAM_BITS         8

#define LVGL_TICK_PERIOD_MS    5
#define LVGL_TASK_STACK_SIZE   (16 * 1024)
#define LVGL_TASK_PRIORITY     2
#define LVGL_PALETTE_SIZE      8

// To use LV_COLOR_FORMAT_I1, we need an extra buffer to hold the converted data
static uint8_t oled_buffer[LCD_H_RES * LCD_V_RES / 8];
// LVGL library is not thread-safe, LVGL APIs will be called from different tasks, so use a mutex to protect it
static _lock_t lvgl_api_lock;

extern void create_ui(lv_disp_t *disp);

static bool notify_lvgl_flush_ready(esp_lcd_panel_io_handle_t io_panel, esp_lcd_panel_io_event_data_t *edata, void *user_ctx)
{
    lv_display_t *disp = (lv_display_t *)user_ctx;
    lv_display_flush_ready(disp);
    return false;
}

static void lvgl_flush_cb(lv_display_t *disp, const lv_area_t *area, uint8_t *px_map)
{
    esp_lcd_panel_handle_t panel_handle = lv_display_get_user_data(disp);

    // This is necessary because LVGL reserves 2 x 4 bytes in the buffer, as these are assumed to be used as a palette. Skip the palette here
    // More information about the monochrome, please refer to https://docs.lvgl.io/9.2/porting/display.html#monochrome-displays
    px_map += LVGL_PALETTE_SIZE;

    uint16_t hor_res = lv_display_get_physical_horizontal_resolution(disp);
    int x1 = area->x1;
    int x2 = area->x2;
    int y1 = area->y1;
    int y2 = area->y2;

    for (int y = y1; y <= y2; y++) {
        for (int x = x1; x <= x2; x++) {
            /* The order of bits is MSB first
                        MSB           LSB
               bits      7 6 5 4 3 2 1 0
               pixels    0 1 2 3 4 5 6 7
                        Left         Right
            */
            bool chroma_color = (px_map[(hor_res >> 3) * y  + (x >> 3)] & 1 << (7 - x % 8));

            /* Write to the buffer as required for the display.
            * It writes only 1-bit for monochrome displays mapped vertically.*/
            uint8_t *buf = oled_buffer + hor_res * (y >> 3) + (x);
            if (chroma_color) {
                (*buf) &= ~(1 << (y % 8));
            } else {
                (*buf) |= (1 << (y % 8));
            }
        }
    }
    // pass the draw buffer to the driver
    esp_lcd_panel_draw_bitmap(panel_handle, x1, y1, x2 + 1, y2 + 1, oled_buffer);
}

static void increase_lvgl_tick(void *arg)
{
    /* Tell LVGL how many milliseconds has elapsed */
    lv_tick_inc(LVGL_TICK_PERIOD_MS);
}

static void lvgl_port_task(void *arg)
{
    ESP_LOGI(TAG, "Starting LVGL task");
    uint32_t time_till_next_ms = 0;
    while (1) {
        _lock_acquire(&lvgl_api_lock);
        time_till_next_ms = lv_timer_handler();
        _lock_release(&lvgl_api_lock);
        usleep(1000 * time_till_next_ms);
    }
}


static esp_err_t initialize_i2c_bus(i2c_master_bus_handle_t *i2c_bus) {
    ESP_LOGI(TAG, "Initialize I2C bus");

    i2c_master_bus_config_t bus_config = {
        .clk_source = I2C_CLK_SRC_DEFAULT,
        .glitch_ignore_cnt = 7,
        .i2c_port = I2C_BUS_PORT,
        .sda_io_num = PIN_NUM_SDA,
        .scl_io_num = PIN_NUM_SCL,
        .flags.enable_internal_pullup = true,
    };
    return i2c_new_master_bus(&bus_config, i2c_bus);
}

static esp_err_t install_panel_io(i2c_master_bus_handle_t i2c_bus, esp_lcd_panel_io_handle_t *io_handle) {
    ESP_LOGI(TAG, "Install panel IO");

    esp_lcd_panel_io_i2c_config_t io_config = {
        .dev_addr = I2C_HW_ADDR,
        .scl_speed_hz = LCD_PIXEL_CLOCK_HZ,
        .control_phase_bytes = 1,
        .lcd_cmd_bits = LCD_CMD_BITS,
        .lcd_param_bits = LCD_CMD_BITS,
#if CONFIG_LCD_CONTROLLER_SSD1306
        .dc_bit_offset = 6,
#elif CONFIG_LCD_CONTROLLER_SH1107
        .dc_bit_offset = 0,
        .flags = {
            .disable_control_phase = 1,
        }
#endif
    };
    return esp_lcd_new_panel_io_i2c(i2c_bus, &io_config, io_handle);
}

static esp_err_t install_panel_driver(esp_lcd_panel_io_handle_t io_handle, esp_lcd_panel_handle_t *panel_handle) {
    ESP_LOGI(TAG, "Install panel driver");

    esp_lcd_panel_dev_config_t panel_config = {
        .bits_per_pixel = 1,
        .reset_gpio_num = PIN_NUM_RST,
    };

#if CONFIG_LCD_CONTROLLER_SSD1306
    esp_lcd_panel_ssd1306_config_t ssd1306_config = {
        .height = LCD_V_RES,
    };
    panel_config.vendor_config = &ssd1306_config;
    return esp_lcd_new_panel_ssd1306(io_handle, &panel_config, panel_handle);
#elif CONFIG_LCD_CONTROLLER_SH1107
    return esp_lcd_new_panel_sh1107(io_handle, &panel_config, panel_handle);
#endif
}

static esp_err_t initialize_lvgl(esp_lcd_panel_handle_t panel_handle, lv_display_t **display) {
    ESP_LOGI(TAG, "Initialize LVGL");

    lv_init();
    *display = lv_display_create(LCD_H_RES, LCD_V_RES);
    lv_display_set_user_data(*display, panel_handle);
    lv_display_set_color_format(*display, LV_COLOR_FORMAT_I1);

    size_t draw_buffer_sz = LCD_H_RES * LCD_V_RES / 8 + LVGL_PALETTE_SIZE;
    void *buf = heap_caps_calloc(1, draw_buffer_sz, MALLOC_CAP_INTERNAL | MALLOC_CAP_8BIT);
    assert(buf);

    lv_display_set_buffers(*display, buf, NULL, draw_buffer_sz, LV_DISPLAY_RENDER_MODE_FULL);
    lv_display_set_flush_cb(*display, lvgl_flush_cb);
    return ESP_OK;
}

static esp_err_t setup_lvgl_callbacks_and_timer(esp_lcd_panel_io_handle_t io_handle, lv_display_t *display) {
    ESP_LOGI(TAG, "Register io panel event callback and setup timer");
    const esp_lcd_panel_io_callbacks_t cbs = {
        .on_color_trans_done = notify_lvgl_flush_ready,
    };
    ESP_ERROR_CHECK(esp_lcd_panel_io_register_event_callbacks(io_handle, &cbs, display));

    const esp_timer_create_args_t lvgl_tick_timer_args = {
        .callback = &increase_lvgl_tick,
        .name = "lvgl_tick"
    };
    esp_timer_handle_t lvgl_tick_timer = NULL;
    ESP_ERROR_CHECK(esp_timer_create(&lvgl_tick_timer_args, &lvgl_tick_timer));
    ESP_ERROR_CHECK(esp_timer_start_periodic(lvgl_tick_timer, LVGL_TICK_PERIOD_MS * 1000));
    return ESP_OK;
}

esp_err_t initialize_display(void) {
    i2c_master_bus_handle_t i2c_bus = NULL;
    esp_lcd_panel_io_handle_t io_handle = NULL;
    esp_lcd_panel_handle_t panel_handle = NULL;
    lv_display_t *display = NULL;

    ESP_ERROR_CHECK(initialize_i2c_bus(&i2c_bus));
    ESP_ERROR_CHECK(install_panel_io(i2c_bus, &io_handle));
    ESP_ERROR_CHECK(install_panel_driver(io_handle, &panel_handle));

    ESP_ERROR_CHECK(esp_lcd_panel_reset(panel_handle));
    ESP_ERROR_CHECK(esp_lcd_panel_init(panel_handle));
    ESP_ERROR_CHECK(esp_lcd_panel_disp_on_off(panel_handle, true));

#if CONFIG_LCD_CONTROLLER_SH1107
    ESP_ERROR_CHECK(esp_lcd_panel_invert_color(panel_handle, true));
#endif

    ESP_ERROR_CHECK(initialize_lvgl(panel_handle, &display));
    ESP_ERROR_CHECK(setup_lvgl_callbacks_and_timer(io_handle, display));

    ESP_LOGI(TAG, "Create LVGL task");
    xTaskCreate(lvgl_port_task, "LVGL", LVGL_TASK_STACK_SIZE, NULL, LVGL_TASK_PRIORITY, NULL);

    return ESP_OK;
}

esp_err_t add_keypad_input(lv_indev_read_cb_t read_cb, void* args) {
    ESP_LOGI(TAG, "Adding Keypad Input");

    lv_indev_t *indev = lv_indev_create();
    lv_indev_set_type(indev, LV_INDEV_TYPE_KEYPAD);
    lv_indev_set_user_data(indev, args);
    lv_indev_set_read_cb(indev, read_cb);

    lv_group_t *g = lv_group_create();
    lv_indev_set_group(indev, g);
    lv_group_set_default(g);
    return ESP_OK;
}


esp_err_t start_rendering() {
    ESP_LOGI(TAG, "Composing LVGL UI");

    ESP_LOGI(TAG, "Starting LVGL Rendering");
    _lock_acquire(&lvgl_api_lock);
    lv_display_t *display = lv_display_get_default();
    if (display == NULL) {
        ESP_LOGE(TAG, "Display not initialized!");
        _lock_release(&lvgl_api_lock);
        return ESP_FAIL; // Return an error code
    }
    create_ui(display);
    _lock_release(&lvgl_api_lock);
    return ESP_OK; // Return success
}

