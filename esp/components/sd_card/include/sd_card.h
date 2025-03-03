#pragma once

#ifdef __cplusplus
extern "C" {
#endif


/**
 * @brief Type defined for matrix keyboard handle
 *
 */
// typedef struct matrix_kbd_t *matrix_kbd_handle_t;


/**
 * @brief Type defined for matrix keyboard event handler
 *
 * @note The event handler runs in a OS timer context
 *
 * @param[in] mkbd_handle Handle of matrix keyboard that return from `matrix_kbd_install`
 * @param[in] event Event ID, refer to `matrix_kbd_event_id_t` to see all supported events
 * @param[in] event_data Data for corresponding event
 * @param[in] handler_args Arguments that user passed in from `matrix_kbd_register_event_handler`
 * @return Currently always return ESP_OK
 */
// typedef esp_err_t (*matrix_kbd_event_handler)(matrix_kbd_handle_t mkbd_handle, matrix_kbd_event_id_t event, void *event_data, void *handler_args);

/**
 * @brief Configuration structure defined for matrix keyboard
 *
 */
// typedef struct {
//     const int *row_gpios;  /*!< Array, contains GPIO numbers used by row line */
//     const int *col_gpios;  /*!< Array, contains GPIO numbers used by column line */
//     uint8_t nr_row_gpios; /*!< row_gpios array size */
//     uint8_t nr_col_gpios; /*!< col_gpios array size */
//     uint32_t debounce_ms;  /*!< Debounce time */
// } matrix_kbd_config_t;

/**
 * @brief Structure defined for key event
 *
 */
// typedef struct {
//     int row; /*!< Row number */
//     int col; /*!< Column number */
//     uint32_t key_code; /*!< Key code, refer to `MAKE_KEY_CODE` to see how to make a key code */
//     matrix_kbd_event_id_t event; /*!< Event ID, refer to `matrix_kbd_event_id_t` to see all supported events */
// } key_event_t;



/**
 * @brief Initializes sd card and mounts the filesystem
 *
 * @param[in] config Configuration of matrix keyboard driver
 * @param[out] mkbd_handle Returned matrix keyboard handle if installation succeed
 * @return
 *      - ESP_OK: Install matrix keyboard driver successfully
 *      - ESP_ERR_INVALID_ARG: Install matrix keyboard driver failed because of some invalid argument
 *      - ESP_ERR_NO_MEM: Install matrix keyboard driver failed because there's no enough capable memory
 *      - ESP_FAIL: Install matrix keyboard driver failed because of other error
 */
void init_sdcard(void);

/**
 * @brief Uninstall matrix keyboard driver
 *
 * @param[in] mkbd_handle Handle of matrix keyboard that return from `matrix_kbd_install`
 * @return
 *      - ESP_OK: Uninstall matrix keyboard driver successfully
 *      - ESP_ERR_INVALID_ARG: Uninstall matrix keyboard driver failed because of some invalid argument
 *      - ESP_FAIL: Uninstall matrix keyboard driver failed because of other error
 */
// esp_err_t matrix_kbd_uninstall(matrix_kbd_handle_t mkbd_handle);

/**
 * @brief Start matrix keyboard driver
 *
 * @param[in] mkbd_handle Handle of matrix keyboard that return from `matrix_kbd_install`
 * @return
 *      - ESP_OK: Start matrix keyboard driver successfully
 *      - ESP_ERR_INVALID_ARG: Start matrix keyboard driver failed because of some invalid argument
 *      - ESP_FAIL: Start matrix keyboard driver failed because of other error
 */
// esp_err_t matrix_kbd_start(matrix_kbd_handle_t mkbd_handle);

/**
 * @brief Stop matrix kayboard driver
 *
 * @param[in] mkbd_handle Handle of matrix keyboard that return from `matrix_kbd_install`
 * @return
 *      - ESP_OK: Stop matrix keyboard driver successfully
 *      - ESP_ERR_INVALID_ARG: Stop matrix keyboard driver failed because of some invalid argument
 *      - ESP_FAIL: Stop matrix keyboard driver failed because of other error
 */
// esp_err_t matrix_kbd_stop(matrix_kbd_handle_t mkbd_handle);

/**
 * @brief Register matrix keyboard event handler
 *
 * @param[in] mkbd_handle Handle of matrix keyboard that return from `matrix_kbd_install`
 * @param[in] handler Event handler
 * @param[in] args Arguments that will be passed to the handler
 * @return
 *      - ESP_OK: Register event handler successfully
 *      - ESP_ERR_INVALID_ARG: Register event handler failed because of some invalid argument
 *      - ESP_FAIL: Register event handler failed because of other error
 */
// esp_err_t matrix_kbd_register_event_handler(matrix_kbd_handle_t mkbd_handle, matrix_kbd_event_handler handler, void *args);

/**
 * @brief read all current events from matrix keyboard
 *
 * @param[in] mkbd_handle Handle of matrix keyboard that return from `matrix_kbd_install`
 * @param[in] events_ptr Pointer to the pointer of key_event_t
 * @return Number of events. If no events, return 0, otherwise return the number of events, if error occured, return negative value.
 */ 
// int matrix_kbd_get_all_events(matrix_kbd_handle_t mkbd_handle, key_event_t** events_ptr);

#ifdef __cplusplus
}
#endif