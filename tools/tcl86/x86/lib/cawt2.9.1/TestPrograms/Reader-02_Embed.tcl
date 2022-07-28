# Test CawtExcel procedures for embedding an Acrobat Reader window into a Tk frame.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require Tk
package require cawt

set twapiVersion [Cawt GetPkgVersion "twapi"]

set inFile [file join [pwd] "testIn" "CawtManual1.pdf"]

proc Quit {} {
    Reader Quit
    Cawt Destroy
    exit 0
}

# Create the Tk user interface. One frame is a container frame
# for embedding the Reader application window.
wm title . "Excel-36_Embed"
wm geometry . "800x600"

set statFr   [frame .statFr]
set infoFr   [frame .infoFr]
set readerFr [frame .readerFr -container true -borderwidth 0]
grid $statFr   -row 0 -column 0 -sticky news -columnspan 2
grid $infoFr   -row 1 -column 0 -sticky news
grid $readerFr -row 1 -column 1 -sticky news
grid rowconfigure    . 1 -weight 1
grid columnconfigure . 1 -weight 1

label $statFr.version -text "Embedding Acrobat Reader using Tcl [info patchlevel] and Twapi $twapiVersion"
pack $statFr.version -side top

label $infoFr.file
pack $infoFr.file -side top -anchor w
update

puts "Starting Reader instance with file [file tail $inFile] ..."
Cawt SetEmbedTimeout 1.0
Reader OpenNew $inFile -page 2 -pagemode none -toolbar false -zoom 100 -embed $readerFr 

$infoFr.file configure -text "File: [file tail $inFile]"

Cawt PrintNumComObjects

bind . <Escape> "Quit"
wm protocol . WM_DELETE_WINDOW "Quit"

if { [lindex $argv 0] eq "auto" } {
    Reader Quit
    Cawt Destroy
    exit 0
}
