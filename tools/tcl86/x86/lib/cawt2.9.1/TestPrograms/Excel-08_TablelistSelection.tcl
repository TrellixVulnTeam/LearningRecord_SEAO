# Test CawtExcel procedures to exchange data between Excel and Tablelist.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

# We need to explicitly load the tablelist package.
package require Tk

set retVal [catch {package require tablelist} version]
if { $retVal != 0 } {
    puts "Test not performed. Tablelist is not available."
    exit 0
}

package require cawt

set xlsFile [file join [pwd] "testOut" "Excel-08_Tablelist.xlsx"]

# Open new instance of Excel and open workbook.
set appId [Excel OpenNew]
set workbookId [Excel OpenWorkbook $appId $xlsFile]
set worksheetId [Excel GetWorksheetIdByName $workbookId "Full_WithHeader"]

proc GetSelection { appId table1Id table2Id } {
    set worksheetId [$appId ActiveSheet]
    set selection   [$appId Selection]

    $table1Id delete 0 end
    Excel WorksheetToTablelist $worksheetId $table1Id -selection true -rownumber true
    $table2Id delete 0 end
    Excel WorksheetToTablelist $worksheetId $table2Id -selection true -header true
}

proc Exit { appId } {
    Excel Quit $appId
    Cawt Destroy
    exit 0
}

ttk::button     .b -text "Get selection" -command "GetSelection $appId .fr1.tl .fr2.tl"
ttk::button     .e -text "Quit" -command "Exit $appId"
ttk::labelframe .fr1 -text "Table without header"
ttk::labelframe .fr2 -text "Table with header"
grid .b   -row 0 -column 0 -sticky news
grid .e   -row 0 -column 1 -sticky news
grid .fr1 -row 1 -column 0 -sticky news
grid .fr2 -row 1 -column 1 -sticky news
grid rowconfigure . 1 -weight 1
grid columnconfigure . 0 -weight 1
grid columnconfigure . 1 -weight 1

tablelist::tablelist .fr1.tl
pack .fr1.tl -expand true -fill both
tablelist::tablelist .fr2.tl
pack .fr2.tl -expand true -fill both

if { [lsearch -nocase $argv "--interactive"] < 0 } {
    .b configure -state disabled
    .e configure -state disabled
    Excel SelectRangeByString $worksheetId "B3:C5" true
    GetSelection $appId .fr1.tl .fr2.tl
    set matrixList { { "Cell_2_2" "Cell_2_3" } { "Cell_3_2" "Cell_3_3" } { "Cell_4_2" "Cell_4_3" } }
    Cawt CheckMatrix $matrixList [Excel GetTablelistValues .fr1.tl] "GetTablelistValues"

    Cawt PrintNumComObjects

    if { [lindex $argv 0] eq "auto" } {
        Exit $appId
    }
    Cawt Destroy
}
