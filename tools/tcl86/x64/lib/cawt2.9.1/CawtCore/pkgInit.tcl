# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtCore { dir version } {
    package provide cawtcore $version

    source [file join $dir cawtBasic.tcl]
    source [file join $dir cawtColorUtil.tcl]
    source [file join $dir cawtDateUtil.tcl]
    source [file join $dir cawtFileUtil.tcl]
    source [file join $dir cawtImgUtil.tcl]
    source [file join $dir cawtStringUtil.tcl]
    source [file join $dir cawtInterpolate.tcl]
    source [file join $dir cawtEmbed.tcl]
    source [file join $dir cawtTestUtil.tcl]
}
