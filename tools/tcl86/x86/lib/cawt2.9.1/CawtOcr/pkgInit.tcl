# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtOcr { dir version } {
    package provide cawtocr $version

    source [file join $dir ocrBasic.tcl]
}
