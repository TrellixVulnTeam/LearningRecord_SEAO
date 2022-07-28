# Test basic functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

# Load CAWT as a complete package and all sub-packages.
set retVal [catch {package require cawt} cawtVersion]
set retVal [catch {package require Img} imgVersion]
set retVal [catch {package require tablelist} tblVersion]
set retVal [catch {package require base64} base64Version]

puts [format "%-25s: %s (%d-bit)" "Tcl version" [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]] 

puts [format "%-25s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]
puts [format "%-25s: %s" "tDOM version"  [Cawt GetPkgVersion "tdom"]]
puts [format "%-25s: %s" "Img version" $imgVersion]
puts [format "%-25s: %s" "Tablelist version" $tblVersion]
puts [format "%-25s: %s" "Base64 version" $base64Version]
puts ""
puts [format "%-25s: %s" "CAWT version" $cawtVersion]
puts ""
puts [format "%-25s: %s" "CawtCore version"     [Cawt GetPkgVersion "cawtcore"]]
puts [format "%-25s: %s" "CawtOffice version"   [Cawt GetPkgVersion "cawtoffice"]]
puts [format "%-25s: %s" "CawtEarth version"    [Cawt GetPkgVersion "cawtearth"]]
puts [format "%-25s: %s" "CawtExcel version"    [Cawt GetPkgVersion "cawtexcel"]]
puts [format "%-25s: %s" "CawtExplorer version" [Cawt GetPkgVersion "cawtexplorer"]]
puts [format "%-25s: %s" "CawtMatlab version"   [Cawt GetPkgVersion "cawtmatlab"]]
puts [format "%-25s: %s" "CawtOcr version"      [Cawt GetPkgVersion "cawtocr"]]
puts [format "%-25s: %s" "CawtOneNote version"  [Cawt GetPkgVersion "cawtonenote"]]
puts [format "%-25s: %s" "CawtOutlook version"  [Cawt GetPkgVersion "cawtoutlook"]]
puts [format "%-25s: %s" "CawtPpt version"      [Cawt GetPkgVersion "cawtppt"]]
puts [format "%-25s: %s" "CawtWord version"     [Cawt GetPkgVersion "cawtword"]]
puts ""

Cawt CheckBoolean 1 [Cawt HavePkg "cawtexcel"]    "HavePkg cawtexcel"
Cawt CheckBoolean 0 [Cawt HavePkg "cawtunknown"]  "HavePkg cawtunknown"
puts ""

Cawt CheckNumber 72.0 [Cawt InchesToPoints 1]  "InchesToPoints"
Cawt CheckNumber  1.0 [Cawt PointsToInches 72] "PointsToInches"

Cawt CheckNumber 1.0 [Cawt PointsToInches      [Cawt InchesToPoints      1]] "InchesToPoints"
Cawt CheckNumber 1.0 [Cawt PointsToCentiMeters [Cawt CentiMetersToPoints 1]] "CentiMetersToPoints"
puts ""

Cawt CheckNumber [Cawt CentiMetersToPoints 1] [Cawt ValueToPoints 1c] "ValueToPoints 1c"
Cawt CheckNumber [Cawt InchesToPoints 1]      [Cawt ValueToPoints 1i] "ValueToPoints 1i"
Cawt CheckNumber 1                            [Cawt ValueToPoints 1p] "ValueToPoints 1p"
Cawt CheckNumber 1                            [Cawt ValueToPoints 1]  "ValueToPoints 1 "
puts ""

Cawt CheckBoolean true  [Cawt TclBool 3]  "TclBool 3"
Cawt CheckBoolean true  [Cawt TclBool 1]  "TclBool 1"
Cawt CheckBoolean false [Cawt TclBool 0]  "TclBool 0"

Cawt CheckBoolean 1 [Cawt TclInt 3]  "TclInt 3"
Cawt CheckBoolean 1 [Cawt TclInt 1]  "TclInt 1"
Cawt CheckBoolean 0 [Cawt TclInt 0]  "TclInt 0"

Cawt CheckString "Cawt"  [Cawt TclString "Cawt"]  "TclString Cawt"
puts ""

Cawt CheckNumber  72  [Cawt GetDotsPerInch]  "GetDotsPerInch"
Cawt SetDotsPerInch 132
Cawt CheckNumber 132  [Cawt GetDotsPerInch]  "GetDotsPerInch"
puts ""

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
