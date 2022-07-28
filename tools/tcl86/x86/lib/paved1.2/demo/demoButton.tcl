###
### DEMO for Paved::button ###
###

 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]

package require Paved::button


 image create photo aaa -file $thisDir/backgrounds/pool.gif

 option add *Button*borderWidth  10
 option add *Button*compound     center



button .b1 -text "simple button"
button .b2 -text {simple button\nwith image}
 .b2 configure -text "simple button\nwith image"
 .b2 configure -image aaa
button .b3 -image aaa
 .b3 configure -text "simple button\nwith image\n(-height 40)"
 .b3 configure -height 40 -bg #9999FF
 
pack .b1 -fill x -expand 1
pack .b2 -fill x -expand 1
pack .b3 -fill x -expand 1


Paved::button .tb1 -text "Paved::button" \
        -tile aaa \
        -height 40 \

pack .tb1 -fill x -expand 1

. configure -padx 20 -pady 20
wm geometry . 400x500
