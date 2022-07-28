# Test quitting Word without saving modified documents.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

set msg1 "This is a italic line of text in italic.\n"

# Create a new document.
set docId [Word AddDocument $appId]

# Insert a short piece of text as one paragraph.
set range1 [Word AppendText $docId $msg1]
Word SetRangeFontItalic $range1 true
Word SetRangeFontSize $range1 12
Word SetRangeFontName $range1 "Courier"

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId false
    Cawt Destroy
    exit 0
}
Word Quit $appId true
Cawt Destroy
