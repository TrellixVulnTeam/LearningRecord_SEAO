# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtOneNote { dir version } {
    package provide cawtonenote $version

    source [file join $dir oneNoteConst.tcl]
    source [file join $dir oneNoteBasic.tcl]
}
