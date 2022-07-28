package require platform

package ifneeded tclcsv 2.3 \
    "[list load [file join $dir [platform::generic] tclcsv23t.dll] tclcsv] ;
        [list source [file join $dir csv.tcl]]"
