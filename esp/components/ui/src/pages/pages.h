#include "lvgl.h"
#include "display.h"

lv_obj_t *compose_status_page(lv_obj_t *parent, lv_fragment_manager_t *manager, state_subjects_t *state_subjects);
lv_obj_t *compose_connection_page(lv_obj_t *parent, lv_fragment_manager_t *manager, state_subjects_t *state_subjects);

void pop_page(lv_fragment_manager_t *manager);
void page_pop_on_event(lv_event_t *e);