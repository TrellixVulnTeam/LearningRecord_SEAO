#
# << Haru Free PDF Library 2.3.0 >> -- line_demo.c
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

proc draw_line {page x y label} {

    HPDF_Page_BeginText $page
    HPDF_Page_MoveTextPos $page $x [expr {$y - 10}]
    HPDF_Page_ShowText $page [haru::hpdf_encode $label]
    HPDF_Page_EndText $page

    HPDF_Page_MoveTo $page $x [expr {$y - 15}]
    HPDF_Page_LineTo $page [expr {$x + 220}] [expr {$y - 15}]
    HPDF_Page_Stroke $page
}

proc draw_line2 {page x y label} {

    HPDF_Page_BeginText $page
    HPDF_Page_MoveTextPos $page $x $y
    HPDF_Page_ShowText $page [haru::hpdf_encode $label]
    HPDF_Page_EndText $page

    HPDF_Page_MoveTo $page [expr {$x + 30}] [expr {$y - 25}]
    HPDF_Page_LineTo $page [expr {$x + 160}] [expr {$y - 25}]
    HPDF_Page_Stroke $page
}

proc draw_rect {page x y label} {

    HPDF_Page_BeginText $page
    HPDF_Page_MoveTextPos $page $x [expr {$y - 10}]
    HPDF_Page_ShowText $page [haru::hpdf_encode $label]
    HPDF_Page_EndText $page


    HPDF_Page_Rectangle $page $x [expr {$y - 40}] 220 25
}


set page_title "Line Example"

set DASH_MODE1 {3}
set DASH_MODE2 {3 7}
set DASH_MODE3 {8 7 2 7}

set pdf [HPDF_New]

# create default-font
set font [HPDF_GetFont $pdf "Helvetica" ""]
# add a new page object.
set page [HPDF_AddPage $pdf]

# print the lines of the page.
HPDF_Page_SetLineWidth $page 1
HPDF_Page_Rectangle $page 50 50 [expr {[HPDF_Page_GetWidth $page] - 100}] [expr {[HPDF_Page_GetHeight $page] - 110}]
HPDF_Page_Stroke $page

# print the title of the page (with positioning center).
HPDF_Page_SetFontAndSize $page $font 24
set tw [HPDF_Page_TextWidth $page [haru::hpdf_encode $page_title]]
HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {([HPDF_Page_GetWidth $page] - $tw) / 2.0}] [expr {[HPDF_Page_GetHeight $page] - 50}]
HPDF_Page_ShowText $page [haru::hpdf_encode $page_title]
HPDF_Page_EndText $page

HPDF_Page_SetFontAndSize $page $font 10

# Draw verious widths of lines.
HPDF_Page_SetLineWidth $page 0
draw_line $page 60 770 "line width = 0"

HPDF_Page_SetLineWidth $page 1.0
draw_line $page 60 740 "line width = 1.0"

HPDF_Page_SetLineWidth $page 2.0
draw_line $page 60 710 "line width = 2.0"

# Line dash pattern
HPDF_Page_SetLineWidth $page 1.0

HPDF_Page_SetDash $page $DASH_MODE1 1 1
draw_line $page 60 680 "dash_ptn=\[3], phase=1 -- 2 on, 3 off, 3 on..."

HPDF_Page_SetDash $page $DASH_MODE2 2 2
draw_line $page 60 650 "dash_ptn=\[7, 3], phase=2 -- 5 on 3 off, 7 on,..."

HPDF_Page_SetDash $page $DASH_MODE3 4 0
draw_line $page 60 620 "dash_ptn=\[8, 7, 2, 7], phase=0"

HPDF_Page_SetDash $page "" 0 0

HPDF_Page_SetLineWidth $page 30
HPDF_Page_SetRGBStroke $page 0 0.5 0

# Line Cap Style
HPDF_Page_SetLineCap $page HPDF_BUTT_END
draw_line2 $page 60 570 "PDF_BUTT_END"

HPDF_Page_SetLineCap $page HPDF_ROUND_END
draw_line2 $page 60 505 "PDF_ROUND_END"

HPDF_Page_SetLineCap $page HPDF_PROJECTING_SCUARE_END
draw_line2 $page 60 440 "PDF_PROJECTING_SCUARE_END"

# Line Join Style
HPDF_Page_SetLineWidth $page 30
HPDF_Page_SetRGBStroke $page 0 0 0.5

HPDF_Page_SetLineJoin $page HPDF_MITER_JOIN
HPDF_Page_MoveTo $page 120 300
HPDF_Page_LineTo $page 160 340
HPDF_Page_LineTo $page 200 300
HPDF_Page_Stroke $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 60 360
HPDF_Page_ShowText $page [haru::hpdf_encode "PDF_MITER_JOIN"]
HPDF_Page_EndText $page


HPDF_Page_SetLineJoin $page HPDF_ROUND_JOIN
HPDF_Page_MoveTo $page 120 195
HPDF_Page_LineTo $page 160 235
HPDF_Page_LineTo $page 200 195
HPDF_Page_Stroke $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 60 255
HPDF_Page_ShowText $page [haru::hpdf_encode "PDF_ROUND_JOIN"]
HPDF_Page_EndText $page


HPDF_Page_SetLineJoin $page HPDF_BEVEL_JOIN
HPDF_Page_MoveTo $page 120 90
HPDF_Page_LineTo $page 160 130
HPDF_Page_LineTo $page 200 90
HPDF_Page_Stroke $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 60 150
HPDF_Page_ShowText $page [haru::hpdf_encode "PDF_BEVEL_JOIN"]
HPDF_Page_EndText $page

# Draw Rectangle
HPDF_Page_SetLineWidth $page 2
HPDF_Page_SetRGBStroke $page 0 0 0
HPDF_Page_SetRGBFill $page 0.75 0 0

draw_rect $page 300 770 "Stroke"
HPDF_Page_Stroke $page

draw_rect $page 300 720 "Fill"
HPDF_Page_Fill $page

draw_rect $page 300 670 "Fill then Stroke"
HPDF_Page_FillStroke $page

# Clip Rect
HPDF_Page_GSave $page ;  # Save the current graphic state
draw_rect $page 300 620 "Clip Rectangle"
HPDF_Page_Clip $page
HPDF_Page_Stroke $page
HPDF_Page_SetFontAndSize $page $font 13

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 290 600
HPDF_Page_SetTextLeading $page 12
HPDF_Page_ShowText $page [haru::hpdf_encode "Clip Clip Clip Clip Clip Clipi Clip Clip Clip"]
HPDF_Page_ShowTextNextLine $page [haru::hpdf_encode "Clip Clip Clip Clip Clip Clip Clip Clip Clip"]
HPDF_Page_ShowTextNextLine $page [haru::hpdf_encode "Clip Clip Clip Clip Clip Clip Clip Clip Clip"]
HPDF_Page_EndText $page
HPDF_Page_GRestore $page

# Curve Example(CurveTo2)
set x  330
set y  440
set x1 430
set y1 530
set x2 480
set y2 470
set x3 480
set y3 90

HPDF_Page_SetRGBFill $page 0 0 0

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 300 540
HPDF_Page_ShowText $page [haru::hpdf_encode "CurveTo2(x1, y1, x2. y2)"]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {$x + 5}] [expr {$y - 5}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Current point"]
HPDF_Page_MoveTextPos $page [expr {$x1 - $x}] [expr {$y1 - $y}]
HPDF_Page_ShowText $page [haru::hpdf_encode "(x1, y1)"]
HPDF_Page_MoveTextPos $page [expr {$x2 - $x1}] [expr {$y2 - $y1}]
HPDF_Page_ShowText $page [haru::hpdf_encode "(x2, y2)"]
HPDF_Page_EndText $page

HPDF_Page_SetDash $page $DASH_MODE1 1 0

HPDF_Page_SetLineWidth $page 0.5
HPDF_Page_MoveTo $page $x1 $y1
HPDF_Page_LineTo $page $x2 $y2
HPDF_Page_Stroke $page

HPDF_Page_SetDash $page "" 0 0

HPDF_Page_SetLineWidth $page 1.5
HPDF_Page_MoveTo $page $x $y
HPDF_Page_CurveTo3 $page $x1 $y1 $x2 $y2
HPDF_Page_Stroke $page


# Curve Example(CurveTo3)
incr y -150
incr y1 -150
incr y2 -150

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 300 390
HPDF_Page_ShowText $page [haru::hpdf_encode "CurveTo3(x1, y1, x2. y2)"]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {$x + 5}] [expr {$y - 5}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Current point"]
HPDF_Page_MoveTextPos $page [expr {$x1 - $x}] [expr {$y1 - $y}]
HPDF_Page_ShowText $page [haru::hpdf_encode "(x1, y1)"]
HPDF_Page_MoveTextPos $page [expr {$x2 - $x1}] [expr {$y2 - $y1}]
HPDF_Page_ShowText $page [haru::hpdf_encode "(x2, y2)"]
HPDF_Page_EndText $page

HPDF_Page_SetDash $page $DASH_MODE1 1 0

HPDF_Page_SetLineWidth $page 0.5
HPDF_Page_MoveTo $page $x $y
HPDF_Page_LineTo $page $x1 $y1
HPDF_Page_Stroke $page

HPDF_Page_SetDash $page "" 0 0

HPDF_Page_SetLineWidth $page 1.5
HPDF_Page_MoveTo $page $x $y
HPDF_Page_CurveTo3 $page $x1 $y1 $x2 $y2
HPDF_Page_Stroke $page


# Curve Example(CurveTo)
incr y -150
incr y1 -160
incr y2 -130
incr x2 10

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 300 240
HPDF_Page_ShowText $page [haru::hpdf_encode "CurveTo(x1, y1, x2. y2, x3, y3)"]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {$x + 5}] [expr {$y - 5}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Current point"]
HPDF_Page_MoveTextPos $page [expr {$x1 - $x}] [expr {$y1 - $y}]
HPDF_Page_ShowText $page [haru::hpdf_encode "(x1, y1)"]
HPDF_Page_MoveTextPos $page [expr {$x2 - $x1}] [expr {$y2 - $y1}]
HPDF_Page_ShowText $page [haru::hpdf_encode "(x2, y2)"]
HPDF_Page_MoveTextPos $page [expr {$x3 - $x2}] [expr {$y3 - $y2}]
HPDF_Page_ShowText $page [haru::hpdf_encode "(x3, y3)"]
HPDF_Page_EndText $page

HPDF_Page_SetDash $page $DASH_MODE1 1 0

HPDF_Page_SetLineWidth $page 0.5
HPDF_Page_MoveTo $page $x $y
HPDF_Page_LineTo $page $x1 $y1
HPDF_Page_Stroke $page
HPDF_Page_MoveTo $page $x2 $y2
HPDF_Page_LineTo $page $x3 $y3
HPDF_Page_Stroke $page

HPDF_Page_SetDash $page "" 0 0

HPDF_Page_SetLineWidth $page 1.5
HPDF_Page_MoveTo $page $x $y
HPDF_Page_CurveTo $page $x1 $y1 $x2 $y2 $x3 $y3
HPDF_Page_Stroke $page

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf