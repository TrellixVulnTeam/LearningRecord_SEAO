# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval OneNote {

    namespace ensemble create

    namespace export GetApplicationId
    namespace export GetDomId
    namespace export GetDomRoot
    namespace export GetExtString
    namespace export GetLastModified
    namespace export GetNodeAttribute
    namespace export GetNodeHyperLink
    namespace export GetNodeName
    namespace export GetNodeType
    namespace export FindNodeByName
    namespace export GetNodesByType
    namespace export FindNotebook
    namespace export FindPage
    namespace export FindSection
    namespace export GetNotebooks
    namespace export GetPageContent
    namespace export GetPages
    namespace export GetSections
    namespace export GetVersion
    namespace export IsNodeType
    namespace export Open
    namespace export PrintPage
    namespace export Quit

    variable oneNoteVersion "0.0"
    variable oneNoteAppName "OneNote.Application"

    variable _ruff_preamble {
        The `OneNote` namespace provides commands to control Microsoft OneNote.
    }

    proc GetVersion { oneNoteId { useString false } } {
        # Return the version of a OneNote application.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        # useString - If set to true, return the version name (ex. `OneNote 2010`).
        #             Otherwise return the version number (ex. `12.0`).
        #
        # Both version name and version number are returned as strings.
        # Version number is in a format, so that it can be evaluated as a
        # floating point number.
        #
        # Returns the version of a OneNote application.
        #
        # See also: Open GetExtString

        variable oneNoteVersion

        array set map {
            "12.0" "OneNote 2007"
            "14.0" "OneNote 2010"
            "15.0" "OneNote 2013"
            "16.0" "OneNote 2016"
        }

        if { $useString } {
            if { [info exists map($oneNoteVersion)] } {
                return $map($oneNoteVersion)
            } else {
                return "Unknown OneNote version $oneNoteVersion"
            }
        } else {
            return $oneNoteVersion
        }
    }

    proc GetExtString { oneNoteId } {
        # Return the default extension of a OneNote file.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        #
        # Returns the default extension of a OneNote file.
        #
        # See also: Open GetVersion

        # oneNoteId is only needed, so we are sure, that oneNoteVersion is initialized.
        # Note: Currently not needed, but kept to be conformant to other Cawt modules.

        variable oneNoteVersion

        return ".one"
    }

    proc GetNodeType { domNode } {
        # Get type of a DOM node.
        #
        # domNode  - DOM node.
        #
        # Returns node type as string.
        # Possible values: `Notebook`, `Section`, `Page`.
        #
        # See also: IsNodeType GetNodesByType

        set nodeType [$domNode nodeName]
        return [lindex [split $nodeType ":"] 1]
    }

    proc IsNodeType { domNode nodeType } {
        # Check, if node is of specific type.
        #
        # domNode  - DOM node.
        # nodeType - Node type (`Notebook`, `Section`, `Page`).
        #
        # Returns true, if node is of specified type. Otherwise false.
        #
        # See also: GetNodeType GetNodesByType

        if { $nodeType eq "any" || [OneNote GetNodeType $domNode] eq $nodeType } {
            return true
        } else {
            return false
        }
    }

    proc GetNodeAttribute { domNode attrName } {
        # Get attribute value of a DOM node.
        #
        # domNode  - DOM node.
        # attrName - Attribute name.
        #
        # Returns attribute value as string.
        #
        # See also: GetNodeName GetNodeHyperLink

        set attrValue ""
        if { [$domNode hasAttribute $attrName] } {
            set attrValue [$domNode getAttribute $attrName]
        }
        return $attrValue
    }

    proc GetNodeName { domNode } {
        # Get value of node attribute `name`.
        #
        # domNode - DOM node.
        #
        # Returns attribute value as string.
        #
        # See also: GetNodeAttribute GetNodeHyperLink

        return [OneNote GetNodeAttribute $domNode "name"]
    }

    proc GetNodeHyperLink { oneNoteId domNode } {
        # Get hyperlink to OneNote node.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        # domNode   - DOM node.
        #
        # Returns hyperlink as string.
        #
        # See also: Open GetNodeAttribute GetNodeName

        set objId [OneNote GetNodeAttribute $domNode "ID"]
        set appId [OneNote GetApplicationId $oneNoteId]
        $appId -call GetHyperlinkToObject $objId "" xmlOut
        return [twapi::variant_value $xmlOut 0 0 0]
    }

    proc GetPageContent { oneNoteId domNode } {
        # Get page content as XML.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        # domNode   - DOM node of a page.
        #
        # See also: Open PrintPage

        set pageId [OneNote GetNodeAttribute $domNode "ID"]
        set appId  [OneNote GetApplicationId $oneNoteId]
        $appId -call GetPageContent $pageId xmlOut
        set pageXml [twapi::variant_value $xmlOut 0 0 0]
        set pageDoc [dom parse $pageXml]
        return $pageDoc
    }

    proc _GetHierarchy { appId root hierarchyScope } {
        $appId -call GetHierarchy $root $hierarchyScope xmlOut
        return [twapi::variant_value $xmlOut 0 0 0]
    }

    proc Open {} {
        # Open a OneNote instance.
        #
        # Returns the identifier of the OneNote instance.
        #
        # The identifier is a dictionary containing 2 elements:
        # Key appId - The application identifier.
        # Key docId - The DOM node identifier.
        #
        # See also: Quit GetApplicationId GetDomId

        variable oneNoteVersion
        variable oneNoteAppName

        if { ! [Cawt HavePkg "tdom"] } {
            error "Cannot use $oneNoteAppName. No tDOM extension available."
        }
        foreach version { 10 11 12 13 14 15 16 17 18 19 20 } {
            set catchVal [catch { twapi::comobj $oneNoteAppName.$version } appId]
            if { ! $catchVal } {
                set catchVal [catch { $appId GetHierarchy "" $::OneNote::hsSelf str } retVal]
                if { ! $catchVal } {
                    # puts "Using $oneNoteAppName.$version"
                    set oneNoteVersion "$version.0"
                    set hierarchyXml [OneNote::_GetHierarchy $appId "" $::OneNote::hsPages]
                    set doc [dom parse $hierarchyXml]
                    dict set oneNoteId "appId" $appId
                    dict set oneNoteId "docId" $doc
                    return $oneNoteId
                }
            }
        }
        error "Cannot open $oneNoteAppName application."
    }

    proc Quit { oneNoteId } {
        # Quit a OneNote instance.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        #
        # Returns no value.
        #
        # See also: Open
    }

    proc GetApplicationId { oneNoteId } {
        # Get the application identifier of a OneNote object.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        #
        # Returns the application identifier of the OneNote object.
        #
        # See also: Open GetDomId

        return [dict get $oneNoteId "appId"]
    }

    proc GetDomId { oneNoteId } {
        # Get the DOM identifier of a OneNote object.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        #
        # Returns the DOM identifier of the OneNote object.
        #
        # See also: Open GetApplicationId GetDomRoot

        return [dict get $oneNoteId "docId"]
    }

    proc GetDomRoot { oneNoteId } {
        # Get the DOM root of a OneNote object.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        #
        # Returns the DOM root of the OneNote object.
        #
        # See also: Open GetApplicationId GetDomId

        return [[dict get $oneNoteId "docId"] documentElement]
    }

    proc GetNodesByType { domNode nodeType } {
        # Get nodes of specific type.
        #
        # domNode  - DOM node.
        # nodeType - Node type (`Notebook`, `Section`, `Page`).
        #
        # Returns the found nodes as a list.
        #
        # See also: GetNotebooks GetSections GetPages GetNodeType

        set resultList [list]
        if { [OneNote IsNodeType $domNode $nodeType] } {
            return $domNode
        }
        if {[$domNode hasChildNodes]} {
            foreach childNode [$domNode childNodes] {
                set result [OneNote::GetNodesByType $childNode $nodeType]
                if { [llength $result] > 0 } {
                    lappend resultList {*}$result
                }
            }
        }
        return $resultList
    }

    proc GetNotebooks { domNode } {
        # Get the notebooks of a OneNote object.
        #
        # domNode - DOM root node as returned by GetDomRoot.
        #
        # Returns the notebooks of the OneNote object as list.
        #
        # See also: GetNodesByType GetSections GetPages GetDomRoot GetNodeType

        return [OneNote::GetNodesByType $domNode "Notebook"]
    }

    proc GetSections { domNode } {
        # Get the sections of a OneNote notebook.
        #
        # domNode - DOM node identifying a notebook.
        #
        # Returns the sections of the OneNote notebook as list.
        #
        # See also: GetNodesByType GetNotebooks GetPages FindNotebook GetNodeType

        return [OneNote::GetNodesByType $domNode "Section"]
    }

    proc GetPages { domNode } {
        # Get the pages of a OneNote section.
        #
        # domNode - DOM node identifying a section.
        #
        # Return the pages of the OneNote section as list.
        #
        # See also: GetNodesByType GetSections GetPages FindSection GetNodeType

        return [OneNote::GetNodesByType $domNode "Page"]
    }

    proc FindNodeByName { domNode nodeType nodeName } {
        # Get a specific node by name.
        #
        # domNode  - DOM node.
        # nodeType - Node type (`Notebook`, `Section`, `Page`).
        # nodeName - Node name.
        #
        # Returns the found node or an empty string, if the node could not be found.
        #
        # See also: FindNotebook FindSection FindPage GetNodeName

        set result ""
        if { [OneNote IsNodeType $domNode $nodeType] } {
            if { [OneNote GetNodeName $domNode] eq $nodeName } {
                set result $domNode
            }
            return $result
        }
        if { [$domNode hasChildNodes] } {
            foreach childNode [$domNode childNodes] {
                set result [OneNote::FindNodeByName $childNode $nodeType $nodeName]
                if { $result ne "" } {
                    return $result
                }
            }
        }
        return $result
    }

    proc FindNotebook { domNode nodeName } {
        # Get a specific notebook by name.
        #
        # domNode  - DOM root node as returned by [GetDomRoot].
        # nodeName - Node name.
        #
        # Returns the found notebook or an empty string, if the notebook could not be found.
        #
        # See also: FindNodeByName FindSection FindPage GetDomRoot GetNodeName

        return [OneNote::FindNodeByName $domNode "Notebook" $nodeName]
    }

    proc FindSection { domNode nodeName } {
        # Get a specific section by name.
        #
        # domNode  - DOM node identifying a notebook.
        # nodeName - Node name.
        #
        # Returns the found section or an empty string, if the section could not be found.
        #
        # See also: FindNodeByName FindNotebook FindPage GetSections GetNodeName

        return [OneNote::FindNodeByName $domNode "Section" $nodeName]
    }

    proc FindPage { domNode nodeName } {
        # Get a specific page by name.
        #
        # domNode  - DOM node identifying a section.
        # nodeName - Node name.
        #
        # Returns the found page or an empty string, if the page could not be found.
        #
        # See also: FindNodeByName FindNotebook FindSection GetPages GetNodeName

        return [OneNote::FindNodeByName $domNode "Page" $nodeName]
    }

    proc _GetLastModifiedRecursive { domNode compareDate nodeType notebookName } {
        variable sModifiedList

        if { $notebookName ne "" && \
             ( [OneNote IsNodeType $domNode "Notebook"] && [OneNote GetNodeName $domNode] ne $notebookName ) } {
            return
        }
        if { [OneNote IsNodeType $domNode $nodeType] } {
            set lastModifiedXml [OneNote GetNodeAttribute $domNode "lastModifiedTime"]
            if { $lastModifiedXml ne "" } {
                set lastModifiedSecs [Cawt XmlDateToSeconds $lastModifiedXml]
                if { $compareDate <= $lastModifiedSecs } {
                    if { [info exists sModifiedList($lastModifiedSecs)] } {
                        lappend sModifiedList($lastModifiedSecs) $domNode
                    } else {
                        set sModifiedList($lastModifiedSecs) $domNode
                    }
                } else {
                    # puts "Skipping [OneNote GetNodeName $domNode] because of date: [Cawt SecondsToIsoDate $lastModifiedSecs]"
                }
            }
        } else {
            # puts "Skipping [OneNote GetNodeName $domNode] because of type: [OneNote GetNodeType $domNode]"
        }
        if {[$domNode hasChildNodes]} {
            foreach childNode [$domNode childNodes] {
                OneNote::_GetLastModifiedRecursive $childNode $compareDate $nodeType $notebookName
            }
        }
    }

    proc GetLastModified { domNode { compareDate 0 } { nodeType "any" } { notebookName "" } } {
        # Get nodes with specific modification date.
        #
        # domNode      - DOM node.
        # compareDate  - Date in seconds (as returned by `clock seconds`). 
        # nodeType     - Node type (`any`, `Notebook`, `Section`, `Page`).
        # notebookName - Notebook name.
        #
        # Returns found nodes as list.
        #
        # See also: FindNotebook GetDomRoot

        variable sModifiedList

        catch { unset sModifiedList }
        set modifiedList [list]
        OneNote::_GetLastModifiedRecursive $domNode $compareDate $nodeType $notebookName
        foreach date [lsort -integer -decreasing [array names sModifiedList]] {
            foreach entry $sModifiedList($date) {
                lappend modifiedList $entry
            }
        }
        return $modifiedList
    }

    proc PrintPage { oneNoteId domNode } {
        # Print page content as XML to standard output.
        #
        # oneNoteId - Identifier dictionary of a OneNote object.
        # domNode   - DOM node of a page.
        #
        # Returns no value.
        #
        # See also: GetPageContent

        set pageDomDoc [OneNote GetPageContent $oneNoteId $domNode]
        set pageRoot   [$pageDomDoc documentElement]
        puts [$pageRoot asXML]
    }
}
