#! /bin/sh
# The next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}

if {![catch {sdltk android}] && [sdltk android]} {
    error "Sorry, not on Android. Please start the demo scripts manually."
}

package require Tk
package require Canvas3d

set demodir [file join [pwd] [file dirname [info script]]]

set demos {Cube Duodecahedron Shapes Texture2 Triangles}

bind . <KeyPress-Q> exit
bind . <KeyPress-q> exit

wm title . "3dCanvas Demos"

grid [label .l0 -text "Double-Click on a demo to run it"]
grid [label .l1 -text "Qq to exit"]
grid [listbox .lb -listvariable demos] -sticky news

bind demos <Double-Button-1> [list click %W]
bindtags .lb [linsert [bindtags .lb] end demos]

proc click {w} {
	global demodir demos
	if {[llength [set sel [$w curselection]]] == 0} { return }
	set demo [file join $demodir [string tolower [lindex $demos [lindex $sel 0]]].tcl]
	if {![file exists $demo]} { return }
	exec $demo &
}
