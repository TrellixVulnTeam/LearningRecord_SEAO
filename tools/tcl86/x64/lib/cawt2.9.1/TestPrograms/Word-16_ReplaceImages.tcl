# Test CawtWord procedures for replacing images stored as InlinesShapes and Shapes.
#
# Note, that replacement of Shapes does not work correctly yet.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set squareImg [file join [pwd] "testIn/Square.gif"]

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-16_ReplaceImages"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

set inFile [file join [pwd] "testIn" "ReplaceImageTemplate.docx"]

# Open the replacement template document.
set docId [Word OpenDocument $appId $inFile]
Word SetViewParameters $docId -pagefit wdPageFitFullPage

set numPages      [Word GetNumPages  $docId]
set numImgs       [Word GetNumImages $docId false]
set numInlineImgs [Word GetNumImages $docId true]

Cawt CheckNumber 2 $numPages      "Number of pages"
Cawt CheckNumber 4 $numImgs       "Total number of images"
Cawt CheckNumber 2 $numInlineImgs "Number of inline images"

set i 0
foreach imgId [Word GetImageList $docId] {
    set title [Word GetImageName $imgId]
    puts "  Image $i: $title"

    set keepSize false
    if { [string match "*KeepSize*" $title] } {
        set keepSize true
    }
    set newImgId [Word ReplaceImage $imgId $squareImg -keepsize $keepSize]

    incr i
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
