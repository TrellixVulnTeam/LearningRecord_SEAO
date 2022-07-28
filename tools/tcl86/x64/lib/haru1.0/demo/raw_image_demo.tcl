#
# << Haru Free PDF Library 2.3.0 >> -- raw_image_demo.c
#
# Copyright (c) 1999-2006 Takeshi Kanno <takeshi_kanno@est.hi-ho.ne.jp>
#
# Permission to use, copy, modify, distribute and sell this software
# and its documentation for any purpose is hereby granted without fee,
# provided that the above copyright notice appear in all copies and
# that both that copyright notice and this permission notice appear
# in supporting documentation.
# It is provided "as is" without express or implied warranty.
#
#
# port to Tcl by Nicolas Robert

set demodir [file dirname [info script]]
lappend auto_path [file dirname $demodir]

package require haru

set RAW_IMAGE_DATA {
    0xff 0xff 0xff 0xfe 0xff 0xff 0xff 0xfc
    0xff 0xff 0xff 0xf8 0xff 0xff 0xff 0xf0
    0xf3 0xf3 0xff 0xe0 0xf3 0xf3 0xff 0xc0
    0xf3 0xf3 0xff 0x80 0xf3 0x33 0xff 0x00
    0xf3 0x33 0xfe 0x00 0xf3 0x33 0xfc 0x00
    0xf8 0x07 0xf8 0x00 0xf8 0x07 0xf0 0x00
    0xfc 0xcf 0xe0 0x00 0xfc 0xcf 0xc0 0x00
    0xff 0xff 0x80 0x00 0xff 0xff 0x00 0x00
    0xff 0xfe 0x00 0x00 0xff 0xfc 0x00 0x00
    0xff 0xf8 0x0f 0xe0 0xff 0xf0 0x0f 0xe0
    0xff 0xe0 0x0c 0x30 0xff 0xc0 0x0c 0x30
    0xff 0x80 0x0f 0xe0 0xff 0x00 0x0f 0xe0
    0xfe 0x00 0x0c 0x30 0xfc 0x00 0x0c 0x30
    0xf8 0x00 0x0f 0xe0 0xf0 0x00 0x0f 0xe0
    0xe0 0x00 0x00 0x00 0xc0 0x00 0x00 0x00
    0x80 0x00 0x00 0x00 0x00 0x00 0x00 0x00
}


set pdf [HPDF_New]

HPDF_SetCompressionMode $pdf $::haru::HPDF_COMP_ALL

# create default-font
set font [HPDF_GetFont $pdf "Helvetica" "WinAnsiEncoding"]

# add a new page object.
set page [HPDF_AddPage $pdf]

HPDF_Page_SetWidth $page 172
HPDF_Page_SetHeight $page 80

HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $font 20
HPDF_Page_MoveTextPos $page 10 [expr {[HPDF_Page_GetHeight $page] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "RawImageDemo" "WinAnsiEncoding"]
HPDF_Page_EndText $page

# load RGB raw-image file.
set image [HPDF_LoadRawImageFromFile $pdf [file join $demodir rawimage 32_32_rgb.dat] 32 32 HPDF_CS_DEVICE_RGB]

# Draw image to the canvas. (normal-mode with actual size.)
HPDF_Page_DrawImage $page $image 20 20 32 32

# load GrayScale raw-image file.
set image [HPDF_LoadRawImageFromFile $pdf [file join $demodir rawimage 32_32_gray.dat] 32 32 HPDF_CS_DEVICE_GRAY]

# Draw image to the canvas. (normal-mode with actual size.)
HPDF_Page_DrawImage $page $image 70 20 32 32

# load GrayScale raw-image (1bit) file from memory.
set lensize [expr {[string length $RAW_IMAGE_DATA] + 1}]
set image [HPDF_LoadRawImageFromMem $pdf $RAW_IMAGE_DATA 32 32 HPDF_CS_DEVICE_GRAY 1 $lensize]

# Draw image to the canvas. (normal-mode with actual size.)
HPDF_Page_DrawImage $page $image 120 20 32 32

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf

