# Test Check functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawtcore

Cawt CheckBoolean 1     1     "CheckBoolean 1 1"
Cawt CheckBoolean 0     0     "CheckBoolean 0 0"
Cawt CheckBoolean true  1     "CheckBoolean true 1"
Cawt CheckBoolean true  true  "CheckBoolean true true"
Cawt CheckBoolean false 0     "CheckBoolean false 0"
Cawt CheckBoolean false false "CheckBoolean false false"

Cawt CheckNumber 1   1     "CheckNumber 1 1"
Cawt CheckNumber 1.0 1     "CheckNumber 1.0 1"
Cawt CheckNumber 1   1.0   "CheckNumber 1 1.0"

Cawt CheckString 1    1    "CheckString 1 1"
Cawt CheckString Cawt Cawt "CheckString Cawt Cawt"

Cawt CheckList [list 1 2 3]  { 1 2 3 } "CheckList 1 2 3"

Cawt CheckMatrix [list [list 1 2] [list 3 4]]  { { 1 2 } { 3 4 } } "CheckMatrix { { 1 2 } { 3 4 } }"

Cawt CheckComObjects 1 "CheckComObjects"
puts "COM Objects: [Cawt GetComObjects]"

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
