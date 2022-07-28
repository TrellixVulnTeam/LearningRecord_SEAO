# Test CawtWord procedures related to Word table cell merging.
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
set wordFile [file join [pwd] "testOut" "Word-15_MergeCells"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

# Create a new document.
set docId [Word AddDocument $appId]

set numRows 13
set numCols  4
set tableId [Word AddTable [Word GetEndRange $docId] $numRows $numCols]
Word SetTableBorderLineStyle $tableId

for { set r 1 } { $r <= $numRows } { incr r } {
    for { set c 1 } { $c <= $numCols } { incr c } {
        Word SetCellValue $tableId $r $c [format "R-%d C-%d" $r $c]
    }
}

# Merge columns 1 and 2 of row 1.
set rangeId [Word MergeCells $tableId 1 1  1 2]
Word SetRangeBackgroundColor $rangeId "red"

# Merge rows 3 and 4 of column 2.
set rangeId [Word MergeCells $tableId 3 2  4 2]
Word SetRangeBackgroundColor $rangeId "green"

# Merge columns 2 and 3 of rows 6 and 7.
set rangeId [Word MergeCells $tableId 6 2  8 3]
Word SetRangeBackgroundColor $rangeId "yellow"

# Merge all columns from 2 till the end of row 10.
set rangeId [Word MergeCells $tableId 10 2  10 end]
Word SetRangeBackgroundColor $rangeId "green"

# Merge all cells starting at row 12 and column 2 till the end of the table.
set rangeId [Word MergeCells $tableId 12 2  end end]
Word SetRangeBackgroundColor $rangeId "grey"

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
