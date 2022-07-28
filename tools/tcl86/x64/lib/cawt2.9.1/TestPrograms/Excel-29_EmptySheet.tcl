# Test CawtExcel procedures dealing with empty worksheets.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

proc CheckWorksheet { worksheetId isEmpty } {
    Cawt CheckBoolean $isEmpty [Excel IsWorksheetEmpty $worksheetId] "IsWorksheetEmpty"
    Cawt CheckNumber 1 [Excel GetNumUsedRows $worksheetId] "GetNumUsedRows"
    Cawt CheckNumber 1 [Excel GetNumUsedColumns $worksheetId] "GetNumUsedColumns"
    Cawt CheckNumber 1 [Excel GetFirstUsedRow $worksheetId] "GetFirstUsedRow"
    Cawt CheckNumber 1 [Excel GetFirstUsedColumn $worksheetId] "GetFirstUsedColumn"
    Cawt CheckNumber 1 [Excel GetLastUsedRow $worksheetId] "GetLastUsedRow"
    Cawt CheckNumber 1 [Excel GetLastUsedColumn $worksheetId] "GetLastUsedColumn"

    if { $isEmpty } {
        set value [list]
    } else {
        set value [list "Value"]
    }
    Cawt CheckList $value [Excel GetWorksheetAsMatrix $worksheetId] "GetWorksheetAsMatrix"
}

# Open new instance of Excel and create a workbook and an empty sheet.
set appId [Excel OpenNew]
set workbookId [Excel AddWorkbook $appId]

set worksheetId [Excel AddWorksheet $workbookId "EmptySheet"]

CheckWorksheet $worksheetId true

Excel SetCellValue $worksheetId 1 1 "Value"

CheckWorksheet $worksheetId false

Cawt PrintNumComObjects

Excel Close $workbookId

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
