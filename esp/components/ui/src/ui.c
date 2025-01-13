#include "lvgl.h"

#include "esp_log.h"
#include "symbols.h"
#include "screen.h"
#include "common_types.h"

LV_FONT_DECLARE(mdi)

static const char *TAG = "SCREEN.UI";

const char *menu_labels[] = {CONNECTION_SYMBOL " status", "control", "connections", "messages", "something"};

typedef enum
{
    PAGE_MAIN_MENU = 0,
    PAGE_STATUS = 1,
} page_id_t;

typedef struct push_page_args_t
{
    lv_fragment_manager_t *manager;
    page_id_t page_id;
} push_page_args_t;

typedef struct nav_fragment_t
{
    lv_fragment_t base;
    lv_obj_t *label;
    page_id_t page_id;
} nav_fragment_t;

static state_subjects_t state_subjects;

static void set_first_page(lv_fragment_manager_t *manager, page_id_t page_id);
static lv_obj_t *nav_fragment_create(lv_fragment_t *self, lv_obj_t *parent);
static void pop_page(lv_fragment_manager_t *manager);
static void push_page(lv_fragment_manager_t *manager, page_id_t page_id);

static lv_obj_t *keypad_label;
static lv_obj_t *container = NULL;

// static void go_up(lv_obj_t *list)
// {
//     if (currentButton == NULL)
//         return;
//     uint32_t index = lv_obj_get_index(currentButton);
//     if (index <= 0)
//         return;
//     currentButton = lv_obj_get_child(list, index - 1);
//     lv_obj_scroll_to_view(currentButton, LV_ANIM_ON);
//     uint32_t i;
//     for (i = 0; i < lv_obj_get_child_cnt(list); i++)
//     {
//         lv_obj_t *child = lv_obj_get_child(list, i);
//         lv_obj_clear_state(child, LV_STATE_CHECKED);
//         if (child == currentButton)
//         {
//             lv_obj_add_state(child, LV_STATE_CHECKED);
//         }
//     }
// }

// static void go_down(lv_obj_t *list)
// {
//     uint32_t child_count = lv_obj_get_child_cnt(list);
//     if (currentButton == NULL)
//         return;
//     const uint32_t index = lv_obj_get_index(currentButton);
//     if (child_count - 1 <= index)
//         return;
//     currentButton = lv_obj_get_child(list, index + 1);
//     lv_obj_scroll_to_view(currentButton, LV_ANIM_ON);

//     uint32_t i;
//     for (i = 0; i < lv_obj_get_child_cnt(list); i++)
//     {
//         lv_obj_t *child = lv_obj_get_child(list, i);
//         lv_obj_clear_state(child, LV_STATE_CHECKED);
//         if (child == currentButton)
//         {
//             lv_obj_add_state(child, LV_STATE_CHECKED);
//         }
//     }
// }

// static void list_event_handler(lv_event_t *e)
// {
//     lv_event_code_t code = lv_event_get_code(e);
//     lv_obj_t *obj = lv_event_get_target(e);
//     const uint32_t before = lv_obj_get_index(currentButton);
//     ESP_LOGI(TAG, "Button index before event: %lu", before);
//     if (code == LV_EVENT_KEY)
//     {
//         switch (lv_indev_get_key(lv_indev_active()))
//         {
//         case LV_KEY_UP:
//             ESP_LOGI(TAG, "List LV_KEY_UP event");
//             LV_LOG_USER("List LV_KEY_UP event");
//             go_up(obj);
//             break;
//         case LV_KEY_DOWN:
//             ESP_LOGI(TAG, "List LV_KEY_DOWN event");
//             LV_LOG_USER("List LV_KEY_DOWN event");
//             go_down(obj);
//             break;
//         case LV_KEY_LEFT:
//             ESP_LOGI(TAG, "List LV_KEY_LEFT event");
//             LV_LOG_USER("List LV_KEY_LEFT event");
//             break;

//         case LV_KEY_RIGHT:
//             ESP_LOGI(TAG, "List LV_KEY_RIGHT event");
//             LV_LOG_USER("List LV_KEY_RIGHT event");
//             break;
//         default:
//             ESP_LOGI(TAG, "List OTHER event");
//             LV_LOG_USER("List OTHER event");
//             break;
//         }
//     }
//     const uint32_t after = lv_obj_get_index(currentButton);
//     ESP_LOGI(TAG, "Button  index after event: %lu", after);
// }

static void menu_button_cb(lv_event_t *e)
{
    if (e == NULL)
    {
        ESP_LOGW(TAG, "menu_button_cb: Invalid event pointer");
        return;
    }

    push_page_args_t *args = (push_page_args_t *)lv_event_get_user_data(e);
    if (args == NULL || args->manager == NULL)
    {
        ESP_LOGW(TAG, "Invalid user data in event callback (menu_button_cb)");
        return;
    }
    push_page(args->manager, args->page_id);
}

static void page_press_cb(lv_event_t *e)
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

static lv_obj_t *compose_status_page(lv_obj_t *parent, lv_fragment_manager_t *manager)
{
    if (parent == NULL)
    {
        parent = lv_obj_create(NULL);
    }
    lv_obj_t *status_page = lv_obj_create(parent);
    lv_obj_set_size(status_page, 128, lv_pct(100));
    lv_obj_center(status_page);
    lv_group_add_obj(lv_group_get_default(), status_page);

    if (manager != NULL)
    {
        lv_obj_add_event_cb(status_page, page_press_cb, LV_EVENT_PRESSED, manager);
    }

    lv_obj_t *label = lv_label_create(status_page);
    lv_label_set_text(label, "Conntected: ");
    // lv_obj_bind_flag_if_eq(label, &subject, LV_OBJ_FLAG_*, ref_value);
    lv_obj_center(label);

    return status_page;
}

static lv_obj_t *compose_unknown_page(lv_obj_t *parent, lv_fragment_manager_t *manager)
{
    if (parent == NULL)
    {
        parent = lv_obj_create(NULL);
    }
    lv_obj_t *unknown_page = lv_obj_create(parent);
    lv_obj_set_size(unknown_page, 128, lv_pct(100));
    lv_obj_center(unknown_page);
    lv_group_add_obj(lv_group_get_default(), unknown_page);

    if (manager == NULL)
    {
        ESP_LOGW(TAG, "ADDING event to unknown page ");
        lv_obj_add_event_cb(unknown_page, page_press_cb, LV_EVENT_PRESSED, NULL);
    }

    lv_obj_t *label = lv_label_create(unknown_page);
    lv_label_set_text(label, "Hello, I am hiding here");
    lv_obj_center(label);

    return unknown_page;
}

lv_obj_t *compose_main_menu(lv_obj_t *parent, lv_fragment_manager_t *manager)
{
    if (parent == NULL)
    {
        ESP_LOGW(TAG, "CREATING PARENT IN COMPOSE MENU");
        parent = lv_screen_active();
    }

    // -----------------------
    // BUTTON STYLE
    // -----------------------
    static lv_style_t style_btn_default;
    lv_style_init(&style_btn_default);
    lv_style_set_bg_color(&style_btn_default, lv_color_white());
    lv_style_set_text_color(&style_btn_default, lv_color_black());
    lv_style_set_radius(&style_btn_default, 16);
    lv_style_set_pad_ver(&style_btn_default, 2);
    lv_style_set_width(&style_btn_default, lv_pct(100));
    lv_style_set_height(&style_btn_default, 28);
    lv_style_set_text_font(&style_btn_default, &mdi);

    static lv_style_t style_btn_focused;
    lv_style_set_border_color(&style_btn_focused, lv_color_black());
    lv_style_set_border_width(&style_btn_focused, 2);
    // =======================

    // -----------------------
    // MENU LIST
    // -----------------------
    lv_obj_t *menu_container = lv_obj_create(parent);
    lv_gridnav_add(menu_container, LV_GRIDNAV_CTRL_NONE);
    lv_obj_set_size(menu_container, lv_pct(100), lv_pct(100));
    lv_obj_set_flex_flow(menu_container, LV_FLEX_FLOW_COLUMN);
    lv_group_add_obj(lv_group_get_default(), menu_container);

    lv_obj_set_style_pad_row(menu_container, 0, 0);
    lv_obj_set_style_pad_ver(menu_container, 2, 0);
    lv_obj_set_style_pad_hor(menu_container, 0, 0);

    // ------------------------
    // PAGES
    // ------------------------

    uint32_t i;
    size_t num_labels = sizeof(menu_labels) / sizeof(menu_labels[0]);
    for (i = 0; i < num_labels; i++)
    {
        lv_obj_t *btn = lv_obj_create(menu_container);
        lv_obj_add_style(btn, &style_btn_default, LV_STATE_DEFAULT);
        lv_obj_add_style(btn, &style_btn_default, LV_STATE_FOCUSED);
        lv_obj_add_style(btn, &style_btn_focused, LV_STATE_FOCUSED);
        switch (i)
        {
        case 0:
            static push_page_args_t args;
            args.manager = manager;
            args.page_id = PAGE_STATUS;
            lv_obj_add_event_cb(btn, menu_button_cb, LV_EVENT_CLICKED, &args);
            break;
        default:
            break;
        }
        lv_group_remove_obj(btn); /*Not needed, we use the gridnav instead*/

        lv_obj_t *label = lv_label_create(btn);
        lv_label_set_text_fmt(label, menu_labels[i]);
        lv_obj_center(label);
    }
    return menu_container;
}

static void nav_fragment_constructor(lv_fragment_t *self, void *args)
{
    LV_UNUSED(args);
    ((nav_fragment_t *)self)->page_id = *((int *)args);
}

static const lv_fragment_class_t nav_fragment_class = {
    .constructor_cb = nav_fragment_constructor,
    .create_obj_cb = nav_fragment_create,
    .instance_size = sizeof(nav_fragment_t),
};

static void push_page(lv_fragment_manager_t *manager, page_id_t page_id)
{
    lv_fragment_t *fragment = lv_fragment_create(&nav_fragment_class, &page_id);
    lv_fragment_manager_push(manager, fragment, &container);
}

static void pop_page(lv_fragment_manager_t *manager)
{

    if (lv_fragment_manager_get_stack_size(manager) > 1)
    {
        ESP_LOGD(TAG, "Popping fragment");
        lv_fragment_manager_pop(manager);
    }
}

static lv_obj_t *nav_fragment_create(lv_fragment_t *self, lv_obj_t *parent)
{
    nav_fragment_t *fragment = (nav_fragment_t *)self;

    lv_fragment_manager_t *manager = lv_fragment_get_manager(self);

    switch (fragment->page_id)
    {
    case PAGE_MAIN_MENU:
        return compose_main_menu(parent, manager);
    case PAGE_STATUS:
        ESP_LOGD(TAG, "Creating status_page fragment");
        return compose_status_page(parent, manager);
    default:
        return compose_unknown_page(parent, manager);
    }
}

void set_first_page(lv_fragment_manager_t *manager, page_id_t page_id)
{
    if (manager == NULL)
    {
        manager = lv_fragment_manager_create(NULL);
    }
    container = lv_obj_create(lv_screen_active());
    lv_obj_remove_style_all(container);
    lv_group_remove_obj(container);
    lv_obj_set_size(container, lv_pct(100), lv_pct(100));

    lv_fragment_t *fragment = lv_fragment_create(&nav_fragment_class, &page_id);
    lv_fragment_manager_push(manager, fragment, &container);
}

void connected_clients_count_cb(lv_observer_t *observer, lv_subject_t *subject)
{
    const client_info_data_t *clients_data = lv_subject_get_pointer(subject);
    if (clients_data == NULL || clients_data->clients_info == NULL)
    {
        return;
    }
    ESP_LOGI(TAG, "FROM UI value %d", clients_data->client_count);

    lv_obj_t *label = lv_observer_get_target(observer);
    if (label == NULL)
    {
        return;
    }
    lv_label_set_text_fmt(label, "Connected clients: %d", clients_data->client_count);
}

void compose_ui(lv_display_t *disp, state_subjects_t *arg_state_subjects)
{
    state_subjects = *arg_state_subjects;
    // lv_obj_t *p = lv_obj_create(lv_screen_active());
    // lv_obj_remove_style_all(p);
    // lv_group_remove_obj(p);
    // compose_main_menu(p, NULL);

    lv_fragment_manager_t *manager = lv_fragment_manager_create(NULL);
    set_first_page(manager, PAGE_MAIN_MENU);
}
