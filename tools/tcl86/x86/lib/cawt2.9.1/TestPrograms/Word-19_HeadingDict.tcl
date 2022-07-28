# Test CawtWord procedures related to Word headings.
#
# Note, that this test needs the output file of test Word-05_Report.tcl.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

set rootName [file join [pwd] "testOut" "Word-05_Report"]
set inFile [format "%s%s" $rootName [Word GetExtString $appId]]

set numTotalHeadings  21
set numLevel1Headings  6
set table1Index 1
set table2Name  "Table-3.2"

# Open the Word document.
set docId  [Word OpenDocument $appId $inFile]

# Get the range of table with index 1. This is the summary table.
set tableId1         [Word GetTableIdByIndex $docId $table1Index]
set tableRangeId1    [$tableId1 Range]
set tableStartRange1 [Word GetRangeStartIndex $tableRangeId1]
set tableEndRange1   [Word GetRangeEndIndex   $tableRangeId1]
set tablePageNum1    [$tableRangeId1 Information $Word::wdActiveEndPageNumber]
puts "Table #$table1Index          is on page $tablePageNum1 using range ($tableStartRange1, $tableEndRange1)"

# Get the range of table with name "Table-3.2".
set tableId2         [Word GetTableIdByName $docId $table2Name]
set tableRangeId2    [$tableId2 Range]
set tableStartRange2 [Word GetRangeStartIndex $tableRangeId2]
set tableEndRange2   [Word GetRangeEndIndex   $tableRangeId2]
set tablePageNum2    [$tableRangeId2 Information $Word::wdActiveEndPageNumber]
puts "Table \"$table2Name\" is on page $tablePageNum2 using range ($tableStartRange2, $tableEndRange2)"

# Find the headings of all 9 levels.
puts "Using GetHeadingsAsDict as coroutine ..."
coroutine GetHeadings Word::GetHeadingsAsDict $docId
while { 1 } {
    set headingDict [GetHeadings]
    if { [string is integer -strict $headingDict] } {
        puts -nonewline "\b\b\b$headingDict" ; flush stdout
    } else {
        break
    }
}
puts ""
Cawt CheckNumber $numTotalHeadings [dict size $headingDict] "Headings of level 1-9"

# Copy dictionary information start and level into Tcl arrays.
dict for { id info } $headingDict {
    dict with info {
        set headingText($start)  $text
        set headingLevel($start) $level
    }
}

# Find the heading, where table #1 is located in.
set rangeList [lsort -decreasing -integer [array names headingText]]
foreach rangeVal $rangeList {
    if { $rangeVal < $tableStartRange1 } {
        puts "Table #$table1Index is in heading \"$headingText($rangeVal)\" (Level $headingLevel($rangeVal))"
        Cawt CheckString "Summary of performed tests" $headingText($rangeVal) "Heading text"
        Cawt CheckNumber $table1Index $headingLevel($rangeVal) "Heading level"
        break
    }
}

# Find the heading, where table "Table-3.2" is located in.
set rangeList [lsort -decreasing -integer [array names headingText]]
foreach rangeVal $rangeList {
    if { $rangeVal < $tableStartRange2 } {
        puts "Table \"$table2Name\" is in heading \"$headingText($rangeVal)\" (Level $headingLevel($rangeVal))"
        Cawt CheckString "Test case 2" $headingText($rangeVal) "Heading text"
        Cawt CheckNumber 2 $headingLevel($rangeVal) "Heading level"
        break
    }
}

# Find the headings of level 1 only.
set headingDict [Word GetHeadingsAsDict $docId 1]
Cawt CheckNumber $numLevel1Headings [dict size $headingDict] "Headings of level 1"
Word PrintHeadingDict $headingDict

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
