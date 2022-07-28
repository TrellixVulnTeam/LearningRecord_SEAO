# Test CawtWord procedures related to Word table management.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

set wordInFile  [file join [pwd] "testIn" "WordTables.doc"]

# Open the Word document in read-only mode.
puts "Open Word input file: $wordInFile"
set docId [Word OpenDocument $appId $wordInFile false]
Word ToggleSpellCheck $appId false

# Check table with combined cells.
set tableNum 1
set tableId [Word GetTableIdByIndex $docId $tableNum]
set numRows [Word GetNumRows    $tableId]
set numCols [Word GetNumColumns $tableId]
Cawt CheckNumber 4 $numRows "Number of rows in table"
Cawt CheckNumber 5 $numCols "Number of columns in table"

for { set r 1 } { $r <= $numRows } { incr r } {
    set numColsInRow 0
    for { set c 1 } { $c <= $numCols } { incr c } {
        if { [Word IsValidCell $tableId $r $c] } {
            puts -nonewline "[Word GetCellValue $tableId $r $c] | "
            incr numColsInRow
        } else {
            puts -nonewline "INV | "
        }
    }
    puts " ($numColsInRow columns)"
}

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
