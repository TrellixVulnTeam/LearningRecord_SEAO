# Test basic functionality of the CawtWord package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Word OpenNew false]

puts [format "%-25s: %s" "Tcl version" [info patchlevel]]
puts [format "%-25s: %s" "Cawt version" $pkgVersion]
puts [format "%-25s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]
puts [format "%-25s: %s (%s)" "Word version" \
                             [Word GetVersion $appId] \
                             [Word GetVersion $appId true]]
puts ""
puts [format "%-25s: %s" "Word filename extension" \
                             [Word GetExtString $appId]]

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

set docId [Word AddDocument $appId]

puts [format "%-30s: %s" "Appl. name (from Application)" [Office GetApplicationName $appId]]
puts [format "%-30s: %s" "Appl. name (from Document)"    [Office GetApplicationName $docId]]

puts [format "%-30s: %s" "Version (from Application)" [Word GetVersion $appId]]
puts [format "%-30s: %s" "Version (from Document)"    [Word GetVersion $docId]]

puts ""
puts "Word has [llength [Word GetEnumTypes]] enumeration types."
set exampleEnum [lindex [Word GetEnumTypes] 0]
puts "  $exampleEnum names : [Word GetEnumNames $exampleEnum]"
puts -nonewline "  $exampleEnum values:"
foreach name [Word GetEnumNames $exampleEnum] {
    puts -nonewline " [Word GetEnumVal $name]"
}

puts ""
Word Close $docId

Cawt PrintNumComObjects

Cawt CheckBoolean true [Cawt IsAppIdValid $appId] "IsAppIdValid"

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
    exit 0
}
Cawt Destroy
Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
