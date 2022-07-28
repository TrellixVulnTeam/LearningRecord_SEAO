# Test CawtExcel procedures related to import functionality.
#
# Copyright: 2018-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# The file to be imported.
set inFile [file join [pwd] "testIn" "temperatures.dat"]

# Open new instance of Excel and create a workbook.
set appId [Excel Open]
set workbookId  [Excel AddWorkbook $appId]

# Delete Excel file from previous test run.
file mkdir testOut
set xlsFile [file join [pwd] "testOut" "Excel-31_Import"]
append xlsFile [Excel GetExtString $appId]
file delete -force $xlsFile

set srcWorksheetId [Excel AddWorksheet $workbookId "CsvImp"]

# Import the CSV file, which has spaces as delimiters
# and a dot as the decimal separator of the floating-point values.
set rangeId [Excel SelectRangeByString $srcWorksheetId "A1"]
Excel Import $rangeId $inFile \
       -delimiter " " \
       -decimalseparator "." \
       -thousandsseparator ","
Cawt CheckNumber 100 [Excel GetNumUsedRows $srcWorksheetId] "Number of imported rows"

# Copy the first and last column into a new worksheet.
# Copy the data into the second row of the new worksheet,
# so we can add a header row later.
set destWorksheetId [Excel AddWorksheet $workbookId "Compare"]
set numCols [Excel GetNumUsedColumns $srcWorksheetId]
Excel CopyColumn $srcWorksheetId 1         $destWorksheetId 2  1 2
Excel CopyColumn $srcWorksheetId $numCols  $destWorksheetId 1  1 2

# Add header line for the 3 new columns and autofit the column width.
Excel SetHeaderRow $destWorksheetId { "Min (K)" "Max (K)" "Diff (K)" }
Excel SetColumnsWidth $destWorksheetId 1 3

Cawt CheckNumber 101 [Excel GetNumUsedRows $destWorksheetId] "Number of copied rows"

# Calculate the absolute difference between min and max values
# via Excel formulas and add these into column 3.
set numRows [Excel GetNumUsedRows $destWorksheetId]
for { set row 2 } { $row <= $numRows } { incr row } {
    set cellId [Excel SelectCellByIndex $destWorksheetId $row 3]
    $cellId FormulaR1C1 "=ABS(RC\[-2\]-RC\[-1\])"
    Cawt Destroy $cellId
}

# Create a simple line chart to display the min and max values.
set chartId [Excel CreateChart $destWorksheetId $Excel::xlLine]
Excel SetChartSourceByIndex $chartId $destWorksheetId 1 1 $numRows 2
Excel SetChartTitle $chartId "Min/Max of [file tail $inFile]"
Excel SetChartMinScale $chartId "y" 250
Excel SetChartMaxScale $chartId "y" 350

Cawt CheckNumber 2 [Excel GetChartNumSeries $chartId] "Number of series in chart"

# Get first series and set the line width.
set series [Excel GetChartSeries $chartId 1]
Excel SetSeriesLineWidth $series 2

# Place the chart into the destination worksheet.
Excel SetChartObjPosition [Excel PlaceChart $chartId $destWorksheetId] 200 20
Cawt Destroy $rangeId
Cawt Destroy $chartId

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
