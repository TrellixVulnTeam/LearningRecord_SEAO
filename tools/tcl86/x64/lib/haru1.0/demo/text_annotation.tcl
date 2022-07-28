#
# << Haru Free PDF Library 2.3.0 >> -- text_annotation.c
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

set rect1 {left 50 bottom 350 right 150 top 400}
set rect2 {left 210 bottom 350 right 350 top 400}
set rect3 {left 50 bottom 250 right 150 top 300}
set rect4 {left 210 bottom 250 right 350 top 300}
set rect5 {left 50 bottom 150 right 150 top 200}
set rect6 {left 210 bottom 150 right 350 top 200}
set rect7 {left 50 bottom 50 right 150 top 100}
set rect8 {left 210 bottom 50 right 350 top 100}

set pdf [HPDF_New]
set encode "WinAnsiEncoding"

# create default-font
set font [HPDF_GetFont $pdf "Times-Roman" $encode]

# create index page
set page [HPDF_AddPage $pdf]
HPDF_Page_SetWidth $page 400
HPDF_Page_SetHeight $page 500

HPDF_Page_BeginText $page

HPDF_Page_SetFontAndSize $page $font 16
HPDF_Page_MoveTextPos $page 130 450
HPDF_Page_ShowText $page [haru::hpdf_encode "Annotation Demo" $encode]
HPDF_Page_EndText $page

set text [haru::hpdf_encode "Annotation with Comment Icon. \n This annotation set to be opened initially." $encode]
set annot [HPDF_Page_CreateTextAnnot $page $rect1 $text NULL]

HPDF_TextAnnot_SetIcon $annot HPDF_ANNOT_ICON_COMMENT
HPDF_TextAnnot_SetOpened $annot $::haru::HPDF_TRUE

set text [haru::hpdf_encode "Annotation with Key Icon" $encode]
set annot [HPDF_Page_CreateTextAnnot $page $rect2 $text NULL]

HPDF_TextAnnot_SetIcon $annot HPDF_ANNOT_ICON_PARAGRAPH

set text [haru::hpdf_encode "Annotation with Note Icon" $encode]
set annot [HPDF_Page_CreateTextAnnot $page $rect3 $text NULL]

HPDF_TextAnnot_SetIcon $annot HPDF_ANNOT_ICON_NOTE

set text [haru::hpdf_encode "Annotation with Help Icon" $encode]
set annot [HPDF_Page_CreateTextAnnot $page $rect4 $text NULL]

HPDF_TextAnnot_SetIcon $annot HPDF_ANNOT_ICON_HELP

set text [haru::hpdf_encode "Annotation with NewParagraph Icon" $encode]
set annot [HPDF_Page_CreateTextAnnot $page $rect5 $text NULL]

HPDF_TextAnnot_SetIcon $annot HPDF_ANNOT_ICON_NEW_PARAGRAPH

set text [haru::hpdf_encode "Annotation with Paragraph Icon" $encode]
set annot [HPDF_Page_CreateTextAnnot $page $rect6 $text NULL]

HPDF_TextAnnot_SetIcon $annot HPDF_ANNOT_ICON_PARAGRAPH

set text [haru::hpdf_encode "Annotation with Insert Icon" $encode]
set annot [HPDF_Page_CreateTextAnnot $page $rect7 $text NULL]

HPDF_TextAnnot_SetIcon $annot HPDF_ANNOT_ICON_INSERT

set encoding [HPDF_GetEncoder $pdf "ISO8859-2"]

HPDF_Page_SetFontAndSize $page $font 11

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {[dict get $rect1 left] + 35}] [expr {[dict get $rect1 top] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Comment Icon." $encode]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {[dict get $rect2 left] + 35}] [expr {[dict get $rect2 top] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Key Icon" $encode]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {[dict get $rect3 left] + 35}] [expr {[dict get $rect3 top] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Note Icon." $encode]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {[dict get $rect4 left] + 35}] [expr {[dict get $rect4 top] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Help Icon" $encode]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {[dict get $rect5 left] + 35}] [expr {[dict get $rect5 top] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "NewParagraph Icon" $encode]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {[dict get $rect6 left] + 35}] [expr {[dict get $rect6 top] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Paragraph Icon" $encode]
HPDF_Page_EndText $page

HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {[dict get $rect7 left] + 35}] [expr {[dict get $rect7 top] - 20}]
HPDF_Page_ShowText $page [haru::hpdf_encode "Insert Icon" $encode]
HPDF_Page_EndText $page


# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf