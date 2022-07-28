# Test CawtWord procedures for embedding a Word document into a Tk frame.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require Tk
package require cawt

set twapiVersion [Cawt GetPkgVersion "twapi"]

# Open new Word instance and show the application window.
set appId [Word OpenNew]
set appVersion [Word GetVersion $appId true]

set inFile [file join [pwd] "testIn" "ReplaceImageTemplate.docx"]

proc Quit { appId } {
    # Word application may have been closed. 
    # Check, if appId refers to a valid COM object.
    if { [Cawt IsAppIdValid $appId] } {
        Word Quit $appId
        Cawt Destroy
    }
    exit 0
}

# Create the Tk user interface. One frame is a container frame
# for embedding the Word document.
wm title . "Word-23_Embed"
wm geometry . "800x600"

set statFr [frame .statFr]
set infoFr [frame .infoFr]
set wordFr [frame .wordFr -container true -borderwidth 0]
grid $statFr -row 0 -column 0 -sticky news -columnspan 2
grid $infoFr -row 1 -column 0 -sticky news
grid $wordFr -row 1 -column 1 -sticky news
grid rowconfigure    . 1 -weight 1
grid columnconfigure . 1 -weight 1

label $statFr.version -text "Embedding $appVersion using Tcl [info patchlevel] and Twapi $twapiVersion"
pack $statFr.version -side top

label $infoFr.numImgs
label $infoFr.numPages
pack $infoFr.numImgs $infoFr.numPages -side top -anchor w

# Open the Word document and embed into Tk frame.
set docId [Word OpenDocument $appId $inFile -embed $wordFr -readonly true]
Word SetViewParameters $docId -pagefit wdPageFitFullPage

set numImgs  [Word GetNumImages $docId false]
set numPages [Word GetNumPages  $docId]

$infoFr.numImgs  configure -text "Number of images: $numImgs"
$infoFr.numPages configure -text "Number of pages : $numPages"

Cawt CheckNumber 4 $numImgs  "Total number of images"
Cawt CheckNumber 2 $numPages "Number of pages"

Cawt PrintNumComObjects

bind . <Escape> "Quit $appId"
wm protocol . WM_DELETE_WINDOW "Quit $appId"

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId false
    Cawt Destroy
    exit 0
}
