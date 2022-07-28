if {![package vsatisfies [package provide Tcl] 8.6]} {return}
package ifneeded tarray 1.0.0 [list ::apply {dir {
    source [file join $dir critcl-rt.tcl]
    set path [file join $dir [::critcl::runtime::MapPlatform]]
    set ext [info sharedlibextension]
    set lib [file join $path "tarray$ext"]
    load $lib Tarray
    ::critcl::runtime::Fetch $dir tabulate_1.tcl
    ::critcl::runtime::Fetch $dir tarray_2.tcl
    ::critcl::runtime::Fetch $dir taprint_3.tcl
    ::critcl::runtime::Fetch $dir tarbc_4.tcl
    ::critcl::runtime::Fetch $dir dbimport_5.tcl
    ::critcl::runtime::Fetch $dir taversion_6.tcl
    package provide tarray 1.0.0
}} $dir]
