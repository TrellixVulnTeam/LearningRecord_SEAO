# Test date conversion functionality of the CawtCore package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require cawt

set isoDate "2016-08-10 12:15:30"

set seconds1 [Cawt IsoDateToSeconds     $isoDate]
set xmlDate1 [Cawt IsoDateToXmlDate     $isoDate]
set olDate1  [Cawt IsoDateToOfficeDate  $isoDate]

set isoDate1 [Cawt SecondsToIsoDate     $seconds1]
set xmlDate2 [Cawt SecondsToXmlDate     $seconds1]
set olDate2  [Cawt SecondsToOfficeDate  $seconds1]

set isoDate2 [Cawt XmlDateToIsoDate $xmlDate2]
set seconds2 [Cawt XmlDateToSeconds $xmlDate2]

set isoDate3 [Cawt OfficeDateToIsoDate $olDate2]

Cawt CheckNumber $seconds1 $seconds2 "Seconds     "
Cawt CheckString $isoDate1 $isoDate2 "ISO dates   "
Cawt CheckString $xmlDate1 $xmlDate2 "XML dates   "
Cawt CheckNumber $olDate1  $olDate2  "Office dates"
Cawt CheckString $isoDate1 $isoDate3 "ISO dates   "

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
