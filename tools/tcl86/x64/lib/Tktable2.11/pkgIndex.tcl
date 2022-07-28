if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded Tktable 2.11 [list load [file join $dir tcl9Tktable211t.dll]] 
} else { 
package ifneeded Tktable 2.11 [list load [file join $dir Tktable211t.dll]] 
} 
