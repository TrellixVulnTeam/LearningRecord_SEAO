if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded Mpexpr 1.2 [list load [file join $dir tcl9Mpexpr12t.dll]] 
} else { 
package ifneeded Mpexpr 1.2 [list load [file join $dir Mpexpr12t.dll]] 
} 
