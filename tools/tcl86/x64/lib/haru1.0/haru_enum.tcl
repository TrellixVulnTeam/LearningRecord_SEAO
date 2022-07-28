# Copyright (c) 2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl binding for libharu (http://libharu.org/) PDF library.

cffi::enum define HPdfPageLayout {
    HPDF_PAGE_LAYOUT_SINGLE         0
    HPDF_PAGE_LAYOUT_ONE_COLUMN     1
    HPDF_PAGE_LAYOUT_TWO_CLUMN_LEFT 2
    HPDF_PAGE_LAYOUT_TWO_CLUMN_RIGH 3
    HPDF_PAGE_LAYOUT_EOF            4
}

cffi::enum define HPdfPageMode {
    HPDF_PAGE_MODE_USE_NONE     0
    HPDF_PAGE_MODE_USE_OUTLINE  1
    HPDF_PAGE_MODE_USE_THUMBS   2
    HPDF_PAGE_MODE_FULL_SCREEN  3
    HPDF_PAGE_MODE_EOF          4
}

cffi::enum define HPdfPageSizes {
    HPDF_PAGE_SIZE_LETTER    0
    HPDF_PAGE_SIZE_LEGAL     1
    HPDF_PAGE_SIZE_A3        2
    HPDF_PAGE_SIZE_A4        3
    HPDF_PAGE_SIZE_A5        4
    HPDF_PAGE_SIZE_B4        5
    HPDF_PAGE_SIZE_B5        6
    HPDF_PAGE_SIZE_EXECUTIVE 7
    HPDF_PAGE_SIZE_US4x6     8
    HPDF_PAGE_SIZE_US4x8     9
    HPDF_PAGE_SIZE_US5x7     10
    HPDF_PAGE_SIZE_COMM10    11
    HPDF_PAGE_SIZE_EOF       12
}

cffi::enum define HPdfPageDirection {
    HPDF_PAGE_PORTRAIT  0
    HPDF_PAGE_LANDSCAPE 1
}

cffi::enum define HPdfPageNumStyle {
    HPDF_PAGE_NUM_STYLE_DECIMAL       0
    HPDF_PAGE_NUM_STYLE_UPPER_ROMAN   1
    HPDF_PAGE_NUM_STYLE_LOWER_ROMAN   2
    HPDF_PAGE_NUM_STYLE_UPPER_LETTERS 3
    HPDF_PAGE_NUM_STYLE_LOWER_LETTERS 4
    HPDF_PAGE_NUM_STYLE_EOF           5
}

cffi::enum define HPdfWritingMode {
    HPDF_WMODE_HORIZONTAL 0
    HPDF_WMODE_VERTICAL   1
    HPDF_WMODE_EOF        2
}

cffi::enum define HPdfEncoderType {
    HPDF_ENCODER_TYPE_SINGLE_BYTE   0
    HPDF_ENCODER_TYPE_DOUBLE_BYTE   1
    HPDF_ENCODER_TYPE_UNINITIALIZED 2
    HPDF_ENCODER_UNKNOWN            3
}

cffi::enum define HPdfByteType {
    HPDF_BYTE_TYPE_SINGLE  0
    HPDF_BYTE_TYPE_LEAD    1
    HPDF_BYTE_TYPE_TRIAL   2
    HPDF_BYTE_TYPE_UNKNOWN 3
}

cffi::enum define HPdfAnnotHighlightMode {
    HPDF_ANNOT_NO_HIGHTLIGHT       0
    HPDF_ANNOT_INVERT_BOX          1
    HPDF_ANNOT_INVERT_BORDER       2
    HPDF_ANNOT_DOWN_APPEARANCE     3
    HPDF_ANNOT_HIGHTLIGHT_MODE_EOF 4
}
cffi::enum define HPdfAnnotIcon {
    HPDF_ANNOT_ICON_COMMENT       0
    HPDF_ANNOT_ICON_KEY           1
    HPDF_ANNOT_ICON_NOTE          2
    HPDF_ANNOT_ICON_HELP          3
    HPDF_ANNOT_ICON_NEW_PARAGRAPH 4
    HPDF_ANNOT_ICON_PARAGRAPH     5
    HPDF_ANNOT_ICON_INSERT        6
    HPDF_ANNOT_ICON_EOF           7
}
cffi::enum define HPdfColorSpace {
    HPDF_CS_DEVICE_GRAY 0
    HPDF_CS_DEVICE_RGB  1
    HPDF_CS_DEVICE_CMYK 2
    HPDF_CS_CAL_GRAY    3
    HPDF_CS_CAL_RGB     4
    HPDF_CS_LAB         5
    HPDF_CS_ICC_BASED   6
    HPDF_CS_SEPARATION  7
    HPDF_CS_DEVICE_N    8
    HPDF_CS_INDEXED     9
    HPDF_CS_PATTERN     10
    HPDF_CS_EOF         11
}
cffi::enum define HPdfInfoType {
    HPDF_INFO_CREATION_DATE 0
    HPDF_INFO_MOD_DATE      1
    HPDF_INFO_AUTHOR        2
    HPDF_INFO_CREATOR       3
    HPDF_INFO_PRODUCER      4
    HPDF_INFO_TITLE         5
    HPDF_INFO_SUBJECT       6
    HPDF_INFO_KEYWORDS      7
    HPDF_INFO_EOF           8
}
cffi::enum define HPdfEncryptMode {
    HPDF_ENCRYPT_R2 2
    HPDF_ENCRYPT_R3 3
}
cffi::enum define HPdfTextRenderingMode {
    HPDF_FILL                 0
    HPDF_STROKE               1
    HPDF_FILL_THEN_STROKE     2
    HPDF_INVISIBLE            3
    HPDF_FILL_CLIPPING        4
    HPDF_STROKE_CLIPPING      5
    HPDF_FILL_STROKE_CLIPPING 6
    HPDF_CLIPPING             7
    HPDF_RENDERING_MODE_EOF   8
}
cffi::enum define HPdfLineCap {
    HPDF_BUTT_END              0
    HPDF_ROUND_END             1
    HPDF_PROJECTING_SCUARE_END 2
    HPDF_LINECAP_EOF           3
}
cffi::enum define HPdfLineJoin {
    HPDF_MITER_JOIN   0
    HPDF_ROUND_JOIN   1
    HPDF_BEVEL_JOIN   2
    HPDF_LINEJOIN_EOF 3
}
cffi::enum define HPdfTextAlignment {
    HPDF_TALIGN_LEFT    0
    HPDF_TALIGN_RIGHT   1
    HPDF_TALIGN_CENTER  2
    HPDF_TALIGN_JUSTIFY 3
}
cffi::enum define HPdfTransitionStyle {
    HPDF_TS_WIPE_RIGHT                       0
    HPDF_TS_WIPE_UP                          1
    HPDF_TS_WIPE_LEFT                        2
    HPDF_TS_WIPE_DOWN                        3
    HPDF_TS_BARN_DOORS_HORIZONTAL_OUT        4
    HPDF_TS_BARN_DOORS_HORIZONTAL_IN         5
    HPDF_TS_BARN_DOORS_VERTICAL_OUT          6
    HPDF_TS_BARN_DOORS_VERTICAL_IN           7
    HPDF_TS_BOX_OUT                          8
    HPDF_TS_BOX_IN                           9
    HPDF_TS_BLINDS_HORIZONTAL                10
    HPDF_TS_BLINDS_VERTICAL                  11
    HPDF_TS_DISSOLVE                         12
    HPDF_TS_GLITTER_RIGHT                    13
    HPDF_TS_GLITTER_DOWN                     14
    HPDF_TS_GLITTER_TOP_LEFT_TO_BOTTOM_RIGHT 15
    HPDF_TS_REPLACE                          16
    HPDF_TS_EOF                              17
}
cffi::enum define HPdfBlendMode {
    HPDF_BM_NORMAL      0
    HPDF_BM_MULTIPLY    1
    HPDF_BM_SCREEN      2
    HPDF_BM_OVERLAY     3
    HPDF_BM_DARKEN      4
    HPDF_BM_LIGHTEN     5
    HPDF_BM_COLOR_DODGE 6
    HPDF_BM_COLOR_BUM   7
    HPDF_BM_HARD_LIGHT  8
    HPDF_BM_SOFT_LIGHT  9
    HPDF_BM_DIFFERENCE  10
    HPDF_BM_EXCLUSHON   11
    HPDF_BM_EOF         12
}