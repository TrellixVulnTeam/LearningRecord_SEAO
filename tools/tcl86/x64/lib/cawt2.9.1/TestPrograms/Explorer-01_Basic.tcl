# Test basic functionality of the CawtExplorer package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Explorer OpenNew false]

puts [format "%-30s: %s" "Tcl version" [info patchlevel]]
puts [format "%-30s: %s" "Cawt version" $pkgVersion]
puts [format "%-30s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]

puts [format "%-30s: %s" "Active Printer" \
                        [Office GetActivePrinter $appId]]

puts [format "%-30s: %s" "User Name" \
                        [Office GetUserName $appId]]

puts [format "%-30s: %s" "Startup Pathname" \
                         [Office GetStartupPath $appId]]
puts [format "%-30s: %s" "Templates Pathname" \
                         [Office GetTemplatesPath $appId]]
puts [format "%-30s: %s" "Add-ins Pathname" \
                         [Office GetUserLibraryPath $appId]]
puts [format "%-30s: %s" "Installation Pathname" \
                         [Office GetInstallationPath $appId]]
puts [format "%-30s: %s" "User Folder Pathname" \
                         [Office GetUserPath $appId]]

puts [format "%-30s: %s" "Appl. name (from Application)" \
         [Office GetApplicationName $appId]]

Cawt CheckBoolean true [Cawt IsAppIdValid $appId] "IsAppIdValid"

if { [lindex $argv 0] eq "auto" } {
    Explorer Quit $appId
    Cawt Destroy
    Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
    exit 0
}
Cawt Destroy
Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
