##############################
# DEMO for Scrodget (with text)
##############################

  # touch 'auto_path', so that package can be found even
  #  it has not been installed in 'standard' directories.
 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]
   
 package require scrodget

 set c  .c
 set sc .sc
  # create a scrodget, a text, and associate it

 scrodget $sc
 text $c
 $sc associate $c
 
 $c configure \
     -relief sunken -borderwidth 2 \
     -bg green
 $c configure -wrap none

  ## some decoration ###
 
 $c insert end {
  This text widget
  has been associated to a scrodget widget
 
  Type some text and observe scrollbars' behaviour

  ....
 }
  # both vertical scrollbars
 $sc configure -scrollsides ew

  #  set the widget border
 $c configure -bd 5
  # set the "container" frame border
 $sc frame configure -bd 5 -relief groove
  # configure the scrollbar
# $sc eastScroll configure -width 20
# $sc westScroll configure -width 20

  # pack the scrolled-window, not the text !
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
 

 pack $ctrlW.sides $ctrlW.auto -fill x
 pack $ctrlW.lbl -fill x  -padx 2 -pady 2
  

  #  provide a feedback
 bind $c <Motion> { 
    set ::POSITION "Mouse at  X:%x  Y:%y"
 }

   # place it x-centered on the screen, at y=0
 tkwait visibility $ctrlW
 wm geometry $ctrlW \
   +[expr ([winfo screenwidth $ctrlW]-[winfo width $ctrlW])/2]+0






