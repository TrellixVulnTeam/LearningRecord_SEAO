# Test contact functionality of the CawtOutlook package.
#
# Copyright: 2007-2020 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Options for more test output.
set optPrintExistingFolders     true
set optPrintContactOrder        true
set optPrintAllProperties       false
set optAddAppointmentProperties false

set testContactFolderName "CAWT Test Contacts"
set testCatName           "CAWT Contact Category"
set testNumContacts       5

set contactImgTemplate "testIn/Cawt-%03d.png"

set appId [Outlook Open olFolderContacts]

set numFolders            [Outlook GetNumContactFolders $appId]
set contactFolderNameList [Outlook GetContactFolderNames $appId]

if { $optPrintExistingFolders } {
    puts "Existing contact folders:"
    foreach name $contactFolderNameList {
        set contactFolderId [Outlook GetContactFolderId $appId $name]
        set numContacts [Outlook GetNumContacts $contactFolderId]
        if { $numContacts < 0 } {
            puts "  \"$name\" is not accessible. Folder path: \"[$contactFolderId FolderPath]\""
        } else {
            puts "  \"$name\" has $numContacts contacts. Folder path: \"[$contactFolderId FolderPath]\""
        }
    }
}

if { [Outlook HaveContactFolder $appId $testContactFolderName] } {
    puts "Deleting contact folder \"$testContactFolderName\""
    set contactFolderId [Outlook GetContactFolderId $appId $testContactFolderName]
    Outlook DeleteContactFolder $contactFolderId
    incr numFolders -1
}

puts "Adding contact folder \"$testContactFolderName\""
set contactFolderId [Outlook AddContactFolder $appId $testContactFolderName -addressbook true]
incr numFolders

Cawt CheckNumber  $numFolders [Outlook GetNumContactFolders $appId]                     "AddContactFolder "
Cawt CheckBoolean true        [Outlook HaveContactFolder $appId $testContactFolderName] "HaveContactFolder"
Cawt CheckNumber  0           [Outlook GetNumContacts $contactFolderId]                 "GetNumContacts   "

puts "Adding $testNumContacts contacts"
set curDate [clock seconds]
for { set i 1 } { $i <= $testNumContacts } { incr i } {
    set imgFile [format $contactImgTemplate $i]
    set contactId [Outlook AddContact $contactFolderId \
        -category                    $testCatName \
        -image                       $imgFile \
        Account                      "Account-$i" \
        AssistantName                "AssistantName-$i" \
        AssistantTelephoneNumber     "AssistantTelephoneNumber-$i" \
        BillingInformation           "BillingInformation-$i" \
        Body                         "Body-$i" \
        Business2TelephoneNumber     "Business2TelephoneNumber-$i" \
        BusinessAddress              "BusinessAddress-$i" \
        BusinessAddressCity          "BusinessAddressCity-$i" \
        BusinessAddressCountry       "BusinessAddressCountry-$i" \
        BusinessAddressPostalCode    "BusinessAddressPostalCode-$i" \
        BusinessAddressPostOfficeBox "BusinessAddressPostOfficeBox-$i" \
        BusinessAddressState         "BusinessAddressCountry-$i" \
        BusinessAddressStreet        "BusinessAddressStreet-$i" \
        BusinessFaxNumber            "BusinessFaxNumber-$i" \
        BusinessHomePage             "BusinessHomePage-$i" \
        BusinessTelephoneNumber      "BusinessTelephoneNumber-$i" \
        CallbackTelephoneNumber      "CallbackTelephoneNumber-$i" \
        CarTelephoneNumber           "CarTelephoneNumber-$i" \
        CompanyMainTelephoneNumber   "CompanyMainTelephoneNumber-$i" \
        CompanyName                  "CompanyName-$i" \
        ComputerNetworkName          "ComputerNetworkName-$i" \
        CustomerID                   "CustomerID-$i" \
        Department                   "Department-$i" \
        Email1Address                "cawt-$i@tcl3d.org" \
        Email1AddressType            "SMTP" \
        Email1DisplayName            "CAWT Mail 1" \
        Email2Address                "info-$i@tcl3d.org" \
        Email2AddressType            "SMTP" \
        Email2DisplayName            "CAWT Mail 2" \
        Email3Address                "paul-$i@tcl3d.org" \
        Email3AddressType            "SMTP" \
        Email3DisplayName            "CAWT Mail 3" \
        FileAs                       "CAWT Contact $i" \
        FirstName                    "FirstName-$i" \
        FTPSIte                      "FTPSIte-$i" \
        Gender                       "olFemale" \
        GovernmentIDNumber           "GovernmentIDNumber-$i" \
        Hobby                        "Hobby-$i" \
        Home2TelephoneNumber         "Home2TelephoneNumber-$i" \
        HomeAddress                  "HomeAddress-$i" \
        HomeAddressCity              "HomeAddressCity-$i" \
        HomeAddressCountry           "HomeAddressCountry-$i" \
        HomeAddressPostalCode        "HomeAddressPostalCode-$i" \
        HomeAddressPostOfficeBox     "HomeAddressPostOfficeBox-$i" \
        HomeAddressState             "HomeAddressState-$i" \
        HomeAddressStreet            "HomeAddressStreet-$i" \
        HomeFaxNumber                "HomeFaxNumber-$i" \
        HomeTelephoneNumber          "HomeTelephoneNumber-$i" \
        IMAddress                    "IMAddress-$i" \
        Initials                     "Initials-$i" \
        InternetFreeBusyAddress      "InternetFreeBusyAddress-$i" \
        ISDNNumber                   "ISDNNumber-$i" \
        JobTitle                     "JobTitle-$i" \
        Language                     "Language-$i" \
        LastName                     "LastName-$i" \
        MailingAddress               "MailingAddress-$i" \
        MailingAddressCity           "MailingAddressCity-$i" \
        MailingAddressCountry        "MailingAddressCountry-$i" \
        MailingAddressPostalCode     "MailingAddressPostalCode-$i" \
        MailingAddressPostOfficeBox  "MailingAddressPostOfficeBox-$i" \
        MailingAddressState          "MailingAddressState-$i" \
        MailingAddressStreet         "MailingAddressStreet-$i" \
        ManagerName                  "ManagerName-$i" \
        MiddleName                   "MiddleName-$i" \
        Mileage                      "Mileage-$i" \
        MobileTelephoneNumber        "MobileTelephoneNumber-$i" \
        NetMeetingAlias              "NetMeetingAlias-$i" \
        NetMeetingServer             "NetMeetingServer-$i" \
        NickName                     "NickName-$i" \
        OfficeLocation               "OfficeLocation-$i" \
        OrganizationalIDNumber       "OrganizationalIDNumber-$i" \
        OtherAddress                 "OtherAddress-$i" \
        OtherAddressCity             "OtherAddressCity-$i" \
        OtherAddressCountry          "OtherAddressCountry-$i" \
        OtherAddressPostalCode       "OtherAddressPostalCode-$i" \
        OtherAddressPostOfficeBox    "OtherAddressPostOfficeBox-$i" \
        OtherAddressState            "OtherAddressState-$i" \
        OtherAddressStreet           "OtherAddressStreet-$i" \
        OtherFaxNumber               "OtherFaxNumber-$i" \
        OtherTelephoneNumber         "OtherTelephoneNumber-$i" \
        PagerNumber                  "PagerNumber-$i" \
        PersonalHomePage             "PersonalHomePage-$i" \
        PrimaryTelephoneNumber       "PrimaryTelephoneNumber-$i" \
        Profession                   "Profession-$i" \
        RadioTelephoneNumber         "RadioTelephoneNumber-$i" \
        ReferredBy                   "ReferredBy-$i" \
        Spouse                       "Spouse-$i" \
        Subject                      "Subject-$i" \
        Suffix                       "Suffix-$i" \
        TaskCompletedDate            [Cawt SecondsToIsoDate $curDate] \
        TaskDueDate                  [Cawt SecondsToIsoDate $curDate] \
        TaskStartDate                [Cawt SecondsToIsoDate $curDate] \
        TaskSubject                  "TaskSubject-$i" \
        TelexNumber                  "TelexNumber-$i" \
        Title                        "Title-$i" \
        ToDoTaskOrdinal              [Cawt SecondsToIsoDate $curDate] \
        TTYTDDTelephoneNumber        "TTYTDDTelephoneNumber-$i" \
        User1                        "User1-$i" \
        User2                        "User2-$i" \
        User3                        "User3-$i" \
        User4                        "User4-$i" \
        WebPage                      "WebPage-$i" \
        YomiCompanyName              "YomiCompanyName-$i" \
        YomiFirstName                "YomiFirstName-$i" \
        YomiLastName                 "YomiLastName-$i" \
    ]
    Cawt Destroy $contactId
}

Cawt CheckNumber $testNumContacts [Outlook GetNumContacts $contactFolderId] "GetNumContacts"

$contactFolderId -with { Items } Sort "\[LastName\]" [Cawt TclBool false]

if { $optPrintContactOrder } {
    for { set i 1 } { $i <= $testNumContacts } { incr i } {
        set conId [Outlook GetContactByIndex $contactFolderId $i]
        puts [format "  Contact %d: %s %s" $i [$conId FirstName] [$conId LastName]]
    }
}

puts "Removing first and last contact"
Outlook DeleteContactByIndex $contactFolderId 1
Outlook DeleteContactByIndex $contactFolderId end
Cawt CheckNumber [expr $testNumContacts - 2] [Outlook GetNumContacts $contactFolderId] "GetNumContacts"

set contact1Id [Outlook GetContactByIndex $contactFolderId 1]

if { $optAddAppointmentProperties } {
    puts "Adding appointment properties to first contact:"
    Outlook SetContactProperties $contact1Id \
            Anniversary [Cawt SecondsToIsoDate $curDate] \
            Birthday    [Cawt SecondsToIsoDate $curDate]
}

puts "Some properties of first contact:"
set propKeys [list FirstName LastName Profession]
set propVals [Outlook GetContactProperties $contact1Id {*}$propKeys]
foreach { key val } $propVals {
    Cawt CheckString "${key}-2" $val "GetContactProperties"
}
puts "FullName: [Outlook GetContactProperties $contact1Id "FullName"]"

puts "Get all properties of first contact:"
set propVals [Outlook GetContactProperties $contact1Id]
set keyList  [concat [Outlook GetContactReadWritePropertyNames] [Outlook GetContactReadOnlyPropertyNames]]
Cawt CheckNumber [llength $keyList] [expr [llength $propVals] / 2] "GetContactProperties"
if { $optPrintAllProperties } {
    set count 1
    foreach { key val } $propVals {
        puts [format "  %3d: %-30s: \"%s\"" $count $key $val]
        incr count
    }
}

Cawt CheckNumber 108 [llength [Outlook GetContactReadWritePropertyNames]] "Number of read-write properties"
Cawt CheckNumber  21 [llength [Outlook GetContactReadOnlyPropertyNames]]  "Number of read-only properties "

# Get the default contact folder.
set contactDefId [Outlook GetContactFolderId $appId]
puts "Default contact folder     : [$contactDefId Name]"
puts "Default contact folder path: [$contactDefId FolderPath]"
puts "Contacts in default folder : [Outlook GetNumContacts $contactDefId]"

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Outlook DeleteCategory $appId $testCatName
    Outlook DeleteContactFolder $contactFolderId
    Outlook Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
