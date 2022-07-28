# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export CreateMail
    namespace export CreateHtmlMail
    namespace export GetMailIds
    namespace export GetMailSubjects
    namespace export SendMail

    proc _CreateMail { appId mailType recipientList { subject "" } { body "" } { attachmentList {} } } {
        set mailId [$appId CreateItem $Outlook::olMailItem]

        $mailId Display
        foreach recipient $recipientList {
            $mailId -with { Recipients } Add $recipient
        }
        if { $mailType eq "text" } {
            set sig [$mailId Body]
            $mailId Body [format "%s\n%s" $body $sig]
        } else {
            set sig [$mailId HtmlBody]
            $mailId HtmlBody [format "%s %s" $body $sig]
        }
        $mailId Subject $subject
        foreach attachment $attachmentList {
            $mailId -with { Attachments } Add [file nativename [file normalize $attachment]]
        }
        return $mailId
    }

    proc CreateMail { appId recipientList { subject "" } { body "" } { attachmentList {} } } {
        # Create a new Outlook text mail.
        #
        # appId          - Identifier of the Outlook instance.
        # recipientList  - List of mail addresses.
        # subject        - Subject text.
        # body           - Mail body text.
        # attachmentList - List of files used as attachment.
        #
        # Returns the identifier of the new mail object.
        #
        # See also: CreateHtmlMail SendMail

        return [Outlook::_CreateMail $appId "text" $recipientList $subject $body $attachmentList]
    }

    proc CreateHtmlMail { appId recipientList { subject "" } { body "" } { attachmentList {} } } {
        # Create a new Outlook HTML mail.
        #
        # appId          - Identifier of the Outlook instance.
        # recipientList  - List of mail addresses.
        # subject        - Subject text.
        # body           - Mail body text in HTML format.
        # attachmentList - List of files used as attachment.
        #
        # Returns the identifier of the new mail object.
        #
        # See also: CreateMail SendMail

        return [Outlook::_CreateMail $appId "html" $recipientList $subject $body $attachmentList]
    }

    proc SendMail { mailId } {
        # Send an Outlook mail.
        #
        # mailId - Identifier of the Outlook mail object.
        #
        # Returns no value.
        #
        # See also: CreateMail CreateHtmlMail

        $mailId Send
    }

    proc GetMailIds { appId } {
        # Get a list of mail identifiers.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of mail identifiers.
        #
        # See also: GetMailSubjects CreateMail SendMail 

        set idList [list]
        foreach { name folderId } [Outlook::GetFoldersRecursive $appId $Outlook::olMailItem] {
            set numItems [$folderId -with { Items } Count]
            if { $numItems > 0 } {
                for { set i 1 } { $i <= $numItems } { incr i } {
                    lappend idList [$folderId -with { Items } Item $i]
                }
            }
        }
        return $idList
    }

    proc GetMailSubjects { appId } {
        # Get a list of mail subjects.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of mail subjects.
        #
        # See also: GetMailIds CreateMail SendMail 

        set subjectList [list]
        foreach { name folderId } [Outlook::GetFoldersRecursive $appId $Outlook::olMailItem] {
            set numItems [$folderId -with { Items } Count]
            if { $numItems > 0 } {
                for { set i 1 } { $i <= $numItems } { incr i } {
                    set mailId [$folderId -with { Items } Item $i]
                    lappend subjectList [$mailId Subject]
                    Cawt Destroy $mailId
                }
            }
        }
        return $subjectList
    }
}
