# Test Word page setup setter and getter procedures.
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
set wordFile [file join [pwd] "testOut" "Word-18_PageSetup"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

set msg "This is a line of text in italic.\n"

# Create a new document.
set docId [Word AddDocument $appId]

# Insert a short piece of text as one paragraph.
set range [Word AppendText $docId $msg]
Word SetRangeFontItalic $range true

set top     1
set bottom  2
set left    0.8
set right   0.5
set footer  1.5
set header  2.5
set height  30
set width   20

# Change the page setup of the document.
Word SetPageSetup $docId \
    -top     ${top}c    \
    -bottom  ${bottom}c \
    -left    ${left}c   \
    -right   ${right}c  \
    -footer  ${footer}c \
    -header  ${header}c \
    -height  ${height}c \
    -width   ${width}c

# Check the page setup of the changed document.
proc GetPageSetupValue { docId which } {
    return [format "%.2f" [Word GetPageSetup $docId -centimeter $which]]
}

Cawt CheckNumber $top    [GetPageSetupValue $docId -top]    "GetPageSetup -top"
Cawt CheckNumber $bottom [GetPageSetupValue $docId -bottom] "GetPageSetup -bottom"
Cawt CheckNumber $left   [GetPageSetupValue $docId -left]   "GetPageSetup -left"
Cawt CheckNumber $right  [GetPageSetupValue $docId -right]  "GetPageSetup -right"
Cawt CheckNumber $footer [GetPageSetupValue $docId -footer] "GetPageSetup -footer"
Cawt CheckNumber $header [GetPageSetupValue $docId -header] "GetPageSetup -header"
Cawt CheckNumber $height [GetPageSetupValue $docId -height] "GetPageSetup -height"
Cawt CheckNumber $width  [GetPageSetupValue $docId -width]  "GetPageSetup -width"

# Save document as Word file.
puts "Saving as Word file: $wordFile"
Word SaveAs $docId $wordFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId false
    Cawt Destroy
    exit 0
}
Cawt Destroy
