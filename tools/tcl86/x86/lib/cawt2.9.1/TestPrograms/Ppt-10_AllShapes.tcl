# Test CawtPpt procedure for creating all available shapes.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set appId [Ppt Open]
set presId [Ppt AddPres $appId]

# Delete PowerPoint file from previous test run.
file mkdir testOut
set pptFile [file join [pwd] "testOut" "Ppt-10_AllShapes"]
append pptFile [Ppt GetExtString $appId]
file delete -force $pptFile

set slideId [Ppt AddSlide $presId]
Cawt CheckNumber 1 [Ppt GetCurrentSlideIndex $presId] "Current slide index"

set shapeTypeList [Office GetEnumNames MsoAutoShapeType]
# set shapeTypeList [list msoShapeRectangle msoShapeOval]
set numShapes [llength $shapeTypeList]

# Determine needed page size to fit all shapes.
set numCols 20
set numRows [expr ($numShapes / $numCols) + 1]
set pageWidth  [expr $numCols * 2 + 1]
set pageHeight [expr $numRows * 2 + 1]
Ppt SetPresPageSetup $presId -width ${pageWidth}c -height ${pageHeight}c

# Add all shapes available from enumeration Office::MsoAutoShapeType.
set left 1
set top  1
set slideNum 2
Cawt PushComObjects
foreach shapeType $shapeTypeList {
    set catchVal [ catch { Ppt AddShape $slideId $shapeType \
                           ${left}c ${top}c 1c 1c -textsize 12 } shapeId]
    if { $catchVal } {
        puts "Warning: A shape of type $shapeType could not be created."
    } else {
        set numSites [Ppt GetNumSites $shapeId]
        incr siteCount($numSites)
        Ppt ConfigureShape $shapeId -text "$numSites"
        incr left 2
        if { $left > [expr $numCols * 2] } {
            incr top 2
            set left 1
        }
        # Add the shape on a separate slide in large with additional information.
        set newSlideId [Ppt AddSlide $presId]
        set newShapeId [Ppt AddShape $newSlideId $shapeType 5c 5c 10c 10c -textsize 20]
        Ppt ConfigureShape $newShapeId -text "$numSites"
        set textboxId [Ppt AddTextbox $newSlideId 1c 1c 15c 3c]
        Ppt AddTextboxText $textboxId $shapeType

        # Create a hyperlink from small shape to slide with large shape.
        Ppt SetHyperlinkToSlide $shapeId $newSlideId $shapeType
        # Create a hyperlink from large shape to first slide with small shapes.
        Ppt SetHyperlinkToSlide $newShapeId 1 "Back to overview"
        Cawt CheckNumber $slideNum [Ppt GetCurrentSlideIndex $presId] "Current slide index"
        incr slideNum
    }
}
Cawt PopComObjects
Ppt ShowSlide $presId 1
Cawt CheckNumber 1 [Ppt GetCurrentSlideIndex $presId] "Current slide index"

foreach c [lsort -integer [array names siteCount]] {
    puts [format "Number of shapes with %2d connection sites: %3d" $c $siteCount($c)]
}

puts "Saving as PowerPoint file: $pptFile"
Ppt SaveAs $presId $pptFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
