package ifneeded rbc 0.1.1 "
    # This package always requires Tk
    [list package require Tk]
    [list load [file join $dir rbc011t.dll]]
    [list source [file join $dir graph.tcl]]
"
