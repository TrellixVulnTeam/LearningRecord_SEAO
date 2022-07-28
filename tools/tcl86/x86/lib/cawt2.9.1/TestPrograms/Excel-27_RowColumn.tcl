# Test CawtExcel procedures for row and column handling:
# Insert, delete, hide, duplicate.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

# Number of test rows and columns being generated.
set numRows 10
set numCols  9

# Generate matrix with test data.
set matrixList [list]
for { set row 1 } { $row <= $numRows } { incr row } {
    set rowList [list]
    for { set col 1 } { $col <= $numCols } { incr col } {
        lappend rowList [format "Cell_%d_%d" $row $col]
    }
    lappend matrixList $rowList
}

# Open new instance of Excel and add a workbook.
set appId [Excel OpenNew]
set workbookId [Excel AddWorkbook $appId]

# Delete Excel file from previous test run.
file mkdir testOut
set xlsFile [file join [pwd] "testOut" "Excel-27_RowColumn"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

puts "Adding worksheets with $numRows rows and $numCols columns ..."
set colWorksheetId [Excel AddWorksheet $workbookId "ColumnHandling"]
set rowWorksheetId [Excel AddWorksheet $workbookId "RowHandling"]

Excel SetMatrixValues $colWorksheetId $matrixList
Excel SetMatrixValues $rowWorksheetId $matrixList

set index(hide) 2
set index(ins)  4
set index(dup)  6
set index(del)  8

set color(hide) "magenta"
set color(ins)  "green"
set color(dup)  "yellow"
set color(del)  "red"

foreach type [array names index] {
    set rangeId [Excel SelectRangeByIndex $rowWorksheetId $index($type) 1 $index($type) $numCols true]
    Excel SetRangeFillColor $rangeId $color($type)
    Cawt Destroy $rangeId
    set rangeId [Excel SelectRangeByIndex $colWorksheetId 1 $index($type) $numRows $index($type)]
    Excel SetRangeFillColor $rangeId $color($type)
    Cawt Destroy $rangeId
}

puts "\nRow handling: Hide, delete, duplicate, insert ..."

Excel HideRow $rowWorksheetId $index(hide)
Cawt CheckNumber $numRows [Excel GetNumUsedRows $rowWorksheetId] "Number of used rows after hiding #$index(hide)"

Excel DeleteRow $rowWorksheetId $index(del)
Cawt CheckNumber [expr $numRows-1] [Excel GetNumUsedRows $rowWorksheetId] "Number of used rows after deleting #$index(del)"

Excel DuplicateRow $rowWorksheetId $index(dup)
Cawt CheckNumber $numRows [Excel GetNumUsedRows $rowWorksheetId] "Number of used rows after duplicating #$index(dup)"

Excel InsertRow $rowWorksheetId $index(ins)
Cawt CheckNumber [expr $numRows+1] [Excel GetNumUsedRows $rowWorksheetId] "Number of used rows after inserting #$index(ins)"

set hiddenRows [Excel GetHiddenRows $rowWorksheetId]
Cawt CheckNumber 1 [llength $hiddenRows] "Number of hidden rows"
Cawt CheckNumber $index(hide) [lindex $hiddenRows 0] "Hidden row"

puts "\nColumn handling: Hide, delete, duplicate, insert ..."

Excel HideColumn $colWorksheetId $index(hide)
Cawt CheckNumber $numCols [Excel GetNumUsedColumns $colWorksheetId] "Number of used columns after hiding #$index(hide)"

Excel DeleteColumn $colWorksheetId $index(del)
Cawt CheckNumber [expr $numCols-1] [Excel GetNumUsedColumns $colWorksheetId] "Number of used columns after deleting #$index(del)"

Excel DuplicateColumn $colWorksheetId $index(dup)
Cawt CheckNumber $numCols [Excel GetNumUsedColumns $colWorksheetId] "Number of used columns after duplicating #$index(dup)"

Excel InsertColumn $colWorksheetId $index(ins)
Cawt CheckNumber [expr $numCols+1] [Excel GetNumUsedColumns $colWorksheetId] "Number of used columns after inserting #$index(ins)"

set hiddenCols [Excel GetHiddenColumns $colWorksheetId]
Cawt CheckNumber 1 [llength $hiddenCols] "Number of hidden columns"
Cawt CheckNumber $index(hide) [lindex $hiddenCols 0] "Hidden column"

Excel ShowWorksheet $colWorksheetId

puts "\nSaving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
