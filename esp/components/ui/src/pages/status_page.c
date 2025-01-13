#include "lvgl.h"
#include "common_types.h"
#include "esp_log.h"
#include "pages.h"
#include "symbols.h"
#include "display.h"


LV_FONT_DECLARE(font_mdi_10)
LV_FONT_DECLARE(font_mdi_12)
LV_FONT_DECLARE(font_mdi_14)

static const char *TAG = "SCREEN.UI.STATUS_PAGE";


static void connected_clients_count_cb(lv_observer_t *observer, lv_subject_t *subject)
{
    ESP_LOGI(TAG, "connected_clients_count_cb");
    const client_info_data_t *clients_data = lv_subject_get_pointer(subject);
    if (clients_data == NULL || clients_data->clients_info == NULL)
    {
        return;
    }
    lv_obj_t *label = lv_observer_get_target(observer);
    if (label == NULL)
    {
        return;
    }
    lv_label_set_text_fmt(label, CONNECTION_SYMBOL " connections: %d", clients_data->client_count);
}



lv_obj_t *compose_status_page(lv_obj_t *parent, lv_fragment_manager_t *manager, state_subjects_t *state_subjects)
{
    if (parent == NULL)
    {
        parent = lv_obj_create(NULL);
    }
    lv_obj_t *status_page = lv_obj_create(parent);
    lv_obj_set_size(status_page, 128, lv_pct(100));
    lv_obj_center(status_page);
    lv_group_add_obj(lv_group_get_default(), status_page);
    lv_obj_set_flex_flow(status_page, LV_FLEX_FLOW_COLUMN);
    
    if (manager != NULL)
    {
        lv_obj_add_event_cb(status_page, page_pop_on_event, LV_EVENT_PRESSED, manager);
    }
    lv_obj_t *label = lv_label_create(status_page);
    lv_obj_set_style_text_font(label, &font_mdi_12, 0);
    lv_label_set_text(label, CONNECTION_SYMBOL " connections: -1");

    lv_subject_add_observer_obj(&state_subjects->connected_clients, connected_clients_count_cb, label, NULL);

    return status_page;
}