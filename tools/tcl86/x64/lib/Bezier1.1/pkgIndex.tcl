package ifneeded Bezier 1.1 [string map [list @ $dir] {
    package require Tcl 8.5
    source [file join {@} Bezier.tcl]
    package provide Bezier 1.1
}]

package ifneeded BContour 1.1 [string map [list @ $dir] {
    package require Tcl 8.5
    source [file join {@} BContour.tcl]
    package provide BContour 1.1
}]	