if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded Tix 8.4.3 [list load [file join $dir tcl9Tix843t.dll]] 
} else { 
package ifneeded Tix 8.4.3 [list load [file join $dir Tix843t.dll]] 
} 
