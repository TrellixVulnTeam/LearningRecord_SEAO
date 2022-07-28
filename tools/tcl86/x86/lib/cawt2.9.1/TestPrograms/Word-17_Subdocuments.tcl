# Test CawtWord procedures related to subdocument handling.
#
# Retrieve information about the subdocuments and save the
# document in expanded form (i.e. no subdocument links anymore)
# in Word and PDF format.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open new Word instance and show the application window.
set appId [Word OpenNew]

# Delete Word file from previous test run.
file mkdir testOut
set rootName [file join [pwd] "testOut" "Word-17_SubdocumentsExpanded"]
set pdfFile  [format "%s%s" $rootName ".pdf"]
set wordFile [format "%s%s" $rootName [Word GetExtString $appId]]
file delete -force $pdfFile
file delete -force $wordFile

set inFile [file join [pwd] "testIn" "Subdocuments" "Master.docx"]

# Open the master document document.
set docId [Word OpenDocument $appId $inFile]

# Get some information about the subdocuments.
set numSubs [Word GetNumSubdocuments $docId]
Cawt CheckNumber 3 $numSubs "Number of subdocuments"
for { set i 1 } { $i <= $numSubs } { incr i } {
    set subFileExp [file normalize [file join [pwd] "testIn" "Subdocuments" "Sub$i.docx"]]
    set subFileVal [Word GetSubdocumentPath $docId $i]
    Cawt CheckString $subFileExp $subFileVal "Subdocument $i"
}

# Now expand the subdocuments and delete the file links.
Word ExpandSubdocuments $docId
Word DeleteSubdocumentLinks $docId

# Update the table of content.
Word UpdateFields $docId

puts "Saving as expanded Word file: $wordFile"
Word SaveAs $docId $wordFile

puts "Saving as expanded PDF  file: $pdfFile"
# Use in a catch statement, as PDF export is available only in Word 2007 an up.
set catchVal [ catch { Word SaveAsPdf $docId $pdfFile } retVal]
if { $catchVal } {
    puts "Error: $retVal"
}

Word Close $docId

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
