# Test quitting PowerPoint without saving modified presentations.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set appId [Ppt Open]
set presId [Ppt AddPres $appId]

set imgName [file join [pwd] "testIn" "wish.gif"]

set slideId1 [Ppt AddSlide $presId]
set slideId2 [Ppt AddSlide $presId]
set slideId3 [Ppt AddSlide $presId]

set img1Id [Ppt InsertImage $slideId1 $imgName 1c 2c]
set img2Id [Ppt InsertImage $slideId2 $imgName 1c 2c 3c 3c]
set img3Id [Ppt InsertImage $slideId3 $imgName 1c 2c 6c 6c]

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId false
    Cawt Destroy
    exit 0
}
Ppt Quit $appId true
Cawt Destroy
