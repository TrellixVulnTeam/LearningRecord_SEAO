package ifneeded zoom-canvas 2.0 [string map [list @ $dir] {
    package require Tcl 8.6
    source [file join {@} zoom-canvas.tcl]
    package provide zoom-canvas 2.0
}]
	