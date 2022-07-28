# Test CawtExcel procedures for setting and getting cell values.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set startCol 1

# Open Excel, show the application window and create a workbook.
set appId [Excel Open true]
set workbookId [Excel AddWorkbook $appId]

# Delete Excel file from previous test run.
file mkdir testOut
set xlsFile [file join [pwd] "testOut" "Excel-16_SetGet"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

# Select the first - already existing - worksheet,
# set its name and fill it with data.
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]
Excel SetWorksheetName $worksheetId "SetGet"

set valList [list "SetColumnValues" 1 1.4 1.6 012 0x12 2147483647 2147483648 10000000000]

# Insert values with the different SetCellValue procedures.
Excel SetCellValue $worksheetId 1 1  "SetCellValue text"
Excel SetCellValue $worksheetId 2 1  1           "text"
Excel SetCellValue $worksheetId 3 1  1.4         "text"
Excel SetCellValue $worksheetId 4 1  1.6         "text"
Excel SetCellValue $worksheetId 5 1  012         "text"
Excel SetCellValue $worksheetId 6 1  0x12        "text"
Excel SetCellValue $worksheetId 7 1  2147483647  "text"
Excel SetCellValue $worksheetId 8 1  2147483648  "text"
Excel SetCellValue $worksheetId 9 1  10000000000 "text"

Excel SetCellValue $worksheetId 1 2  "SetCellValue int"
Excel SetCellValue $worksheetId 2 2  1           "int"
Excel SetCellValue $worksheetId 3 2  1.4         "int"
Excel SetCellValue $worksheetId 4 2  1.6         "int"
Excel SetCellValue $worksheetId 5 2  012         "int"
Excel SetCellValue $worksheetId 6 2  0x12        "int"
Excel SetCellValue $worksheetId 7 2  2147483647  "int"
Excel SetCellValue $worksheetId 8 2  2147483648  "int"
Excel SetCellValue $worksheetId 9 2  10000000000 "int"

Excel SetCellValue $worksheetId 1 3  "SetCellValue real"
Excel SetCellValue $worksheetId 2 3  1           "real"
Excel SetCellValue $worksheetId 3 3  1.4         "real"
Excel SetCellValue $worksheetId 4 3  1.6         "real"
Excel SetCellValue $worksheetId 5 3  012         "real"
Excel SetCellValue $worksheetId 6 3  0x12        "real"
Excel SetCellValue $worksheetId 7 3  2147483647  "real"
Excel SetCellValue $worksheetId 8 3  2147483648  "real"
Excel SetCellValue $worksheetId 9 3  10000000000 "real"

Excel SetColumnValues $worksheetId 4 $valList

Cawt CheckString "1"                        [Excel GetCellValueA1 $worksheetId "A2" "text"] "GetCellValueA1 text"
Cawt CheckNumber [expr int(1)]              [Excel GetCellValueA1 $worksheetId "B2" "int"]  "GetCellValueA1 int"
Cawt CheckNumber [expr double(1)]           [Excel GetCellValueA1 $worksheetId "C2" "real"] "GetCellValueA1 real"

Cawt CheckString "1"                        [Excel GetCellValue $worksheetId 2 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(1)]              [Excel GetCellValue $worksheetId 2 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(1)]           [Excel GetCellValue $worksheetId 2 3 "real"] "GetCellValue real"

Cawt CheckString "1.4"                      [Excel GetCellValue $worksheetId 3 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(1.4)]            [Excel GetCellValue $worksheetId 3 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(1.4)]         [Excel GetCellValue $worksheetId 3 3 "real"] "GetCellValue real"

Cawt CheckString "1.6"                      [Excel GetCellValue $worksheetId 4 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(1.6)]            [Excel GetCellValue $worksheetId 4 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(1.6)]         [Excel GetCellValue $worksheetId 4 3 "real"] "GetCellValue real"

Cawt CheckString "012"                      [Excel GetCellValue $worksheetId 5 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(012)]            [Excel GetCellValue $worksheetId 5 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(012)]         [Excel GetCellValue $worksheetId 5 3 "real"] "GetCellValue real"

Cawt CheckString "0x12"                     [Excel GetCellValue $worksheetId 6 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(0x12)]           [Excel GetCellValue $worksheetId 6 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(0x12)]        [Excel GetCellValue $worksheetId 6 3 "real"] "GetCellValue real"

Cawt CheckString "2147483647"               [Excel GetCellValue $worksheetId 7 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(2147483647)]     [Excel GetCellValue $worksheetId 7 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(2147483647)]  [Excel GetCellValue $worksheetId 7 3 "real"] "GetCellValue real"

Cawt CheckString "2147483648"               [Excel GetCellValue $worksheetId 8 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(2147483648)]     [Excel GetCellValue $worksheetId 8 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(2147483648)]  [Excel GetCellValue $worksheetId 8 3 "real"] "GetCellValue real"

Cawt CheckString "10000000000"              [Excel GetCellValue $worksheetId 9 1 "text"] "GetCellValue text"
Cawt CheckNumber [expr int(10000000000)]    [Excel GetCellValue $worksheetId 9 2 "int"]  "GetCellValue int"
Cawt CheckNumber [expr double(10000000000)] [Excel GetCellValue $worksheetId 9 3 "real"] "GetCellValue real"

Excel FormatHeaderRow  $worksheetId 1  1 4
Excel SetColumnsWidth  $worksheetId 1 4  0

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
