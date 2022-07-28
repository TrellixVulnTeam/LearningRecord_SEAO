# Test speaking options of the CawtSapi package.
#
# Copyright: 2020-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set sapiId [Sapi Open]

lassign [Sapi GetSpeakOptions $sapiId -rate -volume] defRate defVolume
puts "Default rate and volume: $defRate $defVolume"

set rateValues  { -6 0 6 }
set rateStrings { slow medium fast }

foreach rate $rateValues str $rateStrings {
    set msg [format "Talking at %s rate" $str]
    puts "Speak \"$msg\""
    Sapi SetSpeakOptions $sapiId -rate $rate
    Sapi Speak $sapiId $msg
}

set volumeValues  { 10 50 100 }
set volumeStrings { low medium high }

Sapi SetSpeakOptions $sapiId -rate $defRate -volume $defVolume
foreach volume $volumeValues str $volumeStrings {
    set msg [format "Talking at %s volume" $str]
    puts "Speak \"$msg\""
    Sapi SetSpeakOptions $sapiId -volume $volume
    Sapi Speak $sapiId $msg
}

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
