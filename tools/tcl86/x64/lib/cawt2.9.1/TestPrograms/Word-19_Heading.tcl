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

# Open the document.
set docId [Word OpenDocument $appId $inFile]

# Switch off spell and grammatic checking.
Word ToggleSpellCheck $appId false

# Print all available cross reference types.
foreach refTypeName [Word GetEnumNames "WdReferenceType"] {
    puts "\n$refTypeName:"
    foreach ref [Word GetCrossReferenceItems $docId $refTypeName] {
        puts "  $ref"
    }
}

# Print heading texts. 
# Use four different ways to specify the heading levels.
puts "\nHeading ranges of level 1:"
set rangeIdList [Word GetHeadingRanges $docId $::Word::wdOutlineLevel1]
foreach { rangeId level } $rangeIdList {
    puts "Level $level: [Word GetRangeText $rangeId]"
    Cawt Destroy $rangeId
}
Cawt CheckNumber 6 [expr [llength $rangeIdList] / 2] "Number of level 1 headings"

puts "\nHeading ranges of level 2:"
set rangeIdList [Word GetHeadingRanges $docId "wdOutlineLevel2"]
foreach { rangeId level } $rangeIdList {
    puts "Level $level: [Word GetRangeText $rangeId]"
    Cawt Destroy $rangeId
}
Cawt CheckNumber 15 [expr [llength $rangeIdList] / 2] "Number of level 2 headings"

puts "\nHeading ranges of levels 1 and 2:"
set rangeIdList [Word GetHeadingRanges $docId [list 1 2]]
foreach { rangeId level } $rangeIdList {
    puts "Level $level: [Word GetRangeText $rangeId]"
    Cawt Destroy $rangeId
}
Cawt CheckNumber 21 [expr [llength $rangeIdList] / 2] "Number of level 1 and 2 headings"

puts "\nHeading ranges of all levels:"
set rangeIdList [Word GetHeadingRanges $docId "all"]
foreach { rangeId level } $rangeIdList {
    puts "Level $level: [Word GetRangeText $rangeId]"
    Cawt Destroy $rangeId
}
Cawt CheckNumber 21 [expr [llength $rangeIdList] / 2] "Number of all level headings"

puts ""

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
