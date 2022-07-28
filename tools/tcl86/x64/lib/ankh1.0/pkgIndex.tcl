if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded ankh 1.0 [list ::apply {dir {
    source [file join $dir critcl-rt.tcl]
    set path [file join $dir [::critcl::runtime::MapPlatform]]
    set ext [info sharedlibextension]
    set lib [file join $path "ankh$ext"]
    load $lib Ankh
    ::critcl::runtime::Fetch $dir policy_1.tcl
    package provide ankh 1.0
}} $dir]
