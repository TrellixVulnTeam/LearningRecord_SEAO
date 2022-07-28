# Test CawtWord procedures for handling text.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt
package require Tk

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

# Delete Word file from previous test run.
file mkdir testOut
set rootName [file join [pwd] "testOut" "Word-03_Text"]
set pdfFile  [format "%s%s" $rootName ".pdf"]
set wordFile [format "%s%s" $rootName [Word GetExtString $appId]]
file delete -force $pdfFile
file delete -force $wordFile

set msg1 "This is a italic line of text in italic.\n"
set numOops 20
for { set i 0 } { $i < $numOops } { incr i } {
    append msg3 "This is a large oops paragraph in bold. "
}

# Create a new document.
set docId [Word AddDocument $appId]

# Emtpy document has 1 paragraph character.
Cawt CheckNumber 1 [Word GetNumCharacters $docId] "Number of characters in empty document"

# Insert a short piece of text as one paragraph.
set range1 [Word AppendText $docId $msg1]
Word SetRangeFontItalic $range1 true
Word SetRangeFontSize $range1 12
Word SetRangeFontName $range1 "Courier"
Word SetRangeHighlightColorByEnum $range1 wdYellow

# Check font settings of this range.
lassign [Word GetRangeFont $range1 -italic -name -size -sizei -sizec] italic name size sizei sizec
Cawt CheckBoolean true                          $italic "Font italic flag"
Cawt CheckString  "Courier"                     $name   "Font name"
Cawt CheckNumber  12                            $size   "Font size in points"
Cawt CheckNumber  [Cawt PointsToInches 12]      $sizei  "Font size in inches"
Cawt CheckNumber  [Cawt PointsToCentiMeters 12] $sizec  "Font size in centimeters"

# 1 paragraph character + string
set expectedChars [expr 1 + [string length $msg1]]
Cawt CheckNumber $expectedChars [Word GetNumCharacters $docId] "Number of characters after adding text"

# Insert other short pieces of text with different underlinings.
set range2 [Word AppendText $docId "This is text with default underlining color.\n"]
Word SetRangeFontUnderline $range2

set range3 [Word AppendText $docId "This is text with orange underlining color.\n"]
Word SetRangeFontUnderline $range3 true wdColorLightOrange

# Check font settings of this range.
lassign [Word GetRangeFont $range3 -underline -underlinecolor] underline underlinecolor
Cawt CheckBoolean true                        $underline      "Font underline flag"
Cawt CheckNumber  $::Word::wdColorLightOrange $underlinecolor "Font underline color"

# Insert text with different text colors.
set range4 [Word AppendText $docId "This is text with blue text color.\n"]
Word SetRangeFontColor $range4 $::Word::wdBlue

# Check font settings of this range.
lassign [Word GetRangeFont $range4 -color] color
Cawt CheckString "wdBlue" [Word GetEnumName "WdColorIndex" $color] "Font text color"

set range5 [Word AppendText $docId "This is text with green text color.\n"]
Word SetRangeFontColor $range5 wdGreen

# Check font settings of this range.
lassign [Word GetRangeFont $range5 -color] color
#Cawt CheckNumber $::Word::wdGreen $color "Font text color"
Cawt CheckString "wdGreen" [Word GetEnumName "WdColorIndex" $color] "Font text color"

# Insert a longer piece of text as one paragraph.
set range6 [Word AppendText $docId $msg3 true]
Word SetRangeFontBold $range6 true
Word SetRangeFontBackgroundColor $range6 "orange"

# Check font settings of this range.
lassign [Word GetRangeFont $range6 -bold -background] bold background
Cawt CheckBoolean true                     $bold       "Font bold flag"
Cawt CheckNumber  [Cawt GetColor "orange"] $background "Font background color"

# Test inserting different types of list.
set rangeId [Word AppendText $docId "Different types of lists" true]

set listRange [Word CreateRangeAfter $rangeId]
set listRange [Word InsertList $listRange [list "Unordered list entry 1" "Unordered list entry 2" "Unordered list entry 3"]]

set listRange [Word CreateRangeAfter $listRange]
set listRange [Word InsertList $listRange \
                   [list "Ordered list entry 1" "Ordered list entry 2" "Ordered list entry 3"] \
                   wdNumberGallery wdListListNumOnly]

# Insert lines of text. When we get to 7 inches from top of the
# document, insert a hard page break.
set pos [Cawt InchesToPoints 7]
while { true } {
    Word AppendText $docId "More lines of text." true
    set endRange [Word GetEndRange $docId]
    if { $pos < [Word GetRangeInformation $endRange wdVerticalPositionRelativeToPage] } {
        break
    }
}

Word AddPageBreak $endRange

set rangeId [Word AppendText $docId "This is page 2." true]
Word AddParagraph $rangeId 10
Word AppendParagraph $docId 30
set rangeId [Word AppendText $docId "There must be two paragraphs before this line." true]

# Select whole document and insert text into a text widget in 2 ways:
# 1. Get the text with the Text method and insert into the text widget.
# 2. Copy the text to the clipboard and insert into the text widget.

puts "Retrieve document into a text widget in 2 ways."
Word SetRangeStartIndex $rangeId "begin"
Word SetRangeEndIndex   $rangeId "end"

set docText [$rangeId Text]
Word SelectRange $rangeId
$rangeId Copy

pack [text .t1 -wrap word]
pack [text .t2 -wrap word]
.t1 insert end $docText
.t2 insert end [clipboard get]

# Select a small range.
Word SetRangeStartIndex $rangeId "begin"
Word SetRangeEndIndex   $rangeId 5
Word SelectRange $rangeId
Word PrintRange $rangeId "Selected first 5 characters: "

set screenPosDict [Word GetRangeScreenPos $rangeId]
puts [format "Top-Left pos of selection: %dx%d" \
    [dict get $screenPosDict "left"] \
    [dict get $screenPosDict "top"]]

puts [format "Width-height of selection: %dx%d" \
    [dict get $screenPosDict "width"] \
    [dict get $screenPosDict "height"]] 

# Count words in document.
set wordCountList [Word CountWords $docId \
                   -sortmode "length" \
                   -minlength 2 \
                   -maxlength 5 \
                   -shownumbers false]
puts "Count of words with 2 - 5 characters:"
foreach { word count } $wordCountList {
    puts [format "%-10s %5d" $word $count]
}
Cawt CheckNumber $numOops [dict get $wordCountList "oops"] "Number of oops in document"

# Save document as Word file.
puts "Saving as Word file: $wordFile"
Word SaveAs $docId $wordFile

puts "Saving as PDF file: $pdfFile"
# Use in a catch statement, as PDF export is available only in Word 2007 an up.
set catchVal [ catch { Word SaveAsPdf $docId $pdfFile } retVal]
if { $catchVal } {
    puts "Error: $retVal"
}

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
