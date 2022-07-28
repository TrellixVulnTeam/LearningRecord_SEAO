# Test speaking voices of the CawtSapi package.
#
# Copyright: 2020-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set sapiId [Sapi Open]

set voiceNames [Sapi GetVoiceNames $sapiId]

foreach voiceName $voiceNames {
    set voiceId [Sapi GetVoiceByName $sapiId $voiceName]
    puts "Speak \"$voiceName\""
    Sapi SetVoice $sapiId $voiceId
    Sapi Speak $sapiId $voiceName
}

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
