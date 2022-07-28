##############################
# DEMO for ScrolledWindow + Canvas
##############################

 package require BWidget

 set sc .sc
 set c  .c

  # create a scrolled window + a canvas 
 ScrolledWindow $sc \
     -relief sunken -borderwidth 2

 canvas $c -bg green \
     -scrollregion {-300 -300 300 300}

 $sc setwidget $c

  ## some decoration ###
 
  # move vertical scrollbar to east/north
 $sc configure -sides en

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
 $sc configure -bd 5 -relief groove

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

 set auto [$sc cget -auto]
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
             -command "$sc configure -auto \$auto"]
 
  set scrollRegion [$c cget -scrollregion]
  labelframe $ctrlW.l1 -text "Scroll Region"
  entry $ctrlW.l1.e -textvariable scrollRegion 
  button $ctrlW.l1.b -text "Update" -command "updateScrollRegion $c"
  pack $ctrlW.l1.e $ctrlW.l1.b -side left -fill x -expand 1 -padx 1m -pady 1m 

 pack $chkb $ctrlW.l1 -in $ctrlW.mid

 pack $ctrlW.lbl -fill x  -padx 2 -pady 2
 pack $vFrame $ctrlW.mid $hFrame -side left -expand 1
  
  # scrollbar controls are disabled
  #  since it's no easy to set them independently
  #  ( not so easy as with scrodget )
 foreach i { top bottom none } {
    set w [radiobutton $hFrame.b$i -text "$i" -variable hSide \
	    -relief flat -value $i\
            -command "$sc configure -hscrollside \$hSide" ]
    $w configure -state disabled
    pack $w  -side top -pady 2 -anchor w

 }

 foreach i { right left none } {
    set w [radiobutton $vFrame.b$i -text "$i" -variable vSide \
	    -relief flat -value $i \
            -command "$sc configure -vscrollside \$vSide" ]
    $w configure -state disabled
    pack $w  -side top -pady 2 -anchor w

 }

  #  provide a feedback
bind $c <Motion> { 
    set ::POSITION "Mouse at  X:[%W canvasx %x]  Y:[%W canvasy %y]"
 }

   # place it x-centered on the screen, ay y=0
 tkwait visibility $ctrlW
 wm geometry $ctrlW \
   +[expr ([winfo screenwidth $ctrlW]-[winfo width $ctrlW])/2]+0




