# Test CawtWord procedures related to property handling.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

proc AddPropertyInfo { tableId row propertyId } {
    Word SetCellValue $tableId $row 1 [Office GetPropertyName  $propertyId]
    Word SetCellValue $tableId $row 2 [Office GetPropertyValue $propertyId]
    Word SetCellValue $tableId $row 3 [Office GetPropertyType  $propertyId]
}

# Open Word, show the application window and create a workbook.
set appId  [Word OpenNew true]
set docId1 [Word AddDocument $appId]

# Delete Word file from previous test run.
file mkdir testOut
set docFile1 [file join [pwd] "testOut" "Word-10_Properties1"]
set docFile2 [file join [pwd] "testOut" "Word-10_Properties2"]
append docFile1 [Word GetExtString $appId]
append docFile2 [Word GetExtString $appId]
file delete -force $docFile1
file delete -force $docFile2

# Set some writable builtin properties and check their values.
Office SetDocumentProperty $docId1 "Author"           "Paul"
Office SetDocumentProperty $docId1 "Company"          "poSoft"
Office SetDocumentProperty $docId1 "Title"            $docFile1
Office SetDocumentProperty $docId1 "Document version" "01"

Cawt CheckString "Paul"    [Office GetDocumentProperty $docId1 "Author"]           "Property Author"
Cawt CheckString "poSoft"  [Office GetDocumentProperty $docId1 "Company"]          "Property Company"
Cawt CheckString $docFile1 [Office GetDocumentProperty $docId1 "Title"]            "Property Title"
Cawt CheckString "01"      [Office GetDocumentProperty $docId1 "Document version"] "Property Document version"

# Set some read-only builtin properties and check their values.
Office SetDocumentProperty $docId1 "Revision number" "4"
Office SetDocumentProperty $docId1 "Security"         4
Cawt CheckString "1" [Office GetDocumentProperty $docId1 "Revision number"] "Property Revision number"
Cawt CheckNumber 0   [Office GetDocumentProperty $docId1 "Security"]        "Property Security"

# Set some custom properties and check their values.
Office SetDocumentProperty $docId1 "Custom Prop1" "Custom Value1"
Office SetDocumentProperty $docId1 "Custom Prop2" "2.0"

Office AddProperty $docId1 "BoolProp"   -type msoPropertyTypeBoolean -value true
Office AddProperty $docId1 "IntProp"    -type msoPropertyTypeNumber  -value 123
Office AddProperty $docId1 "FloatProp"  -type msoPropertyTypeFloat   -value 12.45
Office AddProperty $docId1 "DateProp"   -type msoPropertyTypeDate    -value 1.5
Office AddProperty $docId1 "StringProp" -type msoPropertyTypeString  -value "String"

# Add a custom property with same name as a builtin property.
set propDupId [Office AddProperty $docId1 "Title" -type msoPropertyTypeString]
Office SetPropertyValue $propDupId "MyTitle"

Cawt CheckString "Custom Value1" [Office GetDocumentProperty $docId1 "Custom Prop1"] "Property Custom Prop1"
Cawt CheckString "2.0"           [Office GetDocumentProperty $docId1 "Custom Prop2"] "Property Custom Prop2"

# Get all builtin and custom properties and insert them into the document.
Word AppendText $docId1 "Builtin Properties:"
set builtinProps [Office GetDocumentProperties $docId1 "Builtin"]
set builtinTable [Word AddTable [Word GetEndRange $docId1] [expr [llength $builtinProps] +1] 3]
Word SetTableBorderLineStyle $builtinTable
Word SetTableOptions $builtinTable -left 0.4c -right 0.3c -top 0.1c -bottom 0.2c -spacing 0.05c
Word SetHeaderRow $builtinTable [list "Name" "Value" "Type"]

set row 2
foreach propertyName $builtinProps {
    set propertyId [Office GetProperty $docId1 $propertyName]
    AddPropertyInfo $builtinTable $row $propertyId
    Cawt Destroy $propertyId
    incr row
}

Word AppendText $docId1 "\nCustom Properties:"
set customProps [Office GetDocumentProperties $docId1 "Custom"]
set customTable [Word AddTable [Word GetEndRange $docId1] [expr [llength $customProps] +1] 3]
Word SetTableBorderLineStyle $customTable
Word SetHeaderRow $customTable [list "Name" "Value" "Type"]

set row 2
foreach propertyName $customProps {
    set propertyId [Office GetProperty $docId1 $propertyName -type "Custom"]
    AddPropertyInfo $customTable $row $propertyId
    Cawt Destroy $propertyId
    incr row
}

puts "Saving as Word file: $docFile1"
Word SaveAs $docId1 $docFile1
Word Close  $docId1

puts "Changing custom properties ..."
set docId2 [Word OpenDocument $appId $docFile1]

Office SetDocumentProperty $docId2 "Custom Prop1" "CS1"
Office SetDocumentProperty $docId2 "Custom Prop2" "-2.0"
Office SetDocumentProperty $docId2 "BoolProp"     false
Office SetDocumentProperty $docId2 "IntProp"      321
Office SetDocumentProperty $docId2 "FloatProp"    45.12
Office SetDocumentProperty $docId2 "DateProp"     2.5
Office SetDocumentProperty $docId2 "StringProp"   "ChangedString"

# Changing a custom property, which also exists as a builtin type,
# does not work using SetDocumentProperty.
set propTitleId [Office GetProperty $docId2 "Title" -type "Custom"]
Office SetPropertyValue $propTitleId "MyChangedTitle"

Cawt CheckString "CS1"  [Office GetDocumentProperty $docId2 "Custom Prop1"] "Property Custom Prop1"
Cawt CheckString "-2.0" [Office GetDocumentProperty $docId2 "Custom Prop2"] "Property Custom Prop2"

# Check value of a not existing property.
Cawt CheckString "N/A" [Office GetDocumentProperty $docId2 "InvalidProp"] "Property InvalidProp"

Office AddProperty $docId2 "NewProp" -type msoPropertyTypeBoolean -value true
Office AddProperty $docId2 "NewProp" -type msoPropertyTypeString  -value "New" -overwrite true
Cawt CheckString "New" [Office GetDocumentProperty $docId2 "NewProp"] "Property NewProp"

set propId [Office AddProperty $docId2 "NewProp2"]
Cawt CheckString "" [Office GetDocumentProperty $docId2 "NewProp2"] "Property NewProp2"
Office DeleteProperty $propId
Cawt CheckString "N/A" [Office GetDocumentProperty $docId2 "NewProp2"] "Property NewProp2"

# Get all custom properties and insert them into the document.
Word AppendText $docId2 "\nChanged Custom Properties:"
set customProps [Office GetDocumentProperties $docId2 "Custom"]
set customTable [Word AddTable [Word GetEndRange $docId2] [expr [llength $customProps] +1] 3]
Word SetTableBorderLineStyle $customTable
Word SetHeaderRow $customTable [list "Name" "Value" "Type"]

set row 2
foreach propertyName $customProps {
    set propertyId [Office GetProperty $docId2 $propertyName -type "Custom"]
    AddPropertyInfo $customTable $row $propertyId
    Cawt Destroy $propertyId
    incr row
}

puts "Saving as Word file: $docFile2"
Word SaveAs $docId2 $docFile2

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
