# Test CawtWord procedures related to Word table width management.
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
set wordFile [file join [pwd] "testOut" "Word-02_TableWidth"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

# Create a new document.
set docId [Word AddDocument $appId]

proc CreateTable { docId numRows numCols headerList msg } {
    Word AppendText $docId $msg
    set tableId [Word AddTable [Word GetEndRange $docId] $numRows $numCols]
    Word SetHeaderRow $tableId $headerList
    Word SetTableBorderLineStyle $tableId
    Word AppendParagraph $docId
    return $tableId
}

set tableId1 [CreateTable $docId 2 1 { "H1" } "SetTableOptions: None"]
Word SetTableOptions $tableId1

set tableId2 [CreateTable $docId 2 1 { "H1" } "SetTableOptions: -width 50%"]
Word SetTableOptions $tableId2 -width 50%

set tableId3 [CreateTable $docId 2 1 { "H1" } "SetTableOptions: -width 5.2c"]
Word SetTableOptions $tableId3 -width 5.2c

set tableId4 [CreateTable $docId 2 4 { "H1" "H2" "H3" "H4" } "SetTableOptions: -width 100% -autofit true"]
Word SetTableOptions $tableId4 -width 100% -autofit true

set tableId5 [CreateTable $docId 2 4 { "H1" "H2" "H3" "H4" } "SetTableOptions: -autofit true -width 100%"]
Word SetTableOptions $tableId5 -autofit true -width 100%

set tableId6 [CreateTable $docId 2 4 { "H1" "H2" "H3" "H4" } "SetColumnWidth: 10% 20% 30% 40%"]
Word SetColumnWidth $tableId6 1 10%
Word SetColumnWidth $tableId6 2 20%
Word SetColumnWidth $tableId6 3 30%
Word SetColumnWidth $tableId6 4 40%

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
