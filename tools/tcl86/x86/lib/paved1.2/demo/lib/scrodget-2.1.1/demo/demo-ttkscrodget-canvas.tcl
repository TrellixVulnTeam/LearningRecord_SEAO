 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]
   
 package require ttk::scrodget
  # override the 'standard' scrodget command with the ttk::scrodget commnad
 namespace import -force ttk::scrodget
 
  # just a standard theme
 tile::setTheme clam

  # #just source the 'standard'-scrodget demo
 source [file join $thisDir demo-scrodget-canvas.tcl]


