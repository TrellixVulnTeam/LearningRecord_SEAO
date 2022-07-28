# Test CawtExcel procedures related to font attribute handling.
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
set xlsFile [file join [pwd] "testOut" "Excel-23_Font-Attributes"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

# Test the font capabilities.
Excel SetCellValue $worksheetId  1 1 "Subscript"
Excel SetCellValue $worksheetId  2 1 "Superscript"
Excel SetCellValue $worksheetId  3 1 "Bold"
Excel SetCellValue $worksheetId  4 1 "Italic"
Excel SetCellValue $worksheetId  5 1 "Underline"
Excel SetCellValue $worksheetId  6 1 "StrikeThrough"
Excel SetCellValue $worksheetId  7 1 "Size"
Excel SetCellValue $worksheetId  8 1 "Name"
Excel SetCellValue $worksheetId  9 1 "OutlineFont"
Excel SetCellValue $worksheetId 10 1 "Shadow"
Excel SetCellValue $worksheetId 11 1 "ThemeColor"
Excel SetCellValue $worksheetId 12 1 "ThemeFont"
Excel SetCellValue $worksheetId 13 1 "TintAndShade"
Excel SetCellValue $worksheetId 14 1 "FontStyle"

# xlThemeColorLight1

set rangeId [Excel SelectCellByIndex $worksheetId 1 1 true]
Excel SetRangeFontAttributes $rangeId -subscript true
Cawt CheckBoolean true [lindex [Excel GetRangeFontAttributes $rangeId -subscript] 0] "IsSubscript"

set rangeId [Excel SelectCellByIndex $worksheetId 2 1 true]
Excel SetRangeFontAttributes $rangeId -superscript true
Cawt CheckBoolean true [lindex [Excel GetRangeFontAttributes $rangeId -superscript] 0] "IsSuperscript"

set rangeId [Excel SelectCellByIndex $worksheetId 3 1 true]
Excel SetRangeFontAttributes $rangeId -bold true
Cawt CheckBoolean true [lindex [Excel GetRangeFontAttributes $rangeId -bold] 0] "IsBold"

set rangeId [Excel SelectCellByIndex $worksheetId 4 1 true]
Excel SetRangeFontAttributes $rangeId -italic true
Cawt CheckBoolean true [lindex [Excel GetRangeFontAttributes $rangeId -italic] 0] "IsItalic"

set rangeId [Excel SelectCellByIndex $worksheetId 5 1 true]
Excel SetRangeFontAttributes $rangeId -underline xlUnderlineStyleSingle
Cawt CheckNumber $Excel::xlUnderlineStyleSingle \
                 [lindex [Excel GetRangeFontAttributes $rangeId -underline] 0] "IsUnderline"

set rangeId [Excel SelectCellByIndex $worksheetId 6 1 true]
Excel SetRangeFontAttributes $rangeId -strikethrough true
Cawt CheckBoolean true [lindex [Excel GetRangeFontAttributes $rangeId -strikethrough] 0] "IsStrikeThrough"

set rangeId [Excel SelectCellByIndex $worksheetId 7 1 true]
Excel SetRangeFontAttributes $rangeId -size 14
Cawt CheckNumber 14 [lindex [Excel GetRangeFontAttributes $rangeId -size] 0] "Font size"

set rangeId [Excel SelectCellByIndex $worksheetId 8 1 true]
Excel SetRangeFontAttributes $rangeId -name "Times New Roman"
Cawt CheckString "Times New Roman" [lindex [Excel GetRangeFontAttributes $rangeId -name] 0] "Font name"

set rangeId [Excel SelectCellByIndex $worksheetId 9 1 true]
Excel SetRangeFontAttributes $rangeId -outlinefont true
Cawt CheckBoolean true [lindex [Excel GetRangeFontAttributes $rangeId -outlinefont] 0] "IsOutlineFont"

set rangeId [Excel SelectCellByIndex $worksheetId 10 1 true]
Excel SetRangeFontAttributes $rangeId -shadow true
Cawt CheckBoolean true [lindex [Excel GetRangeFontAttributes $rangeId -shadow] 0] "IsShadow"

set rangeId [Excel SelectCellByIndex $worksheetId 11 1 true]
Excel SetRangeFontAttributes $rangeId -themecolor xlThemeColorLight1
Cawt CheckNumber $Excel::xlThemeColorLight1 \
                 [lindex [Excel GetRangeFontAttributes $rangeId -themecolor] 0] "ThemeColor"

set rangeId [Excel SelectCellByIndex $worksheetId 12 1 true]
Excel SetRangeFontAttributes $rangeId -themefont xlThemeFontMajor
Cawt CheckNumber $Excel::xlThemeFontMajor \
                 [lindex [Excel GetRangeFontAttributes $rangeId -themefont] 0] "ThemeFont"

set rangeId [Excel SelectCellByIndex $worksheetId 13 1 true]
Excel SetRangeFontAttributes $rangeId -tintandshade 0.0
Cawt CheckNumber 0.0 [lindex [Excel GetRangeFontAttributes $rangeId -tintandshade] 0] "TintAndShade"

set rangeId [Excel SelectCellByIndex $worksheetId 14 1 true]
Excel SetRangeFontAttributes $rangeId -fontstyle "Bold Italic"
# We do not check the return string, because it is language dependent.
puts "Font style: [lindex [Excel GetRangeFontAttributes $rangeId -fontstyle] 0]"

Excel SetColumnWidth $worksheetId 1 0

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile "" false

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
