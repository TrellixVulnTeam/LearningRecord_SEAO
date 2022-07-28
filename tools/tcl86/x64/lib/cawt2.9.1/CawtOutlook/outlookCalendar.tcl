# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export AddAppointment
    namespace export AddCalendar
    namespace export AddHolidayAppointment
    namespace export ApplyHolidayFile
    namespace export DeleteAppointmentByIndex
    namespace export DeleteCalendar
    namespace export GetAppointmentByIndex
    namespace export GetAppointmentProperties
    namespace export GetCalendarId
    namespace export GetCalendarNames
    namespace export GetNumAppointments
    namespace export GetNumCalendars
    namespace export HaveCalendar
    namespace export ReadHolidayFile

    proc GetCalendarNames { appId } {
        # Get a list of Outlook calendar names.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of calendar names.
        #
        # See also: AddCalendar DeleteCalendar GetNumCalendars HaveCalendar GetCalendarId

        Cawt PushComObjects
        set calendarNameList [list]
        foreach { name calId } [Outlook::GetFoldersRecursive $appId $Outlook::olAppointmentItem] {
            lappend calendarNameList $name
        }
        Cawt PopComObjects
        return $calendarNameList
    }

    proc GetNumCalendars { appId } {
        # Get the number of Outlook calendars.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns the number of Outlook calendars.
        #
        # See also: AddCalendar DeleteCalendar HaveCalendar GetCalendarNames GetCalendarId

        return [llength [Outlook::GetCalendarNames $appId]]
    }

    proc HaveCalendar { appId calendarName } {
        # Check, if an Outlook calendar exists.
        #
        # appId        - Identifier of the Outlook instance.
        # calendarName - Name of the calendar to check.
        #
        # Returns true, if the calendar exists, otherwise false.
        #
        # See also: AddCalendar DeleteCalendar GetNumCalendars GetCalendarNames GetCalendarId

        if { [lsearch -exact [Outlook::GetCalendarNames $appId] $calendarName] >= 0 } {
            return true
        } else {
            return false
        }
    }

    proc GetCalendarId { appId { calendarName "" } } {
        # Get an Outlook calendar by its name.
        #
        # appId        - Identifier of the Outlook instance.
        # calendarName - Name of the calendar to find.
        #
        # Returns the identifier of the found calendar.
        # If $calendarName is not specified or the empty string, the identifier
        # of the default calendar is returned.
        #
        # If a calendar with given name does not exist, an empty string is returned.
        #
        # See also: AddCalendar DeleteCalendar GetNumCalendars HaveCalendar GetCalendarNames

        if { $calendarName eq "" } {
            set nsObj [$appId GetNamespace "MAPI"]
            set calId [$nsObj GetDefaultFolder $Outlook::olFolderCalendar]
            Cawt Destroy $nsObj
            return $calId
        }
        set foundId ""
        foreach { name calId } [Outlook::GetFoldersRecursive $appId $Outlook::olAppointmentItem] {
            if { $name eq $calendarName } {
                set foundId $calId
            } else {
                Cawt Destroy $calId
            }
        }
        return $foundId
    }

    proc AddCalendar { appId calendarName } {
        # Add a new Outlook calendar.
        #
        # appId        - Identifier of the Outlook instance.
        # calendarName - Name of the new calendar.
        #
        # Returns the identifier of the new calendar.
        # If a calendar with given name is already existing, the identifier of that
        # calendar is returned.
        #
        # If the calendar could not be added an error is thrown.
        #
        # See also: AddAppointment DeleteCalendar GetNumCalendars HaveCalendar
        # GetCalendarNames GetCalendarId

        set nsObj [$appId GetNamespace "MAPI"]
        set calId [$nsObj GetDefaultFolder $Outlook::olFolderCalendar]
        set numFolders [$calId -with {Folders} Count]
        for { set i 1 } { $i <= $numFolders } { incr i } {
            set folderId [$calId -with {Folders} Item [expr {$i}]]
            if { [$folderId Name] eq $calendarName } {
                return $folderId
            }
            Cawt Destroy $folderId
        }
        set catchVal [catch {$calId -with { Folders } Add \
                      $calendarName $Outlook::olFolderCalendar} newCalId]
        if { $catchVal != 0 } {
            error "AddCalendar: Could not add calendar \"$calendarName\"."
        }
        Cawt Destroy $calId
        Cawt Destroy $nsObj
        return $newCalId
    }

    proc DeleteCalendar { calId } {
        # Delete an Outlook calendar.
        #
        # calId - Identifier of the Outlook calendar.
        #
        # Returns no value.
        #
        # See also: AddCalendar GetNumCalendars HaveCalendar GetCalendarNames GetCalendarId

        $calId Delete
    }

    proc GetNumAppointments { calId } {
        # Get the number of appointments in an Outlook calendar.
        #
        # calId - Identifier of the Outlook calendar.
        #
        # Returns the number of Outlook appointments.
        #
        # See also: AddCalendar AddAppointment GetAppointmentByIndex DeleteAppointmentByIndex

        set count [$calId -with { Items } Count]
        return $count
    }

    proc GetAppointmentByIndex { calId index } {
        # Get an appointment of an Outlook calendar by its index.
        #
        # calId - Identifier of the Outlook calendar.
        # index - Index of the appointment.
        #
        # Returns the identifier of the found appointment.
        #
        # The first appointment has index 1.
        # Instead of using the numeric index the special word `end` may
        # be used to specify the last appointment.
        # If the index is out of bounds an error is thrown.
        #
        # See also: AddCalendar AddAppointment GetNumAppointments DeleteAppointmentByIndex

        set count [Outlook::GetNumAppointments $calId]
        if { $index eq "end" } {
            set index $count
        } else {
            if { $index < 1 || $index > $count } {
                error "GetAppointmentByIndex: Invalid index $index given."
            }
        }

        set itemId [$calId -with { Items } Item [expr {$index}]]
        return $itemId
    }

    proc DeleteAppointmentByIndex { calId index } {
        # Delete an appointment of an Outlook calendar by its index.
        #
        # calId - Identifier of the Outlook calendar.
        # index - Index of the appointment.
        #
        # Returns no value.
        #
        # The first appointment has index 1.
        # Instead of using the numeric index the special word `end` may
        # be used to specify the last appointment.
        # If the index is out of bounds an error is thrown.
        #
        # See also: AddCalendar AddAppointment GetNumAppointments GetAppointmentByIndex 

        set count [Outlook::GetNumAppointments $calId]
        if { $index eq "end" } {
            set index $count
        } else {
            if { $index < 1 || $index > $count } {
                error "DeleteAppointmentByIndex: Invalid index $index given."
            }
        }
        $calId -with { Items } Remove [expr {$index}]
    }

    proc GetAppointmentProperties { appointId args } {
        # Get properties of an Outlook appointment.
        #
        # appointId - Identifier of the Outlook appointment.
        # args      - List of keys specifying appointment configure options.
        #
        # See [AddAppointment] for a list of configure options.
        #
        # Returns the appointment properties as a list of values.
        # The list elements have the same order as the list of keys.
        #
        # See also: AddCalendar AddAppointment GetNumAppointments GetAppointmentByIndex

        set valueList [list]
        foreach key $args {
            switch -exact -nocase -- $key {
                "-subject" {
                    lappend valueList [$appointId Subject]
                }
                "-startdate" {
                    lappend valueList [Cawt OfficeDateToIsoDate [$appointId Start]]
                }
                "-enddate" {
                    lappend valueList [Cawt OfficeDateToIsoDate [$appointId End]]
                }
                "-category" {
                    lappend valueList [$appointId Categories]
                }
                "-location" {
                    lappend valueList [$appointId Location]
                }
                "-body" {
                    lappend valueList [$appointId Body]
                }
                "-alldayevent" {
                    lappend valueList [$appointId AllDayEvent]
                }
                "-reminder" {
                    lappend valueList [$appointId ReminderSet]
                }
                "-busystate" {
                    lappend valueList [Outlook GetEnumName OlBusyStatus [$appointId BusyStatus]]
                }
                "-importance" {
                    lappend valueList [Outlook GetEnumName OlImportance [$appointId Importance]]
                }
                "-sensitivity" {
                    lappend valueList [Outlook GetEnumName OlSensitivity [$appointId Sensitivity]]
                }
                "-isrecurring" {
                    lappend valueList [$appointId IsRecurring]
                }
                default {
                    error "GetAppointmentProperties: Unknown key \"$key\" specified" 
                }
            }
        }
        return $valueList
    }

    proc AddAppointment { calId args } {
        # Create a new appointment in an Outlook calendar.
        #
        # calId - Identifier of the Outlook calendar.
        # args  - Options described below.
        #
        # -subject <string>            - Set the subject text of the appointment.
        #                                Default: No subject.
        # -startdate <string>          - Set the start date of the appointment in format `%Y-%m-%d %H:%M:%S`.
        #                                Default: Today.
        # -enddate <string>            - Set the end date of the appointment in format `%Y-%m-%d %H:%M:%S`.
        #                                Default: Today.
        # -category <string>           - Assign category to appointment.
        #                                If specified category does not yet exist, it is created. 
        #                                Default: No category.
        # -location <string>           - Set the location of the appointment.
        #                                Default: No location.
        # -body <string>               - Set the body text of the appointment.
        #                                Default: No body text.
        # -alldayevent <bool>          - Specify, if appointment is an all day event.
        #                                Default: false.
        # -reminder <bool>             - Specify, if appointment has a reminder set.
        #                                Default: true.
        # -busystate <OlBusyStatus>    - Set the busy status of the appointment.
        #                                Possible values: `olBusy` `olFree` `olOutOfOffice` `olTentative` `olWorkingElsewhere`.
        #                                Default: `olBusy`.
        # -importance <OlImportance>   - Set the importance of the appointment.
        #                                Possible values: `olImportanceHigh` `olImportanceLow` `olImportanceNormal`.
        #                                Default: `olImportanceNormal`.
        # -sensitivity <OlSensitivity> - Set the sensitivity of the appointment.
        #                                Possible values: `olConfidential` `olNormal` `olPersonal` `olPrivate`.
        #                                Default: `olNormal`.
        # -isrecurring                  - Get the recurring flag of the appointment.
        #                                 Only available for procedure [GetAppointmentProperties].
        #
        # Returns the identifier of the new appointment object.
        #
        # See also: CreateMail AddCalendar AddHolidayAppointment GetAppointmentProperties GetNumAppointments

        set appointId [$calId -with { Items } Add $Outlook::olAppointmentItem]

        foreach { key value } $args {
            if { $value eq "" } {
                error "AddAppointment: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-subject" {
                    $appointId Subject $value
                }
                "-startdate" {
                    $appointId Start [Cawt IsoDateToOfficeDate $value]
                }
                "-enddate" {
                    $appointId End [Cawt IsoDateToOfficeDate $value]
                }
                "-category" {
                    set appId [$calId Application]
                    Outlook AddCategory $appId $value
                    $appointId Categories $value
                    Cawt Destroy $appId
                }
                "-location" {
                    $appointId Location $value
                }
                "-body" {
                    $appointId Body $value
                }
                "-alldayevent" {
                    $appointId AllDayEvent [Cawt TclBool $value]
                }
                "-reminder" {
                    $appointId ReminderSet [Cawt TclBool $value]
                }
                "-busystate" {
                    $appointId BusyStatus [Outlook GetEnum $value]
                }
                "-importance" {
                    $appointId Importance [Outlook GetEnum $value]
                }
                "-sensitivity" {
                    $appointId Sensitivity [Outlook GetEnum $value]
                }
                default {
                    error "AddAppointment: Unknown key \"$key\" specified" 
                }
            }
        }
        $appointId Save
        return $appointId
    }

    proc AddHolidayAppointment { calId subject args } {
        # Create a new appointment in an Outlook calendar.
        #
        # calId   - Identifier of the Outlook calendar.
        # subject - Subject text.
        # args    - Options described below.
        #
        # -date <string>     - Set the date of the appointment in format `%Y-%m-%d`. Default: Today.
        # -category <string> - Assign category to appointment. Default: No category.
        # -location <string> - Set the location of the appointment. Default: No location.
        #
        # The appointment has the following properties automatically set:
        #   `All-Day event`, `No reminder`, `OutOfOffice status`.
        #
        # Returns the identifier of the new appointment object.
        #
        # See also: CreateMail AddAppointment ApplyHolidayFile GetNumAppointments

        set appointId [$calId -with { Items } Add $Outlook::olAppointmentItem]
        foreach { key value } $args {
            if { $value eq "" } {
                error "AddHolidayAppointment: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-date"     { 
                                set dateSec [clock scan $value -format "%Y-%m-%d"]
                                $appointId Start [Cawt SecondsToOfficeDate $dateSec]
                            }
                "-category" {
                                if { $value ne "" } {
                                    set appId [$calId Application]
                                    Outlook AddCategory $appId $value
                                    $appointId Categories $value
                                    Cawt Destroy $appId
                                }
                            }
                "-location" { $appointId Location $value }
                default     { error "AddHolidayAppointment: Unknown key \"$key\" specified" }
            }
        }

        $appointId Subject $subject
        $appointId AllDayEvent [Cawt TclBool true]
        $appointId ReminderSet [Cawt TclBool false]
        $appointId BusyStatus $Outlook::olOutOfOffice
        
        $appointId Save

        return $appointId
    }

    proc ReadHolidayFile { fileName } {
        # Read an Outlook holiday file.
        #
        # fileName - Name of the Outlook holiday file.
        #
        # The data of the holiday file is returned as a dict with the following keys:
        # `SectionList` - The list of sections in the holiday file.
        #
        # For each section the following keys are set:
        #  `SubjectList_$section` - The list of subjects of this section.
        #  `DateList_$section`    - The list of dates of this section.
        #
        # Returns the data of the holiday file as a dictionary.
        # If the holiday file could not be read, an error is thrown.
        #
        # See also: AddHolidayAppointment ApplyHolidayFile

        set isUnicodeFile [Cawt IsUnicodeFile $fileName]

        set catchVal [catch {open $fileName r} fp]
        if { $catchVal != 0 } {
            error "ReadHolidayFile: Could not open file \"$fileName\" for reading."
        }

        if { $isUnicodeFile } {
            # If Unicode, skip the 2 BOM bytes and set appropriate encoding.
            set bom [read $fp 2]
            fconfigure $fp -encoding unicode
        }

        set holidayDict [dict create]
        dict set emptyDict   SectionList [list]
        dict set holidayDict SectionList [list]

        while { [gets $fp line] >= 0 } {
            if { [string length $line] == 0 } {
                continue
            }
            if { [string index $line 0] eq "\[" } {
                set endRange [string first "\]" $line]
                if { $endRange < 0 } {
                    return $emptyDict
                }
                set sectionName [string range $line 1 [expr {$endRange - 1}]]
                dict lappend holidayDict SectionList $sectionName
            } else {
                set nameDateList [split $line ","]
                if { [llength $nameDateList] == 2 } {
                    lassign $nameDateList name date
                    set isoDate [string map { "/" "-" } $date]
                    dict lappend holidayDict "SubjectList_$sectionName" $name
                    dict lappend holidayDict "DateList_$sectionName"    $isoDate
                } else {
                    return $emptyDict
                }
            }
        }
        close $fp
        return $holidayDict
    }

    proc ApplyHolidayFile { calId fileName { category "" } } {
        # Read an Outlook holiday file and insert appointments.
        #
        # calId    - Identifier of the Outlook calendar.
        # fileName - Name of the Outlook holiday file.
        # category - Assign category to appointment. Default: No category.
        #
        # Returns no value.
        # If the holiday file could not be read, an error is thrown.
        #
        # See also: ReadHolidayFile AddHolidayAppointment

        set holidayDict [Outlook::ReadHolidayFile $fileName]
        set sectionList [dict get $holidayDict SectionList]
        foreach section $sectionList {
            set subjectList [dict get $holidayDict "SubjectList_$section"]
            set dateList    [dict get $holidayDict "DateList_$section"]
            foreach subject $subjectList date $dateList {
                Outlook::AddHolidayAppointment $calId $subject \
                    -date $date \
                    -location $section \
                    -category $category
            }
        }
    }
}
