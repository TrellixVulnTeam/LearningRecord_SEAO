# Test embedding procedures of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require Tk
package require cawt

set twapiVersion [Cawt GetPkgVersion "twapi"]

set inFile [file join [pwd] "testIn" "MediaWikiTable.txt"]

proc Quit {} {
    Cawt Destroy
    exit 0
}

# Create the Tk user interface. One frame is a container frame
# for embedding the Notepad application window.
wm title . "Cawt-09_Embed"
wm geometry . "800x600"

set statFr [frame .statFr]
set infoFr [frame .infoFr]
set appFr  [frame .appFr -container true -borderwidth 0]
grid $statFr -row 0 -column 0 -sticky news -columnspan 2
grid $infoFr -row 1 -column 0 -sticky news
grid $appFr  -row 1 -column 1 -sticky news
grid rowconfigure    . 1 -weight 1
grid columnconfigure . 1 -weight 1

label $statFr.version -text "Embedding Notepad using Tcl [info patchlevel] and Twapi $twapiVersion"
pack $statFr.version -side top

label $infoFr.file
pack $infoFr.file -side top -anchor w
update

puts "Starting Notepad instance with file [file tail $inFile] ..."
set notepadPath [auto_execok "notepad.exe"]
eval exec [list $notepadPath] $inFile &

puts "Embedding Notepad ..."
Cawt SetEmbedTimeout 0.5
Cawt EmbedApp $appFr -filename $inFile

$infoFr.file configure -text "File: [file tail $inFile]"

Cawt PrintNumComObjects

bind . <Escape> "Quit"
wm protocol . WM_DELETE_WINDOW "Quit"

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
