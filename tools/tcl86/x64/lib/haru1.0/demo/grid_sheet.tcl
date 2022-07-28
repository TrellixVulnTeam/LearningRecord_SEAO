#
# << Haru Free PDF Library 2.3.0 >> -- grid_sheet.c
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
    set font   [HPDF_GetFont $pdf "Helvetica" "StandardEncoding"]

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

set pdf [HPDF_New]
set page [HPDF_AddPage $pdf]
HPDF_Page_SetWidth $page 600
HPDF_Page_SetHeight $page 400

print_grid $pdf $page

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf