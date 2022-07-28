## Bezier - Bezier's curves.
##
## References:
##  All math stuff from   en.wikipedia.org/wiki/Bezier_curve
##  "length" algorhythm by J.Gravesen
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


#
# LIMITATIONS
# * Only curves up to degree 10 (just a practical limit)
# * "normal_at" and "vnormal_at"  are meaningful only for 2D curves (spaceDim ==2);
#   for curves having dimension <> 2 result is unpredictable.

# CHANGES: internal code refactoring due to Itcl 4.0b incompatibility
#  (Itcl 4.0b does not support common variables complex initialization)
# 1.1  * Improved the accuracy and speed for computing "length".
#      *  Method flatnesstolerance is now DEPRECATED. 
#         Use option -length.tolerance or -flatness.tolerance
#      * Added guards for extreme cases 
#         - curves degenerating in a single point
#         - splitUniform with steps <=0 are now blocked    

package require Itcl

 # Bezier::new
 # Facility for object creation;
 # The generic Bezier class or one of its subclasses Bezier_0, Bezier_1 is automatically
 # selected, based on number of points passed at creation time.
 # Note: Class Bezier can represent curves of any degree, but Bezier_0/Bezier_1
 #  are specialized class for 0/1 degree curves with optimized methods.
 #
 # NOTE: a Point is represented as a list of real-numbers
 #
 #  Usage:
 #   set c1 [Bezier::new {1 2} {3 4} ... ]
 #  or (equivalent)
 #   set c1 [Bezier::new {{1 2} {3 4} ...}]
 #

            

# =============================================================================

itcl::class Bezier {
    # --- class variables ----------------------------------------------------
    public common Default
     # tolerance (absolute error) for the estimated length.
     #   if positive it's the absolute acceptable error
     #   if negative, its abs(value) is the relative error (relative to the curve length)
    set Default(-length.tolerance) 0.001
     # tolerance (abolute error) for the flatness test.
     #  a curve (or some of its parts) will be flattened if all its
     #  points (control points) have a distance from the chord less then this value
     # Note that for drawing a curve a tolerance of 0.5 (pixel) means that
     #  all its points must be less than 0.5 far from the chord.
    set Default(-flatness.tolerance) 0.25

    # --- standard new/destroy -----------------------------------------------    

     # * This is a special "standard" method, 
     #   since args may assume different forms, 
     #   and also best sub-class is automatically selected.
    proc new {args} {
        set args [canonicalForm {*}$args]
        
        set degree [expr {[llength $args]-1}]
        switch -- $degree {
            0 { set class Bezier_0 }
            1 { set class Bezier_1 }
            default { set class Bezier }
        }
         # object should be created in caller's namespace,
         # and fully qualified name should be returned
        uplevel 1 namespace which \[$class #auto $args\]                
    }

    method destroy {} {
        itcl::delete object $this
    }

     # given a point P represented as list of real-numbers
     # returns the dimension of P (an integer > 0)
     # or 0 if P elements are not real-numbers
    public proc P.dim {P} {
    	set n [llength $P]
    	foreach c $P {
    		if { $c == {}  ||  ![string is double $c]} { return 0 }
    	}
    	return $n
    }
    
    
     # Convert 
     #   a sequence of 1 or more Points
     #   or
     #   a list of 1 or more Points
     #  in a list of 1 or more points
     #  (An error is raised if elements are not Points 
     #   or if points have different dimensions)
     #
     # canonicalForm {{1 2 3} {4 5 6}} --> {{1 2 3} {4 5 6}}
     # canonicalForm  {1 2} {3 4}      --> {{1 2} {3 4}}
     # canonicalForm {{1 2}}           --> {{1 2}}
     # canonicalForm  {1 2}            --> {{1 2}}
     # canonicalForm  1 2 3 4          --> {1 2 3 4}    (a list of 4 1-d points)
     # canonicalForm  {1 2 3 4}        --> {{1 2 3 4}}  (a list of 1 4-d points)
     # canonicalForm {{1 2 3 4}}       --> {{1 2 3 4}}  (a list of 1 4-d points) 
     # canonicalForm  {}               --> error: no Points
     # canonicalForm                   --> error: no Points
     # canonicalForm  {{}}             --> error: not a Point ""
     # canonicalForm {{1 2 3} {4 5}}   --> error: Dimension of point "4 5" is 
     #                                            different from dimension of 
     #                                            previous points     
    private proc canonicalForm {args} {
    	if { [llength $args] == 1 } {
    		if { [P.dim {*}$args] == 0 } {
    			set args {*}$args
    		}
    	}
    
    	 # now args *might be* a list of Points;
    	 # let's check if list elements are Points
    	 # and all with the same space-dim
    	set nextPoints [lassign $args P]
    	set N [P.dim $P]
    	if { $N == 0 } {
    			error "Malformed Points: \"$P\" is not a Point"
    	}               
    	foreach P $nextPoints {
    		set n [P.dim $P]
    		if { $n == 0 } {
    			error "Malformed Points: \"$P\" is not a Point"
    		}
    		if { $n != $N } {
    			error "Dimension of point \"$P\" different from dimension of previous points"
    		} 
    	}
		return $args
    }

    # --- precomputed tables ... ---------------------------------------------
    public common BinomialTriangle {} ;# pre-computed binomial coefficients

    # BinomialTriangle will be precomputed once when module will be loaded.
    
     # Build the binomial series (n 0) (n 1) ... (n n)
     # NOTE: Thanks to bignum support [binomial $n] can handle very large $n (..10000)
     # without less of precision. Of course in this context a curve of degree 10
     # (requiring [binomial 10]) is a high complexity curve.
    private proc binomial {n} {
        set nk 1
        lappend L $nk
        for {set k 1} {$k<=$n} {incr k} {
            set nk [expr {$nk*($n+1-$k)/$k}]
            lappend L $nk
        }
        return $L
    }
        
    proc binomialTriangle {N} {
        set T {}
        for { set n 0 } { $n < $N } { incr n } {
            lappend T [binomial $n]    
        }
        return $T
    }

     # Bernstein basis polynomials
     # :: coefficients of the curve parametric function.
     # [Bbp $n $t] returns all the (n+1) Bbp of degree n evaluated at $t
    private proc Bbp { n t } {
         # precompute powers of (1-t)**i
        set {1-t} [expr {1-$t}]
        set {1-T} 1.0   ;#  (1-t)**0
        set {L_1-T} {}
        lappend {L_1-T} ${1-T}
        for {set i 1} {$i<=$n} {incr i} {
            set {1-T} [expr {${1-T}*${1-t}}]
            lappend {L_1-T} ${1-T}
        }
        set {L_1-T} [lreverse ${L_1-T}]
        
        set L {}
        set Ti  1.0  ;#  t**0
        foreach b [lindex $BinomialTriangle $n] {1-T} ${L_1-T} {
            lappend L [expr {$b*${1-T}*$Ti}]
            set Ti [expr {$Ti*$t}]
        }
        return $L
    }

     
     # -- instance variables and constructor ----------------------------------
         
    protected variable my ; # collection (associative array) of object variables
     # my(cPoints)   :: control-polygon points {x0 y0} {x1 y1} ...
     # my(degree)    :: degree of curve
     # my(spaceDim)  :: dimension of a point (all points have the same dimension)
     # my(LenTable)  :: inverse-length table built during the length computation
     # my(derivative):: the derivative of this curve (should be deleted by destructor)   
     # my(splitLeftOver) :: length of remaing arc after t_splitUniform 
     
     # WARNING: argument should be a list of coords.
     # No check on bad parameters here; use [Bezier::new ...] if you want more checks.
    constructor {args} {
        set my(cPoints) $args
        set my(degree) [expr {[llength $my(cPoints)]-1}]
         # spaceDim: since all cPoints have the same dimension, get it from the first point
        set my(spaceDim) [llength [lindex $my(cPoints) 0]]
        set my(flatnesstolerance)  0.1 ;#  dummy value; flatnesstolearnce is simply ignored.                      
        set my(splitLeftOver) 0.0
        $this _resetCache
    }

    private method _resetCache {} {
        set my(LenTable) {}
        set my(LenTable.tolerance) 1e99  ;# infinite
        catch { $my(derivative) destroy }
        set my(derivative) {}    
    }
    
    destructor {
        $this _resetCache
    }

     # get/set my(flatnesstolerance)
     # NOTE: DEPRECATED method. flatnesstolerance is now useless
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

    public method spaceDim {} { return $my(spaceDim) }

     # get a Zero  {0 0 0 ....}    
    public method PZero {} { lrepeat $my(spaceDim) 0.0 }
    
    public method degree {} { return $my(degree) }
    public method points {} { return $my(cPoints) }          

      # get/set a single polygon point.
      # Note that you cannot add/remove a point,
      # (since this op would change the curve's degree);
      #  you can only change a point, and this op has a side effect of resetting
      #  the 'cached' derivative and 'lentable'.
    public method point { idx {P {}} } {
        if { $P == {} } {
            set P [lindex $my(cPoints) $idx]
            if { $P == {} } {
                error "list index out of range"
            }
            return $P
        }
         # set P
        set dim [P.dim $P]
        if { $dim == 0 } {
            error "Malformed Points: \"$P\" is not a Point"
        }
        if { $dim != $my(spaceDim) } {
			error "Dimension of point \"$P\" different from dimension of previous points"        
        }
        # FIX: with TIP 311, 
        # For our purpose, this case must be treated like an error.
        if { [lindex $my(cPoints) $idx] == {} } {
                error "list index out of range"       
        }
        lset my(cPoints) $idx $P
        $this _resetCache
    }        

        
      # clone :: create a clone of this curve.
      # The new curve is created in the caller's namespace
      # Note that if this is an instance of a subclass,
      #  then a clone of the same subclass is created 
    public method clone {} {      
        uplevel 1 Bezier::new [list $my(cPoints)]
    }

    private proc dotProduct {A B} {
        set sum 0.0
        foreach a $A b $B {
            set sum [expr {$sum+$a*$b}]
        }
        return $sum
    }
    
     # distance between points A and B
    protected proc distance { A B } {
        set A-B [addVectors $A -1 $B]
        return [expr {sqrt( [dotProduct ${A-B} ${A-B}] )}]
    }

    private proc vectorLen { A } {
        set len 0.0
        foreach a $A {
            set len [expr {$len + $a*$a}]
        }
        set len [expr {sqrt($len)}]
        return $len
    }
    
    private proc unitVector { A } {
        set len [vectorLen $A]
        if { $len == 0.0 } { return $A }  ;# !! what else ???
        set R {}
        foreach a $A {
            lappend R [expr {$a/$len}]
        }
        return $R
    }

    private proc addVectors { A k B } {
        set R {}
        foreach a $A b $B {
            lappend R [expr {$a+$k*$b}]
        }
        return $R
    }

# unused
if 0 {
     # given a segment A B and a sequence of points,
     #  returns the max distance between all points and the *segment*
     # NOTE: this is different from the distance from points and a straigt line !

     # note: it should also work if A = B      
     # note: it works in every space-dim !!
    public proc maxDistance { A B args } {
        set dMax 0.0

        set B-A [addVectors $B -1 $A]
        set segmentLen [vectorLen ${B-A}]
        set N [unitVector ${B-A}]  ;# normalized B-A
        foreach P $args {
            set A-P [addVectors $A -1 $P]
            set projectedLen [expr {-([dotProduct ${A-P} $N])}]
            if { $projectedLen < 0 } {
                set d [distance $A $P]
            } elseif { $projectedLen > $segmentLen } {
                set d [distance $B $P]            
            } else {
                set d [vectorLen [addVectors ${A-P} $projectedLen $N]]            
            }
            if {$d >$dMax} { set dMax $d }
        }
        return $dMax
    }   
}
            
     # length of the control polygon
    public method polylength {} {
        set len 0.0
        set otherPoints [lassign $my(cPoints) P0]
        foreach P1 $otherPoints {
            set len [expr {$len+[distance $P0 $P1]}]
            set P0 $P1
        }
        return $len
    }

     # distance between first and last control-Point (aka chord-length)
    public method baselength {} {
        set P0 [lindex $my(cPoints) 0]
        set Pn [lindex $my(cPoints) end]        
        distance $P0 $Pn        
    }    
    
     # evaluate B(t)   (0.0<=t<=1.0) 
     # B(t) is the parametric form of the Bezier's curve
    public method at {t} {
        set R [$this PZero]
        foreach b [Bbp [$this degree] $t] P $my(cPoints) {
            set R1 {}
            foreach c $P r $R {
                set r [expr {$r+$b*$c}] 
                lappend R1 $r
            }
            set R $R1
        }
        return $R
    }

     # return $my(derivative)  and create it if does not exist 
    private method _my_derivative {} {
        if { $my(derivative) == {} } {
            set N [$this degree]
            if { $N == 0 } {
                 # degenerate case: derivative of 0-degree curve is 
                 # still a 0-degree curve with just 1 control-point {0 0}
                set dcPoints [list [$this PZero]]
            } else {
                set dcPoints {}  
                set otherPoints [lassign $my(cPoints) P0]   
                foreach P1 $otherPoints {
                    set dP {}
                    foreach p0 $P0 p1 $P1 {
                        lappend dP [expr {$N*($p1-$p0)}]
                    }
                    lappend dcPoints $dP
                    set P0 $P1
                }
            }
             # NOTE: don't care of caller's namespace; since the derivative
             # curve is owned by this curve, we can use this namespace !
            set my(derivative) [Bezier::new $dcPoints]
        }
        return $my(derivative)
    }

     # Returns a new Bezier's curve of degree n-1
     # Derivative of a degenerate 0-degree curves is still a 0-degree curve
     # (NOTE: it's caller responsability to delete it after use )
     #
     # WARNING: don't confuse derivative with tangent;
     #  Both have the same direction but module (length) is different
    public method derivative {} {
        [$this _my_derivative] clone
    }


     # tangent-vector (normalized) at B(t)
     # NOTE: degree-0 curves have no tangent (nor normal).
     #    See subclass Bezier_0 for the redefined method, providing
     #    an (arbitrary/random) normalized vector
    public method tangent_at {t} {
         # optimization:
         # if $my(derivative) does not exist, and ask for t=0 or t=1
         #  then simply compute it !
         if { $my(derivative) == {} && ($t==0.0 || $t==1.0) } {
            if { $t==0.0 } {
                set P0 [lindex $my(cPoints) 0]
                set P1 [lindex $my(cPoints) 1]                
            } else {
                 # t=1.0:  get the last 2 cPoints
                set P0 [lindex $my(cPoints) end-1]
                set P1 [lindex $my(cPoints) end]
            }                
            return [unitVector [addVectors $P1 -1 $P0]]
         }   
    
         # use [$this _my_derivative], don't call [$this derivative] since
         # this latter command creates a new copy!
        set P [[$this _my_derivative] at $t]
        set P [unitVector $P]
    }

    public method vtangent_at {len t} {
        set P0 [$this at $t]
        list $P0 [addVectors $P0 $len [$this tangent_at $t]]
    }
         

     # normal-vector at B(t)
     #  -- unpredictable; meaningful only for 2D
    public method normal_at {t} {
        switch -- $my(spaceDim) {
            2 {
                set P [$this tangent_at $t]
                lassign $P x y
                set P [list [expr -$y] $x]                
            }
            default {
                 # return a fixed versor
                set P [$this PZero]         
            }
        }            
        return $P
    } 

    public method vnormal_at {len t} {
        set P0 [$this at $t]
        list $P0 [addVectors $P0 $len [$this normal_at $t]]
    }
    

     # split_at $t "both"  - split a curve at B(t) and returns its left and right curves.
     # split_at $t "left"  - .. split and returns only the curve left to B(t)
     # split_at $t "right" - .. split and returns only the curve right to B(t)
     # It's caller's responsability to delete the reulting curve(s) after use
     #
     # Algorhythm adapted from Earl Boeber's work:
     #   "Computing the arc length of cubic bezier curves"
    public method split_at {t {side both}} {
        set validSides {left right both}
        if { $side ni $validSides } {
            error "wrong \"side\" parameter: must be one of [join $validSides ", "]"
        }
        set N $my(degree)
        set prevRow  $my(cPoints) ;# N+1 points
        lappend Triangle $prevRow
        set {1-t} [expr {1.0-$t}] ; # loop invariant
        for {set i 1} { $i<=$N } {incr i} {
            set row {}
            set otherPoints [lassign $prevRow P0]
            foreach P1 $otherPoints {
                 # linear interpolation
                 set P {} 
                 foreach p0 $P0 p1 $P1 {
                    lappend P [expr {${1-t}*$p0+$t*$p1}]
                 }
                 lappend row $P
                 set P0 $P1
            }
            lappend Triangle $row
            set prevRow $row
        }
        set splittedCurves [list]
        if { $side in {left both} } {
             # set left control points
            set Pts {}
            foreach row $Triangle {
                lappend Pts [lindex $row 0]
            }
            lappend splittedCurves [Bezier::new $Pts]
        }
        if { $side in {right both} } {        
             # set right control points
            set Pts {}
            foreach row $Triangle {
                lappend Pts [lindex $row end]
            }
            set Pts [lreverse $Pts]
            lappend splittedCurves [Bezier::new $Pts]
        }
        return $splittedCurves
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

    private method _simpleEstimatedLength {} {
        set Lc [$this baselength]
        set Lp [$this polylength]
         # real length L* is always between Lc and Lp  (Lc <= L* <= Lp)
         # return a weighted average between Lc and Lp
         #
         set N [$this degree] ; set N [expr {double($N)}]
         return [expr {(2.0*$Lc+($N-1.0)*$Lp)/($N+1.0)}]       
    }

    # This algorithm is based on "Adaptive subdivision and the length and
    # energy of Bézier curves" by Jens Gravesen.
    public method length {args} {
        set optDict [_parseOptions \
            [list -tolerance $Default(-length.tolerance)] \
            {*}$args]
        set tolerance [dict get $optDict -tolerance]
        if { $tolerance eq "" ||  ! [string is double $tolerance] || abs($tolerance) < 1e-9 } {
            error "Wrong value for \"-tolerance\".  Must be <= -1.e-9 or >= +1.e-9"
        }
        set L0 [$this _simpleEstimatedLength]        
        if { $tolerance < 0 } {
            # this means: relative tolerance
            set tolerance [expr {$L0*abs($tolerance)}]
        }

        return [$this _length $L0 $tolerance]
    } 

    private method _length {L0 accuracy} {
        lassign [$this split_at 0.5] left right
        set lenA [$left  _simpleEstimatedLength]
        set lenB [$right _simpleEstimatedLength]

         # L1 is the new estimated length of this curve
        set L1 [expr {$lenA+$lenB}]
        set err [expr {($L0-$L1)/15.0}]
          # WARNING: working near a cusp may enter an andless split 
          #    -->  ... underflow error (divide by 0)
        if { $accuracy < 1e-12 } { set accuracy 1e-12 }

        if { abs($err) < $accuracy } {
             # get the estimated lenght and correct it with the (signed) error
            set Len [expr {$L1-$err}]

            $left destroy ; $right destroy
        } else {
            set accuracyA [expr {$accuracy*$lenA/$L1}]
            set accuracyB [expr {$accuracy*$lenB/$L1}]          

            set lenA [$left _length $lenA $accuracyA]
            $left destroy            

            set lenB [$right _length $lenB $accuracyB]
            $right destroy
            set Len [expr {$lenA+$lenB}]            
        }
        return $Len        
    }  


     # this method checks if all control-points are close (<=tolerance) 
     #  to the curve's chord segment
     #     
     # DEV-note: this is a variation (more efficient) of the maxDistance proc.
     #  since it does not compute the distance off all points and then compare
     #  with tolerance; when a point with a distance greater than tolerance is
     #  found, this method halts and returns "false" 

    private method almostFlat {tolerance} {
         # we will evaluate all the control points
         # except the first and the last  (A B).  A-B is the chord segment              
        set cpoints [lassign [$this points] A]
        set B [lindex $cpoints end]
        set cpoints [lreplace $cpoints end end]

        set B-A [addVectors $B -1 $A]
        set segmentLen [vectorLen ${B-A}]
        set N [unitVector ${B-A}]  ;# normalized B-A
        
        foreach P $cpoints {
            set A-P [addVectors $A -1 $P]
            set projectedLen [expr {-([dotProduct ${A-P} $N])}]
            if { $projectedLen < 0 } {
                set d [distance $A $P]
            } elseif { $projectedLen > $segmentLen } {
                set d [distance $B $P]            
            } else {
                set d [vectorLen [addVectors ${A-P} $projectedLen $N]]            
            }
            if {$d >$tolerance} { return false }
        }
        return true
    }   



     # LenTable - defs and properties
     # -------------------------------------
     # LenTable is a table for inverting the length of a Bezier's curve
     # i.e. given an intermediate len, find t* such that
     #      Length from B(0) to B(t*)  is len.
     # * Each entry of Lentable is a list {t len} *
     # where 
     #  first *implicit* entry is {0.0 0.0}  
     #  i.e length of curve from B(0) to B(0) is .. 0.0
     #  (this entry is implicit and therefore not stored)
     #   and last entry is {1 LEN}  i.e. length of curve from B(0) to B(1) is LEN
     # LenTable properties : 
     #  * entries are ordered i.e  "t" is strictly increasing,
     #    "len" is non-strictly increasing, i.e:
     #     if  t0>t1  then Len(t0) >= Len(t1)
     #  *  if t0>t1 and Len(t0)=Len(t1)  then  **degenere case of a curve of length 0** !!
     #     ( users should avoid to process these degenere curves!  
     #     (anyway, this package can handle them)
     #  * the curve between two contiguos entries {t0 len0} {t1 len1} is "almostFlat"
     #    and then any point t between t0 and t1 can be computed with a linear interpolation.
     #    BE CAREFUL: Len0 -Len1 is not the length of the segment from B(t0) to B(t1),
     #      but it's the approximated length (with a very high precision) of the
     #      curve between B(t0) and B(t1)
     #
     #    On the other side, with the (counter) linear interpolation,
     #    we can find t* such that len is any value between len0 and len1. 

     #   get the current LenTable (if exists) if the required flatness error
     #   is larger (worst) than the saved flatnessError ...
     #   else build and save a new LenTable
     # WARNING: this is a time-consuming computation; your app should cache the result.
    private method _getLenTable {flatnessError} {
        if { $my(LenTable) eq {} || $my(LenTable.tolerance) > $flatnessError } {
            set L0  [$this _simpleEstimatedLength]
            set my(LenTable) [$this _buildLenTable $L0 0.0 1.0 0.0 $flatnessError]
            set my(LenTable.tolerance) $flatnessError
        }
        return $my(LenTable)
    }    

     ## ** unsupported method ** just for dev/testing
    public method resetLenTable {} {
        set my(LenTable) {}
        return "Done, even if this is an unsupported method"
    }
    
    private  method _buildLenTable {L0 t0 t1 lenAt_t0 flatnessError} {
        lassign [$this split_at 0.5] left right

        set lenA [$left  _simpleEstimatedLength]
        set lenB [$right _simpleEstimatedLength]

        if { [$this almostFlat $flatnessError] } {
            set L1 [expr {$lenA+$lenB}]
            $left destroy
            $right destroy
             # adopt the same average used in "length" method 
            set len [expr {$L1-($L0-$L1)/15.0}]
			set table [list [list $t1 [expr {$lenAt_t0+$len}]]]
        } else {
            set tm [expr {($t0+$t1)/2.0}] ; # midpoint of interval (t0,t1)
             #set flatnessError [expr {$flatnessError/2.0}]
             ##   NO !! the above statement causes far more subsivisions (split)
             ##    without a real gain in length's precision
            set table [$left _buildLenTable $lenA $t0 $tm $lenAt_t0 $flatnessError]
            $left destroy
            set lenAt_tm [lindex $table end 1]
            lappend table {*}[$right _buildLenTable $lenB $tm $t1 $lenAt_tm $flatnessError]
            $right destroy
        }
        return $table
    }


     # Returns the (approximated) length of the curve from B(0) to B(t)
     # Properties:
     #   length_at(0.0) == 0.0
     #   length_at(1.0) == L
     #   length_at(t0) < length_at(t1)  <==>  t0 < t1 )
     #   length_at(invlength(len)) == len
     #   invlength(length_at(t)) == t
     #  Degenerate cases:
     #    if t < 0.0 ==> length_at(t) == 0.0
     #    if t > 1.0 ==> length_at(t) == L   
    public method length_at {t args} {
        set optDict [_parseOptions \
            [list -tolerance $Default(-length.tolerance)] \
            {*}$args]
        set tolerance [dict get $optDict -tolerance]
        if { $tolerance eq "" ||  ! [string is double $tolerance] || abs($tolerance) < 1e-9 } {
            error "Wrong value for \"-tolerance\".  Must be <= -1e-9 or >= +1.e-6"
        }
    
        if { $t <= 0 } { return 0.0 }
        if { $t >= 1 } { return [$this length -tolerance $tolerance] }
        set leftSide [$this split_at $t left]
        set len [$leftSide length -tolerance $tolerance]
        $leftSide destroy
        return $len
    }



    # Given a len, returns t such that  length_at(t) == len
    # Properties:
    #   invlength(0.0) == 0.0
    #   invlength(L) == 1.0
    #   invlength(len0) < invlength(len1)  <==>  len0 < len1 )
    #   Degenerate cases:
    #    if len < 0 ==> invlength(len) == 0.0
    #    if len > L ==> invlength(len) == 1.0
    public method invlength {len args} {            
        set optDict [_parseOptions \
            [list -tolerance $Default(-flatness.tolerance)] \
            {*}$args]
        set tolerance [dict get $optDict -tolerance]
        if { $tolerance eq "" ||  ! [string is double $tolerance] || $tolerance < 1e-9 } {
            error "Wrong value for \"-tolerance\".  Must be >= +1.e-6"
        }

        if { $len <= 0 } { return 0.0 }
        set LenTable [$this _getLenTable $tolerance]
        set LEN [lindex $LenTable end 1]
        if { $len >= $LEN } { return 1.0 }
        
        _invlength $len $tolerance $LenTable
    }

     # prereq:  0 < len < LEN        
    private proc _invlength {len tolerance LenTable} {   
         # do a binary search
        set i0 [lsearch -real -bisect -increasing -index 1 $LenTable $len]
        if { $i0 >= 0 } {
            lassign [lindex $LenTable $i0] t0 len0
            if { $i0+1 == [llength $LenTable] } {
                 # i0 is the last element , therefor we are looking for
                 # a t for length greater then L* . 
                return 1.0
            }
            lassign [lindex $LenTable $i0+1] t1 len1
        } else {
            set t0   0.0
            set len0 0.0
             # next elem is -1+1 = 0
            lassign [lindex $LenTable 0] t1 len1
        }
         # interpolated t between t0 and t1
        set D [expr {$len1-$len0}]
        if { $D < 1e-30 } {
             # degenerate case - curve is made of identical points !
            return $t0
        }
        return [expr {$t0+($t1-$t0)/$D*($len-$len0)}]                  
    }

    
    # *EXPERIMENTAL*
    # Alternative implementation for invlength
    # compute inv leng without a full (and deep) LenTable
    # -- need comparsion of speed and accuracy
    public method EXP_invlength {len args} {            
        set optDict [_parseOptions \
            [list -tolerance $Default(-flatness.tolerance)] \
            {*}$args]
        set tolerance [dict get $optDict -tolerance]
        if { $tolerance eq "" ||  ! [string is double $tolerance] || $tolerance < 1e-9 } {
            error "Wrong value for \"-tolerance\".  Must be >= +1.e-6"
        }

        if { $len <= 0.0 } { return 0.0 }
        if { $len >= [$this length -tolerance $tolerance] } { return 1.0 }
        
        _EXP_invlength $len $tolerance
    }

     # prereq:  0 < len < LEN
    private method _EXP_invlength {len tolerance} {            
        set midT 0.5
        lassign [$this split_at $midT] left right
        set midLen [$left length -tolerance $tolerance]
        if { abs($midLen-$len) < $tolerance } {
            $left destroy
            $right destroy

             # adjust midT ...  average 
            set midT [expr {$midT*($midLen/$len)}]
            return $midT
        }

        if { $len < $midLen} {
            $right destroy
            set t [$left _EXP_invlength $len $tolerance]
            $left destroy
            return [expr {$t/2.0}]
        }

        # no other case:  $len > $midLen
            $left destroy
            set t [$right _EXP_invlength [expr {$len-$midLen}] $tolerance]
            $right destroy
            return [expr {$midT+$t/2.0}]
    }

    
     # This method should be called after calling t_splitUniform and
     #  returns the length of the last remaing arc
     # NOTE: bad design ... maybe t_splitUniform should return the t-list AND
     #  the length of the last remaing arc ( ? by var ?)
     # ?TODO?
    public method splitLeftOver {} {
        return $my(splitLeftOver)
    }

     # t_splitUniform ::
     # returns a list of t (t is parameter of curve B(t))
     #  splitting the curve in subcurves of length $dL
     # Parameter $plen (default is 0.0) is the length of the initial part 
     # of the curve to be skipped 
     #  i.e. let t0 the first element of the returned list,
     #       then
     #        length_at(t0) ==  pLen
     #
     # The remaining last part of the curve (whose length is less than dL)
     #  can be get by calling the splitLeftOver method
     # NOTE:
     #   t_splitUniform(dl,pLen) 
     #     is equivalent to
     #   invlength(pLen+dL)
     #   invlength(pLen+2*dL)
     #    ...
     #   invlength(plen+K*dL)
     # t_splitUniform is an optimized incremental method, far more efficient than
     # calling invlength() repeatedly.
     #
     # Once you get a list of t, then you can get point, tangents, normals,
     #  by simply calling at,tangent_at,normal_at methods.
      

# fai doc (test OK)
     # t_splitUniform dL ?pLen? ?-tolerance x?
    public method t_splitUniform { dL {pLen 0.0} args } {
       if { $dL <= 0.0 } {
            error "split length dL must be > 0.0"
        }
        if { $pLen < 0.0 } {
            error "skipped length (pLen) must be >= 0.0"
        }
        set optDict [_parseOptions \
            [list -tolerance $Default(-flatness.tolerance)] \
            {*}$args]
        set tolerance [dict get $optDict -tolerance]
        if { $tolerance eq "" ||  ! [string is double $tolerance] || $tolerance < 1e-9 } {
            error "Wrong value for \"-tolerance\".  Must be >= +1.e-6"
        }
        set LenTable [$this _getLenTable $tolerance]
        set L {}
        set t0 0.0
        set len0 0.0
        foreach item $LenTable {
            lassign $item t1 len1
             # ???  pLen < len1  ???
            while { $pLen <= $len1 } {
                 # interpolated t
                set D [expr {$len1-$len0}]
                if { $D < 1e-30 } {
                     # degenerate case - curve is made of identical points !
                    return $len0; # this is 0 !
                }
               set t [expr {$t0+($t1-$t0)/$D*($pLen-$len0)}]
               lappend L $t
               set pLen [expr {$pLen+$dL}]
            }
            set t0 $t1
            set len0 $len1
        }
        set my(splitLeftOver) [expr {$len1-($pLen-$dL)}]        
        return $L
    }
}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

 # Bezier curves of degree: 0 
 # These are degenerate curves; just a point.
 # Although degree-0 curves can be representated as 0-degree Bezier's curves,
 #  many of Bezier methods can be extremely simplified.
 # Note that the method inteface is identical, and some general methods are
 # inherited from generic Bezier class.
itcl::class Bezier_0 {
    inherit Bezier

     # WARNING: argument should be a list of coords (1 point required).
     # No check on bad parameters here; use [Bezier::new ...] if you want more checks.     
    constructor { args } { Bezier::constructor {*}$args } {
    }
    
     # redefined general method: simplification for 0-degree Bezier
    public method at {t} {
        lindex $my(cPoints) 0
    }
    public method polylength {} {
        return 0.0
    }
    public method baselength {} {
        return 0.0
    }

    private proc unitVector { A } {
        set P [$this PZero]
        lset P 0 1.0
        return $P
    }

     # tangent-vector (normalized) at B(t)
     # NOTE: degree-0 curves have no tangent (nor normal).
     # What can I do ? 
     #  a) return {0 0}   (but this is not a normalized vector)
     #  b) return a 'random' normalized vector
     #  c) return an arbitrary normalized vector (e.g {1 0 .. 0})
     # ... (c) is the adopted solution 
    public method tangent_at {t} {
        return [unitVector 0]
    } 

     # normal-vector at B(t) {0 1 0 .... 0}
     # since normal is not defined for a single point,
     # return an arbitrary normal
    public method normal_at {t} {
        set P [$this PZero]
        lset P 1 1.0
    } 
                   
     # redefined general method: simplification for 0-degree Bezier
    public method length {} {
        return 0.0   
    }
    
    public method length_at {t args} { return 0.0 }    
    public method invlength {len args} { return 0.0 }    

    public method t_splitUniform { dL {pLen 0.0} args } {
        return {} ; # a point cannot be splitted 
    }
}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

 # Bezier curves of degree: 1 - straight segments
 # Although straight segments can be representated as 1st-degree Bezier's curves,
 #  many of Bezier methods can be extremely simplified for 1st-degree curves.
 # Note that the method inteface is identical, and some general methods are
 # inherited from generic Bezier class.
  
itcl::class Bezier_1 {
    inherit Bezier

     # WARNING: argument should be a list of coords (2 points required).
     # No check on bad parameters here; use [Bezier::new ...] if you want more checks. 
    constructor { args } { Bezier::constructor {*}$args } {
    }
    
     # redefined general method: simplification for 1st degree Bezier
    public method at {t} {
        lassign $my(cPoints) A B        
        set P {}
        foreach a $A b $B {
            lappend P [expr {(1-$t)*$a+$t*$b}]        
        }
        return $P
    }
    
     # redefined general method: simplification for 1st degree Bezier
    public method length {args} {
         # args should be "-tolerance ..." (optional) 
         # but its' simply ignored, since the length is computed with no tolerance.
        lassign $my(cPoints) A B        
        set my(LenTable) {}
        set len [distance $A $B]
        lappend my(LenTable) [list 1.0 $len]
        return $len    
    }
    
    public method almostFlat {tolerance} {
        return true
    }
            
}


## FIX: class variable BinomialTriangle will be initializez once
##      at startup.

   # pre-compute the Binomial triangle up to 10 levels
set Bezier::BinomialTriangle [Bezier::binomialTriangle 10]

