# Test CawtExcel procedures related to CSV files.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set inPath  [file join [pwd] "testIn"]
set outPath [file join [pwd] "testOut"]

# Test file with Unicode characters.
set xlsUnicodeFile [file join $inPath "SampleUnicode.xlsx"]

# Name of CSV file being generated.
set outFileCsv [file join $outPath "Excel-07_CsvUnicode.csv"]

file mkdir testOut
file delete -force $outFileCsv

set appId [Excel OpenNew]
set workbookId [Excel OpenWorkbook $appId $xlsUnicodeFile]
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

if { [Excel GetVersion $appId] < 16.0 } {
    puts "Saving CSV-UTF8 file available only with Excel 2016 or newer"
} else {
    puts "Saving CSV-UTF8 file $outFileCsv with Excel"
    Excel SaveAsCsv $workbookId $worksheetId $outFileCsv xlCSVUTF8
}

Excel Close $workbookId
Excel Quit $appId false

Cawt PrintNumComObjects

Cawt Destroy
if { [lindex $argv 0] eq "auto" } {
    exit 0
}
