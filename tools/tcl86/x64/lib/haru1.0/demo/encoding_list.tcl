#
# << Haru Free PDF Library 2.3.0 >> -- encoding_list.c
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

proc draw_graph {page encoder} {

    HPDF_Page_SetLineWidth $page 0.5

    for {set i 0} {$i < 18} {incr i} {

        set x [expr {$i * $::CELL_WIDTH + 40}]

        HPDF_Page_MoveTo $page $x [expr {$::PAGE_HEIGHT - 60}]
        HPDF_Page_LineTo $page $x 40
        HPDF_Page_Stroke $page

        if {$i > 0 && $i <= 16} {
            
            HPDF_Page_BeginText $page
            HPDF_Page_MoveTextPos $page [expr {$x + 5}] [expr {$::PAGE_HEIGHT - 75}]

            set buf [format "%X" [expr {$i - 1}]]
            HPDF_Page_ShowText $page [haru::hpdf_encode $buf $encoder]
            HPDF_Page_EndText $page

        }
        
    }

    for {set i 0} {$i < 16} {incr i} {

        set y [expr {$i * $::CELL_HEIGHT + 40}]

        HPDF_Page_MoveTo $page 40 $y
        HPDF_Page_LineTo $page [expr {$::PAGE_WIDTH - 40}] $y
        HPDF_Page_Stroke $page

        if {$i < 14} {
            HPDF_Page_BeginText $page
            HPDF_Page_MoveTextPos $page 45 [expr {$y + 5}]
            set buf [format "%X" [expr {15 - $i}]]
            HPDF_Page_ShowText $page [haru::hpdf_encode $buf $encoder]
            HPDF_Page_EndText $page
        }
        
    }
}

proc draw_fonts {page} {

    HPDF_Page_BeginText $page

    # Draw all character from 0x20 to 0xFF to the canvas.
    for {set i 1} {$i < 17} {incr i} {
        for {set j 1} {$j < 17} {incr j} {

            set y [expr {$::PAGE_HEIGHT - 55 - (($i - 1) * $::CELL_HEIGHT)}]
            set x [expr {$j * $::CELL_WIDTH + 50}]
            
            set buf [expr {($i - 1) * 16 + ($j - 1)}]

            if {$buf >= 32} {
                # set buffer [format %c $buf]
                set buffer [binary format cc $buf 0]
                
                set d [expr {$x - ([HPDF_Page_TextWidth $page $buffer] / 2)}]
                HPDF_Page_TextOut $page $d $y $buffer
            }
        }
        
    }

    HPDF_Page_EndText $page
    
}

set PAGE_WIDTH 420
set PAGE_HEIGHT 400
set CELL_WIDTH 20
set CELL_HEIGHT 20
set CELL_HEADER 10

set encodings {
    "StandardEncoding"
    "MacRomanEncoding"
    "WinAnsiEncoding"
    "ISO8859-2"
    "ISO8859-3"
    "ISO8859-4"
    "ISO8859-5"
    "ISO8859-9"
    "ISO8859-10"
    "ISO8859-13"
    "ISO8859-14"
    "ISO8859-15"
    "ISO8859-16"
    "CP1250"
    "CP1251"
    "CP1252"
    "CP1254"
    "CP1257"
    "KOI8-R"
    "Symbol-Set"
    "ZapfDingbats-Set"
}

set pdf [HPDF_New]

# set compression mode
HPDF_SetCompressionMode $pdf $::haru::HPDF_COMP_ALL

# Set page mode to use outlines.
HPDF_SetPageMode $pdf HPDF_PAGE_MODE_USE_OUTLINE

# create default-font
set font [HPDF_GetFont $pdf "Helvetica" ""]

set font_name [HPDF_LoadType1FontFromFile $pdf [file join $demodir type1 a010013l.afm] \
                                               [file join $demodir type1 a010013l.pfb]]

# create outline root.
set root [HPDF_CreateOutline $pdf NULL "Encoding list" NULL]

HPDF_Outline_SetOpened $root $::haru::HPDF_TRUE

foreach encoder $encodings {

    set page [HPDF_AddPage $pdf]
    HPDF_Page_SetWidth $page $PAGE_WIDTH
    HPDF_Page_SetHeight $page $PAGE_HEIGHT

    set outline [HPDF_CreateOutline $pdf $root $encoder NULL]
    set dst [HPDF_Page_CreateDestination $page]
    HPDF_Destination_SetXYZ $dst 0 [HPDF_Page_GetHeight $page] 1
    HPDF_Outline_SetDestination $outline $dst

    HPDF_Page_SetFontAndSize $page $font 15

    draw_graph $page $encoder

    HPDF_Page_BeginText $page
    HPDF_Page_SetFontAndSize $page $font 20
    HPDF_Page_MoveTextPos $page 40 [expr {$PAGE_HEIGHT - 50}]
    HPDF_Page_ShowText $page [haru::hpdf_encode $encoder $encoder]
    HPDF_Page_ShowText $page [haru::hpdf_encode " Encoding" $encoder]
    HPDF_Page_EndText $page

    if {$encoder eq "Symbol-Set"} {
        set font2 [HPDF_GetFont $pdf "Symbol" ""]
    } elseif {$encoder eq "ZapfDingbats-Set"} {
        set font2 [HPDF_GetFont $pdf "ZapfDingbats" ""]
    } else {
        set font2 [HPDF_GetFont $pdf $font_name $encoder]
    }

    HPDF_Page_SetFontAndSize $page $font2 14
    draw_fonts $page

}

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf