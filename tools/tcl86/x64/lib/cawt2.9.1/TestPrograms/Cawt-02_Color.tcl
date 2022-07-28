# Test color functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

set r [Office RgbToColor 255 0 0]
set g [Office RgbToColor 0 255 0]
set b [Office RgbToColor 0 0 255]
puts [format "Red Green Blue as Office color: %08X %08X %08X" $r $g $b]
puts "Red Green Blue as RGB color: \
     [Office ColorToRgb $r] \
     [Office ColorToRgb $g] \
     [Office ColorToRgb $b]"
puts ""

set r [Cawt RgbToOfficeColor 255 0 0]
set g [Cawt RgbToOfficeColor 0 255 0]
set b [Cawt RgbToOfficeColor 0 0 255]
puts [format "Red Green Blue as Office color: %08X %08X %08X (%d %d %d)" $r $g $b $r $g $b]
puts "Red Green Blue as RGB color: \
     [Cawt OfficeColorToRgb $r] \
     [Cawt OfficeColorToRgb $g] \
     [Cawt OfficeColorToRgb $b]"
puts ""

set black [Cawt RgbToOfficeColor 0 0 0]
Cawt CheckNumber $black [Cawt GetColor "black"]   "Name color   black  " true
Cawt CheckNumber $black [Cawt GetColor "#000000"] "Hex color    #000000" true
Cawt CheckNumber $black [Cawt GetColor 0 0 0]     "RGB color    0 0 0  " true
Cawt CheckNumber $black [Cawt GetColor $black]    "Office color 0x0    " true
puts ""

set green [Cawt RgbToOfficeColor 0 255 0]
Cawt CheckNumber $green [Cawt GetColor "green1"]  "Name Color   green1 " true
Cawt CheckNumber $green [Cawt GetColor "#00FF00"] "Hex Color    #00FF00" true
Cawt CheckNumber $green [Cawt GetColor 0 255 0]   "RGB Color    0 255 0" true
Cawt CheckNumber $green [Cawt GetColor $green]    "Office color 0xFF00 " true
puts ""

set white [Cawt RgbToOfficeColor 255 255 255]
Cawt CheckNumber $white [Cawt GetColor "white"]     "Name Color   white      " true
Cawt CheckNumber $white [Cawt GetColor "#FFFFFF"]   "Hex Color    #FFFFFF    " true
Cawt CheckNumber $white [Cawt GetColor 255 255 255] "RGB Color    255 255 255" true
Cawt CheckNumber $white [Cawt GetColor $white]      "Office color 0xFFFFFF   " true
puts ""

Cawt CheckBoolean true  [Cawt IsRgbColor 1 2 3]   "IsRgbColor   1 2 3"
Cawt CheckBoolean false [Cawt IsRgbColor 256 2 3] "IsRgbColor 256 2 3"
puts ""

Cawt CheckNumber 752 [llength [Cawt GetColorNames]] "GetColorNames"

if { [lindex $argv 0] eq "full" } {
    puts "Testing color conversion procedures (both directions for all r g b values) ..."
    for { set r 0 } { $r < 256 } { incr r } {
        for { set g 0 } { $g < 256 } { incr g } {
            for { set b 0 } { $b < 256 } { incr b } {
                set colorNum [Cawt RgbToOfficeColor $r $g $b]
                set rgb [Cawt OfficeColorToRgb $colorNum]
                Cawt CheckNumber $r [lindex $rgb 0] "Convert color $r $g $b" false
                Cawt CheckNumber $g [lindex $rgb 1] "Convert color $r $g $b" false
                Cawt CheckNumber $b [lindex $rgb 2] "Convert color $r $g $b" false
            }
        }
    }
    puts "Conversion test finished."
}

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
