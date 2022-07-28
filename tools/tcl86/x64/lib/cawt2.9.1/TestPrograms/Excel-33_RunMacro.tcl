# Test CawtOffice procedures to run macros (Sub and Function)
# contained in an Excel file.
#
# The macros contained in the Excel files are identical to the 
# macros contained in source file testIn/TestMacro.bas".
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Number of test rows and columns being generated.
set numRows 20
set numCols 5

# The Excel files containing the macros.
set xlsFile1 [file join [pwd] "testIn" "SampleMacro.xls"]
set xlsFile2 [file join [pwd] "testIn" "SampleMacro.xlsm"]

# Create testOut directory, if it does not yet exist.
file mkdir testOut
set outFile1 [file join [pwd] "testOut" "Excel-33_RunMacro.xls"]
set outFile2 [file join [pwd] "testOut" "Excel-33_RunMacro.xlsx"]
file delete -force $outFile1
file delete -force $outFile2

# Open new instance of Excel.
set appId [Excel OpenNew]

# Open first workbook in old xls format.
set workbookId  [Excel OpenWorkbook $appId $xlsFile1 -readonly true]
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

puts "Running macro MacroFun from $xlsFile1 ..."
set retVal [Office RunMacro $appId "MacroFun" $worksheetId $numRows $numCols]
Cawt CheckNumber [expr $numRows * $numCols] $retVal "Return value of MacroFun"
Cawt CheckString "Cell(1,2)" [Excel GetCellValue $worksheetId 1 2] "Inserted value"

puts "Saving as Excel file: $outFile1"
Excel SaveAs $workbookId $outFile1 "" false

# Open second workbook in new xlsm format.
set workbookId  [Excel OpenWorkbook $appId $xlsFile2 -readonly true]
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

puts "Running macro MacroFun from $xlsFile2 ..."
set retVal [Office RunMacro $appId "MacroFun" $worksheetId $numRows $numCols]
Cawt CheckNumber [expr $numRows * $numCols] $retVal "Return value of MacroFun"
Cawt CheckString "Cell(1,2)" [Excel GetCellValue $worksheetId 1 2] "Inserted value"

puts "Saving as Excel file: $outFile2"
Excel SaveAs $workbookId $outFile2 xlOpenXMLWorkbook false

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
