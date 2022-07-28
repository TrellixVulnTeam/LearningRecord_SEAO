# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Cawt {
    variable ns [namespace current]

    namespace ensemble create

    namespace export Interpolate

    oo::class create Interpolate {

        variable mPointMap
        variable mCoeffs
        variable mX
        variable mY
        variable mInterpolationType
        variable mInterpolationTypes
        variable mIsDirty
        variable mDebug

        # Private method for initialization of member variables.
        method Init {} {
            set mDebug   false
            set mIsDirty true
            set mInterpolationType  "CubicSpline"
            set mInterpolationTypes [list "Linear" "CubicSpline"]
        }

        constructor { args } {
            # Create an instance of an interpolation curve.
            #
            # args - List of `x y` pairs specifying the control points of the
            #        interpolation curve.
            #
            # An interpolation curve is comprised of one or more control points.
            # The control points are 2-dimensional values:
            # * The x values are increasing, but typically not equidistant. 
            # * The y values hold the corresponding (measurement) values.
            # Possible examples are time vs. speed or waveband vs. reflection parameter.
            # 
            # ```
            # ^  (Reflection value)
            # |
            # |         + y2
            # |
            # |                   + y3
            # |
            # |  + y1
            # |  
            # |
            # ----------------------->
            #    x1     x2        x3   (Waveband)
            # ```
            #
            # Control points can be added to an interpolation curve by specifying
            # them directly in the $args argument of the constructor or by adding 
            # them with method [AddControlPoint].
            # The control points can be given in any order. They are automatically 
            # sorted by their `x` values.
            #
            # The interpolation curve can be sampled with different interpolation methods.
            # Currently supported are linear and cubic spline interpolation, see
            # [SetInterpolationType].
            #
            # Returns no value.
            #
            # See also: destructor AddControlPoint SetInterpolationType

            my Init
            foreach { x y } $args {
                my AddControlPoint $x $y
            }
        }

        destructor {
            # Delete the instance of the interpolation curve.
            #
            # Returns no value.
            #
            # See also: constructor DeleteControlPoint Clear

            my Clear
        }

        method Clear {} {
            # Clear all control points of the interpolation curve.
            #
            # Returns no value.
            #
            # See also: constructor destructor DeleteControlPoint

            my Init
            catch { unset mPointMap }
            catch { unset mCoeffs }
            catch { unset mX }
            catch { unset mY }
        }
        export Clear

        method SetInterpolationType { type } {
            # Set the interpolation type of the interpolation curve.
            #
            # type - Interpolation type as string.
            #
            # Supported values for $type are `Linear` and `CubicSpline`.
            # The default interpolation type is `CubicSpline`.
            #
            # Returns no value.
            #
            # See also: constructor GetInterpolationType GetInterpolationTypes GetInterpolatedValue

            if { [lsearch -exact $mInterpolationTypes $type] >= 0 } {
                set mInterpolationType $type
            } else {
                throw [list Interpolate SetInterpolationType] "Invalid interpolation type \"${type}\"." 
            }
        }
        export SetInterpolationType

        method GetInterpolationType {} {
            # Get the interpolation type of the interpolation curve.
            #
            # Returns the currently specified interpolation type as string.
            #
            # See also: constructor SetInterpolationType GetInterpolationTypes GetInterpolatedValue

            return $mInterpolationType
        }
        export GetInterpolationType

        method GetInterpolationTypes {} {
            # Get the supported interpolation types.
            #
            # Returns the supported interpolation types as list of strings.
            #
            # See also: constructor SetInterpolationType SetInterpolationType GetInterpolatedValue

            return $mInterpolationTypes
        }
        export GetInterpolationTypes

        # Private method.
        method InitFromPointMap {} {
            catch { unset mX }
            catch { unset mY }

            set ind 0
            foreach x [lsort -real [array names mPointMap]] {
                set mX($ind) [expr { double( $x ) }]
                set mY($ind) [expr { double( $mPointMap($x) ) }]
                incr ind
            }
        }

        method AddControlPoint { x y } {
            # Add a new control point to the interpolation curve.
            #
            # x - x value of the control point.
            # y - y value of the control point.
            #
            # The control points can be given in any order. They are automatically 
            # sorted by their `x` values.
            #
            # If a control point with $x value already exists, it is overwritten
            # with the new $y value.
            #
            # Returns no value.
            #
            # See also: constructor DeleteControlPoint ControlPointExists

            set mIsDirty true
            set mPointMap($x) $y
            my InitFromPointMap
        }
        export AddControlPoint

        method ControlPointExists { x } {
            # Check, if a control point exists in the interpolation curve.
            #
            # x - x value of the control point.
            #
            # Returns true, if a control point with $x value exists.
            # Otherwise returns false.
            #
            # See also: constructor AddControlPoint DeleteControlPoint

            return [info exists mPointMap] && [info exists mPointMap($x)]
        }
        export ControlPointExists

        method DeleteControlPoint { x } {
            # Delete a control point of the interpolation curve.
            #
            # x - x value of the control point.
            #
            # If a control point with $x does not exist, no action is taken.
            # 
            # Returns no value.
            #
            # See also: constructor AddControlPoint ControlPointExists

            set mIsDirty true
            if { [my ControlPointExists $x] } {
                unset mPointMap($x)
            }
            my InitFromPointMap
        }
        export DeleteControlPoint

        method GetNumControlPoints {} {
            # Get the number of control points of the interpolation curve.
            #
            # Returns the number of control points of the interpolation curve.
            #
            # See also: constructor AddControlPoint DeleteControlPoint

            if { ! [info exists mPointMap] } {
                return 0
            }
            return [array size mPointMap]
        }
        export GetNumControlPoints

        # Private method to calculate the coefficients of a cubic spline.
        method ComputeCoefficients {} {
            set numCps [my GetNumControlPoints]

            if { $numCps < 3 } {
                return
            }

            set d2y0 0.0
            set d2yn 0.0
            set numRows [expr { $numCps - 2 }]
            set numIntervals [ expr { $numCps - 1 }]

            for { set i 0 } { $i < $numIntervals } { incr i } {
                set i1 [expr { $i + 1 }]
                set h($i) [expr { $mX($i1) - $mX($i) }]
            }

            # Calculate tridiagonal matrix.
            for { set row 0 } { $row < $numRows } { incr row } {
                set row1 [expr { $row + 1 }]
                set a($row) [expr { 2.0 * ( $h($row) + $h($row) ) }]
            }

            for { set row 0 } { $row < [expr { $numRows -1 }] } { incr row } {
                set row1 [expr { $row + 1 }]
                set b($row)  $h($row1)
            }

            set nr  $numRows
            set nrn [expr { $numRows - 1 }]
            set nrp [expr { $numRows + 1 }]

            set v(0) [expr { 6.0 * ( $mY(1) - $mY(0) ) / $h(0) - \
                             6.0 * ( $mY(2) - $mY(1) ) / $h(1) + \
                             $h(0) * $d2y0 }]

            set v($nrn) [expr { 6.0 * ( $mY($nr)  - $mY($nrn) ) / $h($nrn) - \
                                6.0 * ( $mY($nrp) - $mY($nr)  ) / $h($nr)  + \
                                $h($numRows) * $d2yn }]

            for { set row 1 } { $row < [expr { $numRows -1 }] } { incr row } {
                set row1 [expr { $row + 1 }]
                set row2 [expr { $row + 2 }]
                set v($row) [expr { 6.0 * ( $mY($row)  - $mY($row)  ) / $h($row) - \
                                    6.0 * ( $mY($row2) - $mY($row1) ) / $h($row1) }]
            }

            for { set i 0 } { $i < $numRows } { incr i } {
                set v($i) [expr { -1.0 * $v($i) }]
            }

            my ComputeLinearEquation a b v w

            set d2y(0) $d2y0
            for { set i 1 } { $i <= $numRows } { incr i } {
                set d2y($i) [expr { -1.0 * $w([expr { $i - 1 }]) }] 
            }
            set d2y([expr { $numCps - 1 }]) $d2yn
       
            if { $mDebug } {
                puts "Coefficients:"
            }
            for { set i 0 } { $i < $numIntervals } { incr i } {
                set i1 [expr { $i + 1 }]
                set a3 [expr { ( $d2y($i1) - $d2y($i) ) / ( 6.0 * $h($i) ) }]
                set a2 [expr { 0.5 * $d2y($i) }]
                set a1 [expr { ( $mY($i1) - $mY($i) ) / $h($i) - $h($i) * ( $d2y($i1) + 2.0 * $d2y($i) ) / 6.0 }]
                set a0 $mY($i)
                set mCoeffs($i) [list $a0 $a1 $a2 $a3]
                if { $mDebug } {
                    puts [format " Interval $i: a0 = %8.4f a1 = %8.4f a2 = %8.4f a3 = %8.4f" $a0 $a1 $a2 $a3]
                }
            }
            set mIsDirty false
        }

        # Private method to compute the linear equation for cubic splines.
        method ComputeLinearEquation { arrA arrB arrV arrX } {
            upvar 1 $arrA a
            upvar 1 $arrB b
            upvar 1 $arrV v
            upvar 1 $arrX x

            set n [array size a]

            # Matrix separation.
            set m(0) $a(0)
            for { set i 0 } { $i < [expr { $n - 1 }] } { incr i } {
                set i1 [expr { $i + 1 }]
                set l($i)  [expr { $b($i) / $m($i) }]
                set m($i1) [expr { $a($i) - $l($i) * $b($i) }]
            }

            # Forward insertion.
            set y(0) $v(0)
            for { set i 1 } { $i < $n } { incr i } {
                set i1 [expr { $i - 1 }]
                set y($i) [expr { $v($i) - $l($i1) * $y($i1) }]
            }
      
            # Solution.
            set n1 [expr { $n - 1 }]
            set x($n1) [expr { -1.0 * $y($n1) / $m($n1) }]
            for { set i [expr { $n - 2 }] } { $i >= 0 } { incr i -1 } {
                set i1 [expr { $i + 1 }]
                set x($i) [expr { -1.0 * ( $y($i) + $b($i) * $x($i1) ) / $m($i) }]
            }
        }

        method GetControlPoints {} {
            # Get the list of control points of the interpolation curve.
            #
            # Returns a list of `x y` values of all control points.
            #
            # See also: constructor AddControlPoint GetInterpolatedValue

            set xy [list]
            set numCps [my GetNumControlPoints]
            for { set cpInd 0 } { $cpInd < $numCps } { incr cpInd } {
                lappend xy $mX($cpInd) $mY($cpInd)
            }
            return $xy
        }
        export GetControlPoints

        method GetInterpolatedValue { x args } {
            # Get an interpolated value of the curve at a specific sample point.
            #
            # x    - Sample point.
            # args - Options described below.
            #
            # -extrapolate - Enable extrapolation mode.
            #
            # * If the curve contains no control points, an error is thrown.
            # * If the curve contains 1 control point, the `y` value of that control
            #   point is returned.
            # * If the curve contains 2 control points, the linearly interpolated value
            #   of the 2 control points is returned.
            # * If the curve contains 3 or more control points, the interpolated value
            #   is returned depending on the interpolation type, see [SetInterpolationType].
            #
            # If $x is not inside the range of control points and extrapolation mode is
            # disabled, the `y` values of the first resp. last control point are returned.
            # If extrapolation mode is enabled, the `y` values are extrapolated according
            # to the interpolation mode.
            #
            # Returns the interpolated value at sample point $x.
            #
            # See also: constructor AddControlPoint GetNumControlPoints GetInterpolatedValues
            #           SetInterpolationType

            set extrapolate false
            foreach key $args {
                switch -exact -nocase -- $key {
                    "-extrapolate" { set extrapolate true }
                }
            }

            set numCps [my GetNumControlPoints]
            if { $numCps == 0 } {
                throw [list Interpolate GetInterpolatedValue] "No control points specified."
            }
            if { $mIsDirty } {
                my ComputeCoefficients
            }

            if { $numCps == 1 } {
                return $mY(0)
            }

            set index   0
            set numCps1 [expr { $numCps - 1 }]

            if { $x < $mX(0) } {
                # Position is beyond first control point.
                if { $extrapolate == false } {
                    return $mY(0)
                }
                set index 1
            } else {
                while { ( $index <= $numCps1 ) && ( $x >= $mX($index) ) } {
                    incr index
                }
                if { $index == $numCps } {
                    # Position is beyond last control point.
                    if { $extrapolate == false } {
                        return $mY($numCps1)
                    }
                    incr index -1
                }
            }
            incr index -1
            if { $mInterpolationType eq "CubicSpline" && $numCps > 2 } {
                set dx [expr { $x - $mX($index) }]
                # Calculate y from cubic polynomial.
                set coeffs $mCoeffs($index)
                set a0 [lindex $coeffs 0]
                set a1 [lindex $coeffs 1]
                set a2 [lindex $coeffs 2]
                set a3 [lindex $coeffs 3]
                set y [expr { $a0 + $a1 * $dx + $a2 * $dx * $dx + $a3 * $dx * $dx * $dx }]
            } else {
                # Calculate y by linear interpolation.
                set index1 [expr { $index + 1 }]
                set dx [expr { $mX($index1) - $mX($index) }]
                set dy [expr { $mY($index1) - $mY($index) }]
                set m  [expr { $dy / $dx }]
                set t  [expr { $mY($index) - $m * $mX($index) }]
                set y  [expr { $m * $x + $t }] 
            }
            return $y
        }
        export GetInterpolatedValue

        method GetInterpolatedValues { args } {
            # Get interpolated values of the interpolation curve.
            #
            # args - Options described below.
            #
            # -samples - Number of sample points between each control point.
            #            Default: 10
            #
            # Sample the curve between the control points with a specified number of sample points.
            # Use this method for drawing the curve in ex. a canvas.
            # See test script Cawt-10_Interpolate.tcl on how to easily convert the `y` values
            # to the canvas coordinate system, which goes top-down.
            #
            # Returns a list of `x y` values corresponding to the sample points.
            #
            # See also: constructor AddControlPoint GetNumControlPoints GetInterpolatedValue
            #           SetInterpolationType

            set samples 10
            foreach { key value } $args {
                if { $value eq "" } {
                    error "${methodName}: No value specified for key \"$key\"."
                }
                switch -exact -nocase -- $key {
                    "-samples" { set samples [expr { int( $value ) }] }
                }
            }

            set numCps [my GetNumControlPoints]
            if { $numCps == 0 } {
                throw [list Interpolate GetInterpolatedValues] "No control points specified."
            }
            if { $mIsDirty } {
                my ComputeCoefficients
            }

            for { set cpInd 1 } { $cpInd < $numCps } { incr cpInd } {
                set cpInd1 [expr { $cpInd - 1 }]
                set diff [expr { $mX($cpInd) - $mX($cpInd1) }]
                for { set i 0 } { $i < $samples } { incr i } {
                    set x [expr { $mX($cpInd1) + $i * ( $diff / $samples ) }]
                    set y [my GetInterpolatedValue $x]
                    lappend xy $x $y
                }
            }
            set last [lindex [array names mX] end]
            set x $mX($last)
            set y [my GetInterpolatedValue $x]
            lappend xy $x $y
            return $xy
        }
        export GetInterpolatedValues
    }
}
