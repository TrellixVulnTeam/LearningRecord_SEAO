###
### DEMO for Paved::Tree ###
###

 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]


package require Paved::Tree

set bgImageFile [file join $thisDir backgrounds flowers.gif]
set tree [Paved::Tree .t -tile $bgImageFile \
          -linesfill white \
          -selectbackground darkblue ]

 # populate $tree with some data

set parentNode root                                
foreach txt1 { AAA BBB CCC DDD EEE } {
   set nodeID [$tree insert end $parentNode #auto -text $txt1 -fill white]
   foreach txt2 { alpha beta gamma delta } {
       $tree insert end $nodeID #auto -text $txt2 -fill white
   }
}

pack $tree -expand true -fill both

