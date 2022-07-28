# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Office {

    namespace ensemble create

    namespace export AddMacro
    namespace export AddProperty
    namespace export ColorToRgb
    namespace export DeleteProperty
    namespace export GetActivePrinter
    namespace export GetApplicationId
    namespace export GetApplicationName
    namespace export GetApplicationVersion
    namespace export GetDocumentProperties
    namespace export GetDocumentProperty
    namespace export GetInstallationPath
    namespace export GetOfficeType
    namespace export GetProperty
    namespace export GetPropertyName
    namespace export GetPropertyType
    namespace export GetPropertyValue
    namespace export GetStartupPath
    namespace export GetTemplatesPath
    namespace export GetUserLibraryPath
    namespace export GetUserName
    namespace export GetUserPath
    namespace export IsApplicationId
    namespace export RgbToColor
    namespace export RunMacro
    namespace export SetDocumentProperty
    namespace export SetPrinterCommunication
    namespace export SetPropertyValue
    namespace export ShowAlerts

    variable _ruff_preamble {
        The `Office` namespace provides commands for basic Office automation functionality.
    }

    proc RgbToColor { r g b } {
        # Obsolete: Replaced with [::Cawt::RgbToOfficeColor] in version 2.2.0

        return [Cawt RgbToOfficeColor $r $g $b]
    }

    proc ColorToRgb { color } {
        # Obsolete: Replaced with [::Cawt::OfficeColorToRgb] in version 2.2.0

        return [Cawt OfficeColorToRgb $color]
    }

    proc ShowAlerts { appId onOff } {
        # Obsolete: Replaced with module specific procedures in version 2.4.3
        #
        # Toggle the display of Office alerts.
        #
        # appId - The application identifier.
        # onOff - Switch the alerts on or off.
        #
        # Returns no value.

        if { $onOff } {
            if { [Office GetApplicationName $appId] eq "Microsoft Word" } {
                set alertLevel [expr $Word::wdAlertsAll]
            } else {
                set alertLevel [expr 1]
            }
        } else {
            set alertLevel [expr 0]
        }
        $appId -call DisplayAlerts $alertLevel
    }

    proc IsApplicationId { objId } {
        # Check, if Office object is an application identifier.
        #
        # objId - The identifier of an Office object.
        #
        # Returns true, if $objId is a valid Office application identifier.
        # Otherwise return false.
        #
        # See also: ::Cawt::IsComObject GetApplicationId GetApplicationName

        set retVal [catch {$objId Version} errMsg]
        # Version is a property of all Office application classes.
        if { $retVal == 0 } {
            return true
        } else {
            return false
        }
    }

    proc GetApplicationId { objId } {
        # Get the application identifier of an Office object.
        #
        # objId - The identifier of an Office object.
        #
        # Office object are Workbooks, Worksheets, ...
        #
        # Returns the application identifier of the Office object.
        #
        # See also: GetApplicationName IsApplicationId

        return [$objId Application]
    }

    proc GetApplicationName { objId } {
        # Get the name of an Office application.
        #
        # objId - The identifier of an Office object.
        #
        # Returns the name of the application as a string.
        #
        # See also: GetApplicationId IsApplicationId

        if { ! [Office IsApplicationId $objId] } {
            set appId [Office GetApplicationId $objId]
            set name [$appId Name]
            Cawt Destroy $appId
            return $name
        } else {
            return [$objId Name]
        }
    }

    proc GetApplicationVersion { objId } {
        # Get the version number of an Office application.
        #
        # objId - The identifier of an Office object.
        #
        # Returns the version of the application as a floating point number.
        #
        # See also: GetApplicationId GetApplicationName

        if { ! [Office IsApplicationId $objId] } {
            set appId [Office GetApplicationId $objId]
            set version [$appId Version]
            Cawt Destroy $appId
        } else {
            set version [$objId Version]
        }
        return $version
    }

    proc SetPrinterCommunication { objId onOff } {
        # Enable or disable printer communication.
        #
        # objId - The identifier of an Office object.
        # onOff - If set to true, printer communication is enabled.
        #         Otherwise printer communication is disabled.
        #
        # Disable the printer communication to speed up the execution of code
        # that sets PageSetup properties, ex. [::Excel::SetWorksheetPrintOptions].
        # Enable the printer communication after setting properties to commit
        # all cached PageSetup commands.
        #
        # **Note:** This method is only available in Office 2010 or newer.
        #
        # Returns no value.
        #
        # See also: GetActivePrinter

        if { ! [Office IsApplicationId $objId] } {
            set appId [Office GetApplicationId $objId]
            catch {$appId -call PrintCommunication [Cawt TclBool $onOff]}
            Cawt Destroy $appId
        } else {
            catch {$objId -call PrintCommunication [Cawt TclBool $onOff]}
        }
    }

    proc GetActivePrinter { appId } {
        # Get the name of the active printer.
        #
        # appId - The application identifier.
        #
        # Returns the name of the active printer as a string.
        #
        # See also: SetPrinterCommunication

        set retVal [catch {$appId ActivePrinter} val]
        if { $retVal == 0 } {
            return $val
        } else {
            return "Method not available"
        }
    }

    proc GetUserName { appId } {
        # Get the name of the Office application user.
        #
        # appId - The application identifier.
        #
        # Returns the name of the application user as a string.

        set retVal [catch {$appId UserName} val]
        if { $retVal == 0 } {
            return $val
        } else {
            return "Method not available"
        }
    }

    proc GetStartupPath { appId } {
        # Get the Office startup pathname.
        #
        # appId - The application identifier.
        #
        # Returns the startup pathname as a string.

        set retVal [catch {$appId StartupPath} val]
        if { $retVal == 0 } {
            return $val
        } else {
            return "Method not available"
        }
    }

    proc GetTemplatesPath { appId } {
        # Get the Office templates pathname.
        #
        # appId - The application identifier.
        #
        # Returns the templates pathname as a string.

        set retVal [catch {$appId TemplatesPath} val]
        if { $retVal == 0 } {
            return $val
        } else {
            return "Method not available"
        }
    }

    proc GetUserLibraryPath { appId } {
        # Get the Office user library pathname.
        #
        # appId - The application identifier.
        #
        # Returns the user library pathname as a string.

        set retVal [catch {$appId UserLibraryPath} val]
        if { $retVal == 0 } {
            return $val
        } else {
            return "Method not available"
        }
    }

    proc GetInstallationPath { appId } {
        # Get the Office installation pathname.
        #
        # appId - The application identifier.
        #
        # Returns the installation pathname as a string.

        set retVal [catch {$appId Path} val]
        if { $retVal == 0 } {
            return $val
        } else {
            return "Method not available"
        }
    }

    proc GetUserPath { appId } {
        # Get the Office user folder's pathname.
        #
        # appId - The application identifier.
        #
        # Returns the user folder's pathname as a string.

        set retVal [catch {$appId DefaultFilePath} val]
        if { $retVal == 0 } {
            return $val
        } else {
            return "Method not available"
        }
    }

    proc GetDocumentProperties { objId { type "" } } {
        # Get document property names as a list.
        #
        # objId - The identifier of an Office object (Workbook, Document, Presentation).
        # type  - Type of document properties as string: `Builtin` or `Custom`.
        #         If `type` is not specified or the empty string, both types
        #         of document properties are included in the list.
        #
        # Returns a sorted Tcl list containing the names of all properties
        # of the specified type.
        #
        # See also: SetDocumentProperty GetDocumentProperty AddProperty GetProperty DeleteProperty
        #           GetPropertyName GetPropertyType GetPropertyValue SetPropertyValue

        set propsBuiltin [$objId BuiltinDocumentProperties]
        set propsCustom  [$objId CustomDocumentProperties]

        set propList [list]
        if { $type eq "Builtin" || $type eq "" } {
            $propsBuiltin -iterate prop {
                lappend propList [$prop Name]
                Cawt Destroy $prop
            }
        }
        if { $type eq "Custom" || $type eq "" } {
            $propsCustom -iterate prop {
                lappend propList [$prop Name]
                Cawt Destroy $prop
            }
        }
        Cawt Destroy $propsBuiltin
        Cawt Destroy $propsCustom
        return [lsort -dictionary $propList]
    }

    proc AddProperty { objId propertyName args } {
        # Add a custom document property.
        #
        # objId        - The identifier of an Office object (Workbook, Document, Presentation).
        # propertyName - The name of the new custom property.
        # args         - Options described below.
        #
        # -type <enum> -      The type (string, int, bool, date, float) of the property.
        #                     Enumeration of type [Enum::MsoDocProperties].
        #                     If not specified, the property is of type `msoPropertyTypeString`.
        # -value <val>      - Value of the new property. The specified value must match the
        #                     specified type. If not specified, the value is set to the empty
        #                     string for string properties and to zero for all other property types.
        # -overwrite <bool> - If a property with given name already exists, the property is either
        #                     replaced (`-overwrite true`) or an error is thrown 
        #                     (`-overwrite false`). If not specified, overwriting is disabled.
        #
        # Returns the identifier of the new property or an error depending on the setting of
        # option `-overwrite`.
        #
        # See also: SetDocumentProperty GetDocumentProperty GetProperty GetDocumentProperties
        #           GetPropertyName GetPropertyType GetPropertyValue SetPropertyValue DeleteProperty

        set propertyType [Office GetEnum msoPropertyTypeString] 
        set overwrite    false
        foreach { key value } $args {
            if { $value eq "" } {
                error "AddProperty: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-type"      { set propertyType [Office GetEnum $value] }
                "-value"     { set propertyValue $value }
                "-overwrite" { set overwrite $value }
                default  { error "AddProperty: Unknown key \"$key\" specified" }
            }
        }

        if { ! [info exists propertyValue] } {
            if { $propertyType == $::Office::msoPropertyTypeString } {
                set propertyValue ""
            } else {
                set propertyValue 0
            }
        }
        switch -- [Office GetEnumName "MsoDocProperties" $propertyType] {
            "msoPropertyTypeBoolean" { set val [Cawt TclBool $propertyValue] }
            "msoPropertyTypeString"  { set val [Cawt TclString $propertyValue] }
            "msoPropertyTypeNumber"  { set val [expr { int ($propertyValue) }] }
            "msoPropertyTypeDate"    { set val [expr { double ($propertyValue) }] }
            "msoPropertyTypeFloat"   { set val [expr { double ($propertyValue) }] }
            default { error "AddProperty: Unknown property type \"$propertyType\"" }
        }
        set retVal [catch {Office GetProperty $objId $propertyName -type "Custom"} propertyId]
        if { $retVal == 0 } {
            if { $overwrite } {
                Office DeleteProperty $propertyId
            } else {
                error "AddProperty: Property \"$propertyName\" already exists"
            }
        }
        set propsCustom [$objId CustomDocumentProperties]
        set propertyId [$propsCustom -call Add $propertyName [Cawt TclBool false] $propertyType $propertyValue]
        Cawt Destroy $propsCustom
        return $propertyId
    }

    proc DeleteProperty { propertyId } {
        # Delete a document property.
        #
        # propertyId - Identifier of the Office property.
        #
        # Returns no value.
        #
        # See also: SetDocumentProperty GetDocumentProperty AddProperty GetProperty GetPropertyName
        #           GetPropertyType GetPropertyValue SetPropertyValue GetDocumentProperties

        $propertyId -call Delete
        Cawt Destroy $propertyId
    }

    proc GetPropertyName { propertyId } {
        # Get the name of a document property.
        #
        # propertyId - Identifier of the Office property.
        #
        # Returns the name of the property as string.
        #
        # See also: SetDocumentProperty GetDocumentProperty AddProperty GetProperty DeleteProperty
        #           GetPropertyType GetPropertyValue SetPropertyValue GetDocumentProperties

        set retVal [catch {$propertyId Name} propName]
        if { $retVal == 0 } {
            return $propName
        } else {
            return "N/A"
        }
    }

    proc GetPropertyValue { propertyId } {
        # Get the value of a document property.
        #
        # propertyId - Identifier of the Office property.
        #
        # Returns the value of the property.
        # If the property value is not set, the string `N/A` is returned.
        #
        # See also: SetDocumentProperty GetDocumentProperty AddProperty GetProperty DeleteProperty
        #           GetPropertyName GetPropertyType SetPropertyValue GetDocumentProperties

        set retVal [catch {$propertyId Value} propVal]
        if { $retVal == 0 } {
            return $propVal
        } else {
            return "N/A"
        }
    }
 
    proc SetPropertyValue { propertyId propertyValue } {
        # Set the value of a document property.
        #
        # propertyId    - Identifier of the Office property.
        # propertyValue - The value for the property.
        #                 The specified value must match the type of the property,
        #                 see [GetPropertyType].
        #
        # Returns no value.
        #
        # See also: SetDocumentProperty GetDocumentProperty AddProperty GetProperty DeleteProperty
        #           GetPropertyName GetPropertyType GetPropertyValue GetDocumentProperties

        set propertyType [Office GetPropertyType $propertyId]
        switch -- $propertyType {
            "msoPropertyTypeBoolean" { set val [Cawt TclBool $propertyValue] }
            "msoPropertyTypeString"  { set val [Cawt TclString $propertyValue] }
            "msoPropertyTypeNumber"  { set val [expr { int ($propertyValue) }] }
            "msoPropertyTypeDate"    { set val [expr { double ($propertyValue) }] }
            "msoPropertyTypeFloat"   { set val [expr { double ($propertyValue) }] }
            default { error "SetPropertyValue: Unknown property type \"$propertyType\"" }
        }
        $propertyId Value $val
    }

    proc GetPropertyType { propertyId } {
        # Get the type of a document property.
        #
        # propertyId - Identifier of the Office property.
        #
        # Returns the type of the property as enumeration string.
        # The enumeration is of type [Enum::MsoDocProperties].
        #
        # See also: SetDocumentProperty GetDocumentProperty AddProperty GetProperty DeleteProperty
        #           GetPropertyName GetPropertyValue SetPropertyValue GetDocumentProperties

        set retVal [catch {$propertyId Type} propType]
        if { $retVal == 0 } {
            return [Office GetEnumName "MsoDocProperties" $propType]
        } else {
            return "N/A"
        }
    }

    proc GetProperty { objId propertyName args } {
        # Get a document property.
        #
        # objId        - The identifier of an Office object (Workbook, Document, Presentation).
        # propertyName - The name of the property.
        # args         - Options described below.
        #
        # -type <string> - Type of document property (`Builtin` or `Custom`).
        #                  If not specified, the property is searched in the builtin and
        #                  custom properties list. If the property name exists in both lists,
        #                  the builtin property is returned.
        #
        # Returns the identifier of the specified property.
        # If a property with given name does not exist, an error is thrown.
        #
        # See also: SetDocumentProperty GetDocumentProperty AddProperty GetDocumentProperties
        #           GetPropertyName GetPropertyType GetPropertyValue SetPropertyValue DeleteProperty

        set type ""
        foreach { key value } $args {
            if { $value eq "" } {
                error "GetProperty: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-type" { set type $value }
                default { error "GetProperty: Unknown key \"$key\" specified" }
            }
        }
        set properties [Office GetDocumentProperties $objId $type]
        if { [lsearch $properties $propertyName] >= 0 } {
            if { $type eq "Builtin" || $type eq "" } {
                set propsBuiltin [$objId BuiltinDocumentProperties]
                set retVal [catch {$propsBuiltin -get Item $propertyName} property]
                Cawt Destroy $propsBuiltin
                if { $retVal == 0 } {
                    return $property
                }
            }
            if { $type eq "Custom" || $type eq "" } {
                set propsCustom  [$objId CustomDocumentProperties]
                set retVal [catch {$propsCustom -get Item $propertyName} property]
                Cawt Destroy $propsCustom
                if { $retVal == 0 } {
                    return $property
                }
            }
        }
        error "GetProperty: \"$propertyName\" is not a valid property name."
    }

    proc GetDocumentProperty { objId propertyName } {
        # Get the value of a document property.
        #
        # objId        - The identifier of an Office object (Workbook, Document, Presentation).
        # propertyName - The name of the property.
        #
        # Returns the value of specified property.
        # If the property value is not set or an invalid property name is given,
        # the string `N/A` is returned.
        #
        # See also: SetDocumentProperty AddProperty GetProperty GetDocumentProperties
        #           GetPropertyName GetPropertyType GetPropertyValue SetPropertyValue DeleteProperty

        set propertyValue "N/A"
        set retVal [catch {Office GetProperty $objId $propertyName} propertyId]
        if { $retVal == 0 } {
            set propertyValue [Office GetPropertyValue $propertyId]
            Cawt Destroy $propertyId
        }
        return $propertyValue
    }

    proc SetDocumentProperty { objId propertyName propertyValue } {
        # Set the value of a document property.
        #
        # objId         - The identifier of an Office object (Workbook, Document, Presentation).
        # propertyName  - The name of the property to set.
        # propertyValue - The value for the property.
        #                 The specified value must match the type of the property,
        #                 see [GetPropertyType].
        #
        # Returns no value.
        #
        # If the property name is a builtin property, its value is set.
        # Otherwise either a new custom property is created and its value set or,
        # if the custom property already exists, only its value is set.
        #
        # **Note:**
        #  * Some builtin properties are read-only. If trying to set the value of 
        #    a read-only property, no error is generated by an Office application.
        #  * Custom properties created with this procedure are string properties.
        #    If you need other property types, use [AddProperty].
        #
        # See also: GetDocumentProperty AddProperty GetProperty GetDocumentProperties
        #           GetPropertyName GetPropertyType GetPropertyValue SetPropertyValue DeleteProperty

        set retVal [catch {Office GetProperty $objId $propertyName} propertyId]
        if { $retVal != 0 } {
            set propertyId [Office AddProperty $objId $propertyName]
        }
        Office SetPropertyValue $propertyId $propertyValue
        Cawt Destroy $propertyId
    }

    proc GetOfficeType { fileName } {
        # Get the Office type of a file.
        #
        # fileName - File name.
        #
        # Returns the Office type of the file.
        # Possible values are: `Excel`, `Ppt`, `Word`.
        # If the file is not an Office file, the return value
        # is the empty string.
        #
        # See also: ::Excel::GetExtString ::Ppt::GetExtString
        # ::Word::GetExtString

        set ext [string tolower [file extension $fileName]]
        if { $ext eq ".xls"  || $ext eq ".xlsx" || \
             $ext eq ".xlt"  || $ext eq ".xltx" || \
             $ext eq ".xltm" || $ext eq ".xlsm" } {
            return "Excel"
        } elseif { $ext eq ".doc"  || $ext eq ".docx" || \
                   $ext eq ".dot"  || $ext eq ".dotx" || \
                   $ext eq ".docm" || $ext eq ".dotm" } {
            return "Word"
        } elseif { $ext eq ".ppt"  || $ext eq ".pptx" || \
                   $ext eq ".pot"  || $ext eq ".potx" || \
                   $ext eq ".pptm" || $ext eq ".potm" } {
            return "Ppt"
        } else {
            return ""
        }
    }

    proc AddMacro { appId args } {
        # Add macros or functions to an Office document.
        #
        # appId - The application identifier.
        # args  - Options described below.
        #
        # -file <fileName> - Use macros stored in specified file.
        # -code <string>   - Use macros stored in specified string.
        #
        # Returns no value.
        # An error is thrown, if no option or an invalid option is specified,
        # if the file does not exist or if the VBA project object model
        # is not enabled in the trust center.
        #
        # See also: RunMacro

        set fileName ""
        set codeStr  ""
        foreach { key value } $args {
            if { $value eq "" } {
                error "AddMacro: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-file" {
                    set fileName [file nativename [file normalize $value]]
                    if { ! [file exists $fileName] } {
                        error "AddMacro: File $fileName does not exist."
                    }
                }
                "-code" {
                    set codeStr $value 
                }
                default {
                    error "AddMacro: Unknown key \"$key\" specified" 
                }
            }
        }

        if { $fileName ne "" } {
            set catchVal [catch { $appId -with { VBE ActiveVBProject VBComponents } -call Import $fileName }]
            if { $catchVal } {
                error "AddMacro: Trust Access to the VBA project object model must be enabled."
            }
        } elseif { $codeStr ne "" } {
            set vbext_ct_StdModule [expr int(1)]
            set catchVal [catch { $appId -with { VBE ActiveVBProject VBComponents } -call Add $vbext_ct_StdModule } module]
            if { $catchVal } {
                error "AddMacro: Trust Access to the VBA project object model must be enabled."
            }
            $module -with { CodeModule } AddFromString $codeStr
        } else {
            error "AddMacro: Neither \"-file\" nor \"-code\" option specified." 
        }
    }

    proc RunMacro { appId macroName args } {
        # Run a macro or function contained in an Office document.
        #
        # appId     - The application identifier.
        # macroName - The name of the macro or function.
        # args      - Up to 30 macro or function parameters.
        #
        # Returns an empty string, if the macro is a procedure (Sub).
        # If the macro is a Function, the return value of the function is returned.
        # An error is thrown, if the macro does not exist or the execution of the 
        # macro fails.
        #
        # See also: AddMacro

        set retVal [catch { $appId -call Run $macroName {*}$args } val]
        if { $retVal == 0 } {
            return $val
        } else {
            error "RunMacro: $val"
        }
    }
}

# The following procedures have been previously defined in namespace Cawt.
# The original procedures have been moved into namespace Office and are
# therefore redefined here in namespace Cawt for backwards compatibility.
namespace eval Cawt {

    namespace ensemble create

    namespace export ColorToRgb
    namespace export GetActivePrinter
    namespace export GetApplicationId
    namespace export GetApplicationName
    namespace export GetApplicationVersion
    namespace export GetDocumentProperties
    namespace export GetDocumentProperty
    namespace export GetInstallationPath
    namespace export GetStartupPath
    namespace export GetTemplatesPath
    namespace export GetUserLibraryPath
    namespace export GetUserName
    namespace export GetUserPath
    namespace export IsApplicationId
    namespace export RgbToColor
    namespace export SetDocumentProperty
    namespace export SetPrinterCommunication
    namespace export ShowAlerts

    interp alias {} ::Cawt::ColorToRgb              {} ::Office::ColorToRgb
    interp alias {} ::Cawt::GetActivePrinter        {} ::Office::GetActivePrinter
    interp alias {} ::Cawt::GetApplicationId        {} ::Office::GetApplicationId
    interp alias {} ::Cawt::GetApplicationName      {} ::Office::GetApplicationName
    interp alias {} ::Cawt::GetApplicationVersion   {} ::Office::GetApplicationVersion
    interp alias {} ::Cawt::GetDocumentProperties   {} ::Office::GetDocumentProperties
    interp alias {} ::Cawt::GetDocumentProperty     {} ::Office::GetDocumentProperty
    interp alias {} ::Cawt::GetInstallationPath     {} ::Office::GetInstallationPath
    interp alias {} ::Cawt::GetStartupPath          {} ::Office::GetStartupPath
    interp alias {} ::Cawt::GetTemplatesPath        {} ::Office::GetTemplatesPath
    interp alias {} ::Cawt::GetUserLibraryPath      {} ::Office::GetUserLibraryPath
    interp alias {} ::Cawt::GetUserName             {} ::Office::GetUserName
    interp alias {} ::Cawt::GetUserPath             {} ::Office::GetUserPath
    interp alias {} ::Cawt::IsApplicationId         {} ::Office::IsApplicationId
    interp alias {} ::Cawt::RgbToColor              {} ::Office::RgbToColor
    interp alias {} ::Cawt::SetDocumentProperty     {} ::Office::SetDocumentProperty
    interp alias {} ::Cawt::SetPrinterCommunication {} ::Office::SetPrinterCommunication
    interp alias {} ::Cawt::ShowAlerts              {} ::Office::ShowAlerts
}

