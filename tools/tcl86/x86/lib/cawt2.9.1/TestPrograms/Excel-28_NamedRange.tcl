# Test CawtExcel procedures related to named ranges.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set inFile [file join [pwd] "testIn" "SampleNamedRange.xls"]

# Open new instance of Excel.
set appId [Excel OpenNew]

# Delete Excel file from previous test run.
file mkdir testOut
set xlsFile [file join [pwd] "testOut" "Excel-28_NamedRange.xls"]
file delete -force $xlsFile

# Open the Excel file with sample tags.
set workbookId [Excel OpenWorkbook $appId $inFile -readonly true]
set worksheetId [Excel GetWorksheetIdByName $workbookId "Income2015"]

Cawt CheckBoolean true  [Excel IsWorkbookId $workbookId]  "IsWorkbookId workbookId"
Cawt CheckBoolean false [Excel IsWorkbookId $worksheetId] "IsWorkbookId worksheetId"

set rangeId [Excel GetNamedRange $workbookId "Sum"]
Cawt CheckNumber 3000 [Excel GetRangeValues $rangeId] "GetNamedRange Sum"

set rangeId [Excel GetNamedRange $worksheetId "Sum_02"]
Cawt CheckNumber 1000 [Excel GetRangeValues $rangeId] "GetNamedRange Sum_01"

set catchVal [catch { Excel GetNamedRange $worksheetId "Sum_XX" } retVal]
Cawt CheckNumber 1 $catchVal "Catch invalid usage"
if { $catchVal } {
    puts "Successfully caught: $retVal"
}

set monthRangeId [Excel SelectRangeByString $worksheetId "A9:C9"]
Excel SetNamedRange $monthRangeId "All"
set newRangeId [Excel GetNamedRange $worksheetId "All"]
# Range values are returned as matrix (i.e. as list of lists).
set rangeValues [lindex [Excel GetRangeValues $newRangeId] 0]
Cawt CheckList [list 500 1000 1500] $rangeValues "GetNamedRange All"

puts "Named ranges of workbook [Excel GetWorkbookName $workbookId]:"
foreach name [Excel GetNamedRangeNames $workbookId] {
    puts "  $name"
}
puts "Named ranges of worksheet [Excel GetWorksheetName $worksheetId]:"
foreach name [Excel GetNamedRangeNames $worksheetId] {
    puts "  $name"
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
