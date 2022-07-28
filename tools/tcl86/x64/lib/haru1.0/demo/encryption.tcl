#
# << Haru Free PDF Library 2.3.0 >> -- encryption.c
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

set text "This is an encrypt document example."
set owner_passwd "owner"
set user_passwd "user"

set pdf [HPDF_New]

set font [HPDF_GetFont $pdf "Helvetica" ""]
set page [HPDF_AddPage $pdf]

HPDF_Page_SetSize $page HPDF_PAGE_SIZE_B5 HPDF_PAGE_LANDSCAPE

HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $font 20
set tw [HPDF_Page_TextWidth $page [haru::hpdf_encode $text]]

HPDF_Page_MoveTextPos $page [expr {([HPDF_Page_GetWidth $page] - $tw) / 2.}] [expr {([HPDF_Page_GetHeight $page] - 20) / 2.}]
HPDF_Page_ShowText $page [haru::hpdf_encode $text]
HPDF_Page_EndText $page

HPDF_SetPassword $pdf $owner_passwd $user_passwd

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf