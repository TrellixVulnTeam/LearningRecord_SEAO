#! /bin/sh
# The next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}

package require Tk
package require Canvas3d

set demodir [file join [pwd] [file dirname [info script]]]
source [file join $demodir common.tcl]

proc cube {sidelength tag} {
  set p [expr $sidelength / 2.0]
  set m [expr $sidelength / -2.0]

  .win create polygon [list $p $p $p  $m $p $p  $m $m $p  $p $m $p]
  .win create polygon [list $p $p $m  $m $p $m  $m $m $m  $p $m $m]

  .win create polygon [list $p $p $p  $m $p $p  $m $p $m  $p $p $m]
  .win create polygon [list $p $m $p  $m $m $p  $m $m $m  $p $m $m]

  .win create polygon [list $p $p $p  $p $m $p  $p $m $m  $p $p $m]
  .win create polygon [list $m $p $p  $m $m $p  $m $m $m  $m $p $m]
}

cube 1.0 cube_one
.win create light {0.0 0.0 3.0}
.win transform -camera light {lookat all}