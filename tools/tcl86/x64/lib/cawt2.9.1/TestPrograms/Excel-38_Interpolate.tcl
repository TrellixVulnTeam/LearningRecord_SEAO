# Test interpolation functionality of the CawtCore package in Excel example.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set xlsFile [file join [pwd] "testOut" "Excel-38_Interpolate"]

set spectralData [list \
 0.30  0.0029  0.8355 \
 0.35  0.0038  0.8314 \
 0.40  0.0040  0.8468 \
 0.45  0.0055  0.8434 \
 0.50  0.0100  0.8112 \
 0.55  0.0177  0.7643 \
 0.60  0.0406  0.6225 \
 0.70  0.0604  0.5514 \
 0.75  0.0705  0.5172 \
 1.00  0.1276  0.3682 \
 1.68  0.1417  0.1809 \
 3.00  0.0618  0.1124 \
 3.36  0.0369  0.0996 \
 3.44  0.0296  0.2159 \
 3.62  0.0348  0.0775 \
 5.00  0.0312  0.0384 \
 8.00  0.0199  0.0243 \
12.00  0.0099  0.0117 \
12.60  0.0100  0.0025 \
]

# The names of the header row.
set matColumns [list "WaveBand" "Diffuse" "Emissivity" "WaveBandInterp" "DiffInterp" "EmissInterp"]

# Open new Excel instance, show the application window and create a workbook.
set appId [Excel OpenNew]
set workbookId [Excel AddWorkbook $appId]

# Delete Excel file from previous test run.
append xlsFile [Excel GetExtString $appId]
file mkdir testOut
file delete -force $xlsFile

set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]
Excel SetWorksheetName $worksheetId "SpectralData"

Excel SetHeaderRow $worksheetId $matColumns

set row 2
foreach { wb diff emis } $spectralData {
    set rangeId [Excel SelectRangeByIndex $worksheetId $row 1 $row 3]
    Excel SetRangeFormat $rangeId "real" [Excel GetNumberFormat $appId "0" "0000"]
    Excel SetRowValues $worksheetId $row [list $wb $diff $emis]
    incr row
}
set headerRow 1
set xaxisCol  1
set startRow  2
set numRows   [expr { [llength $spectralData] / 3 }]
set startCol  2
set numCols   2
set title     "Copper Measurement"
set lineChartId [Excel AddLineChart $worksheetId $headerRow $xaxisCol $startRow $numRows $startCol $numCols $title]
set lineChartObjId [Excel PlaceChart $lineChartId $worksheetId]
Excel SetChartObjSize     $lineChartObjId 800 300
Excel SetChartObjPosition $lineChartObjId 400 20

set diffCrv [Cawt Interpolate new]
set emisCrv [Cawt Interpolate new]
foreach { wb diff emis } $spectralData {
    $diffCrv AddControlPoint $wb $diff
    $emisCrv AddControlPoint $wb $emis
}

set row 2
set subFmt [Excel GetNumberFormat $appId "0" "0000"]
$diffCrv SetInterpolationType "Linear"
$emisCrv SetInterpolationType "Linear"
for { set wb 0.0 } { $wb < 14.0 } { set wb [expr {$wb + 0.5 }] } {
    set diffInterp [$diffCrv GetInterpolatedValue $wb]
    set emisInterp [$emisCrv GetInterpolatedValue $wb]
    Excel SetCellValue $worksheetId $row 4 $wb         "real" $subFmt
    Excel SetCellValue $worksheetId $row 5 $diffInterp "real" $subFmt
    Excel SetCellValue $worksheetId $row 6 $emisInterp "real" $subFmt
    incr row
}
set headerRow 1
set xaxisCol  4
set startRow  2
set numRows   [expr $row - 2]
set startCol  5
set numCols   2
set title     "Copper Interpolation"
set lineChartId [Excel AddLineChart $worksheetId $headerRow $xaxisCol $startRow $numRows $startCol $numCols $title]
set lineChartObjId [Excel PlaceChart $lineChartId $worksheetId]
Excel SetChartObjSize     $lineChartObjId 800 300
Excel SetChartObjPosition $lineChartObjId 400 220

Excel SetColumnsWidth $worksheetId 1 6

puts "Saving as Excel file: $xlsFile"
Excel SaveAs $workbookId $xlsFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
