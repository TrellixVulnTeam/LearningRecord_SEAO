# Test holiday appointment functionality of the CawtOutlook package.
# Note: This script sets appointments in your Outlook calendar. 
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set testCalName  "CAWT Holiday Calendar"
set testCatName1 "CAWT ASCII File"
set testCatName2 "CAWT Unicode File"

set holidayAsciiFile   "testIn/Holidays.hol"
set holidayUnicodeFile "testIn/HolidaysUnicode.hol"

set appId [Outlook Open olFolderCalendar]

set numCats     [Outlook GetNumCategories $appId]
set catNameList [Outlook GetCategoryNames $appId]

puts "Existing categories:"
foreach catName $catNameList {
    puts "  $catName"
}

set catId1 [Outlook GetCategoryId $appId 1]
Cawt CheckString [lindex $catNameList 0] [$catId1 Name] "GetCategoryId Index"
set catId2 [Outlook GetCategoryId $appId [lindex $catNameList 2]]
Cawt CheckString [lindex $catNameList 2] [$catId2 Name] "GetCategoryId Name "

if { ! [Outlook HaveCategory $appId $testCatName1] } {
    puts "Adding category \"$testCatName1\""
    Outlook AddCategory $appId $testCatName1
    incr numCats
}
Cawt CheckNumber  $numCats [Outlook GetNumCategories $appId]           "AddCategory "
Cawt CheckBoolean true     [Outlook HaveCategory $appId $testCatName1] "HaveCategory"

set numCals     [Outlook GetNumCalendars $appId]
set calNameList [Outlook GetCalendarNames $appId]
puts "Existing calendars:"
foreach calName $calNameList {
    puts "  $calName"
}

if { [Outlook HaveCalendar $appId $testCalName] } {
    set calId [Outlook GetCalendarId $appId $testCalName]
    Outlook DeleteCalendar $calId
    incr numCals -1
}

puts "Adding calendar \"$testCalName\""
set calId [Outlook AddCalendar $appId $testCalName]
incr numCals

Cawt CheckNumber  $numCals [Outlook GetNumCalendars $appId]           "AddCalendar "
Cawt CheckBoolean true     [Outlook HaveCalendar $appId $testCalName] "HaveCalendar"

puts "Applying holiday file $holidayAsciiFile ..."
Outlook ApplyHolidayFile $calId $holidayAsciiFile $testCatName1

puts "Applying holiday file $holidayUnicodeFile ..."
Outlook ApplyHolidayFile $calId $holidayUnicodeFile $testCatName2

Cawt CheckNumber 6 [Outlook GetNumAppointments $calId] "GetNumAppointments"

Cawt PrintNumComObjects

puts "Note: This script has set appointments in calendar \"$testCalName\":"
set holidayDict [Outlook::ReadHolidayFile $holidayAsciiFile]
set sectionList [dict get $holidayDict SectionList]
foreach section $sectionList {
    set subjectList [dict get $holidayDict "SubjectList_$section"]
    set dateList    [dict get $holidayDict "DateList_$section"]
    foreach subject $subjectList date $dateList {
        puts "    $date : $subject"
    }
}

if { [lindex $argv 0] eq "auto" } {
    Outlook DeleteCategory $appId $testCatName1
    Outlook DeleteCategory $appId $testCatName2
    Outlook DeleteCalendar $calId
    Outlook Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
