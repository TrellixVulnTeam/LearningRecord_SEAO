##  zoom-canvas - extended canvas with zoom support
##
## Copyright (c) 2013-2021 <Irrational Numbers> : <aldo.w.buratti@gmail.com> 
##
##
## This library is free software; you can use, modify, and redistribute it
## for any purpose, provided that existing copyright notices are retained
## in all copies and that this notice is included verbatim in any
## distributions.
##
## This software is distributed WITHOUT ANY WARRANTY; without even the
## implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
##


package require Tcl 8.5
package require snit


#
# How to use zoom-canvas:
#   Read "readme.txt" for detailed info.
#   Sample code provided in "demo*.tcl".
#

 # set a default value for -pointbmp option
option add *Canvas.pointbmp  @[file join [file dirname [file normalize [info script]]] point.xbm]    

::snit::widgetadaptor zoom-canvas { 
		# == Summary ==============================
		# A) redefinition of canvas methods/options 
		#   (plus the new 'zoom' method)
		# B) definition of new methods/options
		# =========================================

		# ===========================================
		# ===========================================
		# Section A) redefine canvas methods/options (plus the new 'zoom' method)
		#
		# zoom-canvas is a widget based on the canvas widget.
     	# supporting *all* the options/methods 
		# of the classic canvas-widget,
		#
		#  All the options/methods dealing with coordinates and distances
		#   should be redefined, so that the passed coordinates will be
		#   automatically scaled, and the returned coordinates will be 
		#   inversely scaled.
		#
		# Among all the standard method, the 'create' method will be
		#  extended in order to handle the new 'point' itemtype
		#
		# Added the "zoom" and "overlap" methods
		#  (the core-methods of zoom-canvas)
		# with the -zoommode option
		# ===========================================
		# ===========================================

	typeconstructor {
		 # Fix for x11 platform
        set tkwinsys [tk windowingsystem]
        if { $tkwinsys eq "x11" } {
            bind ZoomCanvas <Button-4> {
                event generate %W <MouseWheel> -x %x -y %y -delta +128
            }
            bind ZoomCanvas <Button-5> {
                event generate %W <MouseWheel> -x %x -y %y -delta -128
            }            
	    }	
	}
	
			
     # variable "my" is an array collecting all object's variables
    variable my -array {}  ; # initialized in constructor

    # NOTE that default values can be externally changed by setting 
    # the "Tk options database" as follows:
    #    option add *Canvas.background  yellow
    #    ...
    # NOTE that a zoom-canvas-widget's class is still "Canvas".
    # In the same way, you can set the "Canvas" options for
    #   background, cursor, .... 

    option -pointbmp ;# WARNING  prefix "@" required if it's a file ..

    delegate option * to hull
    	# the following are the standard options that will be redefined	 
	option -scrollregion -default {} \
		-configuremethod _Cfg_scrollregion		
	option -xscrollincrement -default 0 \
		-configuremethod _Cfg_scrollincrement		
	option -yscrollincrement -default 0 \
		-configuremethod _Cfg_scrollincrement
		
	option -zoommode -default xy \
		-type {snit::enum -values {xy x y}} \
		-configuremethod _Cfg_zoommode

	option -yaxis -default down \
		-type {snit::enum -values {up down}} \
		-configuremethod _Cfg_yaxis \
		-readonly true

	 # Some original methods will be redefined  below;
	 #  for the not-redefined methods, the original method will be used.
    delegate method * to hull

    constructor {args} {
        installhull using canvas                                     
		 # "ZoomCanvas" is a 'pseudo' class used for adding class-bindings to
		 #   zoom-canvas instances
        bindtags $win [linsert [bindtags $win] 1 ZoomCanvas]    
	    set my(zoomX) 1.0
        set my(zoomY) 1.0
        set my(zoom)  1.0
        $self configure -yaxis $options(-yaxis) ;# force the default
        
        $win configurelist $args          
    }

    destructor {} ; # nothing 
    
	 # ------------------------------------------------------------
	 # redefined canvas options (in alphabetical order)
	 # ------------------------------------------------------------

	 # internal note: the true scrollregion will be automatically resized
	 # when the zoom factor changes.
	 # This in turn should resize the internal xyscrollincrement
	method _Cfg_scrollregion {opt value} {
		 # value should be {} or {x0 y0 y1 y1}
		 #  _W2C works in both cases
		set coords [$self _W2C $value]
		# WARNING: the hull-canvas always requires a scrollregion
		#  {x0 y0 x1 y1} having x0<=x1 , y0<=y1.
		# When yaxis is UP, we got y0>=y1, then we need to exchange y
		if { $coords ne {} && $options(-yaxis) eq "up" } {
			lassign $coords x0 y0 x1 y1
			set coords [list $x0 $y1 $x1 $y0]
		}		
		$hull configure -scrollregion $coords
		set options(-scrollregion) $value
		
		# force to resize also the scrollincrement
		$self configure -xscrollincrement $options(-xscrollincrement)
		$self configure -yscrollincrement $options(-yscrollincrement)		
	}

	method _Cfg_scrollincrement {opt value} {
		switch -- $opt {
		  -xscrollincrement {
		  		$hull configure $opt [expr {$value*$my(zoomX)}] 		  
		  }
		  -yscrollincrement { 
		  		 # note that zoomY may be negative (inverted Y)
		  		$hull configure $opt [expr {$value*abs($my(zoomY))}] 
		  }
		}
		set options($opt) $value
	}

	method _Cfg_yaxis {opt value} {
		switch -- $value {
			up { set my(zoomY) [expr {-abs($my(zoomY))}] }
			down { set my(zoomY) [expr {abs($my(zoomY))}] }			
		}
		set options($opt) $value
	}

	method _Cfg_zoommode {opt value} {
		 # before changin the zoommode,
		 # reset the zoom to 1.0
		 # then, reapply the zoom   (with the new mode)
		if { $value ne $options($opt) } {
			set zf [$self zoom]
			$self zoom 1.0
			set options($opt) $value
			$self zoom $zf
		}
	}
	
	 # ------------------------------------------------------------
	 # redefined canvas commands (in alphabetical order)
	 # ------------------------------------------------------------

	 # internal helpers:
	 #	_flatten
	 #  _C2W & _W2C
	 #	_searchSpec
		
    proc flatten {args} {
        if { [llength $args] == 1 } {
           set args {*}$args
        }
        return $args    
    }
    
    method _C2W { coordList } {
        set R {}
        foreach {x y} $coordList {
          set x1 [expr {$x/$my(zoomX)}]
          set y1 [expr {$y/$my(zoomY)}]
          lappend R $x1 $y1
        }
        return $R    
    }

    method _W2C { coordList } {
        set R {}
        foreach {x y} $coordList {
          set x1 [expr {$x*$my(zoomX)}]
          set y1 [expr {$y*$my(zoomY)}]
          lappend R $x1 $y1
        }
        return $R    
    }

	 	
	method _searchSpec {op args} {
		switch -- $op {
		  closest { ;# closest x y ?halo? ?start? 
			lassign $args x y halo start
			lassign [$self _W2C [list $x $y]] x y
			return [list $op $x $y {*}$halo {*}$start]
		  }
		  enclosed -
		  overlapping { ;# enclosed|overlapping x1 y1 x2 y2 
			lassign [$self _W2C $args] x1 y1 x2 y2
			return [list $op $x1 $y1 $x2 $y2]		  		
		  }
		default {
			return [list $op {*}$args]
		 }
		} 
	}

	 
	method addtag {tag searchOp args} {
		$hull addtag $tag {*}[$self _searchSpec $searchOp {*}$args]
	}

	 # WARNING:
	 # since the tk-core "bbox" method is rather imprecise
	 # (see the canvas manual: ...
	 # ... The return value may overestimate the actual bounding box by a few pixels
	 # ) 
	 #  then this zoomed bbox method may return this error amplified
	 #  by (the inverse of) the zoom factor.
	 #  Therefore, as for the standard bbox method, NEVER consider this 
	 # overriden bbox method as a reliable measure.
	 # TODO:
	 #  if the core-bbox error is E, then this overriden-bbox error is E/z
	 #  (z is the zoom factor) 
	method bbox {tagOrId args} {
		 # WARNING bbox should always return {x0 y0  x1 y1}  ) or {}
		 #  with x0<=x1 and y0<=y1.
		 # When the yaxis is "up" we got y1<=y0, thus we must exchange them
		set bbox [$self _C2W [$hull bbox $tagOrId {*}$args]]
		if { $bbox ne {}  &&  $options(-yaxis) eq "up" } {
			lassign $bbox x0 y0 x1 y1
			set bbox [list $x0 $y1 $x1 $y0]
		}
		return $bbox
	}

	method canvasx {Vx} {
		return [expr {[$hull canvasx $Vx]/($my(zoomX))}]
	}
	method canvasy {Vy} {
		return [expr {[$hull canvasy $Vy]/($my(zoomY))}]
	}

	 # WARNING:
	 #  if yaxis is up  (inverted), then just for rectangle and oval items
	 #  this command return the coordinates of two diagonally opposite corners
	 #  of the rectangle/oval (as usual) but these are the top-left and the bottom-right
	 #  corners ,instead of the 'classic' bottom-left and top-right corners.
	method coords {tagOrId args} {
		if {$args == {}} {
			 # get the coords
			set coordList [$self _C2W [$hull coords $tagOrId]]
			 # WARNING: the hull-canvas always stores coords for rectangle/oval
			 #  with a normalized order {x0 y0  x1 y1} so that
			 #     x0<=x1 and y0<=y1.
			 # When the yaxis is "up", the _C2W transformation gives y1<=y0,
			 #  thus we must exchange them
			if { $options(-yaxis) eq "up" &&  [$hull type $tagOrId] in {rectangle oval} } {
				lassign $coordList x0 y0 x1 y1
				set coordList [list $x0 $y1 $x1 $y0]
			} 
			return $coordList
		} 		
		 # else .. set the coords
		set coordList [flatten {*}$args]
		$hull coords $tagOrId [$self _W2C $coordList]
	}

	 # convert the coords for all the item-types
	 # PLUS add the new "point" item-type
    method create {itemtype args} {
        if { $itemtype == "point" } {
			 # a "point" will be created as a "bitmap" item-type.
			 
             # if esists, extract and remove -bitmap xxx from $args
            set idx [lsearch -exact $args -bitmap]
            if { $idx != -1 } {
                set bmp [lindex $args ${idx}+1]
                set args [lreplace $args $idx ${idx}+1]
            } else {
            	set bmp  $options(-pointbmp) ;# default bitmap			
			}
            set itemID [$hull create bitmap {*}$args -bitmap $bmp]
        } else {
            set itemID [$hull create $itemtype {*}$args]
        }
        $hull scale $itemID 0.0 0.0 $my(zoomX) $my(zoomY)
		return $itemID
    }

	 # see notes for the rchars method below
	method insert {tagOrId beforeThis string} {
		 # precompute once (ignore error)
		set coordList $string
		catch {set coordList [$self _W2C $coordList]}
		foreach item [$hull find withtag $tagOrId] {
			if { [$hull type $item] in {line polygon} } {
				$hull insert $item $beforeThis $coordList
			} else {
				$hull insert $item $beforeThis $string					
			}
		}
	}
	
	method find {searchOp args} {
		$hull find {*}[$self _searchSpec $searchOp {*}$args]
	}
	
	method imove {tagOrId index x y} {
		$hull imvove $tagOrId $index {*}[$self _W2C [list $x $y]]	
	}
	
	method move {tagOrId dx dy} {
		$hull move $tagOrId {*}[$self _W2C [list $dx $dy]]
	}    

	method moveto {tagOrId x y} {
		if { $options(-yaxis) eq "up" } {
			# moveto should move the bottom-left corner of the bbox to x y.
			# When the yaxis is UP  bottom and top are swapped
			# so if we want to move the (World) bottom-left corner Y0 to (x,y),
			# we should actually move the top-left corner Y1 to (x,y+(Y1-Y0))

			set bbox [$self bbox $tagOrId]
			if { $bbox eq {} } return ;# nothing to move
			lassign $bbox  X0 Y0 X1 Y1
			set y [expr {$y+($Y1-$Y0)}]			
		} 
		$hull moveto $tagOrId {*}[$self _W2C [list $x $y]]
	}    

# this is an alternative for *exact* moveto.
# It also works for yaxis UP and for rectangle,oval, ...
#  thanks to the 'inversion' operated by [$self coords ...]
# It works! but it's not fully compatible with the standard (and wrong) behaviour
#   of the standard 'moveto'
	method alt_moveto {tagOrId x y} {
		set coordList [$self coords $tagOrId]
		if { $coordList ne {} } {
			lassign $coordList x0 y0
			$self move $tagOrId [expr {$x-$x0}] [expr {$y-$y0}]
		}
	}

	 # From the 'canvas' man page:
	 #This command causes the text or coordinates between first and last for
	 # each of the items indicated by tagOrId to be replaced by string.
	 # Each item interprets first and last independently according to the
	 # rules described in INDICES above.
	 # Out of the standard set of items, text items support this operation 
	 # by altering their text as directed, 
	 # and line and polygon items support this operation by altering 
	 # their coordinate list 
	 # (in which case string should be a list of coordinates to use as a replacement).
	 # The other items ignore this operation. 
	 #
	method rchars {tagOrId first last string} {
		 # precompute once (ignore error)
		set coordList $string
		catch {set coordList [$self _W2C $coordList]}
		foreach item [$hull find withtag $tagOrId] {
			if { [$hull type $item] in {line polygon} } {
				$hull rchars $item $first $last $coordList
			} else {
				$hull rchars $item $first $last $string					
			}
		}
	} 

	method scale {tagOrId xOrigin yOrigin xScale yScale} {
		set Origin [$self _W2C [list $xOrigin $yOrigin]]
		$hull scale $tagOrId {*}$Origin $xScale $yScale
	}

	 # method "scan":
	 # no need to redefine this method since it works on viewport coords (integers)
	 # , not on World-coords.

	 # method "xview", "yview":
	 # no need to redefine them provided that the 'internal' x/yscrollincrement
	 # options are updated when the zoom factor is changed.


      # Absolute zoom
	  # **this is the core method of zoom-canvas**
      #   f : (0 ...INF) - scale factor
      #   (Wx Wy)   is the pivot of zooming  (in World coords)
      #   (if not specified, it's the point related to center of viewport)
 	  #  if scale factor $f is 0 (or very close to 0) no zoom is performed
	  #
 	  #  When this method completes, it generates a virtual event <<Zoom>>
	  #  for the purposes of notification, carrying the actual zoom factor as user data.
	  #  Binding scripts can access this user data as the value of the %d substitution.
    method zoom {{f {}} {Wx {}} {Wy {}}} {
        if { $f == {} } {
            return $my(zoom)
        }
    	 # zoom factor $f may even be negative (axis direction will be inverted!)
    	 # but it cannot be 0 (or very close to 0) because this will
    	 # collapse all point to (0,0) and then we won't be able to
    	 # zoom-back  ( ... black-hole effect)
        if { abs($f) < 1e-9 } {
			return;   # don't raise an error; simply do nothing."
		}
        if { $Wx == {} || $Wy == {} } {
        	 # find the world-point related to the center of the viewport
			set dVx [winfo width  $win]
        	set dVy [winfo height $win]
        	set Wx [$win canvasx [expr {$dVx/2.0}]]
        	set Wy [$win canvasy [expr {$dVy/2.0}]]
        }
        
        # (px,px) is the screen-point related to (Wx,Wy) before zooming
        lassign [$win W2V $Wx $Wy] px py
        
        set f [expr {double($f)}]        
        set A [expr {$f/$my(zoom)}]
        
        switch -- $options(-zoommode) {
			xy {
				set Ax $A
				set Ay $A
			}
			x {
				set Ax $A
				set Ay 1.0
			}
			y {
				set Ax 1.0
				set Ay $A
			}
		}
        $hull scale all 0 0 $Ax $Ay

        set my(zoom) $f
		set my(zoomX) [expr {$Ax*$my(zoomX)}]
		set my(zoomY) [expr {$Ay*$my(zoomY)}]
		        
        # collimate points ...
        $self overlap $Wx $Wy  $px $py
        
        # finally, resize the scrollregion (this will resize the  *scrollincrement)
		$self configure -scrollregion $options(-scrollregion)		
		
        event generate $win <<Zoom>> -data $my(zoom)           
    }


     # Collimate World-Point (Wx,Wy) with Viewport-Point (Vx,Vy)
	 # (Viewport coordinates must be integers).
     # Items don't change their intrinsic coordinates; it's only a viewport
	 #  scrolling.
	 # NOTE:
	 # as for 'standard' canvas, if you set a scrollregion and the -confine
	 #  option is 1 (default), then the viewport is 'confined' within the scrollregion.	 
    method overlap {Wx Wy Vx Vy} {
		 # WARNING
		 # It would be easier but ..
		 # DON'T use scan-mark/scan-dragto because you could invalidate what the user 
		 # had set as scan-mark         
		 #$hull scan mark $Vox $Voy
		 #$hull scan dragto $Vx $Vy 1

        lassign [$win W2V $Wx $Wy] Vox Voy ; # already rounded to integers

		set xincr [$hull cget -xscrollincrement]
		set yincr [$hull cget -yscrollincrement]
		
		$hull configure -xscrollincrement 1.0
		$hull configure -yscrollincrement 1.0
				
 		$hull xview scroll [expr {$Vox-round($Vx)}]  units              
	 	$hull yview scroll [expr {$Voy-round($Vy)}]  units

		$hull configure -xscrollincrement $xincr
		$hull configure -yscrollincrement $yincr
    }


		# ===========================================
		# ===========================================
		# Section B) add some new methods/options
		#
		# option -userdata
		# method rzoom (with the option -zmultiplier)
		# method zoomfit
		# method canvasxy
		# ===========================================
		# ===========================================

    option -userdata -default {}  ; # can contain anything ... 
    option -zmultiplier -type {snit::double -min 1.0} -default 1.4142135623730951

     # relative zoom
     #  df : currently only its sign is meaningful
     #    if positive then the current zoom will be multiplied by the value of
     #    the -zmultiplier option; if negatve it will be divided by that value.
	 #    If df is 0, no zoom is performed
     #   (Wx Wy)   is the pivot of zooming  (in World coords)
     #   (if not specified, the point related to the center of viewport is used)
    method rzoom { df {Wx {}} {Wy {}} } {
         # do nothing if $df is zero
        if { $df == 0.0 } return
                 
        set z $my(zoom)        
        if { $df > 0 } {
            set f [expr {$z*$options(-zmultiplier)}]
        } else {
            set f [expr {$z/double($options(-zmultiplier))}]
        }
        $win zoom $f $Wx $Wy
    } 

     # Set the best zoom and center the worldArea in the viewport.
     # what:
     #   x - best width
     #   y - best height
     #  xy - best fit (default)
     # worldArea:
     #  list of 4 World-Coords
     #  (default is the the bounding-box of all items)
    method zoomfit {{what xy} {worldArea {}}} {
		if { $worldArea ne {} } {
			if { [llength $worldArea] != 4 } {
				error "if specified, a worldArea should be made of 4 numbers"
			}
			foreach x $worldArea {
				if { $x == ""  ||  ![string is double $x] } {
					error "invalid coordinate \"$x\""
				}
			}
		}
		         
         # compute bbox (in World-Coords).
        if { $worldArea eq {} } {
            set worldArea [$win bbox all]
             # if bbox is empty,then set a dummy -1 -1 1 1 bbox,
             # so that origin will appear at the viewport center
            if { $worldArea == {} } {
                set worldArea {-1.0 -1.0 1.0 1.0}
            }
        }
        lassign $worldArea Wx0 Wy0 Wx1 Wy1

        set dWX [expr {double(abs($Wx1-$Wx0))}]
        set dWY [expr {double(abs($Wy1-$Wy0))}]

        set dVX [winfo width $win]
        set dVY [winfo height $win]
        set b [expr {[$hull cget -border]+[$hull cget -highlightthickness]}]
		 # note that if b>0, then the first 'visible point' at the top-left corner
		 #  is (b,b) - i.e. point (0,0) is covered by the border ...
		
		# center of the viewport
		set VMx [expr {$dVX/2.0}]
		set VMy [expr {$dVY/2.0}]

		 # We choose to map the worldArea not to the viewport (0 0 Vx Vy)
		 # but to the 'restricted' viewport (b b Vx-b Vy-b) 

		 # restrict the viewport 
		set dVX [expr {$dVX-2*$b}]
		set dVY [expr {$dVY-2*$b}]
        
        switch -- $what {
          x {
            set ratio [expr {$dVX/$dWX}]
          }
          y {
            set ratio [expr {$dVY/$dWY}]
          }
          xy {
            set ratio [expr min($dVX/$dWX,$dVY/$dWY)]
          }
          default {
		  	error "tag should be; x, y or xy"
		  }
        }
		    
		 # zoom on the center of the worldArea, so that it remains fixed
		 # then collimate this point to the center of the viewport
		set WMx [expr {($Wx0+$Wx1)/2.0}]		
		set WMy [expr {($Wy0+$Wy1)/2.0}]
		$win zoom $ratio $WMx $WMy
		$win overlap $WMx $WMy $VMx $VMy				
    }    

	 # this is a convenience method for getting the the {wx wy} point
	 #  corresponding to the point P on the viewport.
	method canvasxy {P} {
		if { [llength $P] != 2 } {
			error "required a Point as a list of two numbers"
		}
		lassign $P px py 
		list [$self canvasx $px] [$self canvasy $py] ;# on error, let it be!
	}

    # -- helpers --------------------------------------------------------------

	# W2V x y ?x y ...?
	# converts a sequence of x y coords (expressed as WorldCoords)
	# in a list of coords as ViewportCoords.
	# This may be useful for finding if WorldCoord point is within
	# the Viewport (i.e. the canvas visibile areaa).
	# Just test if the returned x is between 0 and [winfo width .c]
	#  and the returned y is between 0 and [winfo height .c]
    method W2V {args} {
        if { [catch { $win _W2V [flatten {*}$args] } res] } {
            error "malformed coordList: must be a sequence of x y ... or a list of x y .."
        }
        return $res    
    }

    method _W2V {L} {
        set R {}
        foreach {Wx Wy} $L {
            set x1 [expr {round($Wx*$my(zoomX) - [$hull canvasx 0])}]
            set y1 [expr {round($Wy*$my(zoomY) - [$hull canvasy 0])}]
            lappend R $x1 $y1
        }            
        return $R
    }
     
	# ===========================================
	# ===========================================
	# Builtin binding have been removed
	#  because they may interfere with other application bindings.
	#  Anyway you may easily redefine them; just
	#   be sure to avoid conflicts with your app's bindings
	# ===========================================
	# ===========================================

if 0 {

	In general, it is recommended to add bindings to the 
	'pseudo' class "ZoomCanvas".

	
	******************
	*** Pan/scroll ***
	******************
	bind ZoomCanvas <Button-1> { %W scan mark %x %y }
	bind ZoomCanvas <B1-Motion> { %W scan dragto %x %y 1 }
	* If your app is alreading using <Button-1> and <B1-Motion> on Canvas,
	* consider using alternatives mouse-bindings like
	* <Control-Button-1> <Control-B1-Motion>
    * or ...  use the scrollbars ! (scrollbars are old-fashioned)

	** IMPORTANT NOTE on scrolling the viewport (panning):
	If no scrollregion is set, then you could move the viewport
	with no limits. 
	If you want to limit the scrolling, you should set the scrollregion
	AND be sure the -confine option is set to 1 (this is the default)
	Example:
	 .zc configure -scrollregion [.zx bbox all]  
	

	******************************
	*** Zoom with <MouseWheel> ***
	******************************

	 # Note: zoom is centered on the cursor position
	bind ZoomCanvas <MouseWheel> { %W rzoom %D [%W canvasx %x] [%W canvasy %y] }

	 # WARNING - COMPATIBILITY:
	 <MouseWheel> on MacOS prior to 8.6.10 had bugs.
     (see http://sourceforge.net/tracker/?func=detail&aid=3609839&group_id=12997&atid=112997) 
	 <MousWheele> on Win32 prior to 8.6.0  had bugs.
	 ( event was delivered to the window with focus, instead to the window under the cursor )
} ;# end of comments

}
