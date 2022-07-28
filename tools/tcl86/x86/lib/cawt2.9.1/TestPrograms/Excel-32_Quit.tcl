# Test quitting Excel without saving modified worksheets.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Number of test rows and columns being generated.
set numRows  10
set numCols   3

# Generate row list with test data
for { set i 1 } { $i <= $numCols } { incr i } {
    lappend rowList $i
}

# Open Excel, show the application window, 
# create a workbook and fill in some data.
set appId [Excel Open true]
set workbookId [Excel AddWorkbook $appId]

set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]
Excel SetWorksheetName $worksheetId "ExcelMisc"

for { set row 1 } { $row <= $numRows } { incr row } {
    Excel SetRowValues $worksheetId $row $rowList
}

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId false
    Cawt Destroy
    exit 0
}
Excel Quit $appId true
Cawt Destroy
