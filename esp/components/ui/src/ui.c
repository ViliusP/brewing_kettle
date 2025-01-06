#include "lvgl.h"

#include "esp_log.h"

static const char *TAG = "SCREEN.UI";


void create_ui(lv_display_t *disp);

static lv_obj_t *keypad_label;


static void my_event_cb(lv_event_t * e) {
    lv_event_code_t event_code = lv_event_get_code(e);
    lv_obj_t * label = lv_event_get_target(e);

    static uint32_t cnt = 1;
    ESP_LOGI(TAG, "my_event_cb %d", lv_event_get_code(e));
    lv_label_set_text_fmt(label, "%lu", cnt);
    cnt++;
}


static void create_external_input_debug_layer(lv_display_t *disp) {
    lv_obj_t *scr = lv_display_get_screen_active(disp);
    lv_obj_t *label = lv_label_create(scr);

    lv_label_set_text(label, "External Input");
    lv_obj_align(label, LV_ALIGN_TOP_MID, 0, 50);
    lv_group_add_obj(lv_group_get_default(), label);
    lv_obj_add_event_cb(label, my_event_cb, LV_EVENT_KEY, NULL);
}




static lv_obj_t* list1;
static lv_obj_t* currentButton = NULL;

static void event_handler(lv_event_t* e)
{
    lv_event_code_t code = lv_event_get_code(e);
    lv_obj_t* obj = lv_event_get_target(e);
    if (code == LV_EVENT_CLICKED)
    {
        ESP_LOGI(TAG, "Clicked: %s", lv_list_get_btn_text(list1, obj));

        if (currentButton == obj)
        {
            currentButton = NULL;
        }
        else
        {
            currentButton = obj;
        }
        lv_obj_t* parent = lv_obj_get_parent(obj);
        uint32_t i;
    }
}

static void go_up(lv_obj_t* list)
{
    if (currentButton == NULL) return;
    uint32_t index = lv_obj_get_index(currentButton);
    if (index <= 0) return;
    lv_obj_move_to_index(currentButton, index - 1);
    lv_obj_scroll_to_view(currentButton, LV_ANIM_ON);
    uint32_t i;
    for (i = 0; i < lv_obj_get_child_cnt(list); i++)
    {
        lv_obj_t* child = lv_obj_get_child(list, i);
        lv_obj_clear_state(child, LV_STATE_CHECKED);
        if (child == currentButton)
        {
            lv_obj_add_state(child, LV_STATE_CHECKED);
        }
    }
}


static void go_down(lv_obj_t* list)
{
    if (currentButton == NULL) return;
    const uint32_t index = lv_obj_get_index(currentButton);
    lv_obj_move_to_index(currentButton, index + 1);
    lv_obj_scroll_to_view(currentButton, LV_ANIM_ON);

    uint32_t i;
    for (i = 0; i < lv_obj_get_child_cnt(list); i++)
    {
        lv_obj_t* child = lv_obj_get_child(list, i);
        lv_obj_clear_state(child, LV_STATE_CHECKED);
        if (child == currentButton)
        {
            lv_obj_add_state(child, LV_STATE_CHECKED);
        }
     
    }
}


static void list_event_handler(lv_event_t* e)
{
    lv_event_code_t code = lv_event_get_code(e);
    lv_obj_t* obj = lv_event_get_target(e);
    if (code == LV_EVENT_KEY)
    {
        switch (lv_indev_get_key(lv_indev_active()))
        {
            case LV_KEY_UP:
                ESP_LOGI(TAG, "List LV_KEY_UP event");
                LV_LOG_USER("List LV_KEY_UP event");
                go_up(obj);
                break;
            case LV_KEY_DOWN:
                ESP_LOGI(TAG, "List LV_KEY_DOWN event");
                LV_LOG_USER("List LV_KEY_DOWN event");
                go_down(obj);
                break;
            case LV_KEY_LEFT:
                ESP_LOGI(TAG, "List LV_KEY_LEFT event");
                LV_LOG_USER("List LV_KEY_LEFT event");
                break;

            case LV_KEY_RIGHT:
                ESP_LOGI(TAG, "List LV_KEY_RIGHT event");
                LV_LOG_USER("List LV_KEY_RIGHT event");
                break;
            default:
                ESP_LOGI(TAG, "List OTHER event");
                LV_LOG_USER("List OTHER event");
                break;
        }
    }
}

const lv_style_const_prop_t style_btn_label_props[] = {
   LV_STYLE_CONST_BG_COLOR({0x00}),
};

LV_STYLE_CONST_INIT(style_btn_label, style_btn_label_props);


void lv_example_list_2(void)
{
    // -----------------------
    // STYLES
    // -----------------------
    static lv_style_t style_btn_default;
    lv_style_init(&style_btn_default);
    lv_style_set_bg_color(&style_btn_default, lv_color_white());
    lv_style_set_text_color(&style_btn_default, lv_color_black());

    lv_style_set_outline_color(&style_btn_default, lv_color_black());
    lv_style_set_outline_width(&style_btn_default, 1);

    static lv_style_t style_btn_focused;
    lv_style_init(&style_btn_focused);
    lv_style_set_bg_color(&style_btn_focused, lv_color_black());
    lv_style_set_text_color(&style_btn_focused, lv_color_white());
    lv_style_set_outline_color(&style_btn_focused, lv_color_white());
    lv_style_set_outline_width(&style_btn_focused, 1);
    // =======================

    /*Create a list*/
    list1 = lv_list_create(lv_scr_act());
    lv_obj_set_size(list1, lv_pct(100), lv_pct(100));
    lv_obj_set_style_pad_row(list1, 2, 0);

    lv_obj_add_event_cb(list1, list_event_handler, LV_EVENT_KEY, NULL);
    lv_group_add_obj(lv_group_get_default(), list1);

    /*Add buttons to the list*/
    lv_obj_t* btn;
    int i;
    for (i = 0; i < 15; i++) {
        btn = lv_btn_create(list1);
        lv_obj_set_width(btn, lv_pct(100));
        lv_obj_add_style(btn, &style_btn_default, LV_STATE_DEFAULT);
        lv_obj_add_style(btn, &style_btn_focused, LV_STATE_CHECKED );
        lv_obj_add_event_cb(btn, event_handler, LV_EVENT_CLICKED, NULL);

        lv_obj_t* label = lv_label_create(btn);
        lv_obj_add_style(label, &style_btn_label, LV_STATE_DEFAULT);
        lv_label_set_text_fmt(label, "Item %d", i);
    }

    // /*Select the first button by default*/
    currentButton = lv_obj_get_child(list1, 0);
    lv_obj_add_state(currentButton, LV_STATE_CHECKED);
}


void create_ui(lv_display_t *disp) {
    // create_external_input_debug_layer(disp);
    // lv_example_menu_1(disp);
    lv_example_list_2();
}
