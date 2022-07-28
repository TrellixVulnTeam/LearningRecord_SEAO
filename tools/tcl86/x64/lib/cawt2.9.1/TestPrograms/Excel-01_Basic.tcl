# Test basic functionality of the CawtExcel package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Excel OpenNew false]

puts [format "%-30s: %s" "Tcl version" [info patchlevel]]
puts [format "%-30s: %s" "Cawt version" $pkgVersion]
puts [format "%-30s: %s" "Twapi version" [Cawt GetPkgVersion "twapi"]]
puts [format "%-30s: %s (%s)" "Excel version" \
                             [Excel GetVersion $appId] \
                             [Excel GetVersion $appId true]]
puts ""
puts [format "%-30s: %s" "Excel filename extension" \
                             [Excel GetExtString $appId]]

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

set workbookId [Excel AddWorkbook $appId]
set worksheetId [Excel GetWorksheetIdByIndex $workbookId 1]
set cellsId [Excel GetCellsId $worksheetId]

puts [format "%-30s: %s" "Appl. name (from Application)" [Office GetApplicationName $appId]]
puts [format "%-30s: %s" "Appl. name (from Workbook)"    [Office GetApplicationName $workbookId]]
puts [format "%-30s: %s" "Appl. name (from Worksheet)"   [Office GetApplicationName $worksheetId]]
puts [format "%-30s: %s" "Appl. name (from Cells)"       [Office GetApplicationName $cellsId]]

puts [format "%-30s: %s" "Version (from Application)" [Excel GetVersion $appId]]
puts [format "%-30s: %s" "Version (from Workbook)"    [Excel GetVersion $workbookId]]
puts [format "%-30s: %s" "Version (from Worksheet)"   [Excel GetVersion $worksheetId]]
puts [format "%-30s: %s" "Version (from Cells)"       [Excel GetVersion $cellsId]]

puts [format "%-30s: %s" "Floating point separator" [Excel GetDecimalSeparator   $appId]]
puts [format "%-30s: %s" "Thousands separator"      [Excel GetThousandsSeparator $appId]]

Cawt CheckNumber  1 [Excel ColumnCharToInt A] "ColumnCharToInt A"
Cawt CheckNumber 13 [Excel ColumnCharToInt M] "ColumnCharToInt M"
Cawt CheckNumber 26 [Excel ColumnCharToInt Z] "ColumnCharToInt Z"

Cawt CheckString "B:G" [Excel GetColumnRange 2 7] "GetColumnRange 2 7"
Cawt CheckString "B1:G5" [Excel GetCellRange 1 2  5 7] "GetCellRange (1,2) (5,7)"

puts "Printing ColumnIntToChar conversions:"
for { set col 1 } { $col <= 100 } { incr col } {
    if { $col % 10 == 1 } {
        puts -nonewline [format "%3d: " $col]
    }
    set colStr [Excel ColumnIntToChar $col]
    puts -nonewline [format "%3s " $colStr]
    if { $col % 10 == 0 } {
        puts ""
    }
}

set maxCols [Excel GetNumColumns $worksheetId]
puts "Testing column conversion procedures (both directions for $maxCols columns) ..."
for { set col 1 } { $col <= $maxCols } { incr col } {
    set colStr [Excel ColumnIntToChar $col]
    set colNum [Excel ColumnCharToInt $colStr]
    Cawt CheckNumber $col $colNum "Convert column indices. Column number $col" false
    set colNum1 [Excel GetColumnNumber $colStr]
    set colNum2 [Excel GetColumnNumber $col]
    Cawt CheckNumber $colNum1 $colNum2 "GetColumnNumber. Column number $col" false
}

puts ""
puts "Excel has [llength [Excel GetEnumTypes]] enumeration types."
set exampleEnum [lindex [Excel GetEnumTypes] end]
puts "  $exampleEnum names : [Excel GetEnumNames $exampleEnum]"
puts -nonewline "  $exampleEnum values:"
foreach name [Excel GetEnumNames $exampleEnum] {
    puts -nonewline " [Excel GetEnumVal $name]"
}

puts ""

Excel Close $workbookId

Cawt PrintNumComObjects

Cawt CheckBoolean true [Cawt IsAppIdValid $appId] "IsAppIdValid"

if { [lindex $argv 0] eq "auto" } {
    Excel Quit $appId
    Cawt Destroy
    Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
    exit 0
}
Cawt Destroy
Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
