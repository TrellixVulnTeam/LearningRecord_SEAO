package require Thread

set dir [file join [pwd] [file dirname [info script]]]

set src [file join $dir duodecahedron.tcl]
set script [subst {
   package require Tk
   wm title . "Duodecahedron"
   source [list $src]
   vwait forever
}]

::thread::create $script

set src [file join $dir cube.tcl]
set script [subst {
   package require Tk
   wm title . "Cube"
   source [list $src]
   vwait forever
}]

::thread::create $script

wm title . "Multiple Threads"
button .exit -command exit -text Exit -width 20
pack .exit -side top
