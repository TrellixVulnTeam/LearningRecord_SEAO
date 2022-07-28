# Test miscellaneous CawtExcel procedures like setting colors, column width,
# inserting formulas and searching.
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

# Open Excel, show the application window and create a workbook.
set appId [Excel Open true]
set workbookId [Excel AddWorkbook $appId]

# Delete Excel file from previous test run.
file mkdir testOut
set xlsFile [file join [pwd] "testOut" "Excel-30_SelectRange"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

# Select the first - already existing - worksheet,
# set its name and fill it with data.
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]
Excel SetWorksheetName $worksheetId "SelectRange"

for { set row 1 } { $row <= $numRows } { incr row } {
    Excel SetRowValues $worksheetId $row $rowList
}

# Test selecting a non-continous range.
set rangeList { 1 1 2 3  4 2 6 3 }
set rangeStr [Excel CreateRangeString {*}$rangeList]
Cawt CheckString "A1:C2;B4:C6" $rangeStr "Range String"
set rangeId [Excel SelectRangeByString $worksheetId $rangeStr true]

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile "" false

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
