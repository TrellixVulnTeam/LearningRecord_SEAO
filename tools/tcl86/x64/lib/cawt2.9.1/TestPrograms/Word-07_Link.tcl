# Test CawtWord procedures for handling links and inserting files.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-07_Link"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

set inFile [file join [pwd] "testIn" "InsertMe.html"]

# Create a new document.
set docId [Word AddDocument $appId]

# Generate valid and invalid hyperlinks of different types.
set relFileName "Word-07_Link.txt"
set absFileName [file join [pwd] "testOut" $relFileName]
set fp [open $absFileName "w"]
puts $fp "This is the text file linked from Word."
close $fp

set valid(url)  0
set valid(file) 0
set valid(int)  0
set invalid(url)  0
set invalid(file) 0
set invalid(int)  0

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink "http://www.cawt.tcl3d.org" "Hyperlink to valid URL"
Word AppendParagraph $docId
incr valid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink \
     "http://www.cawt.tcl3d.org/download/CawtReference_Cawt.html#::Cawt::CheckBoolean" \
     "Hyperlink to valid URL index"
Word AppendParagraph $docId
incr valid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink \
     "http://www.cawt.tcl3d.org/download/CawtReference_Cawt.html#::Cawt::CheckInvalidProc" \
     "Hyperlink to invalid URL index"
Word AppendParagraph $docId
incr invalid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink "http://www.cawt.tcl3d.org/dummy.html" "Hyperlink to invalid URL"
Word AppendParagraph $docId
incr invalid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink "http://www.wrongcawt.tcl3d.org/index.html" "Hyperlink to invalid domain"
Word AppendParagraph $docId
incr invalid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink \
     "https://sourceforge.net/projects/cawt/files/Official Releases/" \
     "Hyperlink to valid URL with spaces"
Word AppendParagraph $docId
incr valid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink \
     "https://sourceforge.net/projects/cawt/files/Official%20Releases/" \
     "Hyperlink to valid URL with spaces masked with %20"
Word AppendParagraph $docId
incr valid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink \
     "http://www.bawt.tcl3d.org/download/Bootstrap-Windows/gcc7.2.0_x86_64-w64-mingw32.7z" \
     "Hyperlink to valid URL with large file"
Word AppendParagraph $docId
incr valid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlink $rangeLink \
     "https://sourceforge.net/projects/cawt/files/Official Releases/CAWT 2.8.2/Cawt-2.8.2-win64.exe" \
     "Hyperlink to valid URL with executable file"
Word AppendParagraph $docId
incr valid(url)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlinkToFile $rangeLink $absFileName "Absolute hyperlink to valid file"
Word AppendParagraph $docId
incr valid(file)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlinkToFile $rangeLink $relFileName "Relative hyperlink to valid file"
Word AppendParagraph $docId
incr valid(file)

set rangeLink [Word AppendText $docId "Dummy"]
Word SetHyperlinkToFile $rangeLink "NotExistingFile.txt" "Hyperlink to invalid file"
Word AppendParagraph $docId
incr invalid(file)

set rangeLink [Word AppendText $docId "This is a bookmark"]
set bookmarkId [Word AddBookmark $rangeLink "Bookmark"]
Word AppendParagraph $docId
set rangeLink [Word AppendText $docId "Dummy"]
Word SetLinkToBookmark $rangeLink $bookmarkId "Link to valid bookmark"
Word AppendParagraph $docId
incr valid(int)

# Add internal links for the external file inserted later.
for { set i 1 } { $i <= 3 } { incr i } {
    Word AppendParagraph $docId
    set rangeLink [Word AppendText $docId "Dummy"]
    Word SetInternalHyperlink $rangeLink "proc$i" "Link to procedure $i"
    incr valid(int)
}

Word AddPageBreak [Word GetEndRange $docId]

#  Calculate the expected number of link types.
set expUrlLinks     [expr $valid(url)  + $invalid(url)]
set expFileLinks    [expr $valid(file) + $invalid(file)]
set expIntLinks     [expr $valid(int)  + $invalid(int)]
set expValidLinks   [expr $valid(url) + $valid(file) + $valid(int)]
set expInvalidLinks [expr $invalid(url) + $invalid(file) + $invalid(int)]
set expNumLinks     [expr $expValidLinks + $expInvalidLinks]

# Retrieve different types of hyperlinks.
set totalNumLinks [Word GetNumHyperlinks $docId]
set hyperlinkDict [Word GetHyperlinksAsDict $docId]
Cawt CheckNumber $expNumLinks   [dict size $hyperlinkDict] "Number of all links         :"
Cawt CheckNumber $totalNumLinks [dict size $hyperlinkDict] "Number of all links         :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -type internal]
Cawt CheckNumber $expIntLinks [dict size $hyperlinkDict] "Number of internal links    :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -type file]
Cawt CheckNumber $expFileLinks [dict size $hyperlinkDict] "Number of file links        :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -type url]
Cawt CheckNumber $expUrlLinks [dict size $hyperlinkDict] "Number of URL links         :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -type url -type file]
Cawt CheckNumber [expr $expUrlLinks + $expFileLinks] [dict size $hyperlinkDict] "Number of URL and file links:"

puts "Using GetHyperlinksAsDict as coroutine ..."
coroutine GetHyperlinks Word::GetHyperlinksAsDict $docId
while { 1 } {
    set retVal [GetHyperlinks]
    if { [string is integer -strict $retVal] } {
        set percent [expr int (100.0 * double ($retVal) / $totalNumLinks)]
        puts -nonewline "\b\b\b$percent%" ; flush stdout
    } else {
        break
    }
}
puts ""
Cawt CheckNumber $expNumLinks [dict size $retVal] "Number of all links         :"

# Insert external file using different methods.
puts "Insert external file via Word InsertFile method ..."
Word AppendText $docId "Inserted external file via Word InsertFile method" true
set endRange [Word GetEndRange $docId]
Word InsertFile $endRange $inFile

puts "Insert external file via PasteAndFormat wdPasteDefault ..."
Word AppendText $docId "Inserted external file via PasteAndFormat wdPasteDefault" true
set endRange [Word GetEndRange $docId]
Word InsertFile $endRange $inFile wdPasteDefault

puts "Insert external file via PasteAndFormat wdFormatOriginalFormatting ..."
Word AppendText $docId "Inserted external file via PasteAndFormat wdFormatOriginalFormatting" true
set endRange [Word GetEndRange $docId]
Word InsertFile $endRange $inFile wdFormatOriginalFormatting

# Check hyperlinks before saving the file. Needs option "-file", if checking relative file links.
set hyperlinkDict [Word GetHyperlinksAsDict $docId -check true -file $wordFile]
Cawt CheckNumber $expNumLinks [dict size $hyperlinkDict] "Number of all checked links    :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -check true -file $wordFile -valid true]
Cawt CheckNumber $expValidLinks [dict size $hyperlinkDict] "Number of all valid links      :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -check true -file $wordFile -valid false]
Cawt CheckNumber $expInvalidLinks [dict size $hyperlinkDict] "Number of all invalid links    :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -check true -type url -valid false]
Cawt CheckNumber $invalid(url) [dict size $hyperlinkDict] "Number of all invalid URL links:"

# Save document as Word file.
puts "Saving as Word file: $wordFile"
Word SaveAs $docId $wordFile

# Check hyperlinks after saving the file. No need for option "-file".
set hyperlinkDict [Word GetHyperlinksAsDict $docId -check true -valid true]
Cawt CheckNumber $expValidLinks [dict size $hyperlinkDict] "Number of all valid links       :"

set hyperlinkDict [Word GetHyperlinksAsDict $docId -check true -type file -valid false]
Cawt CheckNumber $invalid(file) [dict size $hyperlinkDict] "Number of all invalid file links:"

Word PrintHyperlinkDict $hyperlinkDict

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId false
    Cawt Destroy
    exit 0
}
Cawt Destroy
