# Test creating videos from PowerPoint slides.
#
# Copyright: 2019-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Delete PowerPoint and video files from previous test run.
file mkdir testOut
set pptFile1   [file join [pwd] "testOut" "Ppt-14_CreateVideo1.pptx"]
set videoFile1 [file join [pwd] "testOut" "Ppt-14_CreateVideo1.mp4"]
file delete -force $pptFile1
file delete -force $videoFile1
set pptFile2   [file join [pwd] "testOut" "Ppt-14_CreateVideo2.pptx"]
set videoFile2 [file join [pwd] "testOut" "Ppt-14_CreateVideo2.mp4"]
file delete -force $pptFile2
file delete -force $videoFile2
set pptFile3   [file join [pwd] "testOut" "Ppt-14_CreateVideo3.pptx"]
set videoFile3 [file join [pwd] "testOut" "Ppt-14_CreateVideo3.mp4"]
file delete -force $pptFile3
file delete -force $videoFile3

# Open PowerPoint.
set appId [Ppt Open]

#
# Test case 1: Use images of equal size.
#

# Add presentation and configure the slides, so that
# their aspect ratio fits the aspect ratio of the images.
set presId1 [Ppt AddPres $appId]
Ppt SetPresPageSetup $presId1 -width 48c -height 12c

Cawt CheckBoolean true  [Ppt IsImageFormatSupported "TIFF"]     "IsImageFormatSupported TIFF"
Cawt CheckBoolean true  [Ppt IsImageFormatSupported "TIF" true] "IsImageFormatSupported TFF true"
Cawt CheckBoolean false [Ppt IsImageFormatSupported "PCX"]      "IsImageFormatSupported PCX"
Cawt CheckString  "JPG" [Ppt GetPptImageFormat "JPEG"]          "GetPptImageFormat JPEG"

# Look for image files of equal resolutions and insert each
# image into a separate slide.
# Set the image size, so that the image fits the slide size.
# Specify duration and effects for slide transitions.
set imgList [lsort -dictionary [glob [file join [pwd] "testIn" "Cawt*.png"]]]
foreach fileName $imgList {
    set slideId [Ppt AddSlide $presId1]
    set imgId [Ppt InsertImage $slideId $fileName -width 48c -height 12c]
    Ppt SetSlideShowTransition $slideId \
        -duration 2.5 \
        -advancetime 1.0 \
        -effect ppEffectFadeSmoothly
}

set numImgs      [llength $imgList]
set pageWidthCm  [expr round ([Cawt PointsToCentiMeters [Ppt GetPresPageWidth $presId1]])]
set pageHeightCm [expr round ([Cawt PointsToCentiMeters [Ppt GetPresPageHeight $presId1]])]
Cawt CheckNumber 48       $pageWidthCm  "Page width of slides"
Cawt CheckNumber 12       $pageHeightCm "Page height of slides"
Cawt CheckNumber $numImgs [Ppt GetNumSlides $presId1]                       "Number of slides"
Cawt CheckNumber $numImgs [expr [llength [Ppt GetPresImages $presId1]] / 2] "Number of images"

# Save the presentation as PowerPoint file.
puts "Saving as Ppt file: $pptFile1"
Ppt SaveAs $presId1 $pptFile1

# Save the presentation as video file in a low pixel resolution.
# Note, that "-resolution" specifies the vertical resolution.
puts "Saving as MP4 file: $videoFile1"
Ppt CreateVideo $presId1 $videoFile1 -resolution 120 -verbose true

#
# Test case 2: Use images of different size.
#

# Add a presentation and use the slide size as is.
set presId2 [Ppt AddPres $appId]

# Look for image files of different sizes
# and insert each image into a separate slide.
# The image size is calculated to fit optimal to the slide size.
# Specify duration and effects for slide transitions.
set imgList [lsort -dictionary [glob [file join [pwd] "testIn" "*.gif"]]]
foreach fileName $imgList {
    set slideId [Ppt AddSlide $presId2]
    set imgId [Ppt InsertImage $slideId $fileName -fit true]
    Ppt SetSlideShowTransition $slideId \
        -duration 2.5 \
        -advancetime 1.0 \
        -effect ppEffectFadeSmoothly
}

# Save the presentation as PowerPoint file.
puts "Saving as Ppt file: $pptFile2"
Ppt SaveAs $presId2 $pptFile2

# Save the presentation as video file in a medium pixel resolution.
# Note, that "-resolution" specifies the vertical resolution.
puts "Saving as MP4 file: $videoFile2"
Ppt CreateVideo $presId2 $videoFile2 -resolution 480 -verbose true

#
# Test case 3: Use photo images of different size.
#              This way all image types may be loaded which are
#              supported by the Img extension, but not by PowerPoint.
#

set retVal [catch { package require Img } version]
if { $retVal != 0 } {
    puts "Warning: Img extension missing. Test will not be performed."
} else {
    # Add a presentation and use the slide size as is.
    set presId3 [Ppt AddPres $appId]

    # Look for image files of different sizes
    # and insert each image into a separate slide.
    # The image size is calculated to fit optimal to the slide size.
    # Specify duration and effects for slide transitions.
    set imgList [lsort -dictionary [glob [file join [pwd] "testIn" "*.gif"]]]
    foreach fileName $imgList {
        set slideId [Ppt AddSlide $presId3]
        set phImg [image create photo -file $fileName]
        set imgId [Ppt InsertImage $slideId $phImg -fit true]
        Ppt SetSlideShowTransition $slideId \
            -duration 2.5 \
            -advancetime 1.0 \
            -effect ppEffectFadeSmoothly
    }

    # Save the presentation as PowerPoint file.
    puts "Saving as Ppt file: $pptFile3"
    Ppt SaveAs $presId3 $pptFile3

    # Save the presentation as video file in a medium pixel resolution.
    # Note, that "-resolution" specifies the vertical resolution.
    puts "Saving as MP4 file: $videoFile3"
    Ppt CreateVideo $presId3 $videoFile3 -resolution 480 -verbose true
}

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
