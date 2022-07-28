#
# << Haru Free PDF Library 2.3.0 >> -- character_map.c
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

proc draw_page {pdf page title_font font h_byte l_byte} {

    set PAGE_WIDTH  420
    set CELL_HEIGHT 20
    set CELL_WIDTH  20

    set l_byte [expr {int($l_byte / 16) * 16}]
    set h_count [expr {16 - ($l_byte / 16)}]

    
    set page_height [expr {40 + 40 + ($h_count + 1) * $CELL_HEIGHT}]

    HPDF_Page_SetHeight $page $page_height
    HPDF_Page_SetWidth  $page $PAGE_WIDTH

    HPDF_Page_SetFontAndSize $page $title_font 10

    set ypos [expr {$h_count + 1}]

    while {1} {
        set y [expr {$ypos * $CELL_HEIGHT + 40}]

        HPDF_Page_MoveTo $page 40 $y
        HPDF_Page_LineTo $page 380 $y
        HPDF_Page_Stroke $page

        if {$ypos < $h_count} {

            set buf(0) [expr {16 - $ypos -1}]

            if {$buf(0) < 10} {
                set buf(0) [expr {$buf(0) + [scan "0" %c]}]
            } else {
                set buf(0) [expr {$buf(0) + ([scan "A" %c] - 10)}]
            }

            set buf(1) 0

            set buf(0) [expr {$buf(0) % 256}]
            set buf(1) [expr {$buf(1) % 256}]

            set buffer [binary format c* [list $buf(0) $buf(1)]]

            set w [HPDF_Page_TextWidth $page $buffer]

            HPDF_Page_BeginText $page
            HPDF_Page_MoveTextPos $page [expr {40 + (20 - $w) / 2}] [expr {$y + 5}]

            HPDF_Page_ShowText $page [haru::hpdf_encode $buffer]
            HPDF_Page_EndText $page
        }

        if {$ypos == 0} {
            break
        }

        incr ypos -1

    }

    for {set xpos 0} {$xpos < 18} {incr xpos} {
        
        set y [expr {($h_count + 1) * $CELL_HEIGHT + 40}]
        set x [expr {$xpos * $CELL_WIDTH + 40}]


        HPDF_Page_MoveTo $page $x 40
        HPDF_Page_LineTo $page $x $y
        HPDF_Page_Stroke $page

        if {$xpos > 0 && $xpos <= 16} {

            set buf(0) [expr {$xpos - 1}]

            if {$buf(0) < 10} {
                set buf(0) [expr {$buf(0) + [scan "0" %c]}]
            } else {
                set buf(0) [expr {$buf(0) + ([scan "A" %c] - 10)}]
            }

            set buf(1) 0

            set buf(0) [expr {$buf(0) % 256}]
            set buf(1) [expr {$buf(1) % 256}]

            set buffer [binary format c* [list $buf(0) $buf(1)]]

            set w [HPDF_Page_TextWidth $page $buffer]

            HPDF_Page_BeginText $page
            HPDF_Page_MoveTextPos $page [expr {$x + (20 - $w) / 2}] [expr {$h_count * $CELL_HEIGHT + 45}]
            HPDF_Page_ShowText $page [haru::hpdf_encode $buffer]
            HPDF_Page_EndText $page

        }
    }

    HPDF_Page_SetFontAndSize $page $font 15

    set ypos $h_count

    while {1} {

        set y [expr {($ypos - 1) * $CELL_HEIGHT + 45}]

        for {set xpos 0} {$xpos < 16} {incr xpos} {

            set x [expr {$xpos * $CELL_WIDTH + 40 + $CELL_WIDTH}]

            set buf(0) $h_byte
            set buf(1) [expr {(16 - $ypos) * 16 + $xpos}]
            set buf(2) "0x00"

            set buf(0) [expr {$buf(0) % 256}]
            set buf(1) [expr {$buf(1) % 256}]            
            set buf(2) [expr {$buf(2) % 256}]

            set buffer [binary format c* [list $buf(0) $buf(1) $buf(2)]]

            set w [HPDF_Page_TextWidth $page $buffer]

            if {$w > 0} {
                HPDF_Page_BeginText $page
                HPDF_Page_MoveTextPos $page [expr {$x + (20 - $w) / 2}] $y
                HPDF_Page_ShowText $page $buffer
                HPDF_Page_EndText $page

            }            
        }

        if {$ypos == 0} {
            break
        }
        incr ypos -1   
    }    
}

set pdf [HPDF_New]

HPDF_SetPageMode $pdf HPDF_PAGE_MODE_USE_OUTLINE
HPDF_SetCompressionMode    $pdf $::haru::HPDF_COMP_ALL
HPDF_SetPagesConfiguration $pdf 10

HPDF_UseJPEncodings  $pdf
HPDF_UseJPFonts      $pdf
HPDF_UseKREncodings  $pdf
HPDF_UseKRFonts      $pdf
HPDF_UseCNSEncodings $pdf
HPDF_UseCNSFonts     $pdf
HPDF_UseCNTEncodings $pdf
HPDF_UseCNTFonts     $pdf

set cmap "KSCms-UHC-HW-H"
set ft "BatangChe"
set encoder [HPDF_GetEncoder $pdf $cmap]

if {[HPDF_Encoder_GetType $encoder] ne "HPDF_ENCODER_TYPE_DOUBLE_BYTE"} {
    error "error: $cmap is not cmap-encoder"
}

set font [HPDF_GetFont $pdf $ft $cmap]

set min_l 255
set min_h 256
set max_l 0
set max_h 0

for {set i 0} {$i < 256} {incr i} {

    for {set j 20} {$j < 256} {incr j} {

        set code [expr $i * 256 + $j]
        set buf [binary format c* [list $i $j 0]]

        set btype [HPDF_Encoder_GetByteType $encoder $buf 0]
        set unicode [HPDF_Encoder_GetUnicode $encoder $code]

        set unicode [format %X $unicode]

        if {$btype == "HPDF_BYTE_TYPE_LEAD" && $unicode != "25A1"} {

            if {$min_l > $j} {
                set min_l $j
            }

            if {$max_l < $j} {
                set max_l $j
            }

            if {$min_h > $i} {
                set min_h $i
            }
        
            if {$max_h < $i} {
                set max_h $i
            }

            set flg($i) 1
        
        }
    }
    
}

# puts "$min_h $max_h $min_l $max_l"
set root [HPDF_CreateOutline $pdf NULL $cmap NULL]
HPDF_Outline_SetOpened $root 1

for {set i 0} {$i < 256} {incr i} {

    if {[info exists flg($i)]} {
        set page [HPDF_AddPage $pdf]
        set title_font [HPDF_GetFont $pdf "Helvetica" ""]

        set buf [format "0x%04X-0x%04X" [expr {$i * 256 + $min_l}] [expr {$i * 256 + $max_l}]]
        set outline [HPDF_CreateOutline $pdf $root $cmap NULL]

        set dest [HPDF_Page_CreateDestination $page]
        HPDF_Outline_SetDestination $outline $dest

        draw_page $pdf $page $title_font $font $i $min_l

        set buf [format "%s (%s) 0x%04X-0x%04X" $cmap $ft [expr {$i * 256 + $min_l}] [expr {$i * 256 + $max_l}]]

        HPDF_Page_SetFontAndSize $page $title_font 10
        HPDF_Page_BeginText $page
        HPDF_Page_MoveTextPos $page 40 [expr {[HPDF_Page_GetHeight $page] - 35}]
        HPDF_Page_ShowText $page [haru::hpdf_encode $buf]
        HPDF_Page_EndText $page

    }
    
}

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf
