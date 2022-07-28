# Test CawtPpt procedures for simulating button events.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

set pptId [Ppt Open]

# Delete PowerPoint files from previous test run.
file mkdir testOut
set pptFile [file join [pwd] "testOut" "Ppt-15_ButtonEvent"]
append pptFile [Ppt GetExtString $pptId]
file delete -force $pptFile

# Step 1: Create a slide with 3 buttons of type msoControlButton
#         to select a specific sound string.
#         Add the sound string to the AlternativeText attribute.
#         Additionally add a Quit button.

set presId  [Ppt AddPres $pptId]
set slideId [Ppt AddSlide $presId]

set topList   { 2c 5c 8c }
set colorList { "red" "blue" "yellow" }
set sndList   { "Lady in red" "Blue velvet" "Yellow submarine" }

foreach top $topList color $colorList snd $sndList {
    set buttonId [Ppt AddShape $slideId msoControlButton 8c $top 7c 2c \
                  -text "Press me and listen" \
                  -fillcolor $color]
    $buttonId AlternativeText $snd
}
set buttonId [Ppt AddShape $slideId msoControlButton 8c 12c 7c 2c -text "Quit"]
$buttonId AlternativeText "Quit"

# Step 2: Find buttons of type msoControlButton with non-empty AlternativeText.
#         Add macro Clicked to these buttons. The macro creates a new shape with
#         a unique name "SelectedMessage" and stores the selected sound string
#         in the AlternativeText attribute.
#         After adding the macros, proc EventHandler is called, which 
#         periodically checks for the creation of the new shape, extracts the
#         sound string, plays the sound and then deletes the shape.

# Set Left and Top to negative values to make shape invisible.
set macroString "Sub Clicked(oSh as Shape)\n
                 Set slideId = ActivePresentation.Slides(1)\n
                 With slideId.Shapes.AddShape(Type:=msoShapeRectangle, _
                         Left:=50, Top:=50, Width:=10, Height:=10 )\n
                     .Name = \"SelectedMessage\"\n
                     .AlternativeText = oSh.AlternativeText\n
                 End With\n
                 End Sub\n"
set catchVal [catch { Office AddMacro $pptId -code $macroString } errMsg]
if { $catchVal } {
    puts "Error: $errMsg"
    exit 1
}

set numShapes [Ppt GetNumShapes $slideId]
for { set s 1 } { $s <= $numShapes } { incr s } {
    set shapeId [Ppt GetShapeId $slideId $s]
    set shapeType [Ppt GetShapeType $shapeId]
    set snd [$shapeId AlternativeText]
    if { $shapeType == $::Office::msoControlButton && $snd ne "" } {
        set actionId [$shapeId -with { ActionSettings } Item $Ppt::ppMouseClick]
        $actionId Action $Ppt::ppActionRunMacro
        $actionId Run Clicked
    }
}

set sapiId [Sapi Open]

# Save presentation.
puts "Saving as PowerPoint file: $pptFile"
Ppt SaveAs $presId $pptFile

Cawt PrintNumComObjects

# Show first slide and enter presentation mode.
Ppt ShowSlide $presId 1
Ppt UseSlideShow $presId 1

proc EventHandler { slideId pptId sapiId } {
    set numShapes [Ppt GetNumShapes $slideId]
    for { set s 1 } { $s <= $numShapes } { incr s } {
        set shapeId [Ppt GetShapeId $slideId $s]
        if { [$shapeId Name] eq "SelectedMessage" } {
            set speakString [$shapeId AlternativeText]
            if { $speakString eq "Quit" } {
                Ppt Quit $pptId false
                Cawt Destroy
                exit
            }
            $shapeId Delete
            Cawt Destroy $shapeId
            Sapi Speak $sapiId $speakString
        }
    }
    after 500 [list EventHandler $slideId $pptId $sapiId]
}

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $pptId false
    Cawt Destroy
    exit 0
} else {
    EventHandler $slideId $pptId $sapiId
    vwait forever
}
