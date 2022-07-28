# Test CawtExcel procedures for embedding an Excel workbook into a Tk frame.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require Tk
package require cawt

set twapiVersion [Cawt GetPkgVersion "twapi"]

# Open new Excel instance and show the application window.
set appId [Excel OpenNew]
set appVersion [Excel GetVersion $appId true]

set inFile [file join [pwd] "testIn" "SampleTable.xls"]

proc Quit { appId } {
    # Excel application may have been closed. 
    # Check, if appId refers to a valid COM object.
    if { [Cawt IsAppIdValid $appId] } {
        Excel Quit $appId
        Cawt Destroy
    }
    exit 0
}

# Create the Tk user interface. One frame is a container frame
# for embedding the Excel workbook.
wm title . "Excel-36_Embed"
wm geometry . "800x600"

set statFr  [frame .statFr]
set infoFr  [frame .infoFr]
set excelFr [frame .excelFr -container true -borderwidth 0]
grid $statFr  -row 0 -column 0 -sticky news -columnspan 2
grid $infoFr  -row 1 -column 0 -sticky news
grid $excelFr -row 1 -column 1 -sticky news
grid rowconfigure    . 1 -weight 1
grid columnconfigure . 1 -weight 1

label $statFr.version -text "Embedding $appVersion using Tcl [info patchlevel] and Twapi $twapiVersion"
pack $statFr.version -side top

label $infoFr.numSheets
label $infoFr.numRows
label $infoFr.numCols
pack $infoFr.numSheets $infoFr.numRows $infoFr.numCols -side top -anchor w

# Open the Excel workbook and embed into Tk frame.
set workbookId [Excel OpenWorkbook $appId $inFile -embed $excelFr -readonly true]
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]

set numSheets [Excel GetNumWorksheets  $workbookId]
set numRows   [Excel GetNumUsedRows    $worksheetId]
set numCols   [Excel GetNumUsedColumns $worksheetId]

$infoFr.numSheets configure -text "Number of worksheets: $numSheets"
$infoFr.numRows   configure -text "Number of used rows : $numRows"
$infoFr.numCols   configure -text "Number of used cols : $numCols"

Cawt CheckNumber  1 $numSheets "Number of worksheets"
Cawt CheckNumber 12 $numRows   "Number of used rows"
Cawt CheckNumber  4 $numCols   "Number of used columns"

Cawt PrintNumComObjects

bind . <Escape> "Quit $appId"
wm protocol . WM_DELETE_WINDOW "Quit $appId"

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
