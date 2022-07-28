# Test CawtPpt procedures related to media content, i.e. images and videos.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set appId [Ppt Open]

# Delete PowerPoint files from previous test run.
file mkdir testOut
set pptFile [file join [pwd] "testOut" "Ppt-13_Media"]
append pptFile [Ppt GetExtString $appId]
file delete -force $pptFile

# Add a presentation.
set presId [Ppt AddPres $appId]
Ppt SetViewType $presId ppViewSlideSorter

set imgName [file join [pwd] "testIn" "wish.gif"]
set vidName [file join [pwd] "testIn" "CawtVideo.mp4"]
# MPG does not work with newer PowerPoint versions >= 2016.
# See documentation of InsertVideo.
# set vidName [file join [pwd] "testIn" "CawtVideo.mpg"]

set numImgs 0
set numVids 0

proc AddTextbox { slideId msg } {
    set textboxId [Ppt AddTextbox $slideId 1c 1c 30c 3c]
    Ppt AddTextboxText $textboxId $msg
    Cawt Destroy $textboxId
}

# Add some slides and insert the Wish image with different configuration options.
set slideId [Ppt AddSlide $presId]
Cawt CheckNumber 0 [Ppt GetNumSlideImages $slideId] "GetNumSlideImages"
set imgId [Ppt InsertImage $slideId $imgName]
Cawt CheckNumber 1 [Ppt GetNumSlideImages $slideId] "GetNumSlideImages"
Ppt SetShapeName $imgId "MyImageName"
AddTextbox $slideId "InsertImage [file tail $imgName]"
Cawt CheckString "msoPicture" [Ppt GetShapeType $imgId true] "GetShapeType image"
incr numImgs

set slideId [Ppt AddSlide $presId]
set imgId [Ppt InsertImage $slideId $imgName -left 1c -top 2c]
AddTextbox $slideId "InsertImage [file tail $imgName] -left 1c -top 2c"
incr numImgs

set slideId [Ppt AddSlide $presId]
set imgId [Ppt InsertImage $slideId $imgName -left 1c -top 2c -width 100 -height 2i -link true]
AddTextbox $slideId "InsertImage [file tail $imgName] -left 1c -top 2c -width 100 -height 2i -link true"
incr numImgs

if { [Ppt GetVersion $appId] < 14.0 } {
    puts "Error: Videos available only in PowerPoint 2010 or newer. Running [Ppt GetVersion $appId true]."
} else {
    # Add some slides and insert the CAWT video with different configuration options.
    set slideId [Ppt AddSlide $presId]
    Cawt CheckNumber 0 [Ppt GetNumSlideVideos $slideId] "GetNumSlideVideos"
    set vidId [Ppt InsertVideo $slideId $vidName]
    Cawt CheckNumber 1 [Ppt GetNumSlideVideos $slideId] "GetNumSlideVideos"
    Ppt SetShapeName $vidId "MyVideoName"
    Ppt SetMediaPlaySettings $vidId -hide true
    AddTextbox $slideId "InsertVideo [file tail $vidName]"
    Cawt CheckString "msoMedia"         [Ppt GetShapeType $vidId true]      "GetShapeType video"
    Cawt CheckString "ppMediaTypeMovie" [Ppt GetShapeMediaType $vidId true] "GetShapeMediaType video"
    incr numVids

    set slideId [Ppt AddSlide $presId]
    set vidId [Ppt InsertVideo $slideId $vidName -left 1c -top 2c]
    Ppt SetMediaPlaySettings $vidId -play true -rewind true
    AddTextbox $slideId "InsertVideo [file tail $vidName] -left 1c -top 2c"
    incr numVids

    set slideId [Ppt AddSlide $presId]
    set vidId [Ppt InsertVideo $slideId $vidName -width 100 -height 2i -link true]
    Ppt SetMediaPlaySettings $vidId -endless true
    AddTextbox $slideId "InsertVideo [file tail $vidName] -width 100 -height 2i -link true"
    incr numVids
}

Cawt CheckNumber $numImgs [expr [llength [Ppt GetPresImages $presId]] / 2] "GetPresImages"
Cawt CheckNumber $numVids [expr [llength [Ppt GetPresVideos $presId]] / 2] "GetPresVideos"

foreach { name slideIndex } [Ppt GetPresImages $presId] {
    puts [format "Image at slide %03d: %s" $slideIndex $name]
}

foreach { name slideIndex } [Ppt GetPresVideos $presId] {
    puts [format "Video at slide %03d: %s" $slideIndex $name]
}

# Save presentation.
puts "Saving as PowerPoint file: $pptFile"
Ppt SaveAs $presId $pptFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
