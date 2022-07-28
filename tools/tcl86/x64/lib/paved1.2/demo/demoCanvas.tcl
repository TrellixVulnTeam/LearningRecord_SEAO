##############################
# DEMO for Scrodget + Paved::canvas
##############################

  # touch 'auto_path', so that package can be found even
  #  it has not been installed in 'standard' directories.
 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]
   

  # for scrodget ...
 lappend auto_path [file join $thisDir lib]


 package require scrodget
 package require Paved::canvas

 set sc .sc
 set c  .c

  # create a scrodget , a canvas, then insert canvas in scrodget
 scrodget $sc 

 Paved::canvas $c \
     -tile [file join $thisDir backgrounds x100.gif] \
     -relief sunken -borderwidth 2 \
     -bg green \
     -scrollregion {-300 -300 300 300} 
 $sc associate $c

  ## some decoration ###

 $sc configure -scrollsides news
  # draw some points
proc plot { c x y } {
   set r 8
   $c create oval [expr $x-$r] [expr $y-$r] [expr $x+$r] [expr $y+$r]
   $c create text [expr $x+2*$r] $y -anchor w -text "$x , $y"
}
 $c create line -200 -200 200  200
 plot $c 0 0
 plot $c 100 100
 plot $c -100 -100
 $c create line -100  100 100 -100 

  #  set the canvas border
 $c configure -bd 5
  # set the "container" frame border
 $sc frame configure -bd 5 -relief groove

  # pack the scrolled-window, not the canvas !
 pack $sc -side top    -fill both -expand 1 -padx 2 -pady 2



  # ----------------------------------------------------------------------
  # extra stuff ... just for control
  # ----------------------------------------------------------------------
 
 set ctrlW  .control
 toplevel $ctrlW
 wm title $ctrlW "Control-Panel for [info script]"
 wm resizable $ctrlW 0 0
 $ctrlW configure -padx 2 -pady 2 -borderwidth 2 -relief groove 
 
 set autohide [$sc cget -autohide]
 set scrollRegion [$c cget -scrollregion]
   
   # scrollRegion control
proc  updateScrollRegion { w } {
   global scrollRegion
   
   set oldSR [$w cget -scrollregion]
   if { [catch {eval $w configure -scrollregion { $scrollRegion } } errMsg] } {
    tk_messageBox -icon error -message $errMsg
    set scrollRegion $oldSR
   }
} 

 label $ctrlW.lbl -textvariable ::POSITION -relief sunken -bd 2
 set vFrame [labelframe $ctrlW.vscroll -text "vertical scrollbar" -padx 2 -pady 2]
 set hFrame [labelframe $ctrlW.hscroll -text "horizontal scrollbar" -padx 2 -pady 2]
 frame $ctrlW.mid
 set chkb   [checkbutton $ctrlW.b1 -text "Automatically\nhide scrollbars" \
             -variable autohide \
             -command "$sc configure -autohide \$autohide"]

  set scrollRegion [$c cget -scrollregion]
  labelframe $ctrlW.l1 -text "Scroll Region"
  entry $ctrlW.l1.e -textvariable scrollRegion 
  button $ctrlW.l1.b -text "Update" -command "updateScrollRegion $c"
  pack $ctrlW.l1.e $ctrlW.l1.b -side left -fill x -expand 1 -padx 1m -pady 1m 

 pack $chkb $ctrlW.l1 -in $ctrlW.mid

 pack $ctrlW.lbl -fill x  -padx 2 -pady 2
 pack $vFrame $ctrlW.mid $hFrame -side left -expand 1
  
  #  provide a feedback
 bind $c <Motion> { 
    set ::POSITION "Mouse at  X:[%W canvasx %x]  Y:[%W canvasy %y]"
 }

   # place it x-centered on the screen, ay y=0
 tkwait visibility $ctrlW
 wm geometry $ctrlW \
   +[expr ([winfo screenwidth $ctrlW]-[winfo width $ctrlW])/2]+0

 




