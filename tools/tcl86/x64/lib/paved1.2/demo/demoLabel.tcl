###
### DEMO for Paved::label ###
###

 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]


package require Paved::toplevel
package require Paved::frame
package require Paved::label


set top [Paved::toplevel .demoPavedLabel -tile [file join $thisDir backgrounds bathroom.gif]] 
$top configure -padx 20 -pady 20
$top configure -bd 5 -relief sunken

set baseImg [image create photo ${top}_baseImg -file [file join $thisDir backgrounds woodfloor.gif]]
set brownBg #7a4a1b 

set fA [Paved::frame $top.fA -bd 5 -relief sunken -pady 10 -padx 10]
$fA configure -tile [file join $thisDir backgrounds pool.gif]

 set lA [label $fA.lA -bd 5 -relief raised -pady 10 -padx 10 \
         -compound center \
         -image $baseImg -bg $brownBg \
         -text "a simple\nlabel widget" -foreground white \
        ]
  
  # WARNING:
  #  if tlabel size is dynamic (i.e. computed by a geom.manager),
  #  you should specify a minimum -height or -width.
  #  if you don't, anytime you sill resize the window, you can notice
  #   that the geom.manager takes many steps to 'adjust' the widget size ...
  #  (this is true if -padx/-pady are not 0)
  #  It is a complex behaviour ... the solution is:
  #   always set a minimum height/width
 set lB [Paved::label $fA.lB -bd 5 -relief raised -pady 10 -padx 10 \
         -height 50 -width 200 \
         -compound center \
         -tile $baseImg -bg $brownBg \
         -text "an extended\nPaved::label widget" -foreground white \
        ]


button $top.help -text "About.."

pack $top.help -side bottom
 pack $lA $lB  -fill both -expand true -pady 20
 pack $fA  -fill both -expand true -pady 20

wm geometry $top 400x500
wm iconify .

