# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export AddContact
    namespace export AddContactFolder
    namespace export DeleteContactByIndex
    namespace export DeleteContactFolder
    namespace export GetContactByIndex
    namespace export GetContactFolderId
    namespace export GetContactFolderNames
    namespace export GetContactProperties
    namespace export GetNumContactFolders
    namespace export GetContactReadOnlyPropertyNames
    namespace export GetContactReadWritePropertyNames
    namespace export GetNumContacts
    namespace export HaveContactFolder
    namespace export SetContactProperties

    proc GetContactFolderNames { appId } {
        # Get a list of Outlook contact folder names.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of contact folder names.
        #
        # See also: AddContactFolder DeleteContactFolder GetNumContactFolders
        # HaveContactFolder GetContactFolderId

        Cawt PushComObjects
        set contactFolderNameList [list]
        foreach { name folderId } [Outlook::GetFoldersRecursive $appId $Outlook::olContactItem] {
            lappend contactFolderNameList $name
        }
        Cawt PopComObjects
        return $contactFolderNameList
    }

    proc GetNumContactFolders { appId } {
        # Get the number of Outlook contact folders.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns the number of Outlook contact folders.
        #
        # See also: AddContactFolder DeleteContactFolder HaveContactFolder
        # GetContactFolderNames GetContactFolderId

        return [llength [Outlook::GetContactFolderNames $appId]]
    }

    proc HaveContactFolder { appId contactFolderName } {
        # Check, if an Outlook contact folder exists.
        #
        # appId             - Identifier of the Outlook instance.
        # contactFolderName - Name of the contact folder to check.
        #
        # Returns true, if the contact folder exists, otherwise false.
        #
        # See also: AddContactFolder DeleteContactFolder GetNumContactFolders
        # GetContactFolderNames GetContactFolderId

        if { [lsearch -exact [Outlook::GetContactFolderNames $appId] $contactFolderName] >= 0 } {
            return true
        } else {
            return false
        }
    }

    proc GetContactFolderId { appId { contactFolderName "" } } {
        # Get an Outlook contact folder by its name.
        #
        # appId             - Identifier of the Outlook instance.
        # contactFolderName - Name of the contact folder to find.
        #
        # Returns the identifier of the found contact folder.
        # If $contactFolderName is not specified or the empty string, the identifier
        # of the default contact folder is returned.
        #
        # If a contact folder with given name does not exist, an empty string is returned.
        #
        # See also: AddContactFolder DeleteContactFolder GetNumContactFolders
        # HaveContactFolder GetContactFolderNames

        if { $contactFolderName eq "" } {
            set nsObj [$appId GetNamespace "MAPI"]
            set folderId [$nsObj GetDefaultFolder $Outlook::olFolderContacts]
            Cawt Destroy $nsObj
            return $folderId
        }
        set foundId ""
        foreach { name folderId } [Outlook::GetFoldersRecursive $appId $Outlook::olContactItem] {
            if { $name eq $contactFolderName } {
                set foundId $folderId
            } else {
                Cawt Destroy $folderId
            }
        }
        return $foundId
    }

    proc AddContactFolder { appId contactFolderName args } {
        # Add a new Outlook contact folder.
        #
        # appId             - Identifier of the Outlook instance.
        # contactFolderName - Name of the new contact folder.
        # args              - Options described below.
        #
        # -addressbook <bool> - Add the contact folder to the addressbook.
        #                       Default: false.
        #
        # Returns the identifier of the new contact folder.
        #
        # If a contact folder with given name is already existing, the identifier
        # of that contact folder is returned.
        # If the contact folder could not be added, an error is thrown.
        #
        # See also: DeleteContactFolder GetNumContactFolders HaveContactFolder
        # GetContactFolderNames GetContactFolderId

        set addToAddressbook false
        foreach { key value } $args {
            if { $value eq "" } {
                error "AddContactFolder: No value specified for key \"$key\"."
            }
            switch -exact -nocase -- $key {
                "-addressbook" { set addToAddressbook $value }
                default        { error "AddContactFolder: Unknown key \"$key\" specified." }
            }
        }

        set nsObj [$appId GetNamespace "MAPI"]
        set contactFolderId [$nsObj GetDefaultFolder $Outlook::olFolderContacts]
        set numFolders [$contactFolderId -with {Folders} Count]
        for { set i 1 } { $i <= $numFolders } { incr i } {
            set folderId [$contactFolderId -with {Folders} Item [expr {$i}]]
            if { [$folderId Name] eq $contactFolderName } {
                return $folderId
            }
            Cawt Destroy $folderId
        }
        set catchVal [catch {$contactFolderId -with { Folders } Add \
                      $contactFolderName $Outlook::olFolderContacts} folderId]
        if { $catchVal != 0 } {
            error "AddContactFolder: Could not add contact folder \"$contactFolderName\"."
        }
        $folderId ShowAsOutlookAB [Cawt TclBool $addToAddressbook]
        Cawt Destroy $contactFolderId
        Cawt Destroy $nsObj
        return $folderId
    }

    proc DeleteContactFolder { contactFolderId } {
        # Delete an Outlook contact folder.
        #
        # contactFolderId - Identifier of the Outlook contact folder.
        #
        # Returns no value.
        #
        # See also: AddContactFolder GetNumContactFolders HaveContactFolder
        # GetContactFolderNames GetContactFolderId

        $contactFolderId Delete
    }

    proc GetNumContacts { contactFolderId } {
        # Get the number of contacts in an Outlook contact folder.
        #
        # contactFolderId - Identifier of the Outlook contact folder.
        #
        # Returns the number of Outlook contacts.
        # If the contact folder is not accessible, -1 is returned.
        #
        # See also: AddContactFolder AddContact GetContactByIndex DeleteContactByIndex

        set catchVal [catch { $contactFolderId -with { Items } Count } numContacts]
        if { $catchVal != 0 } {
            set numContacts -1
        }
        return $numContacts
    }

    proc GetContactByIndex { contactFolderId index } {
        # Get a contact of an Outlook contact folder by its index.
        #
        # contactFolderId - Identifier of the Outlook contact folder.
        # index           - Index of the contact.
        #
        # Returns the identifier of the found contact.
        #
        # The first contact has index 1.
        # Instead of using the numeric index the special word `end` may
        # be used to specify the last contact.
        #
        # If the index is out of bounds an error is thrown.
        #
        # See also: AddContactFolder AddContact GetNumContacts DeleteContactByIndex

        set count [Outlook::GetNumContacts $contactFolderId]
        if { $index eq "end" } {
            set index $count
        } else {
            if { $index < 1 || $index > $count } {
                error "GetContactByIndex: Invalid index $index given."
            }
        }

        set itemId [$contactFolderId -with { Items } Item [expr {$index}]]
        return $itemId
    }

    proc DeleteContactByIndex { contactFolderId index } {
        # Delete a contact of an Outlook contact folder by its index.
        #
        # contactFolderId - Identifier of the Outlook contact folder.
        # index           - Index of the contact.
        #
        # Returns no value.
        #
        # The first contact has index 1.
        # Instead of using the numeric index the special word `end` may
        # be used to specify the last contact.
        #
        # If the index is out of bounds an error is thrown.
        #
        # See also: AddContactFolder AddContact GetNumContacts GetContactByIndex

        set count [Outlook::GetNumContacts $contactFolderId]
        if { $index eq "end" } {
            set index $count
        } else {
            if { $index < 1 || $index > $count } {
                error "DeleteContactByIndex: Invalid index $index given."
            }
        }
        $contactFolderId -with { Items } Remove [expr {$index}]
    }

    proc GetContactReadWritePropertyNames {} {
        # Get a list of Outlook contact read-write property names.
        #
        # The following contact properties are read-write:
        # **Name** - **Type**
        # `Account` - String
        # `Anniversary` - Date in format `%Y-%m-%d %H:%M:%S`
        # `AssistantName` - String
        # `AssistantTelephoneNumber - String
        # `BillingInformation` - String
        # `Birthday` - Date in format `%Y-%m-%d %H:%M:%S`
        # `Body` - String
        # `Business2TelephoneNumber` - String
        # `BusinessAddress` - String
        # `BusinessAddressCity` - String
        # `BusinessAddressCountry` - String
        # `BusinessAddressPostalCode` - String
        # `BusinessAddressPostOfficeBox` - String
        # `BusinessAddressState` - String
        # `BusinessAddressStreet` - String
        # `BusinessFaxNumber` - String
        # `BusinessHomePage` - String
        # `BusinessTelephoneNumber` - String
        # `CallbackTelephoneNumber` - String
        # `CarTelephoneNumber` - String
        # `CompanyMainTelephoneNumber` - String
        # `CompanyName` - String
        # `ComputerNetworkName` - String
        # `CustomerID` - String
        # `Department` - String
        # `Email1Address` - String
        # `Email1AddressType` - String
        # `Email1DisplayName` - String
        # `Email2Address` - String
        # `Email2AddressType` - String
        # `Email2DisplayName` - String
        # `Email3Address` - String
        # `Email3AddressType` - String
        # `Email3DisplayName` - String
        # `FileAs` - String
        # `FirstName` - String
        # `FTPSIte` - String
        # `FullName` - String
        # `Gender` - Enumeration of type [Enum::OlGender]
        # `GovernmentIDNumber` - String
        # `Hobby` - String
        # `Home2TelephoneNumber` - String
        # `HomeAddress` - String
        # `HomeAddressCity` - String
        # `HomeAddressCountry` - String
        # `HomeAddressPostalCode` - String
        # `HomeAddressPostOfficeBox` - String
        # `HomeAddressState` - String
        # `HomeAddressStreet` - String
        # `HomeFaxNumber` - String
        # `HomeTelephoneNumber` - String
        # `IMAddress` - String
        # `Initials` - String
        # `InternetFreeBusyAddress` - String
        # `ISDNNumber` - String
        # `JobTitle` - String
        # `Language` - String
        # `LastName` - String
        # `MailingAddress` - String
        # `MailingAddressCity` - String
        # `MailingAddressCountry` - String
        # `MailingAddressPostalCode` - String
        # `MailingAddressPostOfficeBox` - String
        # `MailingAddressState` - String
        # `MailingAddressStreet` - String
        # `ManagerName` - String
        # `MiddleName` - String
        # `Mileage` - String
        # `MobileTelephoneNumber` - String
        # `NetMeetingAlias` - String
        # `NetMeetingServer` - String
        # `NickName` - String
        # `OfficeLocation` - String
        # `OrganizationalIDNumber` - String
        # `OtherAddress` - String
        # `OtherAddressCity` - String
        # `OtherAddressCountry` - String
        # `OtherAddressPostalCode` - String
        # `OtherAddressPostOfficeBox` - String
        # `OtherAddressState` - String
        # `OtherAddressStreet` - String
        # `OtherFaxNumber` - String
        # `OtherTelephoneNumber` - String
        # `PagerNumber` - String
        # `PersonalHomePage` - String
        # `PrimaryTelephoneNumber` - String
        # `Profession` - String
        # `RadioTelephoneNumber` - String
        # `ReferredBy` - String
        # `Spouse` - String
        # `Subject` - String
        # `Suffix` - String
        # `TaskCompletedDate` - Date in format `%Y-%m-%d %H:%M:%S`
        # `TaskDueDate` - Date in format `%Y-%m-%d %H:%M:%S`
        # `TaskStartDate` - Date in format `%Y-%m-%d %H:%M:%S`
        # `TaskSubject` - String
        # `TelexNumber` - String
        # `Title` - String
        # `ToDoTaskOrdinal` - Date in format `%Y-%m-%d %H:%M:%S`
        # `TTYTDDTelephoneNumber` - String
        # `User1` - String
        # `User2` - String
        # `User3` - String
        # `User4` - String
        # `WebPage` - String
        # `YomiCompanyName` - String
        # `YomiFirstName` - String
        # `YomiLastName` - String
        #
        # Returns a list of contact property names, which can
        # be read and written.
        #
        # **Note 1:**
        # To get a list of all property names (read-only and read-write), use: 
        #     [concat [GetContactReadWritePropertyNames] [GetContactReadOnlyPropertyNames]]
        #
        # **Note 2:**
        # Converting dates into needed format can be accomplished with [::Cawt::SecondsToIsoDate]:
        #     [Cawt SecondsToIsoDate [clock seconds]]
        #
        # See also: AddContactFolder AddContact GetContactReadOnlyPropertyNames 
        # SetContactProperties GetContactProperties

        return [list \
            Account \
            Anniversary \
            AssistantName \
            AssistantTelephoneNumber \
            BillingInformation \
            Birthday \
            Body \
            Business2TelephoneNumber \
            BusinessAddress \
            BusinessAddressCity \
            BusinessAddressCountry \
            BusinessAddressPostalCode \
            BusinessAddressPostOfficeBox \
            BusinessAddressState \
            BusinessAddressStreet \
            BusinessFaxNumber \
            BusinessHomePage \
            BusinessTelephoneNumber \
            CallbackTelephoneNumber \
            CarTelephoneNumber \
            CompanyMainTelephoneNumber \
            CompanyName \
            ComputerNetworkName \
            CustomerID \
            Department \
            Email1Address \
            Email1AddressType \
            Email1DisplayName \
            Email2Address \
            Email2AddressType \
            Email2DisplayName \
            Email3Address \
            Email3AddressType \
            Email3DisplayName \
            FileAs \
            FirstName \
            FTPSIte \
            FullName \
            Gender \
            GovernmentIDNumber \
            Hobby \
            Home2TelephoneNumber \
            HomeAddress \
            HomeAddressCity \
            HomeAddressCountry \
            HomeAddressPostalCode \
            HomeAddressPostOfficeBox \
            HomeAddressState \
            HomeAddressStreet \
            HomeFaxNumber \
            HomeTelephoneNumber \
            IMAddress \
            Initials \
            InternetFreeBusyAddress \
            ISDNNumber \
            JobTitle \
            Language \
            LastName \
            MailingAddress \
            MailingAddressCity \
            MailingAddressCountry \
            MailingAddressPostalCode \
            MailingAddressPostOfficeBox \
            MailingAddressState \
            MailingAddressStreet \
            ManagerName \
            MiddleName \
            Mileage \
            MobileTelephoneNumber \
            NetMeetingAlias \
            NetMeetingServer \
            NickName \
            OfficeLocation \
            OrganizationalIDNumber \
            OtherAddress \
            OtherAddressCity \
            OtherAddressCountry \
            OtherAddressPostalCode \
            OtherAddressPostOfficeBox \
            OtherAddressState \
            OtherAddressStreet \
            OtherFaxNumber \
            OtherTelephoneNumber \
            PagerNumber \
            PersonalHomePage \
            PrimaryTelephoneNumber \
            Profession \
            RadioTelephoneNumber \
            ReferredBy \
            Spouse \
            Subject \
            Suffix \
            TaskCompletedDate \
            TaskDueDate \
            TaskStartDate \
            TaskSubject \
            TelexNumber \
            Title \
            ToDoTaskOrdinal \
            TTYTDDTelephoneNumber \
            User1 \
            User2 \
            User3 \
            User4 \
            WebPage \
            YomiCompanyName \
            YomiFirstName \
            YomiLastName \
        ]
    }

    proc GetContactReadOnlyPropertyNames {} {
        # Get a list of Outlook contact read-only property names.
        #
        # The following contact properties are read-only:
        # **Name** - **Type**
        # `Categories` - String
        # `Companies` - String
        # `CompanyAndFullName` - String
        # `CompanyLastFirstNoSpace` - String
        # `CompanyLastFirstSpaceOnly` - String
        # `CreationTime` - Date in format `%Y-%m-%d %H:%M:%S`
        # `Email1EntryID` - String
        # `Email2EntryID` - String
        # `Email3EntryID` - String
        # `FullNameAndCompany` - String
        # `HasPicture` - Boolean
        # `LastFirstAndSuffix` - String
        # `LastFirstNoSpace` - String
        # `LastFirstNoSpaceAndSuffix` - String
        # `LastFirstNoSpaceCompany` - String
        # `LastFirstSpaceOnly` - String
        # `LastFirstSpaceOnlyCompany` - String
        # `LastModificationTime` - Date in format `%Y-%m-%d %H:%M:%S`
        # `LastNameAndFirstName` - String
        # `OutlookInternalVersion` - Integer
        # `OutlookVersion` - String
        #
        # Returns a list of contact property names, which are read-only.
        #
        # **Note 1:**
        # To get a list of all property names (read-only and read-write), use: 
        #     [concat [GetContactReadWritePropertyNames] [GetContactReadOnlyPropertyNames]]
        #
        # **Note 2:**
        # Converting dates into needed format can be accomplished with [::Cawt::SecondsToIsoDate]:
        #     [Cawt SecondsToIsoDate [clock seconds]]
        #
        # See also: AddContactFolder AddContact GetContactReadWritePropertyNames
        # SetContactProperties GetContactProperties

        return [list \
            Categories \
            Companies \
            CompanyAndFullName \
            CompanyLastFirstNoSpace \
            CompanyLastFirstSpaceOnly \
            CreationTime \
            Email1EntryID \
            Email2EntryID \
            Email3EntryID \
            FullNameAndCompany \
            HasPicture \
            LastFirstAndSuffix \
            LastFirstNoSpace \
            LastFirstNoSpaceAndSuffix \
            LastFirstNoSpaceCompany \
            LastFirstSpaceOnly \
            LastFirstSpaceOnlyCompany \
            LastModificationTime \
            LastNameAndFirstName \
            OutlookInternalVersion \
            OutlookVersion \
        ]
    }

    proc GetContactProperties { contactId args } {
        # Get property values of an Outlook contact.
        #
        # contactId - Identifier of the Outlook contact.
        # args  - Options described below.
        #
        # List of property names - If args is empty, all read-only and
        # read-write properties are returned.
        #
        # Returns the contact properties as a list of key-value pairs.
        #
        # If a property value could not be read, and error is thrown.
        #
        # See also: AddContactFolder AddContact GetNumContacts GetContactByIndex
        # SetContactProperties GetContactReadWritePropertyNames GetContactReadOnlyPropertyNames

        set keyValueList [list]
        if { [llength $args] == 0 } {
            set keyList [concat [GetContactReadWritePropertyNames] [GetContactReadOnlyPropertyNames]]
        } else {
            set keyList $args
        }
        foreach key $keyList {
            set catchVal [catch { $contactId $key } value]
            if { $catchVal != 0 } {
                error "GetContactProperties: Could not retrieve value of property \"$key\"."
            }
            switch -exact -nocase -- $key {
                "Anniversary" -
                "Birthday" -
                "CreationTime" -
                "LastModificationTime" -
                "TaskCompletedDate" -
                "TaskDueDate" -
                "TaskStartDate" -
                "ToDoTaskOrdinal" {
                    set convertedValue  [Cawt OfficeDateToIsoDate $value]
                }
                "Gender" {
                    set convertedValue [Outlook GetEnumName "OlGender" $value]
                }
                default {
                    set convertedValue $value
                }
            }
            lappend keyValueList $key
            lappend keyValueList $convertedValue
        }
        return $keyValueList
    }
 
    proc SetContactProperties { contactId args } {
        # Set property values of an Outlook contact.
        #
        # contactId - Identifier of the Outlook contact.
        # args      - Options described below.
        #
        # -category <string> - Assign category to contact.
        #                      If specified category does not yet exist, it is created.
        # -image <string>    - Add contact image.
        #                      Supported image formats: 
        #                      `GIF` `JPEG` `BMP` `TIFF` `WMF` `EMF` `PNG`.
        # Key-value pairs    - Key is a read-write property name, value is the property value to be set.
        #
        # Set the properties of an Outlook contact.
        #
        # For details on contact properties see the official [Microsoft documentation]
        # (https://docs.microsoft.com/office/vba/api/outlook.contactitem).
        #
        # **Note 1:**
        # Most properties are of type `String`. Some are of type `Date`, `Boolean` or enumerations.
        #
        # See [GetContactReadOnlyPropertyNames] and [GetContactReadWritePropertyNames]
        # for a list of properties and their corresponding types.
        #
        # **Note 2:**
        # Converting dates into needed format can be accomplished with [::Cawt::SecondsToIsoDate]:
        #     [Cawt SecondsToIsoDate [clock seconds]]
        #
        # **Note 3:**
        # `Anniversary` and `Birthday` set an appointment in the default calendar.
        #
        # Returns no value.
        #
        # See also: AddContact AddContactFolder GetContactProperties GetNumContacts
        # GetContactReadWritePropertyNames GetContactReadOnlyPropertyNames

        foreach { key value } $args {
            if { $key eq "" } {
                error "SetContactProperties: No valid contact property specified: \"$key\""
            }
            switch -exact -nocase -- $key {
                "-image" {
                    set key "AddPicture"
                    set convertedValue [file nativename [file normalize $value]]    
                }
                "-category" {
                    set appId [$contactId Application]
                    Outlook AddCategory $appId $value
                    $contactId Categories $value
                    Cawt Destroy $appId
                    continue
                }
                "Anniversary" -
                "Birthday" -
                "TaskCompletedDate" -
                "TaskDueDate" -
                "TaskStartDate" -
                "ToDoTaskOrdinal" {
                    set convertedValue [Cawt IsoDateToOfficeDate $value]
                }
                "Gender" {
                    set convertedValue [Outlook GetEnum $value]
                }
                default {
                    set convertedValue $value
                }
            }
            set catchVal [catch { $contactId $key $convertedValue } errMsg]
            if { $catchVal != 0 } {
                error "SetContactProperties: Could not set property \"$key\" to value \"$convertedValue\"."
            }
        }
        $contactId Save
    }

    proc AddContact { contactFolderId args } {
        # Create a new contact in an Outlook contact folder.
        #
        # contactFolderId - Identifier of the Outlook contact folder.
        # args            - Options described below.
        #
        # -category <string> - Assign category to contact.
        #                      If specified category does not yet exist, it is created.
        # -image <string>    - Add contact image.
        #                      Supported image formats: 
        #                      `GIF` `JPEG` `BMP` `TIFF` `WMF` `EMF` `PNG`.
        # Key-value pairs    - Key is a read-write property name, value is the property value to be set.
        #
        # Create a new contact in an Outlook contact folder and set the
        # properties of the new contact.
        #
        # For details on contact properties see [SetContactProperties].
        #
        # See also: AddContactFolder SetContactProperties GetContactProperties
        # GetNumContacts GetContactReadWritePropertyNames GetContactReadOnlyPropertyNames

        set contactId [$contactFolderId -with { Items } Add $Outlook::olContactItem]

        Outlook::SetContactProperties $contactId {*}$args

        return $contactId
    }
}
