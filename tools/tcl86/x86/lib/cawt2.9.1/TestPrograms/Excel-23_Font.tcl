# Test CawtExcel procedures related to font handling.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open Excel, show the application window and create a workbook.
set appId [Excel Open true]
set workbookId [Excel AddWorkbook $appId]

# Delete Excel file from previous test run.
file mkdir testOut
set xlsFile [file join [pwd] "testOut" "Excel-23_Font"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

# Test the font capabilities.
Excel SetCellValue $worksheetId  1 1 "Subscript"
Excel SetCellValue $worksheetId  2 1 "Superscript"
Excel SetCellValue $worksheetId  3 1 "Subscript"
Excel SetCellValue $worksheetId  4 1 "Superscript"
Excel SetCellValue $worksheetId  5 1 "Bold"
Excel SetCellValue $worksheetId  6 1 "Italic"
Excel SetCellValue $worksheetId  7 1 "Underline"
Excel SetCellValue $worksheetId  8 1 "12 points"
Excel SetCellValue $worksheetId  9 1 "14 points"
Excel SetCellValue $worksheetId 10 1 "Arial"
Excel SetCellValue $worksheetId 11 1 "Times New Roman"
Excel SetCellValue $worksheetId 12 1 "Horizontal Alignment (Left)"
Excel SetCellValue $worksheetId 13 1 "Horizontal Alignment (Center)"
Excel SetCellValue $worksheetId 14 1 "Horizontal Alignment (Right)"
Excel SetCellValue $worksheetId 15 1 "Vertical Alignment (Top)"
Excel SetCellValue $worksheetId 16 1 "Vertical Alignment (Center)"
Excel SetCellValue $worksheetId 17 1 "Vertical Alignment (Bottom)"

set rangeId [Excel SelectCellByIndex $worksheetId 1 1 true]
Excel SetRangeFontSubscript $rangeId true
Cawt CheckBoolean true [Excel GetRangeFontSubscript $rangeId] "IsSubscript"

set rangeId [Excel SelectCellByIndex $worksheetId 2 1 true]
Excel SetRangeFontSuperscript $rangeId true
Cawt CheckBoolean true [Excel GetRangeFontSuperscript $rangeId] "IsSuperscript"

set rangeId [Excel SelectCellByIndex $worksheetId 3 1 true]
Excel SetRangeFontSubscript [Excel GetRangeCharacters $rangeId 4] true

set rangeId [Excel SelectCellByIndex $worksheetId 4 1 true]
Excel SetRangeFontSuperscript [Excel GetRangeCharacters $rangeId 6 6] true

set rangeId [Excel SelectCellByIndex $worksheetId 5 1 true]
Excel SetRangeFontBold $rangeId true
Cawt CheckBoolean true [Excel GetRangeFontBold $rangeId] "IsBold"

set rangeId [Excel SelectCellByIndex $worksheetId 6 1 true]
Excel SetRangeFontItalic $rangeId true
Cawt CheckBoolean true [Excel GetRangeFontItalic $rangeId] "IsItalic"

set rangeId [Excel SelectCellByIndex $worksheetId 7 1 true]
Excel SetRangeFontUnderline $rangeId
Cawt CheckNumber $Excel::xlUnderlineStyleSingle [Excel GetRangeFontUnderline $rangeId] "IsUnderline"

set rangeId [Excel SelectCellByIndex $worksheetId 8 1 true]
Excel SetRangeFontSize $rangeId 12
Cawt CheckNumber 12 [Excel GetRangeFontSize $rangeId] "Font size"

set rangeId [Excel SelectCellByIndex $worksheetId 9 1 true]
Excel SetRangeFontSize $rangeId 14
Cawt CheckNumber 14 [Excel GetRangeFontSize $rangeId] "Font size"

set rangeId [Excel SelectCellByIndex $worksheetId 10 1 true]
Excel SetRangeFontName $rangeId "Arial"
Cawt CheckString "Arial" [Excel GetRangeFontName $rangeId] "Font name"

set rangeId [Excel SelectCellByIndex $worksheetId 11 1 true]
Excel SetRangeFontName $rangeId "Times New Roman"
Cawt CheckString "Times New Roman" [Excel GetRangeFontName $rangeId] "Font name"

set rangeId [Excel SelectCellByIndex $worksheetId 12 1]
Excel SetRangeHorizontalAlignment $rangeId xlHAlignLeft
Cawt CheckNumber $::Excel::xlHAlignLeft [Excel GetRangeHorizontalAlignment $rangeId] "Horizontal alignment (Left)"

set rangeId [Excel SelectCellByIndex $worksheetId 13 1]
Excel SetRangeHorizontalAlignment $rangeId xlHAlignCenter
Cawt CheckNumber $::Excel::xlHAlignCenter [Excel GetRangeHorizontalAlignment $rangeId] "Horizontal alignment (Center)"

set rangeId [Excel SelectCellByIndex $worksheetId 14 1]
Excel SetRangeHorizontalAlignment $rangeId xlHAlignRight
Cawt CheckNumber $::Excel::xlHAlignRight [Excel GetRangeHorizontalAlignment $rangeId] "Horizontal alignment (Right)"

set rangeId [Excel SelectCellByIndex $worksheetId 15 1]
Excel SetRangeVerticalAlignment $rangeId xlVAlignTop
Cawt CheckNumber $::Excel::xlVAlignTop [Excel GetRangeVerticalAlignment $rangeId] "Vertical alignment (Top)"

set rangeId [Excel SelectCellByIndex $worksheetId 16 1]
Excel SetRangeVerticalAlignment $rangeId xlVAlignCenter
Cawt CheckNumber $::Excel::xlVAlignCenter [Excel GetRangeVerticalAlignment $rangeId] "Vertical alignment (Center)"

set rangeId [Excel SelectCellByIndex $worksheetId 17 1]
Excel SetRangeVerticalAlignment $rangeId xlVAlignBottom
Cawt CheckNumber $::Excel::xlVAlignBottom [Excel GetRangeVerticalAlignment $rangeId] "Vertical alignment (Bottom)"

Excel SetRowsHeight $worksheetId 15 17 1c
Excel SetColumnWidth $worksheetId 1 0

Excel SetCellValue $worksheetId 18 1 "A looooooooooooong cell entry which should be wrapped."
set rangeId [Excel SelectCellByIndex $worksheetId 18 1]
Excel SetRangeWrapText $rangeId
Cawt CheckBoolean true [Excel GetRangeWrapText $rangeId] "IsWrapText"

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile "" false

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
