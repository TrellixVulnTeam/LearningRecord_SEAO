##############################
# DEMO for Scrodget and ttk::scrodget together
##############################
 
 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]
   
 package require scrodget
 package require ttk::scrodget
    
  # just a standard theme
 tile::setTheme clam

 text .t1 -wrap none -bg orange     -height 5
 text .t2 -wrap none -bg lightblue  -height 5

 scrodget .sc1
 ttk::scrodget .sc2

 .sc1 associate .t1
 .sc2 associate .t2

 .t1 insert end "
 This is a text widget associated to a 'standard' scrodget.
 ...
 ...
 ...
 ..
 ..
 ..
 "
 
 .t2 insert end "
 This is a text widget associated to a 'themed' scrodget.
 ...
 ...
 ...
 ..
 ..
 ..
 "

 pack .sc1 .sc2 -expand 1 -fill both

