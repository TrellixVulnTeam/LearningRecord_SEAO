#
# << Haru Free PDF Library 2.3.0 >> -- link_annotation.c
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

proc print_page {page font pagenum} {

    HPDF_Page_SetWidth $page 200
    HPDF_Page_SetHeight $page 200

    HPDF_Page_SetFontAndSize $page $font 20
    HPDF_Page_BeginText $page
    HPDF_Page_MoveTextPos $page 50 150

    HPDF_Page_ShowText $page [haru::hpdf_encode "Page:$pagenum"]
    HPDF_Page_EndText $page
    
}

set uri "http://libharu.org"

set pdf [HPDF_New]

# create default-font
set font [HPDF_GetFont $pdf "Helvetica" ""]
# create index page
set index_page [HPDF_AddPage $pdf]
HPDF_Page_SetWidth $index_page 300
HPDF_Page_SetHeight $index_page 220

# Add 7 pages to the document.
for {set i 0} {$i < 7} {incr i} {
    set page($i) [HPDF_AddPage $pdf]
    print_page $page($i) $font [expr {$i + 1}]
}

HPDF_Page_BeginText $index_page
HPDF_Page_SetFontAndSize $index_page $font 10
HPDF_Page_MoveTextPos $index_page 15 200
HPDF_Page_ShowText $index_page "Link Annotation Demo"
HPDF_Page_EndText $index_page

# Create Link-Annotation object on index page.
HPDF_Page_BeginText $index_page
HPDF_Page_SetFontAndSize $index_page $font 8
HPDF_Page_MoveTextPos $index_page 20 180
HPDF_Page_SetTextLeading $index_page 23

# page1 (HPDF_ANNOT_NO_HIGHTLIGHT)
HPDF_Page_GetCurrentTextPos2 $index_page tp

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "Jump to Page1 (HilightMode=HPDF_ANNOT_NO_HIGHTLIGHT)"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_MoveToNextLine $index_page
set dst [HPDF_Page_CreateDestination $page(0)]
set annot [HPDF_Page_CreateLinkAnnot $index_page $rect $dst]
HPDF_LinkAnnot_SetHighlightMode $annot HPDF_ANNOT_NO_HIGHTLIGHT

# page2 (HPDF_ANNOT_INVERT_BOX)
set tp [HPDF_Page_GetCurrentTextPos $index_page]

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "Jump to Page2 (HilightMode=HPDF_ANNOT_INVERT_BOX)"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_MoveToNextLine $index_page
set dst [HPDF_Page_CreateDestination $page(1)]
set annot [HPDF_Page_CreateLinkAnnot $index_page $rect $dst]
HPDF_LinkAnnot_SetHighlightMode $annot HPDF_ANNOT_INVERT_BOX

# page3 (HPDF_ANNOT_INVERT_BORDER)
set tp [HPDF_Page_GetCurrentTextPos $index_page]

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "Jump to Page3 (HilightMode=HPDF_ANNOT_INVERT_BORDER)"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_MoveToNextLine $index_page
set dst [HPDF_Page_CreateDestination $page(2)]
set annot [HPDF_Page_CreateLinkAnnot $index_page $rect $dst]
HPDF_LinkAnnot_SetHighlightMode $annot HPDF_ANNOT_INVERT_BORDER


# page4 (HPDF_ANNOT_DOWN_APPEARANCE)
set tp [HPDF_Page_GetCurrentTextPos $index_page]

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "Jump to Page4 (HilightMode=HPDF_ANNOT_DOWN_APPEARANCE)"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_MoveToNextLine $index_page
set dst [HPDF_Page_CreateDestination $page(3)]
set annot [HPDF_Page_CreateLinkAnnot $index_page $rect $dst]
HPDF_LinkAnnot_SetHighlightMode $annot HPDF_ANNOT_DOWN_APPEARANCE

# page5 (dash border)
set tp [HPDF_Page_GetCurrentTextPos $index_page]

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "Jump to Page5 (dash border)"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_MoveToNextLine $index_page
set dst [HPDF_Page_CreateDestination $page(4)]
set annot [HPDF_Page_CreateLinkAnnot $index_page $rect $dst]
HPDF_LinkAnnot_SetBorderStyle $annot 1 3 2

# page6 (no border)
set tp [HPDF_Page_GetCurrentTextPos $index_page]

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "Jump to Page6 (no border)"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_MoveToNextLine $index_page
set dst [HPDF_Page_CreateDestination $page(5)]
set annot [HPDF_Page_CreateLinkAnnot $index_page $rect $dst]
HPDF_LinkAnnot_SetBorderStyle $annot 0 0 0

# page7 (bold border)
set tp [HPDF_Page_GetCurrentTextPos $index_page]

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "Jump to Page6 (bold border)"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_MoveToNextLine $index_page
set dst [HPDF_Page_CreateDestination $page(6)]
set annot [HPDF_Page_CreateLinkAnnot $index_page $rect $dst]
HPDF_LinkAnnot_SetBorderStyle $annot 2 0 0

# URI link
set tp [HPDF_Page_GetCurrentTextPos $index_page]

set tpx [dict get $tp x]
set tpy [dict get $tp y]

HPDF_Page_ShowText $index_page [haru::hpdf_encode "URI ("]
HPDF_Page_ShowText $index_page [haru::hpdf_encode $uri]
HPDF_Page_ShowText $index_page [haru::hpdf_encode ")"]

dict set rect left   [expr {$tpx - 4}]
dict set rect bottom [expr {$tpy - 4}]
dict set rect right  [expr {[dict get [HPDF_Page_GetCurrentTextPos $index_page] x] + 4}]
dict set rect top    [expr {$tpy + 10}]

HPDF_Page_CreateURILinkAnnot $index_page $rect $uri

HPDF_Page_EndText $index_page

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf