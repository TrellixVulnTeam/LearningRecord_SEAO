#
# << Haru Free PDF Library 2.3.0 >> -- image_demo.c
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

proc show_description {page x y text} {

    HPDF_Page_MoveTo $page $x [expr {$y - 10}]
    HPDF_Page_LineTo $page $x [expr {$y + 10}]
    HPDF_Page_MoveTo $page [expr {$x - 10}] $y
    HPDF_Page_LineTo $page [expr {$x + 10}] $y
    HPDF_Page_Stroke $page


    HPDF_Page_SetFontAndSize $page [HPDF_Page_GetCurrentFont $page] 8
    HPDF_Page_SetRGBFill $page 0 0 0

    HPDF_Page_BeginText $page

    set buf [format "x=%s,y=%s" $x $y]

    HPDF_Page_MoveTextPos $page [expr {$x - [HPDF_Page_TextWidth $page $buf] - 5}] [expr {$y - 10}]
    HPDF_Page_ShowText    $page [haru::hpdf_encode $buf]
    HPDF_Page_EndText     $page

    HPDF_Page_BeginText   $page
    HPDF_Page_MoveTextPos $page [expr {$x - 20}] [expr {$y - 25}]
    HPDF_Page_ShowText    $page [haru::hpdf_encode $text]
    HPDF_Page_EndText     $page

}

set pdf [HPDF_New]
set page [HPDF_AddPage $pdf]

set font [HPDF_GetFont $pdf "Helvetica" "StandardEncoding"]

HPDF_Page_SetWidth $page 550
HPDF_Page_SetHeight $page 500

set dst [HPDF_Page_CreateDestination $page]

HPDF_Page_BeginText      $page
HPDF_Page_SetFontAndSize $page $font 20
HPDF_Page_MoveTextPos    $page 220 [expr {[HPDF_Page_GetHeight $page] - 70}]
HPDF_Page_ShowText       $page [haru::hpdf_encode "ImageDemo"]
HPDF_Page_EndText        $page


set image  [HPDF_LoadPngImageFromFile $pdf [file join $demodir pngsuite basn3p02.png]]
set image1 [HPDF_LoadPngImageFromFile $pdf [file join $demodir pngsuite basn3p02.png]]
set image2 [HPDF_LoadPngImageFromFile $pdf [file join $demodir pngsuite basn0g01.png]]
set image3 [HPDF_LoadPngImageFromFile $pdf [file join $demodir pngsuite maskimage.png]]

set iw [HPDF_Image_GetWidth $image]
set ih [HPDF_Image_GetHeight $image]

HPDF_Page_SetLineWidth $page 0.5

set x 100
set y [expr {[HPDF_Page_GetHeight $page] - 150}]

HPDF_Page_DrawImage $page $image $x $y $iw $ih
show_description $page $x $y "Actual Size"

incr x 150

HPDF_Page_DrawImage $page $image $x $y $iw [expr {$ih * 1.5}]
show_description $page $x $y "Scalling image (X direction)"

incr x 150
HPDF_Page_DrawImage $page $image $x $y $iw [expr {$ih * 1.5}]
show_description $page $x $y "Scalling image (Y direction)"

set x 100
set y [expr {$y - 120}]

# Skewing image.
set angle1 10
set angle2 20
set rad1 [haru::DegreesToRadians $angle1]
set rad2 [haru::DegreesToRadians $angle2]

HPDF_Page_GSave $page

HPDF_Page_Concat $page $iw [expr {tan($rad1) * $iw}] [expr {tan($rad2) * $ih}] $ih $x $y
HPDF_Page_ExecuteXObject $page $image
HPDF_Page_GRestore $page
show_description $page $x $y "Skewing image"

incr x 150

set angle 30
set rad [haru::DegreesToRadians $angle]

HPDF_Page_GSave $page

HPDF_Page_Concat $page [expr {cos($rad) * $iw}] [expr {sin($rad) * $iw}] [expr {(sin($rad) * -1) * $ih}] [expr {cos($rad) * $ih}] $x $y

HPDF_Page_ExecuteXObject $page $image
HPDF_Page_GRestore $page
show_description $page $x $y "Rotating image"

incr x 150

HPDF_Image_SetMaskImage $image1 $image2

HPDF_Page_SetRGBFill $page 0 0 0
HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {$x - 6}] [expr {$y + 14}]
HPDF_Page_ShowText $page "MASKMASK"
HPDF_Page_EndText $page

HPDF_Page_DrawImage $page $image1 [expr {$x - 3}] [expr {$y - 3}] [expr {$iw + 6}] [expr {$ih + 6}]
show_description $page $x $y "masked image"

set x 100
set y [expr {$y - 120}]

HPDF_Page_SetRGBFill $page 0 0 0
HPDF_Page_BeginText $page
HPDF_Page_MoveTextPos $page [expr {$x - 6}] [expr {$y + 14}]
HPDF_Page_ShowText $page "MASKMASK"
HPDF_Page_EndText $page

HPDF_Image_SetColorMask $image3 0 255 0 0 0 255

HPDF_Page_DrawImage $page $image3 $x $y $iw $ih
show_description $page $x $y "Color Mask"


# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf