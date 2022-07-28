#
# << Haru Free PDF Library 2.3.0 >> -- slide_show_demo.c
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

proc print_page {page caption font style prev next encoding_name} {

    set r [expr {rand()}]
    set g [expr {rand()}]
    set b [expr {rand()}]

    HPDF_Page_SetWidth $page 800
    HPDF_Page_SetHeight $page 600

    HPDF_Page_SetRGBFill $page $r $g $b

    HPDF_Page_Rectangle $page 0 0 800 600
    HPDF_Page_Fill $page

    HPDF_Page_SetRGBFill $page [expr {1.0 - $r}] [expr {1.0 - $g}] [expr {1.0 - $b}]

    HPDF_Page_SetFontAndSize $page $font 30

    HPDF_Page_BeginText $page
    HPDF_Page_SetTextMatrix $page 0.8 0.0 0.0 1.0 0.0 0.0
    HPDF_Page_TextOut $page 50 530 [haru::hpdf_encode $caption $encoding_name]

    HPDF_Page_SetTextMatrix $page 1.0 0.0 0.0 1.0 0.0 0.0
    HPDF_Page_SetFontAndSize $page $font 20

    HPDF_Page_TextOut $page 55 300 [haru::hpdf_encode "Type 'Ctrl+L' in order to return from full screen mode!\u00a9" $encoding_name]
    HPDF_Page_EndText $page

    HPDF_Page_SetSlideShow $page $style 5.0 1.0
    HPDF_Page_SetFontAndSize $page $font 20

    if {$next ne "NULL"} {
        HPDF_Page_BeginText $page
        HPDF_Page_TextOut $page 680 50 [haru::hpdf_encode "Next" $encoding_name]
        HPDF_Page_EndText $page

        set rect {left 680 right 750 top 70 bottom 50}
        set dst [HPDF_Page_CreateDestination $next]
        HPDF_Destination_SetFit $dst
        set annot [HPDF_Page_CreateLinkAnnot $page $rect $dst]
        HPDF_LinkAnnot_SetBorderStyle $annot 0 0 0
        HPDF_LinkAnnot_SetHighlightMode $annot HPDF_ANNOT_INVERT_BOX
    }

    if {$prev ne "NULL"} {
        HPDF_Page_BeginText $page
        HPDF_Page_TextOut $page 50 50 [haru::hpdf_encode "<=Prev" $encoding_name]
        HPDF_Page_EndText $page

        set rect {left 50 right 110 top 70 bottom 50}
        set dst [HPDF_Page_CreateDestination $prev]
        HPDF_Destination_SetFit $dst
        set annot [HPDF_Page_CreateLinkAnnot $page $rect $dst]
        HPDF_LinkAnnot_SetBorderStyle $annot 0 0 0
        HPDF_LinkAnnot_SetHighlightMode $annot HPDF_ANNOT_INVERT_BOX
    }

}

set pdf [HPDF_New]
set encoding_name "CP1252"

# create default-font
set font [HPDF_GetFont $pdf "Courier" $encoding_name]

# Add 17 pages to the document.
for {set i 0} {$i < 17} {incr i} {
    set page($i) [HPDF_AddPage $pdf]
}

print_page $page(0)  "HPDF_TS_WIPE_RIGHT" $font HPDF_TS_WIPE_RIGHT "NULL" $page(1) $encoding_name
print_page $page(1)  "HPDF_TS_WIPE_UP" $font HPDF_TS_WIPE_UP $page(0) $page(2) $encoding_name
print_page $page(2)  "HPDF_TS_WIPE_LEFT" $font HPDF_TS_WIPE_LEFT $page(1) $page(3) $encoding_name
print_page $page(3)  "HPDF_TS_WIPE_DOWN" $font HPDF_TS_WIPE_DOWN $page(2) $page(4) $encoding_name
print_page $page(4)  "HPDF_TS_BARN_DOORS_HORIZONTAL_OUT" $font HPDF_TS_BARN_DOORS_HORIZONTAL_OUT $page(3) $page(5) $encoding_name
print_page $page(5)  "HPDF_TS_BARN_DOORS_HORIZONTAL_IN" $font HPDF_TS_BARN_DOORS_HORIZONTAL_IN $page(4) $page(6) $encoding_name
print_page $page(6)  "HPDF_TS_BARN_DOORS_VERTICAL_OUT" $font HPDF_TS_BARN_DOORS_VERTICAL_OUT $page(5) $page(7) $encoding_name
print_page $page(7)  "HPDF_TS_BARN_DOORS_VERTICAL_IN" $font HPDF_TS_BARN_DOORS_VERTICAL_IN $page(6) $page(8) $encoding_name
print_page $page(8)  "HPDF_TS_BOX_OUT" $font HPDF_TS_BOX_OUT $page(7) $page(9) $encoding_name
print_page $page(9)  "HPDF_TS_BOX_IN" $font HPDF_TS_BOX_IN $page(8) $page(10) $encoding_name
print_page $page(10) "HPDF_TS_BLINDS_HORIZONTAL" $font HPDF_TS_BLINDS_HORIZONTAL $page(9) $page(11) $encoding_name
print_page $page(11) "HPDF_TS_BLINDS_VERTICAL" $font HPDF_TS_BLINDS_VERTICAL $page(10) $page(12) $encoding_name
print_page $page(12) "HPDF_TS_DISSOLVE" $font HPDF_TS_DISSOLVE $page(11) $page(13) $encoding_name
print_page $page(13) "HPDF_TS_GLITTER_RIGHT" $font HPDF_TS_GLITTER_RIGHT $page(12) $page(14) $encoding_name
print_page $page(14) "HPDF_TS_GLITTER_DOWN" $font HPDF_TS_GLITTER_DOWN $page(13) $page(15) $encoding_name
print_page $page(15) "HPDF_TS_GLITTER_TOP_LEFT_TO_BOTTOM_RIGHT" $font HPDF_TS_GLITTER_TOP_LEFT_TO_BOTTOM_RIGHT $page(14) $page(16) $encoding_name
print_page $page(16) "HPDF_TS_REPLACE" $font HPDF_TS_REPLACE $page(15) "NULL" $encoding_name


HPDF_SetPageMode $pdf HPDF_PAGE_MODE_FULL_SCREEN

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf