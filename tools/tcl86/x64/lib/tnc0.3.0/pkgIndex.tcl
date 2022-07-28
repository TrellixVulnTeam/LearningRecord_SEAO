if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded tnc 0.3.0 [list load [file join $dir tcl9tnc030t.dll]] 
} else { 
package ifneeded tnc 0.3.0 [list load [file join $dir tnc030t.dll]] 
} 
