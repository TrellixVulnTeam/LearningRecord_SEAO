# Test CawtOffice procedures to add Excel macros (Sub and Function)
# from a string and run these macros.
#
# To allow adding macros, an option in the trust center must be enabled:
# In "Excel Options" click "Trust Center", then click "Trust Center Settings".
# Click "Macro Settings", click to select the "Trust Access to the VBA project
# object model" check box, and then click OK two times.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# File containing the test macros.
set basFile [file join [pwd] "testIn" "TestMacro.bas"]

# Number of test rows and columns being generated.
set numRows 20
set numCols 5

# Open new instance of Excel and create a workbook.
set appId [Excel OpenNew]
set workbookId [Excel AddWorkbook $appId]

# Create testOut directory, if it does not yet exist.
file mkdir testOut
set outFile [file join [pwd] "testOut" "Excel-33_AddAndRunMacro.xlsx"]
file delete -force $outFile

# Select the first - already existing - worksheet,
# set its name and fill it with data via CAWT.
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]
Excel SetWorksheetName $worksheetId "CAWT"
for { set i 1 } { $i <= $numRows } { incr i } {
    for { set j 1 } { $j <= $numCols } { incr j } {
        Excel SetCellValue $worksheetId $i $j [format "Cell($i,$j)"]
    }
}

# Read the macros stored in the VBA file into a Tcl string.
set fp [open $basFile]
set macroString [read $fp]
close $fp

puts "Adding macros from string ..."
set catchVal [catch { Office AddMacro $appId -code $macroString } errMsg]
if { $catchVal } {
    puts "Error: $errMsg"
} else {
    # Add a new worksheet and and perform the same action with a macro function.
    set worksheetId [Excel AddWorksheet $workbookId "MacroFun"]

    puts "Running macro MacroFun ..."
    set retVal [Office RunMacro $appId "MacroFun" $worksheetId $numRows $numCols]
    Cawt CheckNumber [expr $numRows * $numCols] $retVal "Return value of MacroFun"
    Cawt CheckString "Cell(1,2)" [Excel GetCellValue $worksheetId 1 2] "Inserted value"

    # Add a new worksheet and and perform the same action with a macro procedure.
    set worksheetId [Excel AddWorksheet $workbookId "MacroSub"]

    puts "Running macro MacroSub ..."
    set retVal [Office RunMacro $appId "MacroSub" $worksheetId $numRows $numCols]
    Cawt CheckString "" $retVal "Return value of MacroSub"
    Cawt CheckString "Cell(1,2)" [Excel GetCellValue $worksheetId 1 2] "Inserted value"
}

puts "Saving as Excel file: $outFile"
Excel SaveAs $workbookId $outFile "" false

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
