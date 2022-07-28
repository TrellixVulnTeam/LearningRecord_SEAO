# Test CawtPpt procedures for embedding a PowerPoint presentation into a Tk frame.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require Tk
package require cawt

set twapiVersion [Cawt GetPkgVersion "twapi"]

# Open new PowerPoint instance and show the presentation window.
set appId [Ppt OpenNew]
set appVersion [Ppt GetVersion $appId true]

set inFile [file join [pwd] "testIn" "SamplePpt"]
append inFile [Ppt GetExtString $appId]

proc Quit { appId } {
    # PowerPoint application may have been closed. 
    # Check, if appId refers to a valid COM object.
    if { [Cawt IsAppIdValid $appId] } {
        Ppt Quit $appId
        Cawt Destroy
    }
    exit 0
}

# Create the Tk user interface. One frame is a container frame
# for embedding the PowerPoint document.
wm title . "Ppt-16_Embed"
wm geometry . "800x600"

set statFr [frame .statFr]
set infoFr [frame .infoFr]
set pptFr  [frame .pptFr -container true -borderwidth 0]
grid $statFr -row 0 -column 0 -sticky news -columnspan 2
grid $infoFr -row 1 -column 0 -sticky news
grid $pptFr  -row 1 -column 1 -sticky news
grid rowconfigure    . 1 -weight 1
grid columnconfigure . 1 -weight 1

label $statFr.version -text "Embedding $appVersion using Tcl [info patchlevel] and Twapi $twapiVersion"
pack $statFr.version -side top

label $infoFr.numSlides
pack $infoFr.numSlides -side top -anchor w

# Open the PowerPoint document and embed into Tk frame.
set presId [Ppt OpenPres $appId $inFile -embed $pptFr -readonly true]
Ppt SetViewType $presId ppViewSlideSorter

set numSlides [Ppt GetNumSlides $presId]

$infoFr.numSlides configure -text "Number of slides: $numSlides"

Cawt CheckNumber 3 $numSlides  "Number of slides"

Cawt PrintNumComObjects

bind . <Escape> "Quit $appId"
wm protocol . WM_DELETE_WINDOW "Quit $appId"

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    exit 0
}
