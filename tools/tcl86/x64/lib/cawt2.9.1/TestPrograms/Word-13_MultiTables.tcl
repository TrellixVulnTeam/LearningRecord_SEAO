# Test CawtWord procedures to insert multiple Word tables across multiple pages.
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

if { [lsearch -nocase $argv "--novis"] >= 0 } {
    set useVisible false
}
if { [lsearch -nocase $argv "--noupdate"] >= 0 } {
    set useScreenUpdate false
}

set numData            5
set numDataSets       20
set templateTableName "TemplateTableHeader"

proc GetNextRange { docId rangeId collapseDir } {
    set newRange [Word CreateRangeAfter $rangeId]
    $newRange InsertParagraphBefore
    Word SetRangeFontSize $newRange 1
    Word CollapseRange $newRange $collapseDir
    Cawt Destroy $rangeId
    return $newRange
}

proc GetRangeAfterTable { docId tableId } {
    set endRange [expr { [$tableId -with { Range } End] + 1 }]
    set afterRange [$docId -with { Characters } Item $endRange]
    return [GetNextRange $docId $afterRange "begin"]
}

# Open new Word instance and show the application window.
set appId [Word OpenNew $useVisible]

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-13_MultiTables.docx"]
file delete -force $wordFile

set inFile [file join [pwd] "testIn" "TemplateTable.docx"]

set docId [Word OpenDocument $appId $inFile]

# Switch off spell and grammatical checking.
Word ToggleSpellCheck $appId false

# Retrieve the text of the header and the footer.
set headerText [Word GetHeaderText $docId]
Cawt CheckString "Header Section" $headerText "Header text."
set footerText [Word GetFooterText $docId]
Cawt CheckString "Footer Section" $footerText "Footer text."

# Count the number of tables.
set numTables [Word GetNumTables $docId]
Cawt CheckNumber 2 $numTables "Number of tables in input file."

if { [Word GetVersion $appId] < 14.0 } {
    puts "Error: Table names available only in Word 2010 or newer. Running [Word GetVersion $appId true]."
} else {
    lassign [Word GetPageSetup $docId -usableheight] usablePageHeight

    if { ! $useScreenUpdate } {
        Word ScreenUpdate $appId false
    }

    # Scan all tables and search for the template table to use.
    set templateTableList [Word GetTableIdByName $docId $templateTableName]
    if { [llength $templateTableList] != 0 } {
        set templateTableId [lindex $templateTableList 0]
    } else {
        error "Did not find template table $templateTableName"
    }

    # Get the range of the first row of the template table.
    # This row will be copied to the top of each new page.
    set templateRowRange [Word GetRowRange $templateTableId 1]

    # Get the range just after the template table.
    set rangeAfterTable [GetRangeAfterTable $docId $templateTableId]

    set startTime [clock clicks -milliseconds]
    set numNewPages 0

    puts -nonewline "Current data set: "
    for { set curDataSet 1 } { $curDataSet <= $numDataSets } { incr curDataSet } {
        puts -nonewline "$curDataSet " ; flush stdout

        if { $curDataSet > 1 } {
            # For the first inserted table the range is already determined 
            # as the range after the template table.
            set rangeAfterTable [GetRangeAfterTable $docId $newTableId]

            # Check, if the next table will fit onto the current page.
            # If not, then add a page break and copy the template table
            # to the start of the new page.
            set vertPos   [Word GetRangeInformation $rangeAfterTable wdVerticalPositionRelativeToPage]
            set spaceLeft [expr { $usablePageHeight - $vertPos }]

            if { $spaceLeft < $tableHeight } {
                incr numNewPages
                Word AddPageBreak $rangeAfterTable
                Word CopyRange $templateRowRange $rangeAfterTable
                Word CollapseRange $rangeAfterTable "end"

                set rangeAfterTable [GetNextRange $docId $rangeAfterTable "end"] 
            }
        }

        if { [info exists newTableId] } {
            Cawt Destroy $newTableId
        }
        set newTableId [Word AddTable $rangeAfterTable $numData 3]
        Word SetTableName $newTableId "DataSetTable-${curDataSet}"
        Word SetTableBorderLineStyle $newTableId

        # Write data rows into new table.
        for { set data 1 } { $data <= $numData } { incr data } {
            Word SetCellValue $newTableId $data 1 $curDataSet
            Word SetCellValue $newTableId $data 2 $data
            Word SetCellValue $newTableId $data 3 [format "Value_%02d_%02d" $curDataSet $data]
            incr row
        }

        # Get a range containing all rows except the first one and set cell properties.
        set rangeId [Word GetRowRange $newTableId 1 end]
        Word SetRangeFontName            $rangeId "Arial"
        Word SetRangeFontSize            $rangeId 10
        Word SetRangeFontBold            $rangeId false
        Word SetRangeFontItalic          $rangeId false
        Word SetRangeHorizontalAlignment $rangeId "left"
        Word SetRangeBackgroundColor     $rangeId "white"
        Cawt Destroy $rangeId

        if { $curDataSet == 1 } {
            # If we have created the first dataset table, determine the height of a row
            # and calculate the height of the complete table.
            # Not, that it is assumed, that the first dataset table fits completely onto
            # the page containing the template table.
            set rangeId1 [Word GetRowRange $newTableId 1]
            set rangeId2 [Word GetRowRange $newTableId 2]
            set vertPos1 [Word GetRangeInformation $rangeId1 wdVerticalPositionRelativeToPage]
            set vertPos2 [Word GetRangeInformation $rangeId2 wdVerticalPositionRelativeToPage]
            set rowHeight   [expr { $vertPos2 - $vertPos1 }]
            set tableHeight [expr { $rowHeight * $numData }]
            Cawt Destroy $rangeId1
            Cawt Destroy $rangeId2
        }
        Cawt Destroy $rangeAfterTable
    }
    puts "\n"
    set totalTime [clock clicks -milliseconds]

    set totalTimeSec [format "%.1f" [expr ($totalTime - $startTime)  / 1000.0]]
    puts "Template table $templateTableName:"
    puts "Total time: $totalTimeSec seconds (useVisible: $useVisible useScreenUpdate: $useScreenUpdate)\n"

    if { ! $useScreenUpdate } {
        Word ScreenUpdate $appId true
    }

    Cawt CheckNumber [expr 2 + $numDataSets + $numNewPages] [Word GetNumTables $docId] \
                     "Number of tables in output file."
    set templateTableList [Word GetTableIdByName $docId $templateTableName]
    Cawt CheckNumber [expr $numNewPages + 1] [llength $templateTableList] "Number of tables with name $templateTableName."
    set templateTableList [Word GetTableIdByName $docId "NotExistingName"]
    Cawt CheckNumber 0 [llength $templateTableList] "Number of tables with name NotExistingName."
    set templateTableList [Word GetTableIdByName $docId "DataSetTable-1"]
    Cawt CheckNumber 1 [llength $templateTableList] "Number of tables with name DataSetTable-1."
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
