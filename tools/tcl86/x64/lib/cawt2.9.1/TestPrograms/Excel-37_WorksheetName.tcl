# Test CawtExcel procedures for mapping worksheet names.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Name of Excel file being generated.
set xlsFile [file join [pwd] "testOut" "Excel-37_WorksheetName"]

set appId [Excel OpenNew]
set workbookId [Excel AddWorkbook $appId]

# Append the default Excel filename extension.
append xlsFile [Excel GetExtString $appId]

# Delete Excel file from previous test run.
file mkdir testOut
file delete -force $xlsFile

set longName "This Name Is Too Long For A Worksheet"
set worksheetId [Excel AddWorksheet $workbookId $longName]
Cawt CheckString "This Name Is Too Long For A Wor" \
                 [Excel GetWorksheetName $worksheetId] \
                 "Truncated worksheet name"

set wrongName "Invalid characters: /\\\[\]*?"
set worksheetId [Excel AddWorksheet $workbookId $wrongName]
Cawt CheckString "Invalid characters; __()+|" \
                 [Excel GetWorksheetName $worksheetId] \
                 "Invalid characters"

set worksheetId [Excel AddWorksheet $workbookId ""]
Excel SetWorksheetName $worksheetId "SetName:"
Cawt CheckString "SetName;" \
                 [Excel GetWorksheetName $worksheetId] \
                 "Invalid character"

proc MyMap { name } {
    set mapped [string map { "\[" "_"  "\]" "_"  "\\" "_"  "/" "_"  "?" "_"  "*" "_"  ":" "_" } $name]
    set sheetName [string range $mapped 0 30]
    return $sheetName
}

set worksheetId [Excel AddWorksheet $workbookId $wrongName -mapproc MyMap]
Cawt CheckString "Invalid characters_ ______" \
                 [Excel GetWorksheetName $worksheetId] \
                 "User supplied map procedure"

set catchVal [ catch { Excel AddWorksheet $workbookId $wrongName -mapproc "Unknown" } retVal]
Cawt CheckNumber 1 $catchVal "Catch invalid usage"
if { $catchVal } {
    puts "Successfully caught: $retVal"
}

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
