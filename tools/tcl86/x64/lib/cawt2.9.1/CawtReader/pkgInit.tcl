# Copyright: 2017-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtReader { dir version } {
    package provide cawtreader $version

    source [file join $dir readerBasic.tcl]
}
