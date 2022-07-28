# Test basic functionality of the CawtOutlook package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Outlook Open ""]

puts [format "%-25s: %s" "Tcl version" [info patchlevel]]
puts [format "%-25s: %s" "Cawt version" $pkgVersion]
puts [format "%-25s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]
puts [format "%-25s: %s (%s)" "Outlook version" \
                             [Outlook GetVersion $appId] \
                             [Outlook GetVersion $appId true]]
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

puts [format "%-30s: %s" "Appl. name (from Application)" [Office GetApplicationName $appId]]

puts [format "%-30s: %s" "Version (from Application)" [Outlook GetVersion $appId]]

puts ""
puts "Outlook has [llength [Outlook GetEnumTypes]] enumeration types."
set exampleEnum [lindex [Outlook GetEnumTypes] end]
puts "  $exampleEnum names : [Outlook GetEnumNames $exampleEnum]"
puts -nonewline "  $exampleEnum values:"
foreach name [Outlook GetEnumNames $exampleEnum] {
    puts -nonewline " [Outlook GetEnumVal $name]"
}
puts ""

Cawt CheckNumber 25 [llength [Outlook GetCategoryColorNames]] "Number of category colors"

package require Tk
bind . <Escape> exit

set row 0
label .l_$row -text "Name"
label .e_$row -text "Value"
label .c_$row -text "Color"
grid .l_$row -row $row -column 0
grid .e_$row -row $row -column 1
grid .c_$row -row $row -column 2

set row 1
foreach colorName [lsort -dictionary [Outlook GetCategoryColorNames]] {
    label .l_$row -text $colorName
    label .e_$row -text [Outlook GetCategoryColorEnum $colorName]
    label .c_$row -bg [Outlook GetCategoryColor $colorName] -width 10
    grid .l_$row -row $row -column 0 -sticky w
    grid .e_$row -row $row -column 1 -sticky e
    grid .c_$row -row $row -column 2
    incr row
}
update

Cawt PrintNumComObjects

Cawt CheckBoolean true [Cawt IsAppIdValid $appId] "IsAppIdValid"

if { [lindex $argv 0] eq "auto" } {
    Outlook Quit $appId
    Cawt Destroy
    Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
    exit 0
}
Cawt Destroy
Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
