## BContour : Bezier Contour
##   a BContour is a sequences of connected Bezier curves
##  (note: a BContour is not necessarily a closed contour)
##
## Copyright (c) 2013-2020 <Irrational Numbers> : <aldo.w.buratti@gmail.com> 
##
##
## This library is free software; you can use, modify, and redistribute it
## for any purpose, provided that existing copyright notices are retained
## in all copies and that this notice is included verbatim in any
## distributions.
##
## This software is distributed WITHOUT ANY WARRANTY; without even the
## implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

package require Itcl
package require Bezier


itcl::class BContour {

    # --- class variables ----------------------------------------------------
    public common Default
     # tolerance (absolute error) for the estimated length.
     #  it's the absolute acceptable error
    set Default(-tolerance) 0.5

    # --- standard new/destroy -----------------------------------------------    

    proc new {args} {
        set class [namespace current]
         # object should be created in caller's namespace,
         # and fully qualified name should be returned
        uplevel 1 namespace which \[$class #auto $args\]                
    }

    method destroy {} {
        itcl::delete object $this
    }
         
     # -- instance variables and constructor ----------------------------------
         
    protected variable my ; # collection (associative array) of object variables
     # my(spaceDim)  :: dimension of a point (all points have the same dimension)
       # don't confuse curve degree (linear, quadratic, cubic, ..)
       # with space dimension (1D, 2D, 3D, ...)
     # my(strokes)   :: list of (joined) Bezier curves
     # my(cached_length) :: total length
     # my(cached_C1groups) :: groups of contiguos stokes having C1-coninuity
     
    constructor { startPoint } {
        if { ! [Bezier::P.dim $startPoint] } {
            error "\"$startPoint\" is not a point"
        }
        set my(lastPoint) $startPoint
        set my(spaceDim) [llength $startPoint]
        set my(strokes) {}
        set my(cached_length) -1.0
        set my(cached_tolerance) 1e9 ;# no tolerance
        set my(cached_C1groups) {}
        set my(flatnesstolerance) 0.5 ;#  dummy value; flatnesstolearnce is simply ignored.
    }

    destructor {
        foreach stroke $my(strokes) {
            $stroke destroy
        }
    }   

     # a BContour is built by repeatedly appending control-points of Bezier curves (*),
     # (*) NOTE that since the first point of a control-polygon should be
     #     equal to the last point of previous control-polygon, then
     #     THE FIRST POINT OF EACH CONTROL-POLYGON *MUST NOT* BE SPECIFIED.
     # The number of points passed determines the Bezier's curve degree.
     # All points of a BContour must have the same dimension 
     #   ( e.g.  all 2d, all 3d, ... )
    public method append {args} {
         # put $args in 'canonical form' : a list of points
         # - note: checks on $args contents will be done when calling Bezier::new
        if { [llength $args] == 1 } {
        	if { [Bezier::P.dim {*}$args] == 0 } {
        		set args {*}$args
        	}
        }
         # now args is a list of points ;
         # prepend the lastPoint
        set args [linsert $args 0 $my(lastPoint) ]
    
        set stroke [Bezier::new {*}$args]
        if { [$stroke spaceDim] != $my(spaceDim) } {
            $stroke destroy
            error "points of this stroke have dimension different from other countour's points"
        }

        lappend my(strokes) $stroke
        set my(lastPoint) [lindex $args end]        

         # invalidate cache
        set my(cached_length) -1.0
        set my(cached_C1groups) {}
    }

     # NOTE: DEPRECATED method. flatnesstolerance is now useless
     # get/set my(flatnesstolerance)
    public method flatnesstolerance { args } {
        switch -- [llength $args] {
          0 { ## GET ##
                return $my(flatnesstolerance)
          }
          1 { ## SET ##
                set val $args
                if { ! [string is double $val] } {
                    error "Bad FlatnessTolerance \"$val\""
                }
                set my(flatnesstolerance) $val                
          }
          default { error "Bad FlatnessTolerance \"$val\"" }
        }
    }

    public method strokes {} { return $my(strokes) }
    public method stroke {i} { lindex $my(strokes) $i }

     # is the contour closed ?
     # returns true iff the last and the first points are EQUAL
     # Note that a stroke degenerated in a point
     #  ( e.g a quad with all control point equals)
     # is considered 'closed'
    public method isclosed {} {
         # first point of the first stroke
         # be careful; Contour may be empty
        set S0 [$this stroke 0]
        if { $S0 eq {} } { return false }
        set A [lindex [$S0 points] 0]
         # last point of the last stroke
        set B [lindex [[$this stroke end] points] end]
        foreach a $A b $B {
            if { $a != $b } { return false }
        }
        return true            
    }

    private proc _parseOptions {validOptionsAndDefaults args} {
         # init opt() with defaults
        set validOptions {}
        foreach {key default} $validOptionsAndDefaults {
            dict set optDict $key $default
            lappend validOptions $key
        }
        while { $args ne "" } {
            set args [lassign $args key]
            if { $key ni $validOptions } {
                error "bad option \"$key\". Valid options are: [join $validOptions ", "]"
            }
            if { $args eq "" } {
                error "Missing value after option \"$key\""
            }
            set args [lassign $args value]
            dict set optDict $key $value
        }
        return $optDict
    }
    

    public method length {args} {
        set optDict [_parseOptions \
            [list -tolerance $Default(-tolerance)] \
            {*}$args]
        set tolerance [dict get $optDict -tolerance]
        if { $tolerance eq "" ||  ! [string is double $tolerance] || $tolerance < 1e-9 } {
            error "Wrong value for \"-tolerance\".  Must be >= +1.e-9"
        }
        
         # Should I use the "Standard error of the mean" to enlarge the 
         #  tolerance of the strokes (i.e. the standard error of the strokes) ?
         # stroke.stolerance = mean.tolerance * sqrt(N)
         #  where N is the number of strokes ???
         # just an idea ....
         
        if { $my(cached_length) <= 0.0 || $tolerance < $my(cached_tolerance)} {
            set my(cached_length) 0.0
            foreach stroke $my(strokes) {
                set my(cached_length) \
                    [expr {$my(cached_length)+[$stroke length -tolerance $tolerance]}]
            }
            set my(cached_tolerance) $tolerance
        }
        return $my(cached_length)
    }

     # true iff  i-th Stroke and next stroke are C1 (prime derivate  collinear)
     # NOTE: C1-continuity presumes C0 continuity
     # NOTE: index i1 should be numeric (not end end-1 ...)
    public method isContinuityC1 {i1} {
        set s1 [lindex $my(strokes) $i1]
        if { $s1 == {} } { return false }

        set i2 [expr {$i1+1}]
        if { $i2 == [llength $my(strokes)] } {
            # next stroke is the 0-th.
            # before checking C1-continuity,
            # we must check if the contour extremes coincide.
            # i.e if contour is closed
            if { ! [ $this isclosed] } { return false }
            set i2 0
             # degenerate case: just a single stroke ?
             # not a problem, check if end pointsare C1...
        }
                
        set s2 [lindex $my(strokes) $i2]
        if { $s2 == {} } { return false }
        set TA [$s1 tangent_at 1.0]
        set TB [$s2 tangent_at 0.0]
        
         # since TA and TB have length == 1,
         # cos(theta) = TA * TB (dot-product)
         # Therefore if they are equal (or between-angle is near 0),
         # cos(theta) should be near 1 
		 #   i.e  abs(cos(theta)-1.0) < 0.01
         #   or equivalently ( since cos(theta) is always <=1 ....)
         #   cos(theta) > 1-0.01
        set dotp 0.0
        foreach a $TA b $TB {
            set dotp [expr {$dotp+$a*$b}]
        }
        expr {$dotp>0.99 ? true : false}
    }


     # aggregates adjacents strokes having continuityC1.
     # return a list of groups of strokes
    private method _C1groups {} {
        if { $my(cached_C1groups) == {} } {           
            set groups {}
            set sIdx 0 ;# stroke index
            set nOfStrokes [llength $my(strokes)]
            while { $sIdx < $nOfStrokes } {
                set stroke [lindex $my(strokes) $sIdx]
                set gStrokes $stroke ; # (start of) group of strokes
                while {$sIdx < $nOfStrokes-1 && [$this isContinuityC1 $sIdx]} {
                    incr sIdx                
                    set stroke [lindex $my(strokes) $sIdx]
                    lappend gStrokes $stroke
                }
                lappend groups $gStrokes            
                incr sIdx
            }
             # since my(strokes) MAY form a closed contour, 
             # try to join first and last group
            if { [llength $groups] > 1 } {
                 #  check last stroke continuity
                if { [$this isContinuityC1 [expr $nOfStrokes-1]] } {
                    # remove first group and append it to the last group
                    # NOTE: it would works even if groups is made of just 1 group
                    # but here we are under the condittion [llength $groups]> 1
                    set groups [lassign $groups g0]
                    set gN [lindex $groups end]
                    lset groups end [list {*}$gN {*}$g0] 
                } 
            }
            set my(cached_C1groups) $groups
        }
        return $my(cached_C1groups)
    }


    # split all contiguos strokes in a C1-group.
    # Note that the initial segment-length dL is internally 'rounded', so that
    # it divides the C1-groups in N parts of length dL*
    # NOTE that the last t=1 is NOT returned.
    #
    # results is a list of
    #   strokeObj t-list  strokeObj t-list ....
    private method _gSplitUniform { strokes dL tolerance } {

         # read the above comment in the "length" method section,
         #  about the opportunity to enlarge the tolerance for the singlestroke
         # without compromising the overall rolerance ...
         #  ... to do some day ...
        set len 0.0
        foreach stroke $strokes {
            set len [expr {$len + [$stroke length -tolerance $tolerance]}]                        
        }
         # thumb-rule: change dL so that fits ...
         # TODO : this thumbrule should be enabled/disabled through a flag ..
        set n [expr {round($len/$dL)}]  ;#  ceil ??
        if { $n == 0 } { set n 1 }
        set dL [expr {$len/$n}]
        set res {}
        set pLen 0.0        
        foreach stroke $strokes {
            lappend res $stroke [$stroke t_splitUniform $dL $pLen -tolerance $tolerance]
            set leftOver [$stroke splitLeftOver]
            set pLen [expr {$dL-$leftOver}]
        }

        # NOTE: Given the current method of rearranging pLen, the curve 
        # (or better, the C1-group) is always splitted exactly in n parts), then
        # the last t is always 1.0 (or pretty close).
        
         # check last t-list; if last t is approx 1.0, then remove it
         # (since first t=0 of next C1group will denote the same point.)
        set tlist [lindex $res end]
        if { $tlist != {}  &&  (1.0-[lindex $tlist end]) < 0.0001 } {
            lset res end [lreplace $tlist end end]
        }        
        return $res  
    }


    # split the whole contour in sub-curves each having a curve-length of (about) dL.
    # Note that the initial dL is internally 'rounded', so that
    # it divides each sequence of curves with C1-continuity in N parts of length dL*
    # NOTE that the last t=1 is NOT returned.
    #
    # For methods at,tangent_at,normal_at, result is a list of points
    #   and the last point is NOT returned
    # For methods vtangent_at,vnormal_at, result is a list of segments (pairs of points),
    #  each of lenght dL/2
    
    public method onUniformDistance { dL method args } {
        set optDict [_parseOptions \
            [list -tolerance $Default(-tolerance)] \
            {*}$args]
        set tolerance [dict get $optDict -tolerance]
        if { $tolerance eq "" ||  ! [string is double $tolerance] || $tolerance < 1e-9 } {
            error "Wrong value for \"-tolerance\".  Must be >= +1.e-9"
        }
        set validMethods {at tangent_at normal_at vtangent_at vnormal_at}
        if { $method ni $validMethods } {
            error "invalid method \"$method\". It should be one of [join $validMethods ,]"
        }
        set tmethod $method
        if { $tmethod in {vtangent_at vnormal_at} } {
            lappend tmethod [expr $dL/2.0]
        }
        set res {}
        foreach C1group [$this _C1groups] {
            foreach {stroke tlist} [$this _gSplitUniform $C1group $dL $tolerance] {
                foreach t $tlist {
                    lappend res [$stroke {*}$tmethod $t]
                }
            }
            if { $method in {tangent_at normal_at vtangent_at vnormal_at} } {
                 # add value at the end of C1group
                lappend res [$stroke {*}$tmethod 1.0]
            }
        }
        return $res
    }    
}
