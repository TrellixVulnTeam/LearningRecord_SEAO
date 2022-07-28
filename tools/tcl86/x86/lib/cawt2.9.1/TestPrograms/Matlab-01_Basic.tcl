# Test basic functionality of the CawtMatlab package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Matlab OpenNew]

puts [format "%-25s: %s" "Tcl version" [info patchlevel]]
puts [format "%-25s: %s" "Cawt version" $pkgVersion]
puts [format "%-25s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]

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

if { [lindex $argv 0] eq "auto" } {
    Matlab Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
