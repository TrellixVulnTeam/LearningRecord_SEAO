#
# << Haru Free PDF Library 2.3.0 >> -- text_demo.c
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

proc show_stripe_pattern {page x y} {
    set iy 0
    set textwidth [HPDF_Page_TextWidth $page [haru::hpdf_encode "ABCabc123"]]
    while {$iy < 50} {
        HPDF_Page_SetRGBStroke $page 0.0 0.0 0.5
        HPDF_Page_SetLineWidth $page 1
        HPDF_Page_MoveTo $page $x [expr {$y + $iy}]
        HPDF_Page_LineTo $page [expr {$x + $textwidth}] [expr {$y + $iy}]
        HPDF_Page_Stroke $page
        incr iy 3
    }

    HPDF_Page_SetLineWidth $page 2.5
}

proc show_description {page x y text} {
    set fsize [HPDF_Page_GetCurrentFontSize $page]
    set font [HPDF_Page_GetCurrentFont $page]
    set c [HPDF_Page_GetRGBFill $page]

    HPDF_Page_BeginText $page
    HPDF_Page_SetRGBFill $page 0 0 0
    HPDF_Page_SetTextRenderingMode $page HPDF_FILL
    HPDF_Page_SetFontAndSize $page $font 10
    HPDF_Page_TextOut $page $x [expr {$y - 12}] [haru::hpdf_encode $text]
    HPDF_Page_EndText $page
    HPDF_Page_SetFontAndSize $page $font $fsize
    HPDF_Page_SetRGBFill $page [dict get $c r] [dict get $c g] [dict get $c b]
}

set page_title "Text Demo"
set samp_text "abcdefgABCDEFG123!#$%&+-@?"
set samp_text2 "The quick brown fox jumps over the lazy dog."

set pdf [HPDF_New]

# set compression mode
HPDF_SetCompressionMode $pdf $::haru::HPDF_COMP_ALL

# create default-font
set font [HPDF_GetFont $pdf "Helvetica" ""]

# add a new page object.
set page [HPDF_AddPage $pdf]

# draw grid to the page
print_grid $pdf $page

# print the lines of the page.
HPDF_Page_SetLineWidth $page 1
HPDF_Page_Rectangle $page 45 45 [expr {[HPDF_Page_GetWidth $page] - 70}] [expr {[HPDF_Page_GetHeight $page] - 110}]
HPDF_Page_Stroke $page

# print the title of the page (with positioning center).
HPDF_Page_SetFontAndSize $page $font 24
set tw [HPDF_Page_TextWidth $page [haru::hpdf_encode $page_title]]
HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {([HPDF_Page_GetWidth $page] - $tw) / 2.0}] [expr {[HPDF_Page_GetHeight $page] - 50}]
HPDF_Page_ShowText $page [haru::hpdf_encode $page_title]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page 
HPDF_Page_MoveTextPos $page 60 [expr {[HPDF_Page_GetHeight $page] - 60}]

set fsize 8

while {$fsize < 60} {

    set fsize [expr {int($fsize)}]

    # set style and size of font.
    HPDF_Page_SetFontAndSize $page $font $fsize

    # set the position of the text.
    HPDF_Page_MoveTextPos $page 0 [expr {-5 - $fsize}]
    set buf $samp_text

    # measure the number of characters which included in the page.
    set length [HPDF_Page_MeasureText $page [haru::hpdf_encode $samp_text] [expr {[HPDF_Page_GetWidth $page] - 120}] \
                                            $::haru::HPDF_FALSE 0]

    # truncate the text.
    set buf [string range $buf 0 $length]
    HPDF_Page_ShowText $page [haru::hpdf_encode $buf]

    # print the description.
    HPDF_Page_MoveTextPos $page 0 -10
    HPDF_Page_SetFontAndSize $page $font 8
    HPDF_Page_ShowText $page [haru::hpdf_encode "Fontsize=$fsize"]

    set fsize [expr {$fsize * 1.5}]
    
}

# font color
HPDF_Page_SetFontAndSize $page $font 8
HPDF_Page_MoveTextPos $page 0 -30
HPDF_Page_ShowText $page [haru::hpdf_encode "Font color"]
HPDF_Page_SetFontAndSize $page $font 18
HPDF_Page_MoveTextPos $page 0 -20
set length [string length $samp_text]

for {set i 0} {$i < $length} {incr i} {
    set r [expr {$i / double($length)}]
    set g [expr {1 - ($i / double($length))}]

    HPDF_Page_SetRGBFill $page $r $g 0
    HPDF_Page_ShowText $page [haru::hpdf_encode [string range $samp_text $i $i]]

}

HPDF_Page_MoveTextPos $page 0 -25

for {set i 0} {$i < $length} {incr i} {
    set r [expr {$i / double($length)}]
    set b [expr {1 - ($i / double($length))}]

    HPDF_Page_SetRGBFill $page $r 0 $b
    HPDF_Page_ShowText $page [haru::hpdf_encode [string range $samp_text $i $i]]

}

HPDF_Page_MoveTextPos $page 0 -25

for {set i 0} {$i < $length} {incr i} {
    set b [expr {$i / double($length)}]
    set g [expr {1 - ($i / double($length))}]

    HPDF_Page_SetRGBFill $page 0 $g $b
    HPDF_Page_ShowText $page [haru::hpdf_encode [string range $samp_text $i $i]]

}

HPDF_Page_EndText $page

set ypos 450
# Font rendering mode

HPDF_Page_SetFontAndSize $page $font 32
HPDF_Page_SetRGBFill $page 0.5 0.5 0.0
HPDF_Page_SetLineWidth $page 1.5

# PDF_FILL
show_description $page 60 $ypos "RenderingMode=PDF_FILL"
HPDF_Page_SetTextRenderingMode $page HPDF_FILL
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 $ypos [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page

# PDF_STROKE
show_description $page 60 [expr {$ypos - 50}] "RenderingMode=PDF_STROKE"
HPDF_Page_SetTextRenderingMode $page HPDF_STROKE
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 [expr {$ypos - 50}] [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page

# PDF_FILL_THEN_STROKE
show_description $page 60 [expr {$ypos - 100}] "RenderingMode=PDF_FILL_THEN_STROKE"
HPDF_Page_SetTextRenderingMode $page HPDF_FILL_THEN_STROKE
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 [expr {$ypos - 100}] [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page

# PDF_FILL_CLIPPING
show_description $page 60 [expr {$ypos - 150}] "RenderingMode=PDF_FILL_CLIPPING"
HPDF_Page_GSave $page
HPDF_Page_SetTextRenderingMode $page HPDF_FILL_CLIPPING
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 [expr {$ypos - 150}] [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page
show_stripe_pattern $page 60 [expr {$ypos - 150}]
HPDF_Page_GRestore $page

# PDF_STROKE_CLIPPING
show_description $page 60 [expr {$ypos - 200}] "RenderingMode=PDF_STROKE_CLIPPING"
HPDF_Page_GSave $page
HPDF_Page_SetTextRenderingMode $page HPDF_STROKE_CLIPPING
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 [expr {$ypos - 200}] [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page
show_stripe_pattern $page 60 [expr {$ypos - 200}]
HPDF_Page_GRestore $page

# PDF_FILL_STROKE_CLIPPING
show_description $page 60 [expr {$ypos - 250}] "RenderingMode=PDF_FILL_STROKE_CLIPPING"
HPDF_Page_GSave $page
HPDF_Page_SetTextRenderingMode $page HPDF_FILL_STROKE_CLIPPING
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 [expr {$ypos - 250}] [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page
show_stripe_pattern $page 60 [expr {$ypos - 250}]
HPDF_Page_GRestore $page

# Reset text attributes
HPDF_Page_SetTextRenderingMode $page HPDF_FILL
HPDF_Page_SetRGBFill $page 0 0 0
HPDF_Page_SetFontAndSize $page $font 30

# Rotating text
set angle1 30
set rad1 [haru::DegreesToRadians $angle1]

show_description $page 320 [expr {$ypos - 60}] "Rotating text"
HPDF_Page_BeginText $page
HPDF_Page_SetTextMatrix $page [expr {cos($rad1)}] [expr {sin($rad1)}] \
                              [expr {-sin($rad1)}] [expr {cos($rad1)}] 330 \
                              [expr {$ypos - 60}]

HPDF_Page_ShowText $page [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page

# Skewing text.
show_description $page 320 [expr {$ypos - 120}] "Skewing text"
HPDF_Page_BeginText $page

set angle1 10
set angle2 20

set rad1 [haru::DegreesToRadians $angle1]
set rad2 [haru::DegreesToRadians $angle2]

HPDF_Page_SetTextMatrix $page 1 [expr {tan($rad1)}] [expr {tan($rad2)}] 1 320 [expr {$ypos - 120}]
HPDF_Page_ShowText $page [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page


# scaling text (X direction)
show_description $page 320 [expr {$ypos - 175}] "Scaling text (X direction)"
HPDF_Page_BeginText $page
HPDF_Page_SetTextMatrix $page 1.5 0 0 1 320 [expr {$ypos - 175}]
HPDF_Page_ShowText $page [haru::hpdf_encode "ABCabc12"]
HPDF_Page_EndText $page

# scaling text (Y direction)
show_description $page 320 [expr {$ypos - 250}] "Scaling text (Y direction)"
HPDF_Page_BeginText $page
HPDF_Page_SetTextMatrix $page 1 0 0 2 320 [expr {$ypos - 250}]
HPDF_Page_ShowText $page [haru::hpdf_encode "ABCabc123"]
HPDF_Page_EndText $page

# char spacing, word spacing
show_description $page 60 140 "char-spacing 0"
show_description $page 60 100 "char-spacing 1.5"
show_description $page 60 60 "char-spacing 1.5, word-spacing 2.5"

HPDF_Page_SetFontAndSize $page $font 20
HPDF_Page_SetRGBFill $page 0.1 0.3 0.1

# char-spacing 0
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 140 [haru::hpdf_encode $samp_text2]
HPDF_Page_EndText $page

# char-spacing 1.5
HPDF_Page_SetCharSpace $page 1.5
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 100 [haru::hpdf_encode $samp_text2]
HPDF_Page_EndText $page

# char-spacing 1.5, word-spacing 3.5
HPDF_Page_SetCharSpace $page 2.5
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page 60 60 [haru::hpdf_encode $samp_text2]
HPDF_Page_EndText $page

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf