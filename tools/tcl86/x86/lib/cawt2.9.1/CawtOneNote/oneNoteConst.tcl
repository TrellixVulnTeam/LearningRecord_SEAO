# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval OneNote {

    namespace ensemble create

    # Enumeration CreateFileType
    variable cftNone     0
    variable cftNotebook 1
    variable cftFolder   2
    variable cftSection  3

    # Enumeration DockLocation
    variable dlDefault -1
    variable dlLeft     1
    variable dlRight    2
    variable dlTop      3
    variable dlBottom   4

    # Enumeration FilingLocation
    variable flEMail      0
    variable flContacts   1
    variable flTasks      2
    variable flMeetings   3
    variable flWebContent 4
    variable flPrintOuts  5

    # Enumeration FilingLocationType
    variable fltNamedSectionNewPage   0
    variable fltCurrentSectionNewPage 1
    variable fltCurrentPage           2
    variable fltNamedPage             4

    # Enumeration HierarchyElement
    variable heNone          0
    variable heNotebooks     1
    variable heSectionGroups 2
    variable heSections      4
    variable hePages         8

    # Enumeration HierarchyScope
    variable hsSelf      0
    variable hsChildren  1
    variable hsNotebooks 2
    variable hsSections  3
    variable hsPages     4

    # Enumeration NewPageStyle
    variable npsDefault            0
    variable npsBlankPageWithTitle 1
    variable npsBlankPageNoTitle   2
 
    # Enumeration NotebookFilterOutType
    variable nfoLocal    1
    variable nfoNetwork  2
    variable nfoWeb      4
    variable nfoNoWacUrl 8

    # Enumeration PageInfo
    variable piBasic               0
    variable piBinaryData          1
    variable piSelection           2
    variable piBinaryDataSelection 3
    variable piFileType            4
    variable piBinaryDataFileType  5
    variable piSelectionFileType   6
    variable piAll                 7

    # Enumeration PublishFormat
    variable pfOneNote        0
    variable pfOneNotePackage 1
    variable pfMHTML          2
    variable pfPDF            3
    variable pfXPS            4
    variable pfWord           5
    variable pfEMF            6
    variable pfHTML           7
    variable pfOneNote2007    8

    # Enumeration RecentResultType
    variable rrtNone   0
    variable rrtFiling 1
    variable rrtSearch 2
    variable rrtLinks  3

    # Enumeration SpecialLocation
    variable slBackupFolder          0
    variable slUnfiledNotesSection   1
    variable slDefaultNotebookFolder 2

    # Enumeration TreeCollapsedStateType
    variable tcsExpanded  0
    variable tcsCollapsed 1

    # Enumeration XMLSchema
    variable xs2007 0
    variable xs2010 1
    variable xs2013 2

    # Enumeration procedures

    namespace eval Enum {

        proc CreateFileType {} {
            # cftNone     - 0 # Creates no new object.
            # cftNotebook - 1 # Creates a notebook by using the specified name and location.
            # cftFolder   - 2 # Creates a section group by using the specified name and location.
            # cftSection  - 3 # Creates a section by using the specified name and location.
            return { cftNone 0 cftNotebook 1 cftFolder 2 cftSection 3 }
        }

        proc DockLocation {} {
            # dlDefault - -1 # The OneNote window is docked at the default location on the desktop.
            # dlLeft    -  1 # The OneNote window is docked on the left side of the desktop.
            # dlRight   -  2 # The OneNote window is docked on the right side of the desktop.
            # dlTop     -  3 # The OneNote window is docked at the top of the desktop.
            # dlBottom  -  4 # The OneNote window is docked at the bottom of the desktop.
            return { dlDefault -1 dlLeft 1 dlRight 2 dlTop 3 dlBottom 4 }
        }

        proc FilingLocation {} {
            # flEMail      - 0 # Sets where Outlook email messages will be filed.
            # flContacts   - 1 # Sets where Outlook contacts will be filed.
            # flTasks      - 2 # Sets where Outlook tasks will be filed.
            # flMeetings   - 3 # Sets where Outlook meetings will be filed.
            # flWebContent - 4 # Sets where Internet Explorer contents will be filed.
            # flPrintOuts  - 5 # Sets where printouts from the OneNote printer will be filed.
            return { flEMail 0 flContacts 1 flTasks 2 flMeetings 3 flWebContent 4 flPrintOuts 5 }
        }

        proc FilingLocationType {} {
            # fltNamedSectionNewPage   - 0 # Sets content to be filed on a new page in a specified section.
            # fltCurrentSectionNewPage - 1 # Sets content to be filed on a new page in the current section.
            # fltCurrentPage           - 2 # Sets content to be filed on the current page.
            # fltNamedPage             - 4 # Sets content to be filed on a specified page.
            return { fltNamedSectionNewPage 0 fltCurrentSectionNewPage 1 fltCurrentPage 2 fltNamedPage 4 }
        }

        proc HierarchyElement {} {
            # heNone          - 0 # Refers to no element.
            # heNotebooks     - 1 # Refers to the Notebook elements.
            # heSectionGroups - 2 # Refers to the Section Group elements.
            # heSections      - 4 # Refers to the Section elements.
            # hePages         - 8 # Refers to the Page elements.
            return { heNone 0 heNotebooks 1 heSectionGroups 2 heSections 4 hePages 8 }
        }

        proc HierarchyScope {} {
            # hsSelf      - 0 # Gets just the start node specified and no descendants.
            # hsChildren  - 1 # Gets the immediate child nodes of the start node, and no descendants in higher or lower subsection groups.
            # hsNotebooks - 2 # Gets all notebooks below the start node, or root.
            # hsSections  - 3 # Gets all sections below the start node, including sections in section groups and subsection groups.
            # hsPages     - 4 # Gets all pages below the start node, including all pages in section groups and subsection groups.
            return { hsSelf 0 hsChildren 1 hsNotebooks 2 hsSections 3 hsPages 4 }
        }

        proc NewPageStyle {} {
            # npsDefault            - 0 # Creates a page that has the default page style.
            # npsBlankPageWithTitle - 1 # Creates a blank page that has a title.
            # npsBlankPageNoTitle   - 2 # Creates a blank page that has no title.
            return { npsDefault 0 npsBlankPageWithTitle 1 npsBlankPageNoTitle 2 }
        }

        proc NotebookFilterOutType {} {
            # nfoLocal    - 1 # Allow only Local Notebooks.
            # nfoNetwork  - 2 # Allows UNC or SharePoint Notebooks.
            # nfoWeb      - 4 # Allows OneDrive notebooks.
            # nfoNoWacUrl - 8 # Any notebooks in locations that do not have a web client.
            return { nfoLocal 1 nfoNetwork 2 nfoWeb 4 nfoNoWacUrl 8 }
        }

        proc PageInfo {} {
            # piBasic               - 0 # Returns only basic page content, without selection markup, file types for 
            #                             binary data objects and binary data objects. This is the standard value to pass.
            # piBinaryData          - 1 # Returns page content with no selection markup, but with all binary data.
            # piSelection           - 2 # Returns page content with selection markup, but no binary data.
            # piBinaryDataSelection - 3 # Returns page content with selection markup and all binary data.
            # piFileType            - 4 # Returns page content with file type info for binary data objects.
            # piBinaryDataFileType  - 5 # Returns page content with file type info for binary data objects and binary data objects.
            # piSelectionFileType   - 6 # Returns page content with selection markup and file type info for binary data.
            # piAll                 - 7 # Returns all page content.
            return { piBasic 0 piBinaryData 1 piSelection 2 piBinaryDataSelection 3 piFileType 4 piBinaryDataFileType 5 piSelectionFileType 6 piAll 7 } 
        }

        proc PublishFormat {} {
            # pfOneNote        - 0 # Published page is in the .one format.
            # pfOneNotePackage - 1 # Published page is in the .onepkg format.
            # pfMHTML          - 2 # Published page is in the .mht format.
            # pfPDF            - 3 # Published page is in the .pdf format.
            # pfXPS            - 4 # Published page is in the .xps format.
            # pfWord           - 5 # Published page is in the .doc or .docx format.
            # pfEMF            - 6 # Published page is in the enhanced metafile (.emf) format.
            # pfHTML           - 7 # Published page is in the .html format. This member is new in OneNote 2013.
            # pfOneNote2007    - 8 # Published page is in the 2007 .one format. This member is new in OneNote 2013.
            return { pfOneNote 0 pfOneNotePackage 1 pfMHTML 2 pfPDF 3 pfXPS 4 pfWord 5 pfEMF 6 pfHTML 7 pfOneNote2007 8 }
        }

        proc RecentResultType {} {
            # rrtNone   - 0 # Sets no recent-result list to be rendered.
            # rrtFiling - 1 # Sets the "Filing" recent-result list to be rendered.
            # rrtSearch - 2 # Sets the "Search" recent-result list to be rendered.
            # rrtLinks  - 3 # Sets the "Links" recent-result list to be rendered.
            return { rrtNone 0 rrtFiling 1 rrtSearch 2 rrtLinks 3 }
        }

        proc SpecialLocation {} {
            # slBackupFolder          - 0 # Gets the path to the Backup Folders folder location.
            # slUnfiledNotesSection   - 1 # Gets the path to the Unfiled Notes folder location.
            # slDefaultNotebookFolder - 2 # Gets the path to the Default Notebook folder location.
            return { slBackupFolder 0 slUnfiledNotesSection 1 slDefaultNotebookFolder 2 }
        }

        proc TreeCollapsedStateType {} {
            # tcsExpanded  - 0 # Sets the hierarchy tree to expanded.
            # tcsCollapsed - 1 # Sets the hierarchy tree to collapsed.
            return { tcsExpanded 0 tcsCollapsed 1 }
        }

        proc XMLSchema {} {
            # xs2007    - 0 # References the OneNote 2007 schema.
            # xs2010    - 1 # References the OneNote 2010 schema.
            # xs2013    - 2 # References the OneNote 2013 schema.
            return { xs2007 0 xs2010 1 xs2013 2 } 
        }
    }

    variable enums

    array set enums [list \
        CreateFileType [Enum::CreateFileType] \
        DockLocation [Enum::DockLocation] \
        FilingLocation [Enum::FilingLocation] \
        FilingLocationType [Enum::FilingLocationType] \
        HierarchyElement [Enum::HierarchyElement] \
        HierarchyScope [Enum::HierarchyScope] \
        NewPageStyle [Enum::NewPageStyle] \
        NotebookFilterOutType [Enum::NotebookFilterOutType] \
        PageInfo [Enum::PageInfo] \
        PublishFormat [Enum::PublishFormat] \
        RecentResultType [Enum::RecentResultType] \
        SpecialLocation [Enum::SpecialLocation] \
        TreeCollapsedStateType [Enum::TreeCollapsedStateType] \
        XMLSchema [Enum::XMLSchema] \
    ]

    namespace export GetEnum
    namespace export GetEnumName
    namespace export GetEnumNames
    namespace export GetEnumTypes
    namespace export GetEnumVal

    proc GetEnumTypes { } {
        # Get available enumeration types.
        #
        # Returns the list of available enumeration types.
        #
        # See also: GetEnumName GetEnumNames GetEnumVal GetEnum

        variable enums

        return [lsort -dictionary [array names enums]]
    }

    proc GetEnumName { enumType enumVal } {
        # Get name of a given enumeration type and numeric value.
        #
        # enumType - Enumeration type
        # enumVal  - Enumeration numeric value.
        #
        # Returns the list of names of a given enumeration type.
        #
        # See also: GetEnumNames GetEnumTypes GetEnumVal GetEnum

        variable enums

        set enumName ""
        if { [info exists enums($enumType)] } {
            foreach { key val } $enums($enumType) {
                if { $val eq $enumVal } {
                    set enumName $key
                    break
                }
            }
        }
        return $enumName
    }

    proc GetEnumNames { enumType } {
        # Get names of a given enumeration type.
        #
        # enumType - Enumeration type
        #
        # Returns the list of names of a given enumeration type.
        #
        # See also: GetEnumName GetEnumTypes GetEnumVal GetEnum

        variable enums

        if { [info exists enums($enumType)] } {
            foreach { key val } $enums($enumType) {
                lappend nameList $key
            }
            return $nameList
        } else {
            return [list]
        }
    }

    proc GetEnumVal { enumName } {
        # Get numeric value of an enumeration name.
        #
        # enumName - Enumeration name
        #
        # Returns the numeric value of an enumeration name.
        #
        # See also: GetEnumName GetEnumTypes GetEnumNames GetEnum

        variable enums

        foreach enumType [GetEnumTypes] {
            set ind [lsearch -exact $enums($enumType) $enumName]
            if { $ind >= 0 } {
                return [lindex $enums($enumType) [expr { $ind + 1 }]]
            }
        }
        return ""
    }

    proc GetEnum { enumOrString } {
        # Get numeric value of an enumeration.
        #
        # enumOrString - Enumeration name
        #
        # Returns the numeric value of an enumeration.
        #
        # See also: GetEnumName GetEnumTypes GetEnumVal GetEnumNames

        set retVal [catch { expr int($enumOrString) } enumInt]
        if { $retVal == 0 } {
            return $enumInt
        } else {
            return [GetEnumVal $enumOrString]
        }
    }
}
