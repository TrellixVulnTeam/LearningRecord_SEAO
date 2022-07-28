# Test speaking flags of the CawtSapi package.
#
# Copyright: 2020-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set sapiId [Sapi Open]

set msg "Speaking this sentence with default settings."
puts "Speak \"$msg\""
Sapi Speak $sapiId $msg

set msg "Speaking this sentence, with punctuation characters."
puts "Speak \"$msg\""
Sapi Speak $sapiId $msg -flags $Sapi::SVSFNLPSpeakPunc

set msg "Speaking this sentence asynchronously."
Sapi Speak $sapiId $msg -flags $Sapi::SVSFlagsAsync
puts "Speak \"$msg\""
while { ! [$sapiId WaitUntilDone 500] } {
    puts "  Still speaking ..."
}
puts "Speaking finished."

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
