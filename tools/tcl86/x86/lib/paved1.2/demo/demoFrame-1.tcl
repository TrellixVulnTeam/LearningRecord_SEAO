###
### DEMO for Paved::toplevel and Paved::frame ###
###

 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]


package require Paved::toplevel
package require Paved::frame


set top [Paved::toplevel .demo -tile [file join $thisDir backgrounds bathroom.gif]] 
$top configure -padx 20 -pady 20
$top configure -relief sunken


set fA [Paved::frame $top.fA -bd 5 -relief sunken -pady 10 -padx 10]
$fA configure -tile [file join $thisDir backgrounds pool.gif]
set b1 [button $fA.b1 -text "Cold Water"]
pack $b1 -fill x -expand true
pack $fA -fill both -expand true -pady 20


set fB [Paved::frame $top.fB -bd 5 -relief raised -pady 10 -padx 10]
$fB configure -tile [file join $thisDir backgrounds woodfloor.gif] -bg brown
set b1 [button $fB.b1 -text "Knock on wood" -padx 10 -pady 3]
pack $b1 -expand true
pack $fB -fill both -expand true -pady 20


button $top.help -text "About.."
pack $top.help

wm geometry $top 300x400
wm iconify .

