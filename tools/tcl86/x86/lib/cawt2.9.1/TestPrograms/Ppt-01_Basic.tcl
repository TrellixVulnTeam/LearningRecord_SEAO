# Test basic functionality of the CawtPpt package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Ppt OpenNew]

puts [format "%-25s: %s" "Tcl version" [info patchlevel]]
puts [format "%-25s: %s" "Cawt version" $pkgVersion]
puts [format "%-25s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]
puts [format "%-25s: %s (%s)" "PowerPoint version" \
                             [Ppt GetVersion $appId] \
                             [Ppt GetVersion $appId true]]
puts ""
puts [format "%-25s: %s" "PowerPoint extension" \
                             [Ppt GetExtString $appId]]

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

set presId [Ppt AddPres $appId]

puts [format "%-30s: %s" "Appl. name (from Application)"  [Office GetApplicationName $appId]]
puts [format "%-30s: %s" "Appl. name (from Presentation)" [Office GetApplicationName $presId]]

puts [format "%-30s: %s" "Version (from Application)"  [Ppt GetVersion $appId]]
puts [format "%-30s: %s" "Version (from Presentation)" [Ppt GetVersion $presId]]

puts ""
puts "PowerPoint has [llength [Ppt GetEnumTypes]] enumeration types."
set exampleEnum [lindex [Ppt GetEnumTypes] 0]
puts "  $exampleEnum names : [Ppt GetEnumNames $exampleEnum]"
puts -nonewline "  $exampleEnum values:"
foreach name [Ppt GetEnumNames $exampleEnum] {
    puts -nonewline " [Ppt GetEnumVal $name]"
}

puts ""
Cawt CheckBoolean true [Ppt IsValidPresId $presId] "IsValidPresId"
Ppt Close $presId
Cawt CheckBoolean false [Ppt IsValidPresId $presId] "IsValidPresId"

Cawt PrintNumComObjects

Cawt CheckBoolean true [Cawt IsAppIdValid $appId] "IsAppIdValid"

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
    exit 0
}
Cawt Destroy
Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
