###
### DEMO for Paved::toplevel and Paved::frame ###
###

 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]


package require Paved::toplevel
package require Paved::frame


set top [Paved::toplevel .demo -tile [file join $thisDir backgrounds leaf1.gif]]
$top configure -padx 20 -pady 20
$top configure -bd 5 -relief sunken


set f [Paved::frame $top.f -bd 5 -relief raised -pady 10 -padx 10]
$f configure -tile [file join $thisDir backgrounds cheese.gif]
set b1 [button $f.b1 -text Camembert -padx 10 -pady 3]
set b2 [button $f.b2 -text Emmenthal -padx 10 -pady 3]
set b3 [button $f.b3 -text Parmigiano -padx 10 -pady 3]
pack $b1 $b2 $b3 -side top -expand true
pack $f -fill both -expand true -pady 20

button $top.help -text "About.."
pack $top.help


wm geometry $top 300x400
wm iconify .
