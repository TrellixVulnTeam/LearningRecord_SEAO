if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded udp 1.0.10 [list load [file join $dir tcl9udp1010t.dll]] 
} else { 
package ifneeded udp 1.0.10 [list load [file join $dir udp1010t.dll]] 
} 
