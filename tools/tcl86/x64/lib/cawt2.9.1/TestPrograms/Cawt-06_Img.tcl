# Test image handling functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt
package require Tk

set inPath  [file join [pwd] "testIn"]
set outPath [file join [pwd] "testOut"]
file mkdir $outPath

set imgFile [file join $inPath "Landscape.gif"]

set outFile1 [file join $outPath "Cawt-06_ImgIn.gif"]
set outFile2 [file join $outPath "Cawt-06_ImgOut.gif"]

set photoIn [image create photo -file $imgFile]

label .l1
label .l2
pack .l1 .l2 -side left

Cawt SetClipboardWaitTime 1000
set retVal [catch {Cawt ImgToClipboard $photoIn}]
Cawt CheckNumber 0 $retVal "ImgToClipboard"
if { $retVal == 0 } {
    .l1 configure -image $photoIn
    update
}
$photoIn write $outFile1 -format GIF

set retVal [catch {Cawt ClipboardToImg} photoOut]
Cawt CheckNumber 0 $retVal "ClipboardToImg"
if { $retVal == 0 } {
    .l2 configure -image $photoIn
    update
}
$photoOut write $outFile2 -format GIF

Cawt CheckFile $outFile1 $outFile2 "Clipboarded images"

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
