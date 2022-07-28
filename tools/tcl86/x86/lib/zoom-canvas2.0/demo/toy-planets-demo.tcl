# toy-planets-demo

 # Preamble:
 # these two lines are required for running this script
 # even if the required packages (zoom-canvas ...) are not installed 
 # under a directory listed in auto_path
set thisDir [file normalize [file dirname [info script]]]
set auto_path [linsert $auto_path 0 [file dirname $thisDir]]

 # Press <F1> for the developer's backdoor (Windows-only) ..
bind . <F1> { catch { console show } }


package require tile
package require zoom-canvas 2.0
source [file join $thisDir Stopwatch.tcl]


# ---------------------------------------------------------------------------
#  Table of planets:
#  * planet-name
#  * distance-from-Sun(km) 
#  * radius(km) 
#  * orbit-period(sec) 
#  * theta0: angular position at time T0  (? assume 0.0 )
#  * color: planet's color
#
#  Warning : very approximated measures. Just a toy.

set PlanetsData {
 { Mercury  57.9E6  2440   7595130  0.0  orange}
 { Venus   108.2E6  6051  19400852  0.0  lightgreen }
 { Earth   149.5E6  6371  31536548  0.0  blue  }
 { Mars    227.9E6  3389  59312908  0.0  red   }
 { Jupiter 778.3E6 69900 374016960  0.0  yellow}
 { Saturn  1426E6  58200 927158400  0.0  lightblue}
}
set SunData \
 { Sun     0         8e6   0        0.0  yellow}
 # Sun-size is about 0.8e6 km ; here is set to 10 times wider ...
  
# ---------------------------------------------------------------------------

 # prepare the main control-planet.
 # The following widget are 'public' and should be configured 
 # externally with the proper business logic:
 #  * $w.speed      :: a scale-widget
 #  * $w.animation  :: a checkbutton (true/false)
 #  * $w.showOrbits :: a checkbutton (true/false)
 #  * $w.zoomButton :: a ttk::button 
 #  * $w.planet     :: a container for a group of radiobuttons, whose values 
 #                     are "Mercury", "Venus", ....
 #  * $w.centric    :: a container for a group of radiobuttons, whose values
 #                     are "Sun", "Earth"
  
proc UI_ControlPanel {w} {
	ttk::frame $w -relief raised -pad {10 10 10 10} 
    
    ttk::label $w.title -text "Toy Planets" -font {-size 16}
    grid $w.title -
    
    ttk::checkbutton $w.animation -text "Animation"
    ttk::checkbutton $w.showOrbits -text "Show Orbits"    

    ttk::labelframe $w.centric -text "Mode"
	    ttk::radiobutton  $w.centric.elio -text "ElioCentric" -value "Sun"
	    ttk::radiobutton  $w.centric.geo  -text "GeoCentric"  -value "Earth"
	    grid x $w.centric.elio 
	    grid x $w.centric.geo  

    grid $w.animation $w.centric
	grid $w.showOrbits ^
		grid configure $w.centric -pady 8 -sticky ew
		grid configure $w.animation -sticky w
		grid configure $w.showOrbits -sticky w		
    
	ttk::labelframe $w.planet -text "Tracked planet"
	  	foreach item $::PlanetsData {
	        lassign $item planetName orad prad period theta0 color
			 # prepare the radiobuttun
			set rbW [ttk::radiobutton $w.planet.p_$planetName -text $planetName -value $planetName]
			grid x $rbW
			grid configure $rbW -sticky w
		}
	message $w.planetHelp -font {-slant italic -size 8} -text \
		{In GeoCentric mode, track the orbit of the selected planet as observed from Earth}
	grid $w.planetHelp $w.planet
		grid configure $w.planet -pady 8 -sticky ew

    message $w.speedHelp -font {-slant italic -size 8} \
    	-aspect 1000 \
		-text \
		"Duration of one Earth revolution:\n From 60 seconds to 1 second."  
    ttk::scale $w.speed 
    grid $w.speed - -sticky ew
    grid $w.speedHelp - -sticky ew

    message $w.help -font {-slant italic -size 8} \
		-text "* Use MouseWheel for zooming\n* Press Left-Button for panning"
    ttk::button $w.zoomButton -text "Best Zoom"
    grid $w.help $w.zoomButton x -pady {60 1}

    return $w
}


 # create a zoom-canvas widget with a statusbar
 # provides
 #   a zoom-canvas named $w.zc
proc UI_ZoomCanvasWithStatusBar {w} {
	ttk::frame $w

    zoom-canvas $w.zc -highlightthickness 0 -yaxis up
    ttk::frame $w.status
    	ttk::label $w.status.zoom
    	ttk::label $w.status.xy
    	pack $w.status.xy     -side right
    	pack $w.status.zoom   -side left

    pack $w.zc      -expand 1 -fill both 
    pack $w.status  -side bottom -fill x
		
	 # add pan/scroll capabilities
	bind ZoomCanvas <Button-1> { %W scan mark %x %y }
	bind ZoomCanvas <B1-Motion> { %W scan dragto %x %y 1 }
	
	 # add Zoom by <MouseWheel>
	bind ZoomCanvas <MouseWheel> { %W rzoom %D [%W canvasx %x] [%W canvasy %y] }

	 #
     # bind the <<Zoom>> and <Motion> events with the statusbar ....
	 #	 
    bind $w.zc <<Zoom>> [list apply {
		{zoomLabel value} {
			$zoomLabel configure -text "Zoom: $value"
		}
		} $w.status.zoom %d ]
	 	
	bind $w.zc <Motion> [list __updateXYLabel $w.status.xy $w.zc %x %y]
		 # cannot use a lambda because this code contains "%" characters
		 # that will be inopportunely touched by the bind.
		proc __updateXYLabel {xyLabel zc x y} {
			$xyLabel configure -text \
				[format "(%.2f,%.2f)" [$zc canvasx $x] [$zc canvasy $y]]		
		}
     
	return $w
}

 # create the Full UI
proc UI_Full {w myclock} {
	if { $w eq "." } { set w "" }

	tk::panedwindow $w.pw -orient horizontal
	pack $w.pw -expand 1 -fill both
	
	$w.pw add [UI_ControlPanel $w.panel]    	
	$w.pw add [UI_ZoomCanvasWithStatusBar $w.extendedzc]

	set ZC $w.extendedzc.zc

	UI_ControlPanelLogic .panel $ZC $myclock
	
	# -- 
	$ZC configure -background black
	CreateSolarSystem $ZC

	update ;# required before zoomfit.

	$ZC zoomfit	
	
	$myclock configure -periodiccmd [list updateSolarSystem $ZC]
}




# === control logic =====================================================
# Bind the UI elements to the control logic
# =======================================================================

	 # during the tracking of planets in the GeoCentric animation
	 #  for each tracked planet (plus the Sun) its track is stored as a sequence of points,
	 #  computed and recorded at each 'tick' of the animation (tipically 10 ticks per secs).
	 #
	 #  This sequence should be limited not only for memory space control, but also
	 #  because too long tracks make the whole picture too complex.
	 #  As a thumb rule, we decide to store only the 80% of points tracked in 1 earth-revolution time (TR)
	 #   discarding the old points.
	 #   So, 
	 #    let F be the number of points registered in 1 second -->  1000/(clock's period)
	 #    let S be clock's speed factor (i.e 1 real-second is S apparent-seconds)
	 #     then  0.8*TR/S is the true-duration for (the 80% of) one earth revolution 
	 #     and (0.8*TR/S)*F is the number of points registered for (the 80% of) one earth revolution.
	 #	  Finally we limit this final number to 2000.
	 #
	 #
	 # This proc must be called every time the simulated clock's speed or its tick-period
	 # changes.
	 # - currently in this app, only the speed can be changed; the tick-period is hardcoded and never changes. 
proc suggested_trace_length {myclock} {
	set n [expr {0.8*(3600*24*365.25) / [$myclock cget -speed] * (1000.0/[$myclock cget -period])}]
	set n [expr {round($n)}]
	if {$n>2000} { set n 2000}
	return $n
}

proc UI_ControlPanelLogic {w zcvs myclock} {
	$w.zoomButton configure -command [list $zcvs zoomfit xy]
	
	$w.animation configure -variable ::UI_ANIMATION
	trace add variable ::UI_ANIMATION write [list apply {
		{myclock args} {
			global UI_ANIMATION
		    if { $UI_ANIMATION } {
		        $myclock resume
		    } else {
		        $myclock suspend
		    }
		}
		} $myclock ]
	set ::UI_ANIMATION 0
	
	.panel.showOrbits configure -variable ::UI_SHOWORBITS
	trace add variable ::UI_SHOWORBITS write [list apply {
		{zc args} {
		    global UI_SHOWORBITS
		    set state [expr {$UI_SHOWORBITS ? "normal" : "hidden"}]
	    	$zc itemconfigure ORBIT -state $state
		}
		} $zcvs ] 
	set ::UI_SHOWORBITS 1
	
	 ### .panel.speed
	 ###  set min/max values and bind the slider's value to a custom proc
	 
		# min and max values for the slider ...
	     # be T = 31536548 the duration (in seconds) of one Earth revolution.
		 # then min-speed is set to T/60 (i.e. 1 revolution in 60 secs)
		 #  and max-speed is set to T/1  (i.e. 1 revolution in 1 sec)
	$w.speed configure \
		-from [expr {31536548/60.0}] \
		-to   [expr {31536548/1.0}]
	 	# when the slider's value changes, adjust the speed of myclock
	 	# and the recompute and store MAX_TRACE_LEN within the viewer zc
	$w.speed configure -command [list apply {
		{zc myclock speed} {
			$myclock configure -speed $speed
			
			 # also updated the MAX_TRACE_LEN for the GeoCentric animation
			 set zcDict [$zc cget -userdata]
			 dict set zcDict MAX_TRACE_LEN [suggested_trace_length $myclock] 
			 $zc configure -userdata $zcDict		 
		}  } $zcvs $myclock] 
	$w.speed set [$w.speed cget -from]
	  
	  ## group of radiobuttons .panel.centric
	set ::FOCUS_BODY Sun
	foreach subw [winfo children $w.centric] {
		$subw configure -variable FOCUS_BODY
	}
	
	
	set ::ACTIVE_FOCUS_BODY $::FOCUS_BODY
	trace add variable ::FOCUS_BODY write [list ToggleCentricMode $zcvs $myclock]
	proc ToggleCentricMode {zc myclock args} {
		global ACTIVE_FOCUS_BODY
		global FOCUS_BODY
		
		StopCentricMode $zc $myclock $ACTIVE_FOCUS_BODY
	
		 # == change ACTIVE_FOCUS_BODY
		set ACTIVE_FOCUS_BODY $FOCUS_BODY
	
		# == activate NEW ACTIVE_FOCUS_BODY
		InitCentricMode $zc $myclock $ACTIVE_FOCUS_BODY
	}
	
	
	 ## group of radiobuttons .panel.planet
	set ::TRACKED_PLANET Mercury
	foreach subw [winfo children  $w.planet] {
		$subw configure -variable TRACKED_PLANET
	}
}




## ----------------------------------------------------------------------------

proc InitCentricMode {zc myclock focusPlanet} {
	global PlanetsData
	
	if { $focusPlanet ne "Sun" } {
		# == create (empty) TRACE items (polylines) ..
		
		# -- add the Sun's tracing orbit
		$zc create line 0 0 0 0 -fill gray50 -tags [list TRACE Sun]

    	foreach item $PlanetsData {
	        lassign $item planetName orad prad period theta0 color
			# prepare the orbit TRACE
			if { $planetName ne $focusPlanet } {
				$zc create line 0 0 0 0 -fill $color -tags [list TRACE $planetName]
			}
		}
		$zc itemconfigure TRACE -dash {2 6}
		# --  clear the traces
		$zc dchars TRACE 0 end

		  # just to be sure ...
		 set zcDict [$zc cget -userdata]
		 dict set zcDict MAX_TRACE_LEN [suggested_trace_length $myclock] 
		 $zc configure -userdata $zcDict
	}
}

proc StopCentricMode {zc myclock focusPlanet} {
	if { $focusPlanet ne "Sun" } {
		# destroy all TRACE items
		$zc delete TRACE
	}
}

## ----------------------------------------------------------------------------


 # Warning:
 # planets are drawn at 100x of their real dimension,
 # but even with this augmented size they appear less than one pixel.
 # For this reason, when the planet's disc is too small, a fixed-size icon 
 #  (a small diamond) is drawn. 
proc CreateSolarSystem {zc} {
	global PlanetsData
	global SunData
	
    foreach item [concat [list $SunData] $PlanetsData] {
        lassign $item planetName orad prad period theta0 color

         # draw planet at theta 0
		if { $planetName ne "Sun" } {
			set prad [expr 100.0*$prad] ; #  draw planets 100x
		}
         # planets (even at 100x) are too small; draw also a "point"
        $zc create point 0 0 -foreground $color -tags [list PLANET $planetName CXY]                   
        $zc create oval -$prad -$prad $prad $prad -fill $color -tags [list PLANET $planetName]
        set PXY [list [expr {$orad*cos($theta0)}] [expr {$orad*sin($theta0)}]]
        $zc move "PLANET && $planetName" {*}$PXY

         # draw orbit
		if { $planetName ne "Sun" } {
        	$zc create oval -$orad -$orad $orad $orad -outline gray30 -tags [list ORBIT $planetName]
		}
    }
}
    


proc updateSunCentric {zc t} {
    global PlanetsData
    
    foreach item $PlanetsData {
        lassign $item planetName orad prad period theta0 color

         # new angular pos will be   2PI*t/period + theta0
        set theta [expr {$theta0+2*3.1415*$t/$period}]
        set x [expr {$orad*cos($theta)}]
        set y [expr {$orad*sin($theta)}]
		lassign [$zc coords "PLANET && $planetName && CXY"] x0 y0
        set dx [expr {$x-$x0}] ;
        set dy [expr {$y-$y0}] ;
        $zc move "PLANET && $planetName" $dx $dy
    }
}


 # Short description:
 # update planet positions (as usual calling updateSunCentric)
 # then collimate the new pivotPlanet position with its old position on the screen.
 # In this way the pivotPlanet appears stationary.
 # PLUS: trace the orbits of $tracketPlanet as observed
 #  from the pivotPlanet, showing the apparent reversal of motion (retrograde motion)
  
proc updatePlanetCentric {zc pivotPlanet trackedPlanets t} {
	global SunData
    global PlanetsData
	    
	set pivotPos [$zc coords "PLANET && $pivotPlanet && CXY"] 
    set VXY0 [$zc W2V $pivotPos]
	lassign $pivotPos ppX0 ppY0

	updateSunCentric $zc $t
	 # new pivotPos
	set pivotPos [$zc coords "PLANET && $pivotPlanet && CXY"] 
    $zc overlap {*}$pivotPos {*}$VXY0

	 # move the old traces
	lassign $pivotPos ppX1 ppY1
	$zc move TRACE [expr {$ppX1-$ppX0}] [expr {$ppY1-$ppY0}]

	set zcDict [$zc cget -userdata]
	set MAX_TRACE_LEN [dict get $zcDict MAX_TRACE_LEN]
	set MAX_COORDS [expr {$MAX_TRACE_LEN*2}]
	
	 # trick: add Sun to trackedPlanets
	lappend trackedPlanets "Sun"
	foreach item [concat [list $SunData] $PlanetsData] {
    	lassign $item planetName orad prad period theta0 color
    
    	if { $planetName eq $pivotPlanet } continue
     	 # filter: just 1 or 2 planets tracing
		if { $planetName ni $trackedPlanets } {
			$zc dchars "TRACE && $planetName" 0 end
			continue
		}
		lassign [$zc coords "PLANET && $planetName && CXY"] pX pY 

		set coordCount [llength [$zc coords "TRACE && $planetName"]]
		set excess [expr {$coordCount-$MAX_COORDS}]
		
		if {$excess > 0} {
			$zc dchars "TRACE && $planetName" 0 [expr {$excess-1}]
		}
		$zc insert "TRACE && $planetName" end "$pX $pY"
	}
}  


proc updateSolarSystem {zc t} {
	set t [expr {$t/1000}]   ;# .. quelle sotto voglioni secs non msec ..
	global ACTIVE_FOCUS_BODY
	global TRACKED_PLANET
	
	if { $ACTIVE_FOCUS_BODY eq "Sun" } {
		updateSunCentric $zc $t 
	} else {
		# we could list all the planets as trackePlanets,
		# but this produces a fuzzy/complex picture.
 		# It is recommended to set max two planets
		updatePlanetCentric $zc Earth [list $TRACKED_PLANET] $t 	
	}
}

# ==== START HERE =============================================================

set MYCLOCK [Stopwatch new]

UI_Full . $MYCLOCK

$MYCLOCK suspend
$MYCLOCK configure -period 100
$MYCLOCK reset

set UI_ANIMATION 1
