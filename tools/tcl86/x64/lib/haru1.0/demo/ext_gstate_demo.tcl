#
# << Haru Free PDF Library 2.3.0 >> -- ext_gstate_demo.c
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

proc draw_circles {page description x y} {

    HPDF_Page_SetLineWidth $page 1.0
    HPDF_Page_SetRGBStroke $page 0.0 0.0 0.0
    HPDF_Page_SetRGBFill $page 1.0 0.0 0.0
    HPDF_Page_Circle $page [expr {$x + 40}] [expr {$y + 40}] 40
    HPDF_Page_ClosePathFillStroke $page
    HPDF_Page_SetRGBFill $page 0.0 1.0 0.0
    HPDF_Page_Circle $page [expr {$x + 100}] [expr {$y + 40}] 40
    HPDF_Page_ClosePathFillStroke $page
    HPDF_Page_SetRGBFill $page 0.0 0.0 1.0
    HPDF_Page_Circle $page [expr {$x + 70}] [expr {$y + 74.64}] 40
    HPDF_Page_ClosePathFillStroke $page

    HPDF_Page_SetRGBFill $page 0.0 0.0 0.0
    HPDF_Page_BeginText $page
    HPDF_Page_TextOut $page [expr {$x + 0.0}] [expr {$y + 130.0}] [haru::hpdf_encode $description]
    HPDF_Page_EndText $page

}

set PAGE_WIDTH 600
set PAGE_HEIGHT 900

set pdf [HPDF_New]
set hfont [HPDF_GetFont $pdf "Helvetica-Bold" "StandardEncoding"]

set page [HPDF_AddPage $pdf]

HPDF_Page_SetFontAndSize $page $hfont 10
HPDF_Page_SetHeight $page $PAGE_HEIGHT
HPDF_Page_SetWidth $page $PAGE_WIDTH

# normal
HPDF_Page_GSave $page
draw_circles $page "normal" 40.0 [expr {$PAGE_HEIGHT - 170}]
HPDF_Page_GRestore $page

# transparency 0.8
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetAlphaFill $gstate 0.8
HPDF_ExtGState_SetAlphaStroke $gstate 0.8
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "alpha fill = 0.8" 230.0 [expr {$PAGE_HEIGHT - 170}]
HPDF_Page_GRestore $page

# transparency 0.4
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetAlphaFill $gstate 0.4
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "alpha fill = 0.4" 420.0 [expr {$PAGE_HEIGHT - 170}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_MULTIPLY
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_MULTIPLY
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_MULTIPLY" 40.0 [expr {$PAGE_HEIGHT - 340}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_SCREEN
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_SCREEN
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_SCREEN" 230.0 [expr {$PAGE_HEIGHT - 340}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_OVERLAY
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_OVERLAY
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_OVERLAY" 420.0 [expr {$PAGE_HEIGHT - 340}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_DARKEN
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_DARKEN
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_DARKEN" 40.0 [expr {$PAGE_HEIGHT - 510}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_LIGHTEN
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_LIGHTEN
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_LIGHTEN" 230.0 [expr {$PAGE_HEIGHT - 510}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_COLOR_DODGE
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_COLOR_DODGE
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_COLOR_DODGE" 420.0 [expr {$PAGE_HEIGHT - 510}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_COLOR_BUM
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_COLOR_BUM
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_COLOR_BUM" 40.0 [expr {$PAGE_HEIGHT - 680}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_HARD_LIGHT
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_HARD_LIGHT
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_HARD_LIGHT" 230.0 [expr {$PAGE_HEIGHT - 680}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_SOFT_LIGHT
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_SOFT_LIGHT
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_SOFT_LIGHT" 420.0 [expr {$PAGE_HEIGHT - 680}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_DIFFERENCE
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_DIFFERENCE
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_DIFFERENCE" 40.0 [expr {$PAGE_HEIGHT - 850}]
HPDF_Page_GRestore $page

# blend-mode=HPDF_BM_EXCLUSHON
HPDF_Page_GSave $page
set gstate [HPDF_CreateExtGState $pdf]
HPDF_ExtGState_SetBlendMode $gstate HPDF_BM_EXCLUSHON
HPDF_Page_SetExtGState $page $gstate
draw_circles $page "HPDF_BM_EXCLUSHON" 230.0 [expr {$PAGE_HEIGHT - 850}]
HPDF_Page_GRestore $page

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf