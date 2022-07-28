#! /bin/sh
# The next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}

package require Tk
package require Canvas3d

set demodir [file join [pwd] [file dirname [info script]]]
source [file join $demodir common.tcl]

set img [image create photo -file [file join $demodir drh1.gif]]

set coords [::canvas3d::sphere]
set texcoords {}

foreach triangle $coords {
    foreach {x y z} $triangle {
        lappend texcoords [expr 1.0 - (($x + 1.0) / 2.0)]
        lappend texcoords [expr 1.0 - (($y + 1.0) / 2.0)]
    }
}

.win create polygon $coords -tags S
.win itemconfigure S -teximage $img -texcoords $texcoords -smooth 1

.win create light {10 10 10 0 0 0}
.win configure -bg {0.1 0.1 0.1 1.0}
.win configure -cameralocation {0 0 10}
