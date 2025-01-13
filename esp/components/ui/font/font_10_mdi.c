/*******************************************************************************
 * Size: 10 px
 * Bpp: 1
 * Opts: --bpp 1 --size 10 --no-compress --lcd --font materialdesignicons-webfont.woff --range 988694,984490,984489,988853,983909,988989 --format lvgl -o font_10_mdi.c
 ******************************************************************************/

#include "lvgl.h"

#ifndef FONT_14_MDI
#define FONT_14_MDI 1
#endif

#ifndef FONT_10_MDI
#define FONT_10_MDI 1
#endif

#if FONT_10_MDI

/*-----------------
 *    BITMAPS
 *----------------*/

/*Store the image of the glyphs*/
static LV_ATTRIBUTE_LARGE_CONST const uint8_t glyph_bitmap[] = {
    /* U+F0365 "󰍥" */
    0xf, 0xff, 0xff, 0xc0, 0x60, 0x0, 0x1, 0x81,
    0x80, 0x0, 0x6, 0x6, 0x0, 0x0, 0x18, 0x18,
    0x0, 0x0, 0x60, 0x60, 0x0, 0x1, 0x81, 0xff,
    0xff, 0xfc, 0x7, 0x0, 0x0, 0x0, 0x0, 0x0,
    0x0, 0x0,

    /* U+F05A9 "󰖩" */
    0x0, 0x0, 0x0, 0x0, 0x3f, 0xff, 0xff, 0x1,
    0xc0, 0x0, 0xe, 0x0, 0x1f, 0xfe, 0x0, 0x1,
    0xe0, 0x1e, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
    0xfc, 0x0, 0x0, 0x0, 0xc0, 0x0,

    /* U+F05AA "󰖪" */
    0x0, 0x0, 0x0, 0x0, 0xf1, 0xff, 0xfe, 0x3,
    0xf8, 0x0, 0x1f, 0x0, 0x3c, 0x7c, 0x0, 0x1,
    0xfe, 0x3e, 0x0, 0x0, 0x1f, 0x0, 0x0, 0x1,
    0xff, 0x0, 0x0, 0x0, 0xc3, 0x80, 0x0, 0x0,
    0x0, 0x0,

    /* U+F1616 "󱘖" */
    0x0, 0x0, 0x0, 0x0, 0x0, 0x3, 0xe3, 0x80,
    0x0, 0x3f, 0xf8, 0x0, 0x0, 0x1f, 0xf8, 0x0,
    0x1c, 0xf, 0xe0, 0x1f, 0xc1, 0x0, 0x0, 0xff,
    0xf8, 0x0, 0x0, 0xff, 0xe0, 0x0, 0x1e, 0x3e,
    0x0, 0x0, 0x0, 0x0, 0x0, 0x0,

    /* U+F16B5 "󱚵" */
    0x0, 0x0, 0x0, 0x0, 0x7f, 0xff, 0xf0, 0x3,
    0x80, 0x0, 0x6, 0x0, 0x3f, 0xfe, 0x18, 0x1,
    0xc0, 0x18, 0x0, 0x0, 0x3e, 0x1, 0x0, 0x0,
    0xf8, 0x0, 0x0, 0x0, 0x0, 0x0,

    /* U+F173D "󱜽" */
    0xf, 0xff, 0xff, 0xc0, 0x60, 0x0, 0x1, 0x81,
    0x80, 0x0, 0x6, 0x6, 0x0, 0x0, 0x18, 0x18,
    0x0, 0x0, 0x60, 0x60, 0x0, 0x1, 0x80, 0xff,
    0xff, 0xfe, 0x0, 0x0, 0x0, 0x38, 0x0, 0x0,
    0x0, 0x0
};


/*---------------------
 *  GLYPH DESCRIPTION
 *--------------------*/

static const lv_font_fmt_txt_glyph_dsc_t glyph_dsc[] = {
    {.bitmap_index = 0, .adv_w = 0, .box_w = 0, .box_h = 0, .ofs_x = 0, .ofs_y = 0} /* id = 0 reserved */,
    {.bitmap_index = 0, .adv_w = 160, .box_w = 30, .box_h = 9, .ofs_x = 0, .ofs_y = -1},
    {.bitmap_index = 34, .adv_w = 160, .box_w = 30, .box_h = 8, .ofs_x = 0, .ofs_y = 0},
    {.bitmap_index = 64, .adv_w = 160, .box_w = 30, .box_h = 9, .ofs_x = 0, .ofs_y = -1},
    {.bitmap_index = 98, .adv_w = 160, .box_w = 30, .box_h = 10, .ofs_x = 0, .ofs_y = -1},
    {.bitmap_index = 136, .adv_w = 160, .box_w = 30, .box_h = 8, .ofs_x = 0, .ofs_y = 0},
    {.bitmap_index = 166, .adv_w = 160, .box_w = 30, .box_h = 9, .ofs_x = 0, .ofs_y = -1}
};

/*---------------------
 *  CHARACTER MAPPING
 *--------------------*/

static const uint16_t unicode_list_0[] = {
    0x0, 0x244, 0x245, 0x12b1, 0x1350, 0x13d8
};

/*Collect the unicode lists and glyph_id offsets*/
static const lv_font_fmt_txt_cmap_t cmaps[] =
{
    {
        .range_start = 983909, .range_length = 5081, .glyph_id_start = 1,
        .unicode_list = unicode_list_0, .glyph_id_ofs_list = NULL, .list_length = 6, .type = LV_FONT_FMT_TXT_CMAP_SPARSE_TINY
    }
};



/*--------------------
 *  ALL CUSTOM DATA
 *--------------------*/

#if LVGL_VERSION_MAJOR == 8
/*Store all the custom data of the font*/
static  lv_font_fmt_txt_glyph_cache_t cache;
#endif

#if LVGL_VERSION_MAJOR >= 8
static const lv_font_fmt_txt_dsc_t font_dsc = {
#else
static lv_font_fmt_txt_dsc_t font_dsc = {
#endif
    .glyph_bitmap = glyph_bitmap,
    .glyph_dsc = glyph_dsc,
    .cmaps = cmaps,
    .kern_dsc = NULL,
    .kern_scale = 0,
    .cmap_num = 1,
    .bpp = 1,
    .kern_classes = 0,
    .bitmap_format = 0,
#if LVGL_VERSION_MAJOR == 8
    .cache = &cache
#endif
};

extern const lv_font_t lv_font_montserrat_10;


/*-----------------
 *  PUBLIC FONT
 *----------------*/

/*Initialize a public general font descriptor*/
#if LVGL_VERSION_MAJOR >= 8
const lv_font_t font_10_mdi = {
#else
lv_font_t font_10_mdi = {
#endif
    .get_glyph_dsc = lv_font_get_glyph_dsc_fmt_txt,    /*Function pointer to get glyph's data*/
    .get_glyph_bitmap = lv_font_get_bitmap_fmt_txt,    /*Function pointer to get glyph's bitmap*/
    .line_height = 10,          /*The maximum line height required by the font*/
    .base_line = 1,             /*Baseline measured from the bottom of the line*/
#if !(LVGL_VERSION_MAJOR == 6 && LVGL_VERSION_MINOR == 0)
    .subpx = LV_FONT_SUBPX_HOR,
#endif
#if LV_VERSION_CHECK(7, 4, 0) || LVGL_VERSION_MAJOR >= 8
    .underline_position = 0,
    .underline_thickness = 0,
#endif
    .dsc = &font_dsc,          /*The custom font data. Will be accessed by `get_glyph_bitmap/dsc` */
#if LV_VERSION_CHECK(8, 2, 0) || LVGL_VERSION_MAJOR >= 9
    .fallback = &lv_font_montserrat_10,
#endif
    .user_data = NULL,
};



#endif /*#if FONT_10_MDI*/
