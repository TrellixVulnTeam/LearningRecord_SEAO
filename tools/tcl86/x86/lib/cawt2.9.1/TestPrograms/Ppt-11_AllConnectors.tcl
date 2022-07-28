# Test CawtPpt procedure for creating all available connectors.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set appId [Ppt Open]
set presId [Ppt AddPres $appId]

# Delete PowerPoint file from previous test run.
file mkdir testOut
set pptFile [file join [pwd] "testOut" "Ppt-11_AllConnectors"]
append pptFile [Ppt GetExtString $appId]
file delete -force $pptFile

set slideId [Ppt AddSlide $presId]

set connTypeList [Office GetEnumNames MsoConnectorType]
set numConns [llength $connTypeList]

# Add all connectors available from enumeration Office::MsoConnectorType.
set top1  1
set top2  2
Cawt PushComObjects
foreach connType $connTypeList {
    set srcShape  [Ppt AddShape $slideId msoShapeRectangle  1c ${top1}c 8c 1c -textsize 12]
    set destShape [Ppt AddShape $slideId msoShapeRectangle 12c ${top2}c 1c 1c -textsize 12]
    Ppt ConfigureShape $srcShape -text "$connType" -fillcolor { 0 255 0 } -textcolor { 0 0 0 }
    set catchVal [ catch { Ppt ConnectShapes $slideId $srcShape $destShape \
                           -type $connType -fillcolor { 0 255 0 } } connId]
    if { $catchVal } {
        Ppt ConfigureShape $srcShape -text "$connType (N/A)" -fillcolor { 255 0 0 }
        puts "Warning: A connector of type $connType could not be created."
    } else {
        Ppt ConnectShapes $slideId $srcShape $destShape -fillcolor { 0 0 0 } \
                          -type $connType -beginsite 3 -endsite 4 -weight 0.1c
        incr top1 3
        incr top2 3
    }
}
Cawt PopComObjects

puts "Saving as PowerPoint file: $pptFile"
Ppt SaveAs $presId $pptFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
