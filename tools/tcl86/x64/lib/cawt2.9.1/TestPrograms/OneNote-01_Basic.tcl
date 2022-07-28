# Test basic functionality of the CawtOneNote package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set oneNoteId [OneNote Open]
set appId [OneNote GetApplicationId $oneNoteId]

puts [format "%-25s: %s" "Tcl version" [info patchlevel]]
puts [format "%-25s: %s" "Cawt version" $pkgVersion]
puts [format "%-25s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]
puts [format "%-25s: %s" "tDOM version" [Cawt GetPkgVersion "tdom"]]
puts [format "%-25s: %s (%s)" "OneNote version" \
                             [OneNote GetVersion $appId] \
                             [OneNote GetVersion $appId true]]
puts ""
puts [format "%-25s: %s" "Active Printer" \
                        [Office GetActivePrinter $appId]]

puts [format "%-25s: %s" "User Name" \
                        [Office GetUserName $appId]]

puts [format "%-25s: %s" "Startup Pathname" \
                         [Office GetStartupPath $appId]]
puts [format "%-25s: %s" "Templates Pathname" \
                         [Office GetTemplatesPath $appId]]
puts [format "%-25s: %s" "Add-ins Pathname" \
                         [Office GetUserLibraryPath $appId]]
puts [format "%-25s: %s" "Installation Pathname" \
                         [Office GetInstallationPath $appId]]
puts [format "%-25s: %s" "User Folder Pathname" \
                         [Office GetUserPath $appId]]

puts ""
puts "OneNote has [llength [OneNote GetEnumTypes]] enumeration types."
set exampleEnum [lindex [OneNote GetEnumTypes] end]
puts "  $exampleEnum names : [OneNote GetEnumNames $exampleEnum]"
puts -nonewline "  $exampleEnum values:"
foreach name [OneNote GetEnumNames $exampleEnum] {
    puts -nonewline " [OneNote GetEnumVal $name]"
}

puts ""

if { [lindex $argv 0] eq "auto" } {
    OneNote Quit $oneNoteId
    Cawt Destroy
    exit 0
}
Cawt Destroy
