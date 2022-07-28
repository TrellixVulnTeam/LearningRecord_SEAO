# Test CawtOffice procedures to run a macro contained in a Word file.
#
# This test uses a macro to fill a Word table similar to test Word-12_LargeTable.tcl.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

set numData         5
set numDataSets    20
set templateTable "TemplateTableHeader"

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-21_RunMacro.docx"]
file delete -force $wordFile

set inFile [file join [pwd] "testIn" "SampleMacro.docm"]

set docId [Word OpenDocument $appId $inFile]

# Switch off spell and grammatical checking.
Word ToggleSpellCheck $appId false

# Count the number of tables.
set numTables [Word GetNumTables $docId]
Cawt CheckNumber 1 $numTables "Number of tables in input file."

if { [Word GetVersion $appId] < 14.0 } {
    puts "Error: Table names available only in Word 2010 or newer. Running [Word GetVersion $appId true]."
} else {
    Word ScreenUpdate $appId false

    # Scan all tables and search for the template table to use.
    set templateTableList [Word GetTableIdByName $docId $templateTable]
    if { [llength $templateTableList] != 0 } {
        set templateTableId [lindex $templateTableList 0]
    } else {
        error "Table $templateTable not found."
    }

    puts "Running macro MacroSub ..."
    set startTime [clock clicks -milliseconds]

    Office RunMacro $appId "MacroSub" $templateTableId $numData $numDataSets
    set insertTime [clock clicks -milliseconds]

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

    set formatTime [clock clicks -milliseconds]

    set insertTimeSec [format "%.1f" [expr ($insertTime - $startTime)  / 1000.0]]
    set formatTimeSec [format "%.1f" [expr ($formatTime - $insertTime) / 1000.0]]
    set totalTimeSec  [format "%.1f" [expr ($formatTime - $startTime)  / 1000.0]]
    puts "Template table $templateTable:"
    puts "Time to insert [expr $numDataSets * $numData] rows: $insertTimeSec seconds"
    puts "Time to format [expr $numDataSets * $numData] rows: $formatTimeSec seconds"
    puts "Total time: $totalTimeSec seconds\n"

    Word ScreenUpdate $appId true

    Cawt CheckNumber 1 [Word GetNumTables $docId] "Number of tables in output file."
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
Cawt Destroy

