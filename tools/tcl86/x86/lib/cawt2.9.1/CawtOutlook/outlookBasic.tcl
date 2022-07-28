# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export GetFoldersRecursive
    namespace export GetVersion
    namespace export Open
    namespace export OpenNew
    namespace export Quit

    variable outlookVersion "0.0"
    variable outlookAppName "Outlook.Application"

    variable _ruff_preamble {
        The `Outlook` namespace provides commands to control Microsoft Outlook.
    }

    proc GetVersion { objId { useString false } } {
        # Get the version of an Outlook application.
        #
        # objId     - Identifier of an Outlook object instance.
        # useString - If set to true, return the version name (ex. `Outlook 2000`).
        #             Otherwise return the version number (ex. `9.0`).
        #
        # Returns the version of an Outlook application.
        #
        # Both version name and version number are returned as strings.
        # Version number is in a format, so that it can be evaluated as a
        # floating point number.
        #
        # See also: Open

        array set map {
            "7.0"  "Outlook 95"
            "8.0"  "Outlook 97"
            "9.0"  "Outlook 2000"
            "10.0" "Outlook 2002"
            "11.0" "Outlook 2003"
            "12.0" "Outlook 2007"
            "14.0" "Outlook 2010"
            "15.0" "Outlook 2013"
            "16.0" "Outlook 2016/2019"
        }
        set versionString [Office GetApplicationVersion $objId]

        set members [split $versionString "."]
        set version "[lindex $members 0].[lindex $members 1]"
        if { $useString } {
            if { [info exists map($version)] } {
                return $map($version)
            } else {
                return "Unknown Outlook version $version"
            }
        } else {
            return $version
        }
    }

    proc Open { { explorerType "olFolderInbox" } } {
        # Open an Outlook instance.
        #
        # explorerType - Value of enumeration type [Enum::OlDefaultFolders].
        #                Typical values are: `olFolderCalendar`, `olFolderInbox`, `olFolderTasks`.
        #
        # Returns the identifier of the Outlook application instance.
        #
        # See also: Quit

        variable outlookAppName
	variable outlookVersion

        set appId [Cawt GetOrCreateApp $outlookAppName true]
        set outlookVersion [Outlook GetVersion $appId]

        set explorers [$appId Explorers]
        if { $explorerType ne "" && ! [Cawt IsComObject [$appId ActiveExplorer]] } {
            set nsObj [$appId GetNamespace "MAPI"]
            set myFolder [$nsObj GetDefaultFolder [Outlook GetEnum $explorerType]]
            set myExplorer [$explorers Add $myFolder $Outlook::olFolderDisplayNormal]
            $myExplorer Display
            Cawt Destroy $myExplorer
            Cawt Destroy $myFolder
            Cawt Destroy $nsObj
        }
        Cawt Destroy $explorers
        return $appId
    }

    proc OpenNew { { explorerType "olFolderInbox" } } {
        # Obsolete: Replaced with [Open] in version 2.4.1

        return [Outlook::Open $explorerType]
    }

    proc Quit { appId } {
        # Quit an Outlook instance.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns no value.
        #
        # See also: Open

        $appId Quit
    }

    proc _ScanFoldersRecursive { node type trashPath } {
        variable sFolderListValid
        variable sFolderListInvalid

        set numFolders [$node -with {Folders} Count]
        for { set i 1 } { $i <= $numFolders } { incr i } {
            set folderId   [$node -with {Folders} Item [expr {$i}]]
            set folderName [$folderId Name]
            set folderType [$folderId DefaultItemType]
            # puts "Folder \"$folderName\" [Outlook GetEnumName OlItemType $folderType] [$folderId FolderPath]"
            if { $type == $folderType } {
                set sFolderListValid($folderName) $folderId
            } else {
                set sFolderListInvalid($folderName) $folderId
            }
            # Only traverse, if folder is not the trash folder.
            if { [$folderId FolderPath] ne $trashPath } {
                Outlook::_ScanFoldersRecursive $folderId $type $trashPath
            }
        }
    }

    proc _ScanStoresRecursive { node type trashPath } {
        variable sFolderListValid
        variable sFolderListInvalid

        set numStores [$node -with {Stores} Count]
        for { set i 1 } { $i <= $numStores } { incr i } {
            set storeId   [$node -with {Stores} Item [expr {$i}]]
            set folderId [$storeId GetRootFolder]
            set folderName [$folderId Name]
            set folderType [$folderId DefaultItemType]
            # puts "Store $i: \"$folderName\" [Outlook GetEnumName OlItemType $folderType] [$folderId FolderPath]"
            if { $type == $folderType } {
                set sFolderListValid($folderName) $folderId
            } else {
                set sFolderListInvalid($folderName) $folderId
            }
            # Only traverse, if folder is not the trash folder.
            if { [$folderId FolderPath] ne $trashPath } {
               Outlook::_ScanFoldersRecursive $folderId $type $trashPath
            }
        }
    }

    proc GetFoldersRecursive { appId type } {
        # Get all Outlook folders of a specific type.
        #
        # appId - Identifier of the Outlook instance.
        # type  - Value of enumeration type [Enum::OlItemType].
        #
        # Returns a key-value list containing the name of the folder
        # followed by the folder identifier.
        #
        # See also: GetMailSubjects GetContactFolderNames GetCalendarNames

        variable sFolderListValid
        variable sFolderListInvalid

        set nsObj [$appId GetNamespace "MAPI"]
        if { [info exists sFolderListValid] } {
            foreach name [array names sFolderListValid] {
                if { [Cawt IsComObject $sFolderListValid($name)] } {
                    Cawt Destroy $sFolderListValid($name)
                }
            }
            unset sFolderListValid
        }
        if { [info exists sFolderListInvalid] } {
            foreach name [array names sFolderListInvalid] {
                if { [Cawt IsComObject $sFolderListInvalid($name)] } {
                    Cawt Destroy $sFolderListInvalid($name)
                }
            }
            unset sFolderListInvalid
        }
        set folderList [list]
        set trashPath [[$nsObj GetDefaultFolder $Outlook::olFolderDeletedItems] FolderPath]
        Outlook::_ScanStoresRecursive $nsObj $type $trashPath

        foreach name [lsort -dictionary [array names sFolderListValid]] {
            lappend folderList $name $sFolderListValid($name)
        }
        foreach name [array names sFolderListInvalid] {
            if { [Cawt IsComObject $sFolderListInvalid($name)] } {
                Cawt Destroy $sFolderListInvalid($name)
            }
        }
        Cawt Destroy $nsObj
        return $folderList
    }
}
