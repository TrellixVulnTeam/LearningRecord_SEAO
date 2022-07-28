##############################
# DEMO for Scrodget + canvas
##############################

  # touch 'auto_path', so that package can be found even
  #  it has not been installed in 'standard' directories.
 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]
   
 package require scrodget

 set sc .sc
 set c  .c

  # create a scrodget , a canvas, then insert canvas in scrodget
 scrodget $sc 

 canvas $c \
     -relief sunken -borderwidth 2 \
     -bg green \
     -scrollregion {-200 -200 110 120} 
 $sc associate $c

  ## some decoration ###
 
  # show all scrollbars
 $sc configure -scrollsides nsew
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
  # configure the scrollbar
## $sc northScroll configure -width 30
## $sc southScroll configure -width 20
## $sc westScroll  configure -width 30
## $sc eastScroll  configure -width 20

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
 
 set scrollside [$sc cget -scrollsides]
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

   # scrollSide control
proc  updateScrollSide { w } {
   global scrollside
   
   set oldSS [$w cget -scrollsides]
   if { [catch {$w configure -scrollsides "$scrollside" } errMsg] } {
    tk_messageBox -icon error -message $errMsg
    set scrollside $oldSS
   }
} 


 label $ctrlW.lbl -textvariable ::POSITION -relief sunken -bd 2

 set sFrame [labelframe $ctrlW.sides -text "scrollbar-sides" -padx 2 -pady 2]
  entry $sFrame.e -textvariable scrollside 
  button $sFrame.b -text "Update" -command "updateScrollSide $sc"
  pack $sFrame.e $sFrame.b -side left -fill x -expand 1 -padx 1m -pady 1m 
 

 labelframe $ctrlW.auto -text "Automatically hide scrollbars (if needed)"
 foreach {lbl val} {  none false 
                      horizontal horizontal 
                      vertical vertical 
                      both true 
                   } {
    set w [radiobutton $ctrlW.auto.b$lbl -text "$lbl" -variable autohide \
	    -relief flat -value $val\
            -command "$sc configure -autohide \$autohide" ]
    pack $w  -side left -padx 2
 }

  set scrollRegion [$c cget -scrollregion]
  labelframe $ctrlW.l1 -text "Scroll Region"
  entry $ctrlW.l1.e -textvariable scrollRegion 
  button $ctrlW.l1.b -text "Update" -command "updateScrollRegion $c"
  pack $ctrlW.l1.e $ctrlW.l1.b -side left -fill x -expand 1 -padx 1m -pady 1m 

 pack $ctrlW.sides $ctrlW.auto $ctrlW.l1 -fill x

 pack $ctrlW.lbl -fill x  -padx 2 -pady 2

  

  #  provide a feedback
 bind $c <Motion> { 
    set ::POSITION "Mouse at  X:[%W canvasx %x]  Y:[%W canvasy %y]"
 }

   # place it x-centered on the screen, at y=0
 tkwait visibility $ctrlW
 wm geometry $ctrlW \
   +[expr ([winfo screenwidth $ctrlW]-[winfo width $ctrlW])/2]+0


  




