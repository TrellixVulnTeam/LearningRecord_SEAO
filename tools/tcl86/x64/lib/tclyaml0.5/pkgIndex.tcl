if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded tclyaml 0.5 [list ::apply {dir {
    source [file join $dir critcl-rt.tcl]
    set path [file join $dir [::critcl::runtime::MapPlatform]]
    set ext [info sharedlibextension]
    set lib [file join $path "tclyaml$ext"]
    load $lib Tclyaml
    ::critcl::runtime::Fetch $dir policy_1.tcl
    package provide tclyaml 0.5
}} $dir]
