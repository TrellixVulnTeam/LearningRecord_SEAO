#
# << Haru Free PDF Library 2.3.0 >> -- jpeg_demo.c
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

proc draw_image {pdf filename x y text} {

    set page [HPDF_GetCurrentPage $pdf]
    set image [HPDF_LoadJpegImageFromFile $pdf $filename]


    HPDF_Page_DrawImage $page $image $x $y [HPDF_Image_GetWidth $image] [HPDF_Image_GetHeight $image]

    # Print the text.
    HPDF_Page_BeginText $page
    HPDF_Page_SetTextLeading $page 16
    HPDF_Page_MoveTextPos $page $x $y
    HPDF_Page_ShowTextNextLine $page [haru::hpdf_encode [file tail $filename]]
    HPDF_Page_ShowTextNextLine $page [haru::hpdf_encode $text]
    HPDF_Page_EndText $page
}


set pdf [HPDF_New] 
HPDF_SetCompressionMode $pdf $::haru::HPDF_COMP_ALL

set font [HPDF_GetFont $pdf "Helvetica" ""]
set page [HPDF_AddPage $pdf]

HPDF_Page_SetWidth $page 650
HPDF_Page_SetHeight $page 500

set dst [HPDF_Page_CreateDestination $page]
HPDF_Destination_SetXYZ $dst 0 [HPDF_Page_GetHeight $page] 1
HPDF_SetOpenAction $pdf $dst

HPDF_Page_BeginText $page
HPDF_Page_SetFontAndSize $page $font 20
HPDF_Page_MoveTextPos $page 220 [expr {[HPDF_Page_GetHeight $page] - 70}]
HPDF_Page_ShowText $page [haru::hpdf_encode "JpegDemo"]
HPDF_Page_EndText $page

HPDF_Page_SetFontAndSize $page $font 12

draw_image $pdf [file join $demodir images rgb.jpg] 70 [expr {[HPDF_Page_GetHeight $page] - 410}] "24bit color image"
draw_image $pdf [file join $demodir images gray.jpg] 340 [expr {[HPDF_Page_GetHeight $page] - 410}] "8bit grayscale image"

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf
