# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtMatlab { dir version } {
    package provide cawtmatlab $version

    source [file join $dir matlabBasic.tcl]
}
