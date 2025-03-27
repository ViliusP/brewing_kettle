#include "lvgl.h"
#include "common_types.h"
#include "pages.h"
#include "esp_log.h"

static const char *TAG = "SCREEN.UI.CONNECTION_PAGE";

static void changed_status_cb(lv_observer_t *observer, lv_subject_t *subject)
{
    int32_t status = lv_subject_get_int(subject);
    
    lv_obj_t *label = lv_observer_get_target(observer);
    if (label == NULL)
    {
        return;
    }

    switch (status)
    {
    case APP_STATUS_OK:
        lv_label_set_text_fmt(label, "Status: OK");
        break;
    case APP_STATUS_INITIALIZING:
        lv_label_set_text_fmt(label, "Status: Initializing");
        break;  
    case APP_STATUS_ERROR_SDCARD_INIT:
        lv_label_set_text_fmt(label, "Status: Error SD Card Init");
        break;
    case APP_STATUS_ERROR_WIFI_CREDENTIALS:
        lv_label_set_text_fmt(label, "Status: Error Wifi Credentials");
        break;
    case APP_STATUS_ERROR_WIFI_CONNECT:
        lv_label_set_text_fmt(label, "Status: Error Wifi Connect");
        break;
    case APP_STATUS_UNKNOWN:
        lv_label_set_text_fmt(label, "Status: Unknown");
        break;
    default:
        ESP_LOGW(TAG, "SOMETHING WENT WRONG: %lu", status);
        break;
    }
}

lv_obj_t *compose_connection_page(lv_obj_t *parent, lv_fragment_manager_t *manager, state_subjects_t *state_subjects)
{
    if (parent == NULL)
    {
        parent = lv_obj_create(NULL);
    }
    // -- Container -- //
    // ----> style     //
    static lv_style_t style_container_default;
    lv_style_init(&style_container_default);
    lv_style_set_pad_ver(&style_container_default, 1);
    lv_style_set_pad_row(&style_container_default, 1);
    lv_style_set_size(&style_container_default, 128, lv_pct(100));
    lv_style_set_flex_flow(&style_container_default, LV_FLEX_FLOW_COLUMN);
    lv_style_set_layout(&style_container_default, LV_LAYOUT_FLEX);
    lv_style_set_align(&style_container_default, LV_ALIGN_TOP_MID);

    // ----> init    //
    lv_obj_t *status_page = lv_obj_create(parent);
    lv_obj_add_style(status_page, &style_container_default, LV_STATE_DEFAULT);
    lv_group_add_obj(lv_group_get_default(), status_page);
    if (manager != NULL)
    {
        lv_obj_add_event_cb(status_page, page_pop_on_event, LV_EVENT_PRESSED, manager);
    }
    
    // -- Connection label -- //
    lv_obj_t *connection_label = lv_label_create(status_page);
    lv_subject_get_int(&state_subjects->app_status);
    lv_label_set_text(connection_label, "Status: OK");
    lv_subject_add_observer_obj(&state_subjects->app_status, changed_status_cb, connection_label, NULL);

    return status_page;
}