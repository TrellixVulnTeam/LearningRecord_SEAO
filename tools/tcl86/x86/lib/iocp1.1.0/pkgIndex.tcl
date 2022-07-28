# Core iocp package
package ifneeded iocp 1.1.0 \
    [list apply [list {dir} {
        if {$::tcl_platform(machine) eq "amd64"} {
            set path [file join $dir amd64 "iocp110t.dll"]
        } else {
            set path [file join $dir x86 "iocp110t.dll"]
        }
        if {![file exists $path]} {
            # To accomodate make test
            set path [file join $dir "iocp110t.dll"]
        }
        uplevel #0 [list load $path]
    }] $dir]

# iocp_inet doesn't need anything other than core iocp
package ifneeded iocp_inet 1.1.0 \
    "package require iocp"

if {1} {
    # iocp_bt needs supporting script files
    package ifneeded iocp_bt 1.1.0 \
        "[list source [file join $dir bt.tcl]]"
}

