# Test CawtExcel procedure for diff'ing Excel files.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open Excel, so we can get the extension string.
set appId [Excel Open true]

set outPath1 [file join [pwd] "testOut"]
set outPath2 [file join [pwd] "testOut" "ExcelDiff"]
set xlsOutFile1 [file join $outPath1 Excel-17_Diff-Base[Excel GetExtString $appId]]
set xlsOutFile2 [file join $outPath2 Excel-17_Diff-Base[Excel GetExtString $appId]]

# Create testOut directory, if it does not yet exist.
file mkdir $outPath1
file mkdir $outPath2

# Delete Excel output file from previous test run.
file delete -force $xlsOutFile1
file delete -force $xlsOutFile2

# Create an Excel file with some test data.
set workbookId [Excel AddWorkbook $appId]
set headerList { "Col-1" "Col-2" "Col-3" "Col-4" }
set dataList {
    {"1" "2" "3" "None"}
    {"1.1" "1.2" "1.3" "Dot"}
    {"1,1" "1,2" "1,3" "Comma"}
    {"1|1" "1|2" "1|3" "Pipe"}
    {"1;1" "1;2" "1;3" "Semicolon"}
}

set worksheetId [Excel AddWorksheet $workbookId "DiffTest"]
Excel SetHeaderRow $worksheetId $headerList
Excel SetMatrixValues $worksheetId $dataList 2

Excel SaveAs $workbookId $xlsOutFile1
Excel SaveAs $workbookId $xlsOutFile2

Excel Close $workbookId
Excel Quit $appId

set diffAppId [Excel DiffExcelFiles $xlsOutFile1 $xlsOutFile2 0 255 0]

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $diffAppId
    Cawt Destroy
    exit 0
}
Cawt Destroy
