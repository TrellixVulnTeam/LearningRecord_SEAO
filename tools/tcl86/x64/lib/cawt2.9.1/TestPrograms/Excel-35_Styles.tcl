# Test CawtExcel procedures related to Styles handling.
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
set xlsFile [file join [pwd] "testOut" "Excel-35_Styles"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

# Insert the URL to the official Microsoft documentation site in the
# first row and set the Hyperlink style theme color.
set url "https://docs.microsoft.com/en-us/office/vba/api/excel.style"
set rangeId [Excel SelectRangeByIndex $worksheetId 1 1 1 5]
Excel SetRangeMergeCells $rangeId true
Excel SetHyperlink $worksheetId 1 1 $url
set styleId [Excel GetStyleId $workbookId "Hyperlink"]
Excel SetRangeFontAttributes $styleId -themecolor xlThemeColorLight1
Cawt Destroy $rangeId
Cawt Destroy $styleId

Excel SetHeaderRow $worksheetId [list "Builtin" "Name" "NameLocal" "Value" "FontName"] 2 1
set numStyles [Excel GetNumStyles $workbookId]

# Get all styles by index and insert the names into the worksheet.
set row 3
for { set i 1 } { $i <= $numStyles } { incr i } {
    set styleId [Excel GetStyleId $workbookId $i]
    Excel SetCellValue $worksheetId $row 1 [$styleId Builtin]
    Excel SetCellValue $worksheetId $row 2 [$styleId Name]
    Excel SetCellValue $worksheetId $row 3 [$styleId NameLocal]
    Excel SetCellValue $worksheetId $row 4 [$styleId Value]
    if { [$styleId IncludeFont] } {
        set fontName [Excel GetRangeFontAttribute $styleId -name]
        Excel SetCellValue $worksheetId $row 5 $fontName
    }
    incr row
    Cawt Destroy $styleId
}

# Get all styles by name and compare to the names in the worksheet.
set row 3
for { set i 1 } { $i <= $numStyles } { incr i } {
    set styleName [Excel GetCellValue $worksheetId $row 4]
    set styleId [Excel GetStyleId $workbookId $styleName]
    Cawt CheckString $styleName [$styleId Value] "Style $i"
    incr row
    Cawt Destroy $styleId
}

# Use invalid index and style names.
set catchVal [catch { Excel GetStyleId $workbookId 0 } retVal]
Cawt CheckNumber 1 $catchVal "Catch invalid usage"
if { $catchVal } {
    puts "Successfully caught: $retVal"
}
set catchVal [catch { Excel GetStyleId $workbookId "UnknownStyleName" } retVal]
Cawt CheckNumber 1 $catchVal "Catch invalid usage"
if { $catchVal } {
    puts "Successfully caught: $retVal"
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
