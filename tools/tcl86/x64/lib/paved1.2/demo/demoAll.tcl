###
### DEMO for ALL Paved widgets ###
###

 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]


package require Paved

 set main [toplevel .main]

 option add *main*font      {Jokerman 22 bold}
 option add *main*compound  center
 
 option add *main*statusBar*anchor       w
 option add *main*statusBar*borderWidth  2
 option add *main*statusBar*relief       groove
 option add *main*statusBar*height       35

 option add *main*cvs*borderWidth  2
 option add *main*cvs*relief       sunken
   
 option add *main*Button.height 20



 set imgDir [file join $thisDir backgrounds]
 source [file join $thisDir aboutPave.tcl]



 set pane [panedwindow $main.pane -showhandle true -bd 2 -relief groove]
 set statusBar [Paved::label $main.statusBar \
    -textvariable ::labelText \
    -tile [file join $imgDir bk391.gif] \
    ]

 pack $statusBar -side bottom -fill x -padx 2 -pady 2   
 pack $pane -expand yes -fill both -padx 2 -pady 2
 
 set f1 [Paved::frame $pane.f1 -tile [file join $imgDir aqua.gif] ]
 
 Paved::canvas $pane.cvs


  # create buttons and set minimum height (because their size is expanding)
 Paved::button $f1.b1 \
       -text "Tile A" \
       -foreground gray5 \
       -tile [file join $imgDir ab00.gif] \
       -command [list $pane.cvs configure -tile [file join $imgDir ab00.gif]]

 Paved::button $f1.b2 \
       -text "Tile B" \
       -foreground darkblue \
       -tile [file join $imgDir pebble-light.gif] \
       -command [list $pane.cvs configure -tile [file join $imgDir pebble-light.gif]]

 Paved::button $f1.b3 \
       -text "Tile C" \
       -foreground yellow \
       -tile [file join $imgDir ab01.gif] \
       -command [list $pane.cvs configure -tile [file join $imgDir ab01.gif]]

 Paved::button $f1.b4 \
       -text "About" \
       -foreground black \
       -tile [file join $imgDir confetti.gif] \
       -command aboutPaved
 
 pack $f1.b1 $f1.b2 $f1.b3 $f1.b4 -side top -expand true -fill both \
      -padx 10 -pady 10
      
 
 
 $pane add $pane.f1 $pane.cvs -minsize 180


 # ------------------------------------------------

 # more stuff for fun:
 # allow adding 'spots' to canvas, and manage their interactive positioning
 #  ...

proc funEffect { cvs } {
  # change cursor when you are on a 'spot'
 $cvs bind spot <Enter> "%W configure -cursor fleur"
 $cvs bind spot <Leave> "%W configure -cursor {}"

  # allow 'click and drag' of spots.
 $cvs bind spot <1> "plotDown %W %x %y"
 $cvs bind spot <ButtonRelease-1> "%W dtag selected"
 $cvs bind spot <B1-Motion> "plotMove %W %x %y"

  # few procs for handling the interactive positioning
 set plot($cvs,lastX) 0
 set plot($cvs,lastY) 0

  # wait for widget (otherwise geometry is "wrong" )
 tkwait visibility $cvs

 addSpot $cvs
 addSpot $cvs
 addSpot $cvs
}

 proc plotDown {w x y} {
    global plot
    $w dtag selected
    $w addtag selected withtag current
    $w raise current
    set plot($w,lastX) $x
    set plot($w,lastY) $y
 }

 proc plotMove {w x y} {
    global plot
    $w move selected [expr $x-$plot($w,lastX)] [expr $y-$plot($w,lastY)]
    set plot($w,lastX) $x
    set plot($w,lastY) $y
    set ::labelText "cursor at ($x , $y)"
 }


 # add a random spot to canvas
proc addSpot { cvs } {
     # radius between 25 and 60
   set r [expr int(25+rand()*(60-25))]

     # current-view upper-left corner is
   set wx0 [$cvs canvasx 0]
   set wy0 [$cvs canvasy 0]
     # current-view dim is
   set W [winfo width $cvs]
   set H [winfo height $cvs]

     # xc between $r and $W-$r (plus $wx0)
     # yc between $r and $H-$r (plus $wy0)
   set xc [expr $wx0+$r+int(rand()*($W-2*$r))]
   set yc [expr $wy0+$r+int(rand()*($H-2*$r))]
   set color [format "#%06x" [expr int(rand()*pow(2,24))]]
   $cvs create oval [expr $xc-$r] [expr $yc-$r] [expr $xc+$r] [expr $yc+$r] -fill $color -tags spot
}


wm geometry $main 600x350
wm iconify .


 funEffect .main.pane.cvs
