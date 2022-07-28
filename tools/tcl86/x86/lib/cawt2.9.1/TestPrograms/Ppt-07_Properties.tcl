# Test CawtPpt procedures related to property handling.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

# Open PowerPoint, show the application window and create a presentation.
set appId  [Ppt OpenNew]
set presId [Ppt AddPres $appId]

# Delete PowerPoint file from previous test run.
file mkdir testOut
set pptFile [file join [pwd] "testOut" "Ppt-07_Properties"]
append pptFile [Ppt GetExtString $appId]
file delete -force $pptFile

# Set some builtin and custom properties and check their values.
Office SetDocumentProperty $presId "Author"      "Paul"
Office SetDocumentProperty $presId "Company"     "poSoft"
Office SetDocumentProperty $presId "Title"       $pptFile
Office SetDocumentProperty $presId "Custom Prop" "Custom Value"

Cawt CheckString "Paul"         [Office GetDocumentProperty $presId "Author"]      "Property Author"
Cawt CheckString "poSoft"       [Office GetDocumentProperty $presId "Company"]     "Property Company"
Cawt CheckString $pptFile       [Office GetDocumentProperty $presId "Title"]       "Property Title"
Cawt CheckString "Custom Value" [Office GetDocumentProperty $presId "Custom Prop"] "Property Custom Prop"

Cawt PrintNumComObjects

# Get all builtin and custom properties and insert them into the presentation.
set builtinSlide [Ppt AddSlide $presId]
set textboxId [Ppt AddTextbox $builtinSlide 1c 2c 20c 20c]
set builtinProps [Office GetDocumentProperties $presId "Builtin"]

Cawt PrintNumComObjects

foreach propertyName $builtinProps {
    Ppt AddTextboxText $textboxId "$propertyName: "
    Ppt AddTextboxText $textboxId [Office GetDocumentProperty $presId $propertyName] true
    incr row
}
Ppt SetTextboxFontSize $textboxId 10

Cawt PrintNumComObjects

set customSlide [Ppt AddSlide $presId]
set textboxId [Ppt AddTextbox $customSlide 1c 2c 20c 10c]
set customProps [Office GetDocumentProperties $presId "Custom"]

foreach propertyName [Office GetDocumentProperties $presId "Custom"] {
    Ppt AddTextboxText $textboxId "$propertyName: "
    Ppt AddTextboxText $textboxId [Office GetDocumentProperty $presId $propertyName] true
}
Ppt SetTextboxFontSize $textboxId 18

puts "Saving as PowerPoint file: $pptFile"
Ppt SaveAs $presId $pptFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Ppt Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
