# Test COM object functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

Cawt CheckNumber 1 [Cawt GetNumComObjects] "GetNumComObjects"
set appId [Cawt GetOrCreateApp "Excel.Application" false]
Cawt CheckNumber 2 [Cawt GetNumComObjects] "GetNumComObjects"
Cawt CheckBoolean true [Cawt IsComObject $appId]  "IsComObject"
Cawt CheckBoolean true [Cawt IsAppIdValid $appId] "IsAppIdValid"

Cawt PushComObjects
set appId [Cawt GetOrCreateApp "Word.Application" false]
Cawt PopComObjects
Cawt CheckNumber 2 [Cawt GetNumComObjects]        "GetNumComObjects"
Cawt CheckNumber 2 [llength [Cawt GetComObjects]] "GetComObjects"
Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"

Cawt PrintNumComObjects


if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
