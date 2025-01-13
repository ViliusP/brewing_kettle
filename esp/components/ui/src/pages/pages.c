#include "lvgl.h"
#include "esp_log.h"

static const char *TAG = "SCREEN.UI.PAGES";

void pop_page(lv_fragment_manager_t *manager)
{
    if (lv_fragment_manager_get_stack_size(manager) > 1)
    {
        ESP_LOGD(TAG, "Popping fragment");
        lv_fragment_manager_pop(manager);
    }
}

void page_pop_on_event(lv_event_t *e)
{
    if (e == NULL)
    {
        ESP_LOGD(TAG, "page_press_cb: Invalid event pointer");
        return;
    }
    lv_fragment_manager_t *manager = (lv_fragment_manager_t *)lv_event_get_user_data(e);
    if (manager == NULL)
    {
        ESP_LOGD(TAG, "page_press_cb: Invalid manager in event data");
        return;
    }
    pop_page(manager);
}

