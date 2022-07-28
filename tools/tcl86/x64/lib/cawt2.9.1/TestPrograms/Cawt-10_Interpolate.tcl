# Test interpolation functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawtcore
package require Tk

set cp1 [list 100 100]
set cp2 [list 200 150]
set cp3 [list 250 100]

lappend cpList {*}$cp1 {*}$cp2 {*}$cp3

set xLeft    50
set xInside 150
set xRight  300

proc DrawCross { canv x y { size 10 } } {
    set size2 [expr { $size / 2 }]
    $canv create line [expr { $x - $size2 }] $y [expr { $x + $size2 }] $y -fill black
    $canv create line $x [expr { $y - $size2 }] $x [expr { $y + $size2 }] -fill black
}

# Utility procedure to convert the x y values of the interpolated points
# into canvas coordinates.
# Taken from https://wiki.tcl-lang.org/page/lolcat
proc ConvertCoords args {
    concat {*}[uplevel 1 lmap $args]
}

# Create 4 canvases and labels for displaying curves having 2 or 3
# control points, both in interpolation modes Linear and CubicSpline.
set canvHeight 200

labelframe .f2_l -text "Linear interpolation with 2 control points"
labelframe .f2_c -text "Cubic spline interpolation with 2 control points"
labelframe .f3_l -text "Linear interpolation with 3 control points"
labelframe .f3_c -text "Cubic spline interpolation with 3 control points"
set c2(Linear)      [canvas .f2_l.c2_l -width $xRight -height $canvHeight]
set c2(CubicSpline) [canvas .f2_c.c2_c -width $xRight -height $canvHeight]
set c3(Linear)      [canvas .f3_l.c3_l -width $xRight -height $canvHeight]
set c3(CubicSpline) [canvas .f3_c.c3_c -width $xRight -height $canvHeight]
pack .f2_l.c2_l -fill both -expand true
pack .f2_c.c2_c -fill both -expand true
pack .f3_l.c3_l -fill both -expand true
pack .f3_c.c3_c -fill both -expand true
grid .f2_l -row 0 -column 0 -padx 5 -pady 5
grid .f2_c -row 0 -column 1 -padx 5 -pady 5
grid .f3_l -row 1 -column 0 -padx 5 -pady 5
grid .f3_c -row 1 -column 1 -padx 5 -pady 5

bind . <Escape> exit

# Create an empty interpolation curve crv1 and add some control points to the curve.
# Control points can be specified in any order.

# Case: 0 control points.
set crv1 [Cawt Interpolate new]
Cawt CheckNumber 0 [$crv1 GetNumControlPoints] "Number of control points"
set catchVal [catch { $crv1 GetInterpolatedValue $xInside } retVal]
if { $catchVal } {
    puts "Successfully caught GetInterpolatedValue: $retVal"
}
set catchVal [catch { $crv1 SetInterpolationType "Unknown" } retVal]
if { $catchVal } {
    puts "Successfully caught SetInterpolationType: $retVal"
}
puts ""

# Case: 1 control point.
$crv1 AddControlPoint {*}$cp2
Cawt CheckNumber 1 [$crv1 GetNumControlPoints] "Number of control points"
puts "Control points: [$crv1 GetControlPoints]"
foreach type [$crv1 GetInterpolationTypes] {
    $crv1 SetInterpolationType $type
    Cawt CheckString $type [$crv1 GetInterpolationType] "Interpolation type"

    set yLeft   [$crv1 GetInterpolatedValue $xLeft]
    set yInside [$crv1 GetInterpolatedValue $xInside]
    set yRight  [$crv1 GetInterpolatedValue $xRight]
    Cawt CheckNumber 150.0 $yLeft   "GetInterpolatedValue: 1 CP at $xLeft"
    Cawt CheckNumber 150.0 $yInside "GetInterpolatedValue: 1 CP at $xInside"
    Cawt CheckNumber 150.0 $yRight  "GetInterpolatedValue: 1 CP at $xRight"

    set yLeft   [$crv1 GetInterpolatedValue $xLeft   -extrapolate]
    set yInside [$crv1 GetInterpolatedValue $xInside -extrapolate]
    set yRight  [$crv1 GetInterpolatedValue $xRight  -extrapolate]
    Cawt CheckNumber 150.0 $yLeft   "GetInterpolatedValue -extrapolate: 1 CP at $xLeft"
    Cawt CheckNumber 150.0 $yInside "GetInterpolatedValue -extrapolate: 1 CP at $xInside"
    Cawt CheckNumber 150.0 $yRight  "GetInterpolatedValue -extrapolate: 1 CP at $xRight"
}
puts ""

# Case: 2 control points.
$crv1 AddControlPoint {*}$cp1
Cawt CheckNumber 2 [$crv1 GetNumControlPoints] "Number of control points"
puts "Control points: [$crv1 GetControlPoints]"
foreach type [$crv1 GetInterpolationTypes] {
    $crv1 SetInterpolationType $type
    Cawt CheckString $type [$crv1 GetInterpolationType] "Interpolation type"

    set yLeft   [$crv1 GetInterpolatedValue $xLeft]
    set yInside [$crv1 GetInterpolatedValue $xInside]
    set yRight  [$crv1 GetInterpolatedValue $xRight]
    Cawt CheckNumber 100.0 $yLeft   "GetInterpolatedValue: 2 CP at $xLeft"
    Cawt CheckNumber 125.0 $yInside "GetInterpolatedValue: 2 CP at $xInside"
    Cawt CheckNumber 150.0 $yRight  "GetInterpolatedValue: 2 CP at $xRight"

    set yLeft   [$crv1 GetInterpolatedValue $xLeft   -extrapolate]
    set yInside [$crv1 GetInterpolatedValue $xInside -extrapolate]
    set yRight  [$crv1 GetInterpolatedValue $xRight  -extrapolate]
    Cawt CheckNumber  75.0 $yLeft   "GetInterpolatedValue -extrapolate: 2 CP at $xLeft"
    Cawt CheckNumber 125.0 $yInside "GetInterpolatedValue -extrapolate: 2 CP at $xInside"
    Cawt CheckNumber 200.0 $yRight  "GetInterpolatedValue -extrapolate: 2 CP at $xRight"

    foreach { x y } [$crv1 GetControlPoints] {
        DrawCross $c2($type) $x [expr { $canvHeight - $y - 1}]
    }
    set canvasCoords [ConvertCoords { x y } [$crv1 GetInterpolatedValues] { list $x [expr { $canvHeight - $y - 1}] }]
    $c2($type) create line $canvasCoords -fill green
}
puts ""

# Case: 3 or more control points.
$crv1 AddControlPoint {*}$cp3
Cawt CheckNumber 3 [$crv1 GetNumControlPoints] "Number of control points"
puts "Control points: [$crv1 GetControlPoints]"
foreach type [$crv1 GetInterpolationTypes] {
    $crv1 SetInterpolationType $type
    Cawt CheckString $type [$crv1 GetInterpolationType] "Interpolation type"

    set yLeft   [$crv1 GetInterpolatedValue $xLeft]
    set yInside [$crv1 GetInterpolatedValue $xInside]
    set yRight  [$crv1 GetInterpolatedValue $xRight]
    if { $type eq "Linear" } {
        Cawt CheckNumber 100.0    $yLeft   "GetInterpolatedValue: 3 CP at $xLeft"
        Cawt CheckNumber 125.0    $yInside "GetInterpolatedValue: 3 CP at $xInside"
        Cawt CheckNumber 100.0    $yRight  "GetInterpolatedValue: 3 CP at $xRight"
    } else {
        Cawt CheckNumber 100.0    $yLeft   "GetInterpolatedValue: 3 CP at $xLeft"
        Cawt CheckNumber 139.0625 $yInside "GetInterpolatedValue: 3 CP at $xInside"
        Cawt CheckNumber 100.0    $yRight  "GetInterpolatedValue: 3 CP at $xRight"
    }

    set yLeft   [$crv1 GetInterpolatedValue $xLeft   -extrapolate]
    set yInside [$crv1 GetInterpolatedValue $xInside -extrapolate]
    set yRight  [$crv1 GetInterpolatedValue $xRight  -extrapolate]
    if { $type eq "Linear" } {
        Cawt CheckNumber  75.0 $yLeft      "GetInterpolatedValue -extrapolate: 3 CP at $xLeft"
        Cawt CheckNumber 125.0 $yInside    "GetInterpolatedValue -extrapolate: 3 CP at $xInside"
        Cawt CheckNumber  50.0 $yRight     "GetInterpolatedValue -extrapolate: 3 CP at $xRight"
    } else {
        Cawt CheckNumber  60.9375 $yLeft   "GetInterpolatedValue -extrapolate: 3 CP at $xLeft"
        Cawt CheckNumber 139.0625 $yInside "GetInterpolatedValue -extrapolate: 3 CP at $xInside"
        Cawt CheckNumber  50.0    $yRight  "GetInterpolatedValue -extrapolate: 3 CP at $xRight"
    }

    foreach { x y } [$crv1 GetControlPoints] {
        DrawCross $c3($type) $x [expr { $canvHeight - $y - 1}]
    }
    set canvasCoords [ConvertCoords { x y } [$crv1 GetInterpolatedValues] { list $x [expr { $canvHeight - $y - 1}] }]
    $c3($type) create line $canvasCoords -fill green
}
puts ""

# Create an interpolation curve by adding the control points in the constructor.
set crv2 [Cawt Interpolate new {*}$cpList]
Cawt CheckNumber 3 [$crv2 GetNumControlPoints] "Number of control points"
puts "Control points: [$crv2 GetControlPoints]"
puts ""

puts "Checking interpolated values ..."
for { set x $xLeft } { $x <= $xRight } { incr x } {
    lappend y1List [$crv1 GetInterpolatedValue $x]
    lappend y2List [$crv2 GetInterpolatedValue $x]
}
Cawt CheckList $y1List $y2List "GetInterpolatedValue (crv1 vs. crv2)"

Cawt CheckList [$crv1 GetControlPoints] \
               [$crv2 GetControlPoints] \
               "GetControlPoints (crv1 vs. crv2)"
Cawt CheckList [$crv1 GetInterpolatedValues] \
               [$crv2 GetInterpolatedValues] \
               "GetInterpolatedValues (crv1 vs. crv2)"
Cawt CheckList [$crv1 GetInterpolatedValues -samples 5] \
               [$crv2 GetInterpolatedValues -samples 5] \
               "GetInterpolatedValues -samples 5 (crv1 vs. crv2)"
puts ""

# Delete an existing control point.
Cawt CheckBoolean 1 [$crv1 ControlPointExists 100] "Control point exists"
$crv1 DeleteControlPoint 100
Cawt CheckBoolean 0 [$crv1 ControlPointExists 100] "Control point exists"
Cawt CheckNumber 2 [$crv1 GetNumControlPoints] "Number of control points"

# Delete a non-existing control point.
$crv1 DeleteControlPoint 30
Cawt CheckNumber 2 [$crv1 GetNumControlPoints] "Number of control points"

# Delete all control points.
$crv1 Clear
Cawt CheckNumber 0 [$crv1 GetNumControlPoints] "Number of control points"

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
