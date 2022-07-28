# Test CawtWord procedures for handling fonts.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

# Delete Word file from previous test run.
file mkdir testOut
set rootName [file join [pwd] "testOut" "Word-20_Font"]
set wordFile [format "%s%s" $rootName [Word GetExtString $appId]]
file delete -force $wordFile

# Create a new document.
set docId [Word AddDocument $appId]

# Insert text and set various font properties.
set range1 [Word AppendText $docId "This is italic text in Courier 12 with yellow highlight color\n"]
Word SetRangeFont $range1 -italic true -size 12 -name "Courier"
Word SetRangeHighlightColorByEnum $range1 wdYellow

# Check font settings of this range.
lassign [Word GetRangeFont $range1 -italic -name -size -sizei -sizec] italic name size sizei sizec
Cawt CheckBoolean true                          $italic "Font italic flag"
Cawt CheckString  "Courier"                     $name   "Font name"
Cawt CheckNumber  12                            $size   "Font size in points"
Cawt CheckNumber  [Cawt PointsToInches 12]      $sizei  "Font size in inches"
Cawt CheckNumber  [Cawt PointsToCentiMeters 12] $sizec  "Font size in centimeters"

# Insert text with various underlinings.
set range2 [Word AppendText $docId "This is text with default underlining color.\n"]
Word SetRangeFont $range2 -underline true

set range3 [Word AppendText $docId "This is text with orange underlining color.\n"]
Word SetRangeFont $range3 -underline true -underlinecolor wdColorLightOrange

# Check font settings of this range.
lassign [Word GetRangeFont $range3 -underline -underlinecolor] underline underlinecolor
Cawt CheckBoolean true                        $underline      "Font underline flag"
Cawt CheckNumber  $::Word::wdColorLightOrange $underlinecolor "Font underline color"

# Insert text with various text colors.
set range4 [Word AppendText $docId "This is text with blue text color.\n"]
Word SetRangeFont $range4 -color $::Word::wdBlue

# Check font settings of this range.
lassign [Word GetRangeFont $range4 -color] color
Cawt CheckString "wdBlue" [Word GetEnumName "WdColorIndex" $color] "Font text color"

set range5 [Word AppendText $docId "This is text with green text color.\n"]
Word SetRangeFont $range5 -color wdGreen

# Check font settings of this range.
lassign [Word GetRangeFont $range5 -color] color
Cawt CheckString "wdGreen" [Word GetEnumName "WdColorIndex" $color] "Font text color"

# Insert text with various background colors.
set range6 [Word AppendText $docId "This is bold text with orange background\n"]
Word SetRangeFont $range6 -bold true -background [Cawt GetColor "orange"]

# Check font settings of this range.
lassign [Word GetRangeFont $range6 -bold -background] bold background
Cawt CheckBoolean true                     $bold       "Font bold flag"
Cawt CheckNumber  [Cawt GetColor "orange"] $background "Font background color"

set range7 [Word AppendText $docId "This is normal text with red background\n"]
Word SetRangeFont $range7 -background [Cawt GetColor 255 100 0]

# Check font settings of this range.
lassign [Word GetRangeFont $range7 -background] background
Cawt CheckNumber [Cawt GetColor 255 100 0] $background "Font background color"

# Save document as Word file.
puts "Saving as Word file: $wordFile"
Word SaveAs $docId $wordFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
