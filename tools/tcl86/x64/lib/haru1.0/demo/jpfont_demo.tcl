#
# << Haru Free PDF Library 2.3.0 >> -- jpfont_demo.c
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

set PAGE_HEIGHT 210
set fp [open [file join $demodir mbtext sjis.txt] rb]

fconfigure $fp -encoding shiftjis
set samp_text [read $fp]
close $fp

set pdf [HPDF_New]

HPDF_SetCompressionMode $pdf $::haru::HPDF_COMP_ALL

# declaration for using Japanese font, encoding.
HPDF_UseJPEncodings $pdf
HPDF_UseJPFonts $pdf

set detail_font(0)  [HPDF_GetFont $pdf "MS-Mincho" "90ms-RKSJ-H"]
set detail_font(1)  [HPDF_GetFont $pdf "MS-Mincho,Bold" "90ms-RKSJ-H"]
set detail_font(2)  [HPDF_GetFont $pdf "MS-Mincho,Italic" "90ms-RKSJ-H"]
set detail_font(3)  [HPDF_GetFont $pdf "MS-Mincho,BoldItalic" "90ms-RKSJ-H"]
set detail_font(4)  [HPDF_GetFont $pdf "MS-PMincho" "90msp-RKSJ-H"]
set detail_font(5)  [HPDF_GetFont $pdf "MS-PMincho,Bold" "90msp-RKSJ-H"]
set detail_font(6)  [HPDF_GetFont $pdf "MS-PMincho,Italic" "90msp-RKSJ-H"]
set detail_font(7)  [HPDF_GetFont $pdf "MS-PMincho,BoldItalic" "90msp-RKSJ-H"]
set detail_font(8)  [HPDF_GetFont $pdf "MS-Gothic" "90ms-RKSJ-H"]
set detail_font(9)  [HPDF_GetFont $pdf "MS-Gothic,Bold" "90ms-RKSJ-H"]
set detail_font(10) [HPDF_GetFont $pdf "MS-Gothic,Italic" "90ms-RKSJ-H"]
set detail_font(11) [HPDF_GetFont $pdf "MS-Gothic,BoldItalic" "90ms-RKSJ-H"]
set detail_font(12) [HPDF_GetFont $pdf "MS-PGothic" "90msp-RKSJ-H"]
set detail_font(13) [HPDF_GetFont $pdf "MS-PGothic,Bold" "90msp-RKSJ-H"]
set detail_font(14) [HPDF_GetFont $pdf "MS-PGothic,Italic" "90msp-RKSJ-H"]
set detail_font(15) [HPDF_GetFont $pdf "MS-PGothic,BoldItalic" "90msp-RKSJ-H"]

HPDF_SetPageMode $pdf HPDF_PAGE_MODE_USE_OUTLINE

set root [HPDF_CreateOutline $pdf NULL "JP font demo" NULL]
HPDF_Outline_SetOpened $root $::haru::HPDF_TRUE

for {set i 0} {$i < 16} {incr i} {
    set page [HPDF_AddPage $pdf]

    # create outline entry
    set getfontname [HPDF_Font_GetFontName $detail_font($i)]
    set outline [HPDF_CreateOutline $pdf $root $getfontname NULL]
    set dst [HPDF_Page_CreateDestination $page]
    HPDF_Outline_SetDestination $outline $dst

    set title_font [HPDF_GetFont $pdf "Helvetica" ""]
    HPDF_Page_SetFontAndSize $page $title_font 10

    HPDF_Page_BeginText $page

    # move the position of the text to top of the page.
    HPDF_Page_MoveTextPos $page 10 190
    HPDF_Page_ShowText $page [haru::hpdf_encode $getfontname]
    HPDF_Page_SetFontAndSize $page $detail_font($i) 15
    HPDF_Page_MoveTextPos $page 10 -20
    HPDF_Page_ShowText $page [haru::hpdf_encode "abcdefghijklmnopqrstuvwxyz"]
    HPDF_Page_MoveTextPos $page 0 -20
    HPDF_Page_ShowText $page [haru::hpdf_encode "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    HPDF_Page_MoveTextPos $page 0 -20
    HPDF_Page_ShowText $page [haru::hpdf_encode "1234567890"]
    HPDF_Page_MoveTextPos $page 0 -20

    HPDF_Page_SetFontAndSize $page $detail_font($i) 10
    HPDF_Page_ShowText $page [haru::hpdf_encode $samp_text "shiftjis"]
    HPDF_Page_MoveTextPos $page 0 -18

    HPDF_Page_SetFontAndSize $page $detail_font($i) 16
    HPDF_Page_ShowText $page [haru::hpdf_encode $samp_text "shiftjis"]
    HPDF_Page_MoveTextPos $page 0 -27

    HPDF_Page_SetFontAndSize $page $detail_font($i) 23
    HPDF_Page_ShowText $page [haru::hpdf_encode $samp_text "shiftjis"]
    HPDF_Page_MoveTextPos $page 0 -36

    HPDF_Page_SetFontAndSize $page $detail_font($i) 30
    HPDF_Page_ShowText $page [haru::hpdf_encode $samp_text "shiftjis"]

    set p [HPDF_Page_GetCurrentTextPos $page]
    set px [dict get $p x]
    set py [dict get $p y]

    # finish to print text.
    HPDF_Page_EndText $page

    HPDF_Page_SetLineWidth $page 0.5

    set x_pos 20

    for {set j 0} {$j < [string length $samp_text]} {incr j} {
        HPDF_Page_MoveTo $page $x_pos [expr {$py - 10}]
        HPDF_Page_LineTo $page $x_pos [expr {$py - 12}]
        HPDF_Page_Stroke $page
        incr x_pos 30
    }

    HPDF_Page_SetWidth $page [expr {$px + 20}]
    HPDF_Page_SetHeight $page $PAGE_HEIGHT

    HPDF_Page_MoveTo $page 10 [expr {$PAGE_HEIGHT - 25}]
    HPDF_Page_LineTo $page [expr {$px + 10}] [expr {$PAGE_HEIGHT - 25}]
    HPDF_Page_Stroke $page

    HPDF_Page_MoveTo $page 10 [expr {$PAGE_HEIGHT - 85}]
    HPDF_Page_LineTo $page [expr {$px + 10}] [expr {$PAGE_HEIGHT - 85}]
    HPDF_Page_Stroke $page

    HPDF_Page_MoveTo $page 10 [expr {$py - 12}]
    HPDF_Page_LineTo $page [expr {$px + 10}] [expr {$py - 12}]
    HPDF_Page_Stroke $page

}


# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf