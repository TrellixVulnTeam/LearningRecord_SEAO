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

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-02_Table"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

# Create a new document.
set docId [Word AddDocument $appId]

# Create a table with a header line.
set numRows 3
set numCols 5

Word AppendText $docId "A standard table with a header line (Alignment left):"
set table(1,Id) [Word AddTable [Word GetEndRange $docId] [expr $numRows+1] $numCols]
Word SetTableName $table(1,Id) "Table-1"
set table(1,Rows) [expr $numRows+1]

for { set c 1 } { $c <= $numCols } { incr c } {
    lappend headerList [format "Header-%d" $c]
}
Word SetHeaderRow $table(1,Id) $headerList

for { set r 1 } { $r <= $numRows } { incr r } {
    for { set c 1 } { $c <= $numCols } { incr c } {
        Word SetCellValue $table(1,Id) [expr $r+1] $c [format "R-%d C-%d" $r $c]
    }
}
# Set border line style of a cell range.
set borderRange [Word GetCellRange $table(1,Id) 3 2 4 4]
Word SetTableBorderLineStyle $borderRange wdLineStyleEmboss3D wdLineStyleDashDot

Word SetTableAlignment $table(1,Id) "left"

# Create a table and change some properties.
set numRows 5
set numCols 2
Word AppendParagraph $docId
Word AppendText $docId "Another table with changed properties and added rows (Alignment center):"
set table(2,Id) [Word AddTable [Word GetEndRange $docId] $numRows $numCols 6]
Word SetTableName $table(2,Id) "Table-2"

for { set r 1 } { $r <= $numRows } { incr r } {
    for { set c 1 } { $c <= $numCols } { incr c } {
        Word SetCellValue $table(2,Id) $r $c [format "R-%d C-%d" $r $c]
    }
}

Word AddRow $table(2,Id) 1 2
Word AddRow $table(2,Id)
set table(2,Rows) [expr $numRows+3]

Word SetTableBorderLineStyle $table(2,Id)
Word SetTableBorderLineWidth $table(2,Id) wdLineWidth300pt

# Set background color of a complete row.
set rowRange [Word GetRowRange $table(2,Id) 1]
Word SetRangeFontBold $rowRange true
Word SetRangeBackgroundColor $rowRange 200 100 50

# Set background color of a cell.
set cellRange [Word GetCellRange $table(2,Id) 2 1]
Word SetRangeBackgroundColor $cellRange 0 200 00

set colRange [Word GetColumnRange $table(2,Id) 2]
Word SetRangeFontItalic $colRange true

Word SetColumnWidth $table(2,Id) 1 1i
Word SetColumnWidth $table(2,Id) 2 2.54c

Word SetTableAlignment $table(2,Id) "center"

# Read the number of rows and columns and check them.
set numRowsRead [Word GetNumRows $table(2,Id)]
set numColsRead [Word GetNumColumns $table(2,Id)]
Cawt CheckNumber [expr $numRows + 3] $numRowsRead "GetNumRows"
Cawt CheckNumber $numCols $numColsRead "GetNumColumns"

# Read back the contents of the table and insert them into a newly created table
# (which is 2 rows and 1 column larger than the original).
# Set all columns to an equal width and change the border style.
Word AppendParagraph $docId
Word AppendText $docId "Copy of table with changed borders (Alignment right):"
set table(3,Id) [Word AddTable [Word GetEndRange $docId] \
                [expr $numRows+2] [expr $numCols+1] 6]
Word SetTableName $table(3,Id) "Table-3"
set table(3,Rows) [expr $numRows+2]

set matrixList [Word GetMatrixValues $table(2,Id) 1 1 $numRows $numCols]
Word SetMatrixValues $table(3,Id) $matrixList 3 2

Word SetColumnsWidth $table(3,Id) 1 [expr $numCols+1] 1.9i
Word SetTableBorderLineStyle $table(3,Id) \
        wdLineStyleEmboss3D wdLineStyleDashDot
set rowRange [Word GetRowRange $table(3,Id) 1]
Word SetRangeMergeCells $rowRange

# Insert values into empty column starting at row 3.
set colList [list "Row-3" "Row-4" "Row-5" "Row-6"]
Word SetColumnValues $table(3,Id) 1 $colList 3

# Read back the values of the column starting at row 3.
set readList [Word GetColumnValues $table(3,Id) 1 3 [llength $colList]]
Cawt CheckList $colList $readList "GetColumnValues"

Word SetTableAlignment $table(3,Id) "right"

# Create a table, fill it and delete 3 rows afterwards.
Word AppendParagraph $docId
Word AppendText $docId "Table with deleted rows (1,3,5):"
set table(4,Id) [Word AddTable [Word GetEndRange $docId] $numRows $numCols]
Word SetTableName $table(4,Id) "Table-4"
set table(4,Rows) [expr $numRows-3]
set colList [list "Row-1" "Row-2" "Row-3" "Row-4" "Row-5"]
Word SetColumnValues $table(4,Id) 1 $colList

Word SetTableBorderLineStyle $table(4,Id)
Word DeleteRow $table(4,Id) end
Word DeleteRow $table(4,Id) 3
Word DeleteRow $table(4,Id) 1
set readList [Word GetColumnValues $table(4,Id) 1]
Cawt CheckList [list "Row-2" "Row-4"] $readList "GetColumnValues"

# Create a table, set the row height and vertical alignments
# of each cell individually.
Word AppendParagraph $docId
Word AppendText $docId "Table with individual vertical alignments:"
set table(5,Id) [Word AddTable [Word GetEndRange $docId] 1 3]
Word SetTableName $table(5,Id) "Table-5"
set table(5,Rows) 1
Word SetTableBorderLineStyle $table(5,Id)

Word SetRowHeight $table(5,Id) 1 "1.6c"
Word SetCellValue $table(5,Id) 1 1 "Top"
Word SetCellValue $table(5,Id) 1 2 "Center"
Word SetCellValue $table(5,Id) 1 3 "Bottom"
Word SetCellVerticalAlignment $table(5,Id) 1 1 "top"
Word SetCellVerticalAlignment $table(5,Id) 1 2 "center"
Word SetCellVerticalAlignment $table(5,Id) 1 3 "bottom"

# Create a table, set the row height and vertical alignments
# of the complete table.
Word AppendParagraph $docId
Word AppendText $docId "Table with global vertical alignments:"
set table(6,Id) [Word AddTable [Word GetEndRange $docId] 1 3]
Word SetTableName $table(6,Id) "Table-6"
set table(6,Rows) 1
Word SetTableBorderLineStyle $table(6,Id)

Word SetRowHeight $table(6,Id) 1 "1.6c"
Word SetCellValue $table(6,Id) 1 1 "Bottom"
Word SetCellValue $table(6,Id) 1 2 "Bottom"
Word SetCellValue $table(6,Id) 1 3 "Bottom"
Word SetTableVerticalAlignment $table(6,Id) "bottom"

# Add a table and delete it afterwards.
Word AppendParagraph $docId
Word AppendText $docId "Deleted table:"
set tableId [Word AddTable [Word GetEndRange $docId] $numRows $numCols]
Word DeleteTable $tableId

# Count the number of tables and return their identifiers.
set numTables [Word GetNumTables $docId]
Cawt CheckNumber 6 $numTables "GetNumTables"
for { set n 1 } { $n <= $numTables } {incr n } {
    set tableId [Word GetTableIdByIndex $docId $n]
    Cawt CheckString "Table-$n" [Word GetTableName $tableId] "Table $n GetTableName"
    Cawt CheckNumber $table($n,Rows) [Word GetNumRows $tableId] "Table $n GetNumRows"
    Cawt Destroy $tableId
}

Word UpdateFields $docId

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
