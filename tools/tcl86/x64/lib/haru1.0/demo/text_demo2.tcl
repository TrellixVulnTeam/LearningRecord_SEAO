#
# << Haru Free PDF Library 2.3.0 >> -- text_demo2.c
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

proc print_grid {pdf page} {

    set height [HPDF_Page_GetHeight $page]
    set width  [HPDF_Page_GetWidth $page]
    set font   [HPDF_GetFont $pdf "Helvetica" ""]

    HPDF_Page_SetFontAndSize $page $font 5
    HPDF_Page_SetGrayFill $page 0.5
    HPDF_Page_SetGrayStroke $page 0.8

    set y 0
    while {$y < $height} {

        if {$y % 10 == 0} {
            HPDF_Page_SetLineWidth $page 0.5
        } else {
            if {[HPDF_Page_GetLineWidth $page] != 0.25} {
                HPDF_Page_SetLineWidth $page 0.25
            }
        }

        HPDF_Page_MoveTo $page 0 $y
        HPDF_Page_LineTo $page $width $y
        HPDF_Page_Stroke $page

        if {$y % 10 == 0 && $y > 0} {
            HPDF_Page_SetGrayStroke $page 0.5

            HPDF_Page_MoveTo $page 0 $y
            HPDF_Page_LineTo $page 5 $y
            HPDF_Page_Stroke $page

            HPDF_Page_SetGrayStroke $page 0.8
        }
        incr y 5
    }

    set x 0
    while {$x < $width} {

        if {$x % 10 == 0} {
            HPDF_Page_SetLineWidth $page 0.5
        } else {
            if {[HPDF_Page_GetLineWidth $page] != 0.25} {
                HPDF_Page_SetLineWidth $page 0.25
            }
        }

        HPDF_Page_MoveTo $page $x 0
        HPDF_Page_LineTo $page $x $height
        HPDF_Page_Stroke $page

        if {$x % 50 == 0 && $x > 0} {
            HPDF_Page_SetGrayStroke $page 0.5

            HPDF_Page_MoveTo $page $x 0
            HPDF_Page_LineTo $page $x 5
            HPDF_Page_Stroke $page

            HPDF_Page_MoveTo $page $x $height
            HPDF_Page_LineTo $page $x [expr {$height - 5}]
            HPDF_Page_Stroke $page

            HPDF_Page_SetGrayStroke $page 0.8
        }
        incr x 5
    }

    set y 0
    while {$y < $height} {

        if {$y % 10 == 0 && $y > 0} {

            HPDF_Page_BeginText $page
            HPDF_Page_MoveTextPos $page 5 [expr {$y - 2}]

            set buf [scan $y %d]

            HPDF_Page_ShowText $page $buf
            HPDF_Page_EndText $page

        }
        incr y 5
    }

    set x 0
    while {$x < $width} {

        if {$x % 50 == 0 && $x > 0} {

            HPDF_Page_BeginText $page
            HPDF_Page_MoveTextPos $page $x 5

            set buf [scan $x %d]

            HPDF_Page_ShowText $page $buf
            HPDF_Page_EndText $page

            HPDF_Page_BeginText $page
            HPDF_Page_MoveTextPos $page $x [expr {$height - 10}]
            HPDF_Page_ShowText $page $buf
            HPDF_Page_EndText $page

        }
        incr x 5
    } 

     HPDF_Page_SetGrayFill $page 0
     HPDF_Page_SetGrayStroke $page 0  
}


set samp_text "The quick brown fox jumps over the lazy dog."

set pdf [HPDF_New]

# create default-font
set font [HPDF_GetFont $pdf "Helvetica" ""]

# add a new page object.
set page [HPDF_AddPage $pdf]
HPDF_Page_SetSize $page HPDF_PAGE_SIZE_A5 HPDF_PAGE_PORTRAIT

# draw grid to the page
print_grid $pdf $page

HPDF_Page_SetTextLeading $page 20

# HPDF_TALIGN_LEFT
dict set rect left 20
dict set rect bottom 505
dict set rect right 200
dict set rect top 545

HPDF_Page_Rectangle $page [dict get $rect left] [dict get $rect bottom] \
                          [expr {[dict get $rect right] - [dict get $rect left]}] \
                          [expr {[dict get $rect top] - [dict get $rect bottom]}]

HPDF_Page_Stroke $page

HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $font 10
HPDF_Page_TextOut $page [dict get $rect left] [expr {[dict get $rect top] + 3}] [haru::hpdf_encode "HPDF_TALIGN_LEFT"]

HPDF_Page_SetFontAndSize $page $font 13
HPDF_Page_TextRect $page [dict get $rect left] [dict get $rect top] [dict get $rect right] [dict get $rect bottom] \
                         [haru::hpdf_encode $samp_text] HPDF_TALIGN_LEFT len

HPDF_Page_EndText $page

# HPDF_TALIGN_RIGHT
dict set rect left 220
dict set rect right 395

HPDF_Page_Rectangle $page [dict get $rect left] [dict get $rect bottom] \
                          [expr {[dict get $rect right] - [dict get $rect left]}] \
                          [expr {[dict get $rect top] - [dict get $rect bottom]}]

HPDF_Page_Stroke $page

HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $font 10
HPDF_Page_TextOut $page [dict get $rect left] [expr {[dict get $rect top] + 3}] [haru::hpdf_encode "HPDF_TALIGN_RIGHT"]

HPDF_Page_SetFontAndSize $page $font 13
HPDF_Page_TextRect $page [dict get $rect left] [dict get $rect top] [dict get $rect right] [dict get $rect bottom] \
                         [haru::hpdf_encode $samp_text] HPDF_TALIGN_RIGHT len

HPDF_Page_EndText $page

# HPDF_TALIGN_CENTER
dict set rect left 25
dict set rect bottom 435
dict set rect right 200
dict set rect top 475

HPDF_Page_Rectangle $page [dict get $rect left] [dict get $rect bottom] \
                          [expr {[dict get $rect right] - [dict get $rect left]}] \
                          [expr {[dict get $rect top] - [dict get $rect bottom]}]

HPDF_Page_Stroke $page

HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $font 10
HPDF_Page_TextOut $page [dict get $rect left] [expr {[dict get $rect top] + 3}] [haru::hpdf_encode "HPDF_TALIGN_CENTER"]

HPDF_Page_SetFontAndSize $page $font 13
HPDF_Page_TextRect $page [dict get $rect left] [dict get $rect top] [dict get $rect right] [dict get $rect bottom] \
                         [haru::hpdf_encode $samp_text] HPDF_TALIGN_CENTER len

HPDF_Page_EndText $page

# HPDF_TALIGN_JUSTIFY
dict set rect left 220
dict set rect right 395

HPDF_Page_Rectangle $page [dict get $rect left] [dict get $rect bottom] \
                          [expr {[dict get $rect right] - [dict get $rect left]}] \
                          [expr {[dict get $rect top] - [dict get $rect bottom]}]

HPDF_Page_Stroke $page

HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $font 10
HPDF_Page_TextOut $page [dict get $rect left] [expr {[dict get $rect top] + 3}] [haru::hpdf_encode "HPDF_TALIGN_JUSTIFY"]

HPDF_Page_SetFontAndSize $page $font 13
HPDF_Page_TextRect $page [dict get $rect left] [dict get $rect top] [dict get $rect right] [dict get $rect bottom] \
                         [haru::hpdf_encode $samp_text] HPDF_TALIGN_JUSTIFY len

HPDF_Page_EndText $page

# Skewed coordinate system
HPDF_Page_GSave $page

set angle1 5
set angle2 10
set rad1 [haru::DegreesToRadians $angle1]
set rad2 [haru::DegreesToRadians $angle2]

HPDF_Page_Concat $page 1 [expr {tan($rad1)}] [expr {tan($rad2)}] 1 25 350

dict set rect left 0
dict set rect bottom 0
dict set rect right 175
dict set rect top 40

HPDF_Page_Rectangle $page [dict get $rect left] [dict get $rect bottom] \
                          [expr {[dict get $rect right] - [dict get $rect left]}] \
                          [expr {[dict get $rect top] - [dict get $rect bottom]}]

HPDF_Page_Stroke $page
HPDF_Page_BeginText $page

HPDF_Page_SetFontAndSize $page $font 10
HPDF_Page_TextOut $page [dict get $rect left] [expr {[dict get $rect top] + 3}] [haru::hpdf_encode "Skewed coordinate system"]

HPDF_Page_SetFontAndSize $page $font 13
HPDF_Page_TextRect $page [dict get $rect left] [dict get $rect top] [dict get $rect right] [dict get $rect bottom] \
                         [haru::hpdf_encode $samp_text] HPDF_TALIGN_LEFT len

HPDF_Page_EndText $page
HPDF_Page_GRestore $page

# Rotated coordinate system
HPDF_Page_GSave $page

HPDF_Page_Concat $page [expr {cos($rad1)}] [expr {sin($rad1)}] [expr {-sin($rad1)}] [expr {cos($rad1)}] 220 350

HPDF_Page_Rectangle $page [dict get $rect left] [dict get $rect bottom] \
                          [expr {[dict get $rect right] - [dict get $rect left]}] \
                          [expr {[dict get $rect top] - [dict get $rect bottom]}]

HPDF_Page_Stroke $page
HPDF_Page_BeginText $page

HPDF_Page_SetFontAndSize $page $font 10
HPDF_Page_TextOut $page [dict get $rect left] [expr {[dict get $rect top] + 3}] [haru::hpdf_encode "Rotated coordinate system"]

HPDF_Page_SetFontAndSize $page $font 13
HPDF_Page_TextRect $page [dict get $rect left] [dict get $rect top] [dict get $rect right] [dict get $rect bottom] \
                         [haru::hpdf_encode $samp_text] HPDF_TALIGN_LEFT len

HPDF_Page_EndText $page
HPDF_Page_GRestore $page

# text along a circle

HPDF_Page_SetGrayStroke $page 0
HPDF_Page_Circle $page 210 190 145
HPDF_Page_Circle $page 210 190 113
HPDF_Page_Stroke $page

set angle1 [expr {360 / [string length $samp_text]}]
set angle2 180


HPDF_Page_BeginText $page

set font [HPDF_GetFont $pdf "Courier-Bold" ""]
HPDF_Page_SetFontAndSize $page $font 30

for {set i 0} {$i < [string length $samp_text]} {incr i} {

    set rad1 [haru::DegreesToRadians [expr {$angle2 - 90}]]
    set rad2 [haru::DegreesToRadians $angle2]

    set x [expr {210 + cos($rad2) * 122}]
    set y [expr {190 + sin($rad2) * 122}]

    HPDF_Page_SetTextMatrix $page [expr {cos($rad1)}] [expr {sin($rad1)}] [expr {-sin($rad1)}] [expr {cos($rad1)}] $x $y


    set buf [string range $samp_text $i $i]
    HPDF_Page_ShowText $page [haru::hpdf_encode $buf]

    set angle2 [expr {$angle2 - $angle1}]
    
}

HPDF_Page_EndText $page


# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf