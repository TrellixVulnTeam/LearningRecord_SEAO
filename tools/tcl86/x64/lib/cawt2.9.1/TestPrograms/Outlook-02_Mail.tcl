# Test mail functionality of the CawtOutlook package.
# Note: This script sends two test mails (in text and HTML format) to cawt@tcl3d.org.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set appId [Outlook Open]

set toList [list  \
    "cawt@tcl3d.org" \
]

set attachmentList [list \
    [file nativename [file join [pwd] Outlook-02_Mail.tcl]] \
]

set cawtVersion    [format "%s: %s" "Cawt version"    [package require cawt]]
set outlookVersion [format "%s: %s" "Outlook version" [Outlook GetVersion $appId true]]

set bodyText "Generated with\n$cawtVersion\n$outlookVersion"
set bodyHtml "<html><body><h1>Generated with</h1><p>$cawtVersion</p><p>$outlookVersion</p></body></html>\n"

set mailTextId [Outlook CreateMail $appId $toList "Test mail in text format" $bodyText $attachmentList]
set mailHtmlId [Outlook CreateHtmlMail $appId $toList "Test mail in HTML format" $bodyHtml $attachmentList]

Outlook SendMail $mailTextId
Outlook SendMail $mailHtmlId

Cawt PrintNumComObjects

puts "Note: This script has sent two test mails to cawt@tcl3d.org"

if { [lindex $argv 0] eq "auto" } {
    Outlook Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
