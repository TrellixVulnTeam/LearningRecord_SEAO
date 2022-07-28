# Test string functionalities of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

set numRepeats 2000
set myStr "A 12 AB ABC ABCD ABCDE ABCDEF"
set testStr [string repeat $myStr $numRepeats]
set procArgs "-minlength 2 -maxlength 5 -shownumbers false"

proc PrintAndCheckWordList { wordList } {
    foreach { word count } $wordList {
        Cawt CheckNumber $::numRepeats $count "Word count of $word" false
        puts [format "%-6s: %d" $word $count]
    }
    Cawt CheckNumber 4 [expr [llength $wordList] / 2] "Number of found words"
}

puts "Using Cawt::CountWords as coroutine ..."
coroutine CountWords Cawt::CountWords $testStr {*}$procArgs
while { 1 } {
    set retVal [CountWords]
    if { [string is integer -strict $retVal] } {
        set percent [expr int (100.0 * double ($retVal) / [string length $testStr])]
        puts -nonewline "\b\b\b$percent%" ; flush stdout
    } else {
        break
    }
}
puts ""
PrintAndCheckWordList $retVal
puts ""

puts "Using Cawt::CountWords as standard procedure ..."
set wordList [Cawt CountWords $testStr {*}$procArgs]
PrintAndCheckWordList $wordList

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
