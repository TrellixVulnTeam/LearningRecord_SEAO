# Test basic functionality of the CawtSapi package.
#
# Copyright: 2020-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Sapi Open]

puts [format "%-25s: %s" "Tcl version" [info patchlevel]]
puts [format "%-25s: %s" "Cawt version" $pkgVersion]
puts [format "%-25s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]

puts ""
puts "Sapi has [llength [Sapi GetEnumTypes]] enumeration types."
set exampleEnum [lindex [Sapi GetEnumTypes] end]
puts "  $exampleEnum names : [Sapi GetEnumNames $exampleEnum]"
puts -nonewline "  $exampleEnum values:"
foreach name [Sapi GetEnumNames $exampleEnum] {
    puts -nonewline " [Sapi GetEnumVal $name]"
}

puts ""

puts "Sapi has the following voices:"
foreach voiceName [Sapi GetVoiceNames $appId] {
    puts " $voiceName"
}

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
