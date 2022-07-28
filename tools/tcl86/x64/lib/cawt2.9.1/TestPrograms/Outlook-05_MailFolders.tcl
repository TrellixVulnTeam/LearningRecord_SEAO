# Test mail folder functionality of the CawtOutlook package.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set appId [Outlook Open]

# The following code resembles procedure GetMailSubjects,
# but with additional output messages.
foreach { name folderId } [Outlook::GetFoldersRecursive $appId $Outlook::olMailItem] {
    set numItems [$folderId -with { Items } Count]
    puts "Mail folder: $name ($numItems items) [$folderId FolderPath]"
    if { $numItems > 0 } {
        for { set i 1 } { $i <= $numItems } { incr i } {
            set mailId [$folderId -with { Items } Item $i]
            puts "  Subject: [$mailId Subject]"
        }
    }
}

set nsObj [$appId GetNamespace "MAPI"]
set mailDefId [$nsObj GetDefaultFolder $Outlook::olFolderInbox]

puts ""
puts "Default Inbox : [$mailDefId FolderPath]"
puts "Items in Inbox: [$mailDefId -with { Items } Count]"

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Outlook Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
