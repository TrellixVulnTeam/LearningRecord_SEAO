# Test file handling functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

set inPath  [file join [pwd] "testIn"]
set outPath [file join [pwd] "testOut"]
file mkdir $outPath

set tmpDir [Cawt GetTmpDir]
Cawt CheckBoolean true [file isdirectory $tmpDir] "GetTmpDir"

set nonUnicodeFile [file join $inPath "Holidays.hol"]
set unicodeFile    [file join $inPath "HolidaysUnicode.hol"]

set splitFilePrefix [file join $outPath "Cawt-05_FileSplit"]
set concatFile      [file join $outPath "Cawt-05_FileConcat"]

Cawt CheckFile $unicodeFile    $unicodeFile    "Compare identical files"
Cawt CheckFile $nonUnicodeFile $nonUnicodeFile "Compare identical files"

set fileList [Cawt SplitFile $unicodeFile 80 $splitFilePrefix]
Cawt CheckNumber  3 [llength $fileList] "SplitFile"
Cawt CheckNumber 80 [file size [lindex $fileList 0]] "File size of splitted file"

Cawt ConcatFiles $concatFile {*}$fileList
Cawt CheckFile $unicodeFile $concatFile "ConcatFiles"

Cawt CheckBoolean true  [Cawt IsUnicodeFile [file join $inPath "HolidaysUnicode.hol"]] "IsUnicodeFile"
Cawt CheckBoolean false [Cawt IsUnicodeFile [file join $inPath "Holidays.hol"]]        "IsUnicodeFile"

# First, try to get path to Acrobat Reader from Windows registry.
set progName [Cawt GetProgramByExtension ".xls"]
if { $progName ne "" } {
    puts "Starting and killing $progName ..."
    eval exec [list $progName] &
    after 1000
    Cawt KillApp [file tail $progName]
}

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
