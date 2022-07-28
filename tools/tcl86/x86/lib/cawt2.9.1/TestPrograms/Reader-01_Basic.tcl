# Test basic functionality of the CawtReader package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set pdfFile1 [file join [pwd] "testIn" "CawtManual1.pdf"]
set pdfFile2 [file join [pwd] "testIn" "CawtManual2.pdf"]

puts "Starting Reader instance with file [file tail $pdfFile1] ..."
Reader OpenNew $pdfFile1 -page 5 -pagemode thumbs -toolbar false -zoom 100
after 1000

puts "Adding file in search mode [file tail $pdfFile2] ..."
Reader Open $pdfFile2 -search "detailed information" \
                      -pagemode bookmarks -toolbar false -zoom 50 

if { [lindex $argv 0] eq "auto" } {
    after 1000
    Reader Quit
    exit 0
}
exit 0
