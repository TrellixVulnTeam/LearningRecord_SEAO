# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtSapi { dir version } {
    package provide cawtsapi $version

    source [file join $dir sapiConst.tcl]
    source [file join $dir sapiBasic.tcl]
}
