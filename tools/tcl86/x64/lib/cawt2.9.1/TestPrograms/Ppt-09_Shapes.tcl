# Test CawtPpt procedures related to creating, manipulating and
# connecting shapes.
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
set pptFile [file join [pwd] "testOut" "Ppt-09_Shapes"]
append pptFile [Ppt GetExtString $appId]
file delete -force $pptFile

set slideId [Ppt AddSlide $presId]

# Add 6 shapes.
# Initialize the first rectangle with text and alignment.
# Initialize the second with text and configure later.
# Use default values for the third rectangle and configure later.
# Use default values for the fourth rectangle and configure later.
# Use default values for the fifth rectangle and do not configure.
# Use default values for the sixth shape (oval) and configure later.
set rectId1 [Ppt AddShape $slideId $::Office::msoShapeRectangle  1c 3c 4c 3c \
             -text "R1: Bottom" -valign msoAnchorBottom]
set rectId2 [Ppt AddShape $slideId msoShapeRectangle  8c 2c 4c 5c -text "R2: Default"]
set rectId3 [Ppt AddShape $slideId msoShapeRectangle  5c 9c 4c 3c]
set rectId4 [Ppt AddShape $slideId msoShapeRectangle 15c 3c 4c 3c]
set rectId5 [Ppt AddShape $slideId msoShapeRectangle 11c 9c 4c 3c]
set ovalId6 [Ppt AddShape $slideId msoShapeOval      17c 9c 8c 4c]

Cawt CheckNumber $::Office::msoAutoShape [Ppt GetShapeType $rectId1 false] "GetShapeType int"
Cawt CheckString "msoAutoShape"          [Ppt GetShapeType $ovalId6 true] "GetShapeType string"
Cawt CheckNumber 6 [Ppt GetNumShapes $slideId] "GetNumShapes"

# Configure fill colors in different color representations.
Ppt ConfigureShape $rectId1 -fillcolor { 255 0 0 }
Ppt ConfigureShape $rectId2 -fillcolor "green1"
Ppt ConfigureShape $rectId3 -fillcolor "#0000FF"
Ppt ConfigureShape $rectId4 -fillcolor 0x00FFFF

# Add text and set text color for third rectangle.
Ppt ConfigureShape $rectId3 -text "R3: Top" -valign msoAnchorTop -textcolor [list 0 0 0]

# Add text sixth rectangle.
Ppt ConfigureShape $ovalId6 -text "R6: SiteConnected"

# Connect the rectangles using different configuration options.
Ppt ConnectShapes $slideId $rectId1 $rectId2 -beginarrow msoArrowheadDiamond -fillcolor { 255 0 255 }
Ppt ConnectShapes $slideId $rectId2 $rectId3 -fillcolor { 0 0 0 } -type msoConnectorElbow
Ppt ConnectShapes $slideId $rectId2 $rectId4
Ppt ConnectShapes $slideId $rectId2 $rectId5 -type msoConnectorCurve
Ppt ConnectShapes $slideId $rectId2 $ovalId6 -beginsite 1 -endsite 7 -type msoConnectorElbow

Cawt CheckNumber 4 [Ppt GetNumSites $rectId1] "GetNumSites"
Cawt CheckNumber 8 [Ppt GetNumSites $ovalId6] "GetNumSites"

puts "Saving as PowerPoint file: $pptFile"
Ppt SaveAs $presId $pptFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
