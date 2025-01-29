#include "lvgl.h"
#include "common_types.h"
#include "esp_log.h"
#include "pages.h"
#include "symbols.h"
#include "display.h"
#include "utilities.h"

LV_FONT_DECLARE(font_mdi_10)
LV_FONT_DECLARE(font_mdi_12)
LV_FONT_DECLARE(font_mdi_14)

static const char *TAG = "SCREEN.UI.STATUS_PAGE";

static void connected_clients_count_cb(lv_observer_t *observer, lv_subject_t *subject)
{
    const client_info_data_t *clients_data = lv_subject_get_pointer(subject);

    lv_obj_t *label = lv_observer_get_target(observer);
    if (label == NULL)
    {
        return;
    }

    if (clients_data == NULL || clients_data->clients_info == NULL)
    {
        lv_label_set_text_fmt(label, CONNECTION_SYMBOL " connections: 0");
        return;
    }
    lv_label_set_text_fmt(label, CONNECTION_SYMBOL " connections: %d", clients_data->client_count);
}

static void current_temperature_cb(lv_observer_t *observer, lv_subject_t *subject)
{
    const float *temperature_ptr = (const float *)lv_subject_get_pointer(subject);
    if (temperature_ptr == NULL)
    {
        return;
    }
    double temperature = *temperature_ptr;
    lv_obj_t *label = lv_observer_get_target(observer);
    if (label == NULL)
    {
        return;
    }

    lv_label_set_text_fmt(label, THERMOMETER_SYMBOL " current T: %.2f " TEMPERATURE_CELSIUS_SYMBOL, temperature);
}

static void target_temperature_cb(lv_observer_t *observer, lv_subject_t *subject)
{
    const float *temperature_ptr = (const float *)lv_subject_get_pointer(subject);
    if (temperature_ptr == NULL)
    {
        return;
    }
    double temperature = *temperature_ptr;
    lv_obj_t *label = lv_observer_get_target(observer);
    if (label == NULL)
    {
        return;
    }
    lv_label_set_text_fmt(label, THERMOMETER_CHEVRON_UP_SYMBOL " target T: %.2f " TEMPERATURE_CELSIUS_SYMBOL, temperature);
}

lv_obj_t *compose_status_page(lv_obj_t *parent, lv_fragment_manager_t *manager, state_subjects_t *state_subjects)
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
    lv_obj_set_style_text_font(connection_label, &font_mdi_14, 0);
    lv_label_set_text(connection_label, CONNECTION_SYMBOL " connected: X");
    lv_subject_add_observer_obj(&state_subjects->connected_clients, connected_clients_count_cb, connection_label, NULL);

    // -- Current temperature label -- //
    const float *current_temperature_ptr = (const float *)lv_subject_get_pointer(&state_subjects->current_temp);
    float current_temperature = ABSOLUTE_ZERO;
    if (current_temperature_ptr != NULL)
    {
        current_temperature = *current_temperature_ptr;
    }

    lv_obj_t *current_temp_label = lv_label_create(status_page);
    lv_obj_set_style_text_font(current_temp_label, &font_mdi_14, 0);
    lv_label_set_text_fmt(current_temp_label, THERMOMETER_SYMBOL " current T: %.2f " TEMPERATURE_CELSIUS_SYMBOL, current_temperature);
    lv_subject_add_observer_obj(&state_subjects->current_temp, current_temperature_cb, current_temp_label, NULL);

    // -- Target temperature        -- //
    const float *target_emperature_ptr = (const float *)lv_subject_get_pointer(&state_subjects->target_temp);
    double target_temperature = ABSOLUTE_ZERO;
    if (target_emperature_ptr != NULL)
    {
        target_temperature = *target_emperature_ptr;
    }

    lv_obj_t *target_temp_label = lv_label_create(status_page);
    lv_obj_set_style_text_font(target_temp_label, &font_mdi_14, 0);
    lv_label_set_text_fmt(target_temp_label, THERMOMETER_CHEVRON_UP_SYMBOL " target T: %.2f " TEMPERATURE_CELSIUS_SYMBOL, target_temperature);
    lv_subject_add_observer_obj(&state_subjects->target_temp, target_temperature_cb, target_temp_label, NULL);

    return status_page;
}