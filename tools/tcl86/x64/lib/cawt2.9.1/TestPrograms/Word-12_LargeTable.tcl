# Test CawtWord procedures to insert a large Word table.
#
# If inserting large tables, the following strategies are useful:
# - Do not use a visible window.
# - Do not set cell properties for each row, but use a predefined row as template.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

# Use the next two flags to check speed of row insert and format operations.
set useVisible      true
set useScreenUpdate true
set useInsertImage  false
set useOptimize     false

if { [lsearch -nocase $argv "--novis"] >= 0 } {
    set useVisible false
}
if { [lsearch -nocase $argv "--noupdate"] >= 0 } {
    set useScreenUpdate false
}
if { [lsearch -nocase $argv "--image"] >= 0 } {
    set useInsertImage true
}
if { [lsearch -nocase $argv "--optimize"] >= 0 } {
    set useOptimize true
}

set numData         5
set numDataSets    20
set templateTables [list "TemplateTablePredefined" "TemplateTableHeader"]

# Open new Word instance and show the application window.
set appId [Word OpenNew $useVisible]

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-12_LargeTable.docx"]
file delete -force $wordFile

set inFile [file join [pwd] "testIn" "TemplateTable.docx"]

set imgFile [file join [pwd] "testIn/Landscape.gif"]

set docId [Word OpenDocument $appId $inFile]

# Switch off spell and grammatical checking.
Word ToggleSpellCheck $appId false

# Count the number of tables.
set numTables [Word GetNumTables $docId]
Cawt CheckNumber 2 $numTables "Number of tables in input file."

if { [Word GetVersion $appId] < 14.0 } {
    puts "Error: Table names available only in Word 2010 or newer. Running [Word GetVersion $appId true]."
} else {
    if { ! $useScreenUpdate } {
        Word ScreenUpdate $appId false
    }

    puts ""
    foreach templateTableName $templateTables {
        catch { unset templateTableId }

        # Scan all tables and search for the template table to use.
        set templateTableList [Word GetTableIdByName $docId $templateTableName]
        if { [llength $templateTableList] != 0 } {
            set templateTableId [lindex $templateTableList 0]
        } else {
            continue
        }

        if { $useOptimize } {
            $templateTableId AllowAutoFit False
            set tableRangeId [Word GetRowRange $templateTableId 1 end]
            Word SelectRange $tableRangeId
            set selectionId [Word GetSelectionRange $docId]
            set cellsId [$selectionId -with { Cells } Item 1]
            $cellsId WordWrap False
            $cellsId FitText  False
        }

        set startTime [clock clicks -milliseconds]

        set row 2
        puts -nonewline "Current data set: "
        for { set curDataSet 1 } { $curDataSet <= $numDataSets } { incr curDataSet } {
            puts -nonewline "$curDataSet " ; flush stdout
            Word AddRow $templateTableId end $numData

            # Write data rows to the end of the table.
            for { set data 1 } { $data <= $numData } { incr data } {
                Word SetCellValue $templateTableId $row 1 $curDataSet
                Word SetCellValue $templateTableId $row 2 $data
                if { $useInsertImage } {
                    Word InsertImage [Word GetCellRange $templateTableId $row 3] $imgFile
                } else {
                    Word SetCellValue $templateTableId $row 3 [format "Value_%02d_%02d" $curDataSet $data]
                }
                incr row
            }
        }
        puts ""
        set insertTime [clock clicks -milliseconds]

        if { $templateTableName eq "TemplateTableHeader" } {
            # Set the heading format flag for the first row.
            Word SetHeadingFormat $templateTableId true 1

            # Get a range containing all rows except the first one and set cell properties.
            set rangeId [Word GetRowRange $templateTableId 2 end]
            Word SetRangeFontName            $rangeId "Arial"
            Word SetRangeFontSize            $rangeId 10
            Word SetRangeFontBold            $rangeId false
            Word SetRangeFontItalic          $rangeId false
            Word SetRangeHorizontalAlignment $rangeId "left"
            Word SetRangeBackgroundColor     $rangeId "white"
        } else {
            Word DeleteRow $templateTableId end
        }

        set formatTime [clock clicks -milliseconds]

        set insertTimeSec [format "%.1f" [expr ($insertTime - $startTime)  / 1000.0]]
        set formatTimeSec [format "%.1f" [expr ($formatTime - $insertTime) / 1000.0]]
        set totalTimeSec  [format "%.1f" [expr ($formatTime - $startTime)  / 1000.0]]
        puts "Template table $templateTableName:"
        puts "Time to insert [expr $numDataSets * $numData] rows: $insertTimeSec seconds"
        puts "Time to format [expr $numDataSets * $numData] rows: $formatTimeSec seconds"
        puts "Total time: $totalTimeSec seconds (useVisible: $useVisible useScreenUpdate: $useScreenUpdate)\n"
    }

    if { ! $useScreenUpdate } {
        Word ScreenUpdate $appId true
    }

    Cawt CheckNumber 2 [Word GetNumTables $docId] "Number of tables in output file."
}

# Save document as Word file.
puts "Saving as Word file: $wordFile"
Word SaveAs $docId $wordFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
if { ! [Word IsVisible $appId] } {
    Word Quit $appId
}
Cawt Destroy

