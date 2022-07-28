# Test CawtWord procedures related to generic search and replace functionality.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open new Word instance and show the application window.
set appId [Word Open true]

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-04_FindGeneric"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

set inFile [file join [pwd] "testOut" "Word-03_Text"]
append inFile [Word GetExtString $appId]

# Open an existing document. Set compatibility mode to Word 2003.
set inDocId  [Word OpenDocument $appId $inFile]
Word SetCompatibilityMode $inDocId wdWord2003

set range [Word GetStartRange $inDocId]
if { [Word GetRangeStartIndex $range] != 0 || \
     [Word GetRangeEndIndex   $range] != 0 } {
    puts "Error: Start range not correct"
    Word PrintRange $range
}
foreach searchStr { "italic" "Manfred" } expected { 1 0 } {
    set numFound [Word Search $inDocId $searchStr]
    Cawt CheckNumber $expected $numFound "Search docId   $searchStr"

    set numFound [Word Search $range $searchStr]
    Cawt CheckNumber $expected $numFound "Search rangeId $searchStr"
}

set endIndex [Word GetRangeEndIndex $range]
set range [Word ExtendRange $range 0 500]
Cawt CheckNumber [expr $endIndex + 500] [Word GetRangeEndIndex $range] "End index of extended range"
Word PrintRange $range "Extended range:"
Word Search $range "italic" -replacewith "yellow" -replace wdReplaceOne

set range [Word ExtendRange $range 0 end]
Word PrintRange $range "Extended range:"
Word Search $range "oops " -replacewith "" -replace wdReplaceAll

set range [Word ExtendRange $range 0 end]
Word PrintRange $range "Extended range:"
Word Search $range "lines" -replacewith "rows" -replace wdReplaceAll

set range [Word ExtendRange $range 0 end]
Word PrintRange $range "Extended range:"
Word Search $range "ordered" -replacewith "ORDERED" -replace wdReplaceAll -matchwholeword true -matchcase false

Word InsertText $inDocId "Inserted text at beginning of document\n"

# Save document as Word file.
puts "Saving as Word file: $wordFile"
Word SaveAs $inDocId $wordFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
