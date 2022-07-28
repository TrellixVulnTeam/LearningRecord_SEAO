# Test appointment functionality of the CawtOutlook package.
# Note: This script sets appointments in your Outlook calendar. 
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set testCalName "CAWT Appointment Calendar"
set testCatName "CAWT Appointment Category"
set testNumAppoints 10

set appId [Outlook Open]

if { [Outlook HaveCalendar $appId $testCalName] } {
    set calId [Outlook GetCalendarId $appId $testCalName]
    Outlook DeleteCalendar $calId
}
puts "Adding calendar $testCalName"
set calId [Outlook AddCalendar $appId $testCalName]

Cawt CheckNumber 0 [Outlook GetNumAppointments $calId] "GetNumAppointments"

puts "Adding $testNumAppoints appointments"
set curDate [clock seconds]
for { set i 1 } { $i <= $testNumAppoints } { incr i } {
    set appointId [Outlook AddAppointment $calId \
        -subject     "Subject-$i" \
        -startdate   [Cawt SecondsToIsoDate $curDate] \
        -enddate     [Cawt SecondsToIsoDate [clock add $curDate 1 hour]] \
        -category    $testCatName \
        -location    "CAWT Room" \
        -body        "Appointment body text" \
        -alldayevent false \
        -reminder    false \
        -busystate   olFree \
        -importance  olImportanceHigh \
        -sensitivity olPrivate \
    ]
    set curDate [clock add $curDate 1 day]
    Cawt Destroy $appointId
}
Cawt CheckNumber $testNumAppoints [Outlook GetNumAppointments $calId] "GetNumAppointments"

for { set i 1 } { $i <= $testNumAppoints } { incr i } {
    set appointId [Outlook GetAppointmentByIndex $calId $i]
    Cawt CheckString "Subject-$i" [$appointId Subject] "GetAppointmentByIndex" false
    Cawt Destroy $appointId
}

puts "Removing first and last appointment"
Outlook DeleteAppointmentByIndex $calId 1
Outlook DeleteAppointmentByIndex $calId end
Cawt CheckNumber [expr $testNumAppoints - 2] [Outlook GetNumAppointments $calId] "GetNumAppointments"

set appointId [Outlook GetAppointmentByIndex $calId 1]

puts "Properties of first appointment:"
set propKeys [list -subject -startdate -enddate -location -body -alldayevent \
                   -reminder -isrecurring -busystate -importance -sensitivity]
set propVals [Outlook GetAppointmentProperties $appointId {*}$propKeys]
foreach key $propKeys val $propVals {
    puts [format "    %-12s: %s" $key $val]
}

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Outlook DeleteCategory $appId $testCatName
    Outlook DeleteCalendar $calId
    Outlook Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
