# Test CawtExcel procedures related to property handling.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open Excel, show the application window and create a workbook.
set appId [Excel OpenNew true]
set workbookId [Excel AddWorkbook $appId]

# Delete Excel file from previous test run.
file mkdir testOut
set xlsFile [file join [pwd] "testOut" "Excel-25_Properties"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

# Set some builtin and custom properties and check their values.
Office SetDocumentProperty $workbookId "Author"      "Paul"
Office SetDocumentProperty $workbookId "Company"     "poSoft"
Office SetDocumentProperty $workbookId "Title"       $xlsFile
Office SetDocumentProperty $workbookId "Custom Prop" "Custom Value"

Cawt CheckString "Paul"         [Office GetDocumentProperty $workbookId "Author"]      "Property Author"
Cawt CheckString "poSoft"       [Office GetDocumentProperty $workbookId "Company"]     "Property Company"
Cawt CheckString $xlsFile       [Office GetDocumentProperty $workbookId "Title"]       "Property Title"
Cawt CheckString "Custom Value" [Office GetDocumentProperty $workbookId "Custom Prop"] "Property Custom Prop"

set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

Excel SetHeaderRow $worksheetId "BuiltinProperties" 1 1
Excel SetHeaderRow $worksheetId "CustomProperties" 1 3
Excel SetHeaderRow $worksheetId [list "Name" "Value" "Name" "Value"] 2 1
set rangeId [Excel SelectRangeByIndex $worksheetId 1 1 1 2]
Excel SetRangeMergeCells $rangeId true
set rangeId [Excel SelectRangeByIndex $worksheetId 1 3 1 4]
Excel SetRangeMergeCells $rangeId true

# Get all builtin and custom properties and insert them into the worksheet.
set row 3
set col 1
foreach propertyName [Office GetDocumentProperties $workbookId "Builtin"] {
    Excel SetCellValue $worksheetId $row [expr $col + 0] $propertyName
    Excel SetCellValue $worksheetId $row [expr $col + 1] [Office GetDocumentProperty $workbookId $propertyName]
    incr row
}

set row 3
set col 3
foreach propertyName [Office GetDocumentProperties $workbookId "Custom"] {
    Excel SetCellValue $worksheetId $row [expr $col + 0] $propertyName
    Excel SetCellValue $worksheetId $row [expr $col + 1] [Office GetDocumentProperty $workbookId $propertyName]
    incr row
}

Excel SetColumnsWidth $worksheetId 1 4

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile "" false

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
