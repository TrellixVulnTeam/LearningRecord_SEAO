#
# << Haru Free PDF Library 2.3.0 >> -- font_demo.c
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

set page_title "Font Demo"

set font_list {
    "Courier"
    "Courier-Bold"
    "Courier-Oblique"
    "Courier-BoldOblique"
    "Helvetica-Bold"
    "Helvetica-Oblique"
    "Helvetica-BoldOblique"
    "Times-Roman"
    "Times-Bold"
    "Times-Italic"
    "Times-BoldItalic"
    "Symbol"
    "ZapfDingbats"
}


set pdf [HPDF_New]
set page [HPDF_AddPage $pdf]

set height [HPDF_Page_GetHeight $page]
set width  [HPDF_Page_GetWidth $page]

# Print the lines of the page.
HPDF_Page_SetLineWidth $page 1
HPDF_Page_Rectangle $page 50 50 [expr {$width - 100}] [expr {$height - 110}]
HPDF_Page_Stroke $page

# Print the title of the page with positioning center.
set def_font [HPDF_GetFont $pdf "Helvetica" ""]
HPDF_Page_SetFontAndSize $page $def_font 24
set tw [HPDF_Page_TextWidth $page [haru::hpdf_encode $page_title]]
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page [expr {($width - $tw) / 2}] [expr {$height - 50}] [haru::hpdf_encode $page_title]
HPDF_Page_EndText $page

# output subtitle.
HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $def_font 16
HPDF_Page_TextOut $page 60 [expr {$height - 80}] [haru::hpdf_encode "<Standard Type1 fonts samples>"]
HPDF_Page_EndText $page
HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page 60 [expr {$height - 105}]

set samp_text "abcdefgABCDEFG12345!#$%&+-@?"

foreach f $font_list {

    set font [HPDF_GetFont $pdf $f ""]
    # print a label of text

    HPDF_Page_SetFontAndSize $page $def_font 9
    HPDF_Page_ShowText $page [haru::hpdf_encode $f]
    HPDF_Page_MoveTextPos $page 0 -18

    # print a sample text.
    HPDF_Page_SetFontAndSize $page $font 20
    HPDF_Page_ShowText $page [haru::hpdf_encode $samp_text]
    HPDF_Page_MoveTextPos $page 0 -20
}

HPDF_Page_EndText $page

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf

