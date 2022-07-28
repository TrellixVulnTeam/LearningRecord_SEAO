# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Word {

    namespace ensemble create

    namespace export AddBookmark
    namespace export AddContentControl
    namespace export AddDocument
    namespace export AddPageBreak
    namespace export AddParagraph
    namespace export AddRow
    namespace export AddTable
    namespace export AddText
    namespace export AppendParagraph
    namespace export AppendText
    namespace export Close
    namespace export CollapseRange
    namespace export ConfigureCaption
    namespace export CopyRange
    namespace export CreateRange
    namespace export CreateRangeAfter
    namespace export CropImage
    namespace export DeleteRow
    namespace export DeleteSubdocumentLinks
    namespace export DeleteTable
    namespace export ExpandSubdocuments
    namespace export ExtendRange
    namespace export FindString
    namespace export GetBookmarkName
    namespace export GetBookmarkNames
    namespace export GetCrossReferenceItems
    namespace export GetCellRange
    namespace export GetCellValue
    namespace export GetColumnRange
    namespace export GetColumnValues
    namespace export GetCompatibilityMode
    namespace export GetDocumentId
    namespace export GetDocumentIdByIndex
    namespace export GetDocumentName
    namespace export GetEndRange
    namespace export GetExtString
    namespace export GetFooterText
    namespace export GetHeaderText
    namespace export GetHeadingRanges
    namespace export GetImageId
    namespace export GetImageName
    namespace export GetImageList
    namespace export GetListGalleryId
    namespace export GetListTemplateId
    namespace export GetNumCharacters
    namespace export GetNumColumns
    namespace export GetNumDocuments
    namespace export GetNumImages
    namespace export GetNumHyperlinks
    namespace export GetNumPages
    namespace export GetNumRows
    namespace export GetNumSubdocuments
    namespace export GetNumTables
    namespace export GetPageSetup
    namespace export GetRangeEndIndex
    namespace export GetRangeFont
    namespace export GetRangeInformation
    namespace export GetRangeScreenPos
    namespace export GetRangeStartIndex
    namespace export GetRangeText
    namespace export GetRowId
    namespace export GetRowRange
    namespace export GetRowValues
    namespace export GetSelectionRange
    namespace export GetStartRange
    namespace export GetSubdocumentPath
    namespace export GetTableIdByIndex
    namespace export GetTableIdByName
    namespace export GetTableName
    namespace export GetVersion
    namespace export InsertCaption
    namespace export InsertFile
    namespace export InsertImage
    namespace export InsertList
    namespace export InsertText
    namespace export IsInlineShape
    namespace export IsValidCell
    namespace export IsVisible
    namespace export MergeCells
    namespace export Open
    namespace export OpenDocument
    namespace export OpenNew
    namespace export PrintRange
    namespace export Quit
    namespace export ReplaceByProc
    namespace export ReplaceImage
    namespace export ReplaceString
    namespace export SaveAs
    namespace export SaveAsPdf
    namespace export ScaleImage
    namespace export ScreenUpdate
    namespace export Search
    namespace export SelectRange
    namespace export SetCellValue
    namespace export SetCellVerticalAlignment
    namespace export SetColumnValues
    namespace export SetColumnWidth
    namespace export SetColumnsWidth
    namespace export SetCompatibilityMode
    namespace export SetContentControlDropdown
    namespace export SetContentControlText
    namespace export SetHyperlink
    namespace export SetHyperlinkToFile
    namespace export SetImageName
    namespace export SetInternalHyperlink
    namespace export SetLinkToBookmark
    namespace export SetPageSetup
    namespace export SetRangeBackgroundColor
    namespace export SetRangeBackgroundColorByEnum
    namespace export SetRangeEndIndex
    namespace export SetRangeFont
    namespace export SetRangeFontBold
    namespace export SetRangeFontColor
    namespace export SetRangeFontItalic
    namespace export SetRangeFontName
    namespace export SetRangeFontSize
    namespace export SetRangeFontUnderline
    namespace export SetRangeFontBackgroundColor
    namespace export SetRangeHighlightColorByEnum
    namespace export SetRangeHorizontalAlignment
    namespace export SetRangeMergeCells
    namespace export SetRangeStartIndex
    namespace export SetRangeStyle
    namespace export SetRowHeight
    namespace export SetRowValues
    namespace export SetTableAlignment
    namespace export SetTableBorderLineStyle
    namespace export SetTableBorderLineWidth
    namespace export SetTableName
    namespace export SetTableOptions
    namespace export SetTableVerticalAlignment
    namespace export SetViewParameters
    namespace export ShowAlerts
    namespace export ToggleSpellCheck
    namespace export TrimString
    namespace export UpdateFields
    namespace export Visible

    variable wordVersion "0.0"
    variable wordAppName "Word.Application"

    variable _ruff_preamble {
        The `Word` namespace provides commands to control Microsoft Word.
    }

    proc TrimString { str } {
        # Trim a string.
        #
        # str - String to be trimmed.
        #
        # The string is trimmed from the left and right side.
        # Trimmed characters are whitespaces.
        # Additionally the following control characters are converted:
        # `0xD` to `"\n"`, `0x7` to `" "`.
        #
        # Returns the trimmed string.
        #
        # See also: GetCellValue

        set str [string map [list [format %c 0xD] \n  [format %c 0x7] " "] $str]
        return [string trim $str]
    }

    proc _IsDocument { objId } {
        # ActiveTheme is a property of the Word Document class.
        set retVal [catch {$objId ActiveTheme} errMsg]
        if { $retVal == 0 } {
            return true
        } else {
            return false
        }
    }

    proc IsInlineShape { objId } {
       # Check, if a Word object is an InlineShape.
       #
       # objId - Identifier of a Word object instance.
       #
       # Returns true, if the Word object is an InlineShape.
       # Otherwise false.
       #
       # See also: IsValidCell

       # Borders is a property of the Word InlineShape class,
       # but not of class Shape.
        set retVal [catch {$objId Borders} errMsg]
        if { $retVal == 0 } {
            Cawt Destroy $errMsg
            return true
        } else {
            return false
        }
    }

    proc _FindOrReplace { objId paramDict } {
        # Execute([FindText], [MatchCase], [MatchWholeWord], [MatchWildcards],
        # [MatchSoundsLike], [MatchAllWordForms], [Forward], [Wrap], [Format],
        # [ReplaceWith], [Replace], [MatchKashida], [MatchDiacritics],
        # [MatchAlefHamza], [MatchControl]) As Boolean
        set myFind [$objId Find]
        set retVal [$myFind -callnamedargs Execute {*}$paramDict]
        Cawt Destroy $myFind
        return $retVal
    }

    proc _IterateDocument { rangeOrDocId paramDict } {
        if { [Word::_IsDocument $rangeOrDocId] } {
            set numFound 0
            set stories [$rangeOrDocId StoryRanges]
            $stories -iterate story {
                lappend storyList $story
                set retVal [Word::_FindOrReplace $story $paramDict]
                incr numFound $retVal
                set nextStory [$story NextStoryRange]
                while { [Cawt IsComObject $nextStory] } {
                    lappend storyList $nextStory
                    set retVal [Word::_FindOrReplace $nextStory $paramDict]
                    incr numFound $retVal
                    set nextStory [$nextStory NextStoryRange]
                }
            }
            foreach story $storyList {
                Cawt Destroy $story
            }
            Cawt Destroy $stories
            return $numFound
        } else {
            return [Word::_FindOrReplace $rangeOrDocId $paramDict]
        }
    }

    proc FindString { rangeOrDocId searchStr { matchCase true } { matchWildcards false } } {
        # Find a string in a text range or a document.
        #
        # rangeOrDocId   - Identifier of a text range or a document identifier.
        # searchStr      - Search string.
        # matchCase      - Flag indicating case sensitive search.
        # matchWildcards - Flag indicating wildcard search.
        #
        # Returns zero, if string could not be found. Otherwise a positive integer.
        # If the string was found, the selection is set to the found string.
        #
        # See also: ReplaceString ReplaceByProc Search GetSelectionRange

        return [Word::Search $rangeOrDocId $searchStr \
               -matchcase $matchCase -matchwildcards $matchWildcards \
               -wrap $Word::wdFindStop -forward true] 
    }

    proc ReplaceString { rangeOrDocId searchStr replaceStr \
                        { howMuch "one" } { matchCase true } { matchWildcards false } } {
        # Replace a string in a text range or a document. Simple case.
        #
        # rangeOrDocId   - Identifier of a text range or a document identifier.
        # searchStr      - Search string.
        # replaceStr     - Replacement string.
        # howMuch        - `one` to replace first occurence only. `all` to replace all occurences.
        # matchCase      - Flag indicating case sensitive search.
        # matchWildcards - Flag indicating wildcard search. 
        #
        # Returns zero, if string could not be found and replaced. Otherwise a positive integer.
        #
        # See also: FindString ReplaceByProc Search

        set howMuchEnum $Word::wdReplaceOne
        if { $howMuch ne "one" } {
            set howMuchEnum $Word::wdReplaceAll
        }
        return [Word::Search $rangeOrDocId $searchStr \
               -matchcase $matchCase -matchwildcards $matchWildcards \
               -wrap $Word::wdFindStop -forward true \
               -replacewith $replaceStr -replace $howMuchEnum]
    }

    proc Search { rangeOrDocId searchStr args } {
        # Search or replace a string in a text range or a document. Generic case.
        #
        # rangeOrDocId - Identifier of a text range or a document identifier.
        # searchStr    - Search string.
        # args         - Options described below.
        #
        # -matchcase <bool>         - Search in case sensitive mode.
        # -matchwholeword <bool>    - Search entire words only.
        # -matchwildcards <bool>    - Search with wild cards.
        # -matchsoundslike <bool>   - Search for strings that sound similar.
        # -matchallwordforms <bool> - Search all forms of the search string.
        # -forward <bool>           - Search towards end of document.
        # -wrap <enum>              - Search wrap mode. 
        #                             Value of enumeration type [Enum::WdFindWrap].
        #                             Typical values: `wdFindAsk`, `wdFindContinue`, `wdFindStop`.
        # -format <bool>            - Search operation uses formatting in addition to the search string.
        # -replacewith <string>     - Replacement text.
        # -replace <enum>           - Number of replacements. 
        #                             Value of enumeration type [Enum::WdReplace].
        #                             Typical values: `wdReplaceNone`, `wdReplaceOne`, `wdReplaceAll`. 
        # -matchkashida <bool>      - Match text with matching kashidas in an Arabic-language document.
        # -matchdiacritics <bool>   - Match text with matching diacritics in a right-to-left language document.
        # -matchalefhamza <bool>    - Match text with matching alef hamzas in an Arabic-language document.
        # -matchcontrol <bool>      - Match text with matching bidirectional control characters in a 
        #                             right-to-left language document.
        # -matchprefix <bool>       - Match words beginning with the search string.
        # -matchsuffix <bool>       - Match words ending with the search string.
        # -matchphrase <bool>       - Ignores all white space and control characters between words.
        # -ignorespace <bool>       - Ignore all white space between words.
        # -ignorepunct <bool>       - Ignore all punctuation characters between words.
        #
        # See the Word reference documentation regarding `Find.Execute` at
        # <https://msdn.microsoft.com/en-us/library/office/ff193977.aspx> for more details.
        #
        # Returns zero, if string could not be found and replaced. Otherwise a positive integer.
        #
        # See also: FindString ReplaceString ReplaceByProc

        set params [dict create FindText $searchStr]

        foreach { key value } $args {
            if { $value eq "" && $key ne "-replacewith" } {
                error "Search: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-matchcase"         { dict append params MatchCase         [Cawt TclBool $value] }
                "-matchwholeword"    { dict append params MatchWholeWord    [Cawt TclBool $value] }
                "-matchwildcards"    { dict append params MatchWildcards    [Cawt TclBool $value] }
                "-matchsoundslike"   { dict append params MatchSoundsLike   [Cawt TclBool $value] }
                "-matchallwordforms" { dict append params MatchAllWordForms [Cawt TclBool $value] }
                "-forward"           { dict append params Forward           [Cawt TclBool $value] }
                "-wrap"              { dict append params Wrap              [Word GetEnum $value] }
                "-format"            { dict append params Format            [Cawt TclBool $value] }
                "-replacewith"       { dict append params ReplaceWith       $value }
                "-replace"           { dict append params Replace           [Word GetEnum $value] }
                "-matchkashida"      { dict append params MatchKashida      [Cawt TclBool $value] }
                "-matchdiacritics"   { dict append params MatchDiacritics   [Cawt TclBool $value] }
                "-matchalefhamza"    { dict append params MatchAlefHamza    [Cawt TclBool $value] }
                "-matchcontrol"      { dict append params MatchControl      [Cawt TclBool $value] }
                "-matchprefix"       { dict append params MatchPrefix       [Cawt TclBool $value] }
                "-matchsuffix"       { dict append params MatchSuffix       [Cawt TclBool $value] }
                "-matchphrase"       { dict append params MatchPhrase       [Cawt TclBool $value] }
                "-ignorespace"       { dict append params IgnoreSpace       [Cawt TclBool $value] }
                "-ignorepunct"       { dict append params IgnorePunct       [Cawt TclBool $value] }
                default              { error "Search: Unknown key \"$key\" specified" }
            }
        }
        return [Word::_IterateDocument $rangeOrDocId $params]
    }

    proc ReplaceByProc { rangeId str func args } {
        # Replace a string in a text range. Procedural case.
        #
        # rangeId - Identifier of the text range.
        # str     - Search string.
        # func    - Replacement procedure.
        # args    - Arguments for replacement procedure.
        #
        # Search for string $str in the range $rangeId. For each
        # occurence found, call procedure $func with the range of
        # the found occurence and additional parameters specified in
        # $args. The procedures which can be used for $func must
        # therefore have the following signature:
        #     proc SetRangeXYZ rangeId param1 param2 ...
        #
        # See test script Word-04-Find.tcl for an example.
        #
        # Returns no value.
        #
        # See also: FindString ReplaceString

        set myFind [$rangeId Find]
        set count 0
        while { 1 } {
            # See proc _FindOrReplace for a parameter list of the Execute command.
            set retVal [$myFind -callnamedargs Execute \
                                FindText $str \
                                MatchCase True \
                                Forward True]
            if { ! $retVal } {
                break
            }
            eval $func $rangeId $args
            incr count
        }
        Cawt Destroy $myFind
    }

    proc GetNumCharacters { docId } {
        # Return the number of characters in a Word document.
        #
        # docId - Identifier of the document.
        #
        # Returns the number of characters in the Word document.
        #
        # See also: GetNumColumns GetNumDocuments GetNumImages GetNumHyperlinks
        # GetNumPages GetNumRows GetNumSubdocuments GetNumTables


        return [$docId -with { Characters } Count]
    }

    proc GetNumPages { docId } {
        # Return the number of pages in a Word document.
        #
        # docId - Identifier of the document.
        #
        # Returns the number of pages in the Word document.
        #
        # See also: GetNumCharacters GetNumColumns GetNumDocuments GetNumImages
        # GetNumHyperlinks GetNumRows GetNumSubdocuments GetNumTables

        set endRange [Word GetEndRange $docId]
        set numPages [$endRange Information $::Word::wdNumberOfPagesInDocument]
        Cawt Destroy $endRange
        return $numPages
    }

    proc GetPageSetup { docId args } {
        # Get page setup values.
        #
        # docId - Identifier of the document.
        # args  - Options described below.
        #
        # -top          - Get the size of the top margin.
        # -bottom       - Get the size of the bottom margin.
        # -left         - Get the size of the left margin.
        # -right        - Get the size of the right margin.
        # -footer       - Get the size of the footer margin.
        # -header       - Get the size of the header margin.
        # -height       - Get the height of the page.
        # -width        - Get the width of the page.
        # -usableheight - Get the usable height of the page, i.e. `height - top - bottom`.
        # -usablewidth  - Get the usable width of the page,  i.e. `width - left - right`
        # -centimeter   - Get the values in centimeters.
        # -inch         - Get the values in inches.
        #
        # The values are returned as points, if no unit option is specified.
        #
        # Example:
        #     lassign [GetPageSetup $docId -top -left -inch] top left
        #     returns the top and left margins in inches.
        #
        # Returns the specified page setup values as a list.
        #
        # See also: SetPageSetup ::Cawt::PointsToCentiMeters ::Cawt::PointsToInches

        set pageSetup [$docId PageSetup]
        set valList [list]
        set convert "none"
        foreach key $args {
            switch -exact -nocase -- $key {
                "-inch"         { set convert "inch" }
                "-centimeter"   { set convert "centimeter" }
                "-top"          { lappend valList [$pageSetup TopMargin] }
                "-bottom"       { lappend valList [$pageSetup BottomMargin] }
                "-left"         { lappend valList [$pageSetup LeftMargin] }
                "-right"        { lappend valList [$pageSetup RightMargin] }
                "-header"       { lappend valList [$pageSetup HeaderDistance] }
                "-footer"       { lappend valList [$pageSetup FooterDistance] }
                "-height"       { lappend valList [$pageSetup PageHeight] }
                "-width"        { lappend valList [$pageSetup PageWidth] }
                "-usableheight" { 
                    lappend valList [expr { [$pageSetup PageHeight] - [$pageSetup TopMargin] - [$pageSetup BottomMargin] }] 
                }
                "-usablewidth" {
                    lappend valList [expr { [$pageSetup PageWidth] - [$pageSetup LeftMargin] - [$pageSetup RightMargin] }] 
                }
                default { error "GetPageSetup: Unknown key \"$key\" specified" }
            }
        }
        set convertList [list]
        foreach val $valList {
            if { $convert eq "inch" } {
                lappend convertList [Cawt PointsToInches $val]
            } elseif { $convert eq "centimeter" } {
                lappend convertList [Cawt PointsToCentiMeters $val]
            } else {
                lappend convertList $val
            }
        }
        Cawt Destroy $pageSetup
        return $convertList
    }

    proc SetPageSetup { docId args } {
        # Set page setup values.
        #
        # docId - Identifier of the document.
        # args  - Options described below.
        #
        # -top <size>    - Set the size of the top margin.
        # -bottom <size> - Set the size of the bottom margin.
        # -left <size>   - Set the size of the left margin.
        # -right <size>  - Set the size of the right margin.
        # -footer <size> - Set the size of the footer margin.
        # -header <size> - Set the size of the header margin.
        # -height <size> - Set the height of the page.
        # -width <size>  - Set the width of the page.
        #
        # The size values may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: GetPageSetup ::Cawt::PointsToCentiMeters ::Cawt::PointsToInches

        set pageSetup [$docId PageSetup]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetPageSetup: No value specified for key \"$key\""
            }
            set pointValue [Cawt ValueToPoints $value]
            switch -exact -nocase -- $key {
                "-top"    { $pageSetup TopMargin      $pointValue }
                "-bottom" { $pageSetup BottomMargin   $pointValue }
                "-left"   { $pageSetup LeftMargin     $pointValue }
                "-right"  { $pageSetup RightMargin    $pointValue }
                "-header" { $pageSetup HeaderDistance $pointValue }
                "-footer" { $pageSetup FooterDistance $pointValue }
                "-height" { $pageSetup PageHeight     $pointValue }
                "-width"  { $pageSetup PageWidth      $pointValue }
                default   { error "SetPageSetup: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $pageSetup
    }

    proc SetViewParameters { docId args } {
        # Set view parameters of a document.
        #
        # docId - Identifier of the document.
        # args  - Options described below.
        #
        # -pagefit <enum> - Set the page fit parameter.
        #                   Value of enumeration type [Enum::WdPageFit].
        #
        # Returns no value.
        #
        # See also: OpenDocument SetPageSetup

        foreach { key value } $args {
            if { $value eq "" } {
                error "SetViewParameters: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-pagefit" {
                    $docId -with { ActiveWindow ActivePane View Zoom } \
                           PageFit [Word GetEnum $value]
                }
                default { 
                    error "SetViewParameters: Unknown key \"$key\" specified" 
                }
            }
        }
    }

    proc CreateRange { docId startIndex endIndex } {
        # Create a new text range.
        #
        # docId      - Identifier of the document.
        # startIndex - The start index of the range in characters.
        # endIndex   - The end index of the range in characters.
        #
        # Returns the identifier of the new text range.
        #
        # See also: CreateRangeAfter SelectRange GetSelectionRange

        return [$docId Range $startIndex $endIndex]
    }

    proc CreateRangeAfter { rangeId } {
        # Create a new text range after specified range.
        #
        # rangeId - Identifier of the text range.
        #
        # Returns the identifier of the new text range.
        #
        # See also: CreateRange SelectRange GetSelectionRange

        set docId [Word GetDocumentId $rangeId]
        set index [Word GetRangeEndIndex $rangeId]
        set rangeId [Word CreateRange $docId $index $index]
        Cawt Destroy $docId
        return $rangeId
    }

    proc CollapseRange { rangeId { direction "begin" } } {
        # Collapse a text range to the start or end position.
        #
        # rangeId   - Identifier of the text range.
        # direction - Collapse direction: `begin` or `end`.
        #
        # After a range is collapsed, the start and end points are equal.
        #
        # See also: CreateRange GetStartRange GetEndRange

        if { $direction eq "begin" } {
            $rangeId Collapse $::Word::wdCollapseStart
        } else {
            $rangeId Collapse $::Word::wdCollapseEnd
        }
    }

    proc CopyRange { fromRangeId toRangeId } {
        # Copy the contents of a range into another range.
        #
        # fromRangeId - Identifier of the source range.
        # toRangeId   - Identifier of the destination range.
        #
        # **Note:**
        # The contents of the destination range are overwritten.
        #
        # Returns no value.
        #
        # See also: CreateRange

        $fromRangeId Copy
        $toRangeId Paste
    }

    proc SelectRange { rangeId } {
        # Select a text range.
        #
        # rangeId - Identifier of the text range.
        #
        # Returns no value.
        #
        # See also: GetSelectionRange GetRangeScreenPos

        $rangeId Select
    }

    proc GetSelectionRange { docId } {
        # Return the text range representing the current selection.
        #
        # docId - Identifier of the document.
        #
        # Returns the text range representing the current selection.
        #
        # See also: GetStartRange GetEndRange SelectRange

        return [$docId -with { ActiveWindow } Selection]
    }

    proc GetStartRange { docId } {
        # Return a text range representing the start of the document.
        #
        # docId - Identifier of the document.
        #
        # Returns a text range representing the start of the document.
        #
        # See also: CreateRange GetSelectionRange GetEndRange

        return [Word CreateRange $docId 0 0]
    }

    proc GetEndRange { docId } {
        # Return the text range representing the end of the document.
        #
        # docId - Identifier of the document.
        #
        # **Note:**
        # This corresponds to the built-in bookmark `\endofdoc`.
        # The end range of an empty document is (0, 0), although
        # [GetNumCharacters] returns 1.
        #
        # Returns the text range representing the end of the document.
        #
        # See also: GetSelectionRange GetStartRange GetNumCharacters

        set bookMarks [$docId Bookmarks]
        set endOfDoc  [$bookMarks Item "\\endofdoc"]
        set endRange  [$endOfDoc Range]
        Cawt Destroy $endOfDoc
        Cawt Destroy $bookMarks
        set endIndex [Word GetRangeEndIndex $endRange]
        Cawt Destroy $endRange
        return [Word CreateRange $docId $endIndex $endIndex]
    }

    proc GetRangeInformation { rangeId type } {
        # Get information about a text range.
        #
        # rangeId - Identifier of the text range.
        # type    - Value of enumeration type [Enum::WdInformation].
        #
        # Returns the range information associated with the supplied type.
        #
        # See also: GetStartRange GetEndRange PrintRange GetRangeText

        return [$rangeId Information [Word GetEnum $type]]
    }

    proc PrintRange { rangeId { msg "Range: " } } {
        # Print the indices of a text range.
        #
        # rangeId - Identifier of the text range.
        # msg     - String printed in front of the indices.
        #
        # The range identifiers are printed onto standard output.
        #
        # Returns no value.
        #
        # See also: GetRangeStartIndex GetRangeEndIndex

        puts [format "%s %d %d" $msg \
              [Word GetRangeStartIndex $rangeId] [Word GetRangeEndIndex $rangeId]]
    }

    proc GetRangeText { rangeId } {
        # Return the text of a text range.
        #
        # rangeId - Identifier of the text range.
        #
        # Returns the text of the specified range as a string.
        #
        # See also: GetRangeStartIndex GetRangeEndIndex 
        # GetCellValue GetHeadingRanges

        set val [Word::TrimString [$rangeId Text]]
        return $val
    }

    proc GetRangeStartIndex { rangeId } {
        # Return the start index of a text range.
        #
        # rangeId - Identifier of the text range.
        #
        # Returns the start index of the text range.
        #
        # See also: GetRangeEndIndex PrintRange GetRangeText

        return [$rangeId Start]
    }

    proc GetRangeEndIndex { rangeId } {
        # Return the end index of a text range.
        #
        # rangeId - Identifier of the text range.
        #
        # Returns the end index of the text range.
        #
        # See also: GetRangeStartIndex PrintRange GetRangeText

        return [$rangeId End]
    }

    proc GetRangeScreenPos { rangeId } {
        # Return the screen position of a text range.
        #
        # rangeId - Identifier of the text range.
        #
        # Note, that the text range must be in the active window.
        #
        # Returns the screen position of a text range as a
        # dictionary with keys `left`, `top`, `width`, `height`.
        #
        # See also: SelectRange GetRangeStartIndex GetRangeText

        set docId [$rangeId Document]
        set windowId [$docId ActiveWindow]

        $windowId GetPoint \
            [twapi::outvar screenPixelsLeft] \
            [twapi::outvar screenPixelsTop] \
            [twapi::outvar screenPixelsWidth] \
            [twapi::outvar screenPixelsHeight] \
            $rangeId

        Cawt Destroy $docId
        Cawt Destroy $windowId

        return [dict create \
            "left"   [lindex $screenPixelsLeft 1]   \
            "top"    [lindex $screenPixelsTop 1]    \
            "width"  [lindex $screenPixelsWidth 1]  \
            "height" [lindex $screenPixelsHeight 1] \
        ]
    }

    proc SetRangeStartIndex { rangeId index } {
        # Set the start index of a text range.
        #
        # rangeId - Identifier of the text range.
        # index   - Index for the range start.
        #
        # Index is either an integer value or string `begin` to
        # use the start of the document.
        #
        # Returns no value.
        #
        # See also: SetRangeEndIndex GetRangeStartIndex

        if { $index eq "begin" } {
            set index 0
        }
        $rangeId Start $index
    }

    proc SetRangeEndIndex { rangeId index } {
        # Set the end index of a text range.
        #
        # rangeId - Identifier of the text range.
        # index   - Index for the range end.
        #
        # Index is either an integer value or string `end` to
        # use the end of the document.
        #
        # Returns no value.
        #
        # See also: SetRangeStartIndex GetRangeEndIndex

        if { $index eq "end" } {
            set docId [Word GetDocumentId $rangeId]
            set index [GetRangeEndIndex [GetEndRange $docId]]
            Cawt Destroy $docId
        }
        $rangeId End $index
    }

    proc ExtendRange { rangeId { startIncr 0 } { endIncr 0 } } {
        # Extend the range indices of a text range.
        #
        # rangeId   - Identifier of the text range.
        # startIncr - Increment of the range start index.
        # endIncr   - Increment of the range end index.
        #
        # Increment is either an integer value or strings `begin` or `end` to
        # use the start or end of the document.
        #
        # Returns the new extended range.
        #
        # See also: SetRangeStartIndex SetRangeEndIndex

        set startIndex [Word GetRangeStartIndex $rangeId]
        set endIndex   [Word GetRangeEndIndex   $rangeId]
        if { [string is integer $startIncr] } {
            set startIndex [expr $startIndex + $startIncr]
        } elseif { $startIncr eq "begin" } {
            set startIndex 0
        }
        if { [string is integer $endIncr] } {
            set endIndex [expr $endIndex + $endIncr]
        } elseif { $endIncr eq "end" } {
            set docId [Word GetDocumentId $rangeId]
            set endRange [GetEndRange $docId]
            set endIndex [$endRange End]
            Cawt Destroy $endRange
            Cawt Destroy $docId
        }
        $rangeId Start $startIndex
        $rangeId End $endIndex
        return $rangeId
    }

    proc AddContentControl { rangeId type { title "" } } {
        # Add a content control to a text range.
        #
        # rangeId - Identifier of the text range.
        # type    - Value of enumeration type [Enum::WdContentControlType].
        #           Often used values: `wdContentControlCheckBox`, `wdContentControlText`.
        # title   - Title string for the control.
        #
        # Returns the content control identifier.
        #
        # See also: SetContentControlText SetContentControlDropdown

        variable wordVersion

        if { $wordVersion < 12.0 } {
            error "Content controls available only in Word 2007 or newer. Running [Word GetVersion $rangeId true]."
        }

        set controlId [$rangeId -with { ContentControls } Add [Word GetEnum $type]]
        if { $title ne "" } {
            $controlId Title $title
        }
        return $controlId
    }

    # TODO Selection.ParentContentControl.LockContents = True

    proc SetContentControlText { controlId placeholderText } {
        # Set the text of a content control.
        #
        # controlId       - Identifier of the content control.
        # placeholderText - Text for the content control.
        #
        # Returns no value.
        #
        # See also: AddContentControl SetContentControlDropdown

        if { $placeholderText ne "" } {
            $controlId SetPlaceholderText NULL NULL $placeholderText
        }
    }

    proc SetContentControlDropdown { controlId placeholderText keyValueList } {
        # Set the values for a content control dropdown list.
        #
        # controlId       - Identifier of the content control.
        # placeholderText - Text for the content control.
        # keyValueList    - List of key-value pairs.
        #
        # Returns no value.
        #
        # See also: AddContentControl SetContentControlText

        if { $placeholderText ne "" } {
            $controlId SetPlaceholderText NULL NULL $placeholderText
        }
        $controlId -with { DropdownListEntries } Clear
        foreach { key val } $keyValueList {
            $controlId -with { DropdownListEntries } Add $key $val
        }
    }

    proc SetRangeStyle { rangeId style } {
        # Set the style of a text range.
        #
        # rangeId - Identifier of the text range.
        # style   - Value of enumeration type [Enum::WdBuiltinStyle].
        #           Often used values: `wdStyleHeading1`, `wdStyleNormal`.
        #
        # Returns no value. 
        #
        # See also: SetRangeFontSize SetRangeFontName

        set docId [Word GetDocumentId $rangeId]
        set styleId [$docId -with { Styles } Item [Word GetEnum $style]]
        $rangeId Style $styleId
        Cawt Destroy $styleId
        Cawt Destroy $docId
    }

    proc GetRangeFont { rangeId args } {
        # Get font specific parameters.
        #
        # rangeId - Identifier of the text range.
        # args    - Options described below.
        #
        # -name           - Get the font name of the text range.
        # -size           - Get the font size of the text range in points.
        # -sizei          - Get the font size of the text range in inches.
        # -sizec          - Get the font size of the text range in centimeters.
        # -bold           - Get the bold font style flag of the text range.
        # -italic         - Get the italic font style flag of the text range.
        # -underline      - Get the underline font style flag of the text range.
        # -underlinecolor - Get the underline color of the text range.
        #                   Return value is of enumeration type [Enum::WdColor].
        # -background     - Get the background color of the text range.
        #                   Return value is an Office color number.
        # -color          - Get the text color of the text range.
        #                   Return value is of enumeration type [Enum::WdColorIndex].
        #
        # Returns the specified font parameter values as a list.
        #
        # See also: SetRangeFont CreateRange [::Cawt::GetColor]

        set font [$rangeId Font]
        set valList [list]
        foreach key $args {
            switch -exact -nocase -- $key {
                "-name"           { lappend valList [$font Name] }
                "-size"           { lappend valList [$font Size] }
                "-sizei"          { lappend valList [Cawt PointsToInches [$font Size]] }
                "-sizec"          { lappend valList [Cawt PointsToCentiMeters [$font Size]] }
                "-bold"           { lappend valList [Cawt TclBool [$font Bold]] }
                "-italic"         { lappend valList [Cawt TclBool [$font Italic]] }
                "-underline"      { lappend valList [Cawt TclBool [$font Underline]] }
                "-underlinecolor" { lappend valList [$font UnderlineColor] }
                "-background"     { lappend valList [$font -with { Shading } BackgroundPatternColor] }
                "-color"          { lappend valList [$font ColorIndex] }
                default           { error "GetRangeFont: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $font
        return $valList
    }

    proc SetRangeFont { rangeId args } {
        # Set font specific parameters.
        #
        # rangeId - Identifier of the text range.
        # args    - Options described below.
        #
        # -name <string>         - Set the font name of the text range.
        # -size <float>          - Set the font size of the text range in points.
        # -sizei <float>         - Set the font size of the text range in inches.
        # -sizec <float>         - Set the font size of the text range in centimeters.
        # -bold <bool>           - Set the bold font style flag of the text range.
        # -italic <bool>         - Set the italic font style flag of the text range.
        # -underline <bool>      - Set the underline font style flag of the text range.
        # -underlinecolor <enum> - Set the underline color of the text range.
        #                          Enumeration of type [Enum::WdColor].
        # -background <int>      - Set the background color of the text range.
        #                          Value is an Office color number.
        # -color <enum>          - Set the text color of the text range.
        #                          Enumeration of type [Enum::WdColorIndex].
        #
        # Returns no value.
        #
        # See also: GetRangeFont [::Cawt::GetColor]

        set font [$rangeId Font]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetRangeFont: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-name"           { $font Name $value }
                "-size"           { $font Size $value }
                "-sizei"          { $font Size [Cawt InchesToPoints $value] }
                "-sizec"          { $font Size [Cawt CentiMetersToPoints $value] }
                "-bold"           { $font Bold [Cawt TclInt $value] }
                "-italic"         { $font Italic [Cawt TclInt $value] }
                "-underline"      { $font Underline [Cawt TclInt $value] }
                "-underlinecolor" { $font UnderlineColor [Word GetEnum $value] }
                "-background"     { $font -with { Shading } BackgroundPatternColor $value }
                "-color"          { $font ColorIndex [Word GetEnum $value] }
                default           { error "SetRangeFont: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $font
    }

    proc SetRangeFontName { rangeId fontName } {
        # Set the font name of a text range.
        #
        # rangeId  - Identifier of the text range.
        # fontName - Font name.
        #
        # Returns no value.
        #
        # See also: SetRangeFont GetRangeFont

        $rangeId -with { Font } Name $fontName
    }

    proc SetRangeFontSize { rangeId fontSize } {
        # Set the font size of a text range.
        #
        # rangeId  - Identifier of the text range.
        # fontSize - Font size.
        #
        # The size value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: SetRangeFont GetRangeFont

        $rangeId -with { Font } Size [Cawt ValueToPoints $fontSize]
    }

    proc SetRangeFontBold { rangeId { onOff true } } {
        # Toggle the bold font style of a text range.
        #
        # rangeId - Identifier of the text range.
        # onOff   - If set to true, set bold style on.
        #           Otherwise set bold style off.
        #
        # Returns no value.
        #
        # See also: SetRangeFont GetRangeFont

        $rangeId -with { Font } Bold [Cawt TclInt $onOff]
    }

    proc SetRangeFontItalic { rangeId { onOff true } } {
        # Toggle the italic font style of a text range.
        #
        # rangeId - Identifier of the text range.
        # onOff   - If set to true, set italic style on.
        #           Otherwise set italic style off.
        #
        # Returns no value.
        #
        # See also: SetRangeFont GetRangeFont

        $rangeId -with { Font } Italic [Cawt TclInt $onOff]
    }

    proc SetRangeFontUnderline { rangeId { onOff true } { color wdColorAutomatic } } {
        # Toggle the underline font style of a text range.
        #
        # rangeId - Identifier of the text range.
        # onOff   - If set to true, set underline style on.
        #           Otherwise set underline style off.
        # color   - Value of enumeration type [Enum::WdColor].
        #
        # Returns no value.
        #
        # See also: SetRangeFont GetRangeFont

        $rangeId -with { Font } Underline [Cawt TclInt $onOff]
        if { $onOff } {
            $rangeId -with { Font } UnderlineColor [Word GetEnum $color]
        }
    }

    proc SetRangeFontBackgroundColor { rangeId args } {
        # Set the background color of a text range.
        #
        # rangeId - Identifier of the text range.
        # args    - Background color.
        #
        # Color value may be specified in a format acceptable by procedure [::Cawt::GetColor],
        # i.e. color name, hexadecimal string, Office color number or a list of 3 integer
        # RGB values.
        #
        # Returns no value.
        #
        # See also: SetRangeFont GetRangeFont

        $rangeId -with { Font Shading } BackgroundPatternColor [Cawt GetColor {*}$args]
    }

    proc SetRangeFontColor { rangeId color } {
        # Set the text color of a text range.
        #
        # rangeId - Identifier of the text range.
        # color   - Value of enumeration type [Enum::WdColorIndex].
        #
        # Returns no value.
        #
        # See also: SetRangeFont GetRangeFont

        $rangeId -with { Font } ColorIndex [Word GetEnum $color]
    }

    proc SetRangeHorizontalAlignment { rangeId align } {
        # Set the horizontal alignment of a text range.
        #
        # rangeId - Identifier of the text range.
        # align   - Value of enumeration type [Enum::WdParagraphAlignment]
        #           or any of the following strings: `left`, `right`, `center`.
        #
        # Returns no value.
        #
        # See also: SetCellVerticalAlignment SetRangeHighlightColorByEnum

        if { $align eq "center" } {
            set alignEnum $Word::wdAlignParagraphCenter
        } elseif { $align eq "left" } {
            set alignEnum $Word::wdAlignParagraphLeft
        } elseif { $align eq "right" } {
            set alignEnum $Word::wdAlignParagraphRight
        } else {
            set alignEnum [Word GetEnum $align]
        }

        $rangeId -with { ParagraphFormat } Alignment $alignEnum
    }

    proc SetRangeHighlightColorByEnum { rangeId colorEnum } {
        # Set the highlight color of a text range.
        #
        # rangeId   - Identifier of the text range.
        # colorEnum - Value of enumeration type [Enum::WdColorIndex].
        #
        # Returns no value.
        #
        # See also: SetRangeBackgroundColorByEnum

        $rangeId HighlightColorIndex [Word GetEnum $colorEnum]
    }

    proc SetRangeBackgroundColorByEnum { rangeId colorEnum } {
        # Set the background color of a table cell range.
        #
        # rangeId   - Identifier of the cell range.
        # colorEnum - Value of enumeration type [Enum::WdColor].
        #
        # **Note:** This functionality is very slow with large tables ( > 100 rows).
        #
        # Returns no value.
        #
        # See also: SetRangeBackgroundColor SetRangeHighlightColorByEnum

        $rangeId -with { Cells Shading } BackgroundPatternColor [Word GetEnum $colorEnum]
    }

    proc SetRangeBackgroundColor { rangeId args } {
        # Set the background color of a table cell range.
        #
        # rangeId - Identifier of the cell range.
        # args    - Background color.
        #
        # Color value may be specified in a format acceptable by procedure [::Cawt::GetColor],
        # i.e. color name, hexadecimal string, Office color number or a list of 3 integer RGB values.
        #
        # **Note:** This functionality is very slow with large tables ( > 100 rows).
        #
        # Returns no value.
        #
        # See also: SetRangeBackgroundColorByEnum SetRangeHighlightColorByEnum

        $rangeId -with { Cells Shading } BackgroundPatternColor [Cawt GetColor {*}$args]
    }

    proc SetRangeMergeCells { rangeId } {
        # Merge a range of cells.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns no value.
        #
        # See also: SetRangeHorizontalAlignment SelectRange

        set appId [Office GetApplicationId $rangeId]
        Word::ShowAlerts $appId false
        $rangeId -with { Cells } Merge
        Word::ShowAlerts $appId true
        Cawt Destroy $appId
    }

    proc MergeCells { tableId row1 col1 row2 col2 } {
        # Merge a range of cells.
        #
        # tableId - Identifier of the Word table.
        # row1    - Range start row number. Row numbering starts with 1.
        # col1    - Range start column number. Column numbering starts with 1.
        # row2    - Range end row number.
        #           If set to `end`, the last row of the table is used.
        # col2    - Range end column number.
        #           If set to `end`, the last column of the table is used.
        #
        # Returns the range identifier of the merged cells.
        #
        # See also: SetRangeMergeCells SelectRange

        set appId [Office GetApplicationId $tableId]
        Word::ShowAlerts $appId false

        if { $row2 eq "end" } {
            set row2 [Word GetNumRows $tableId]
        }
        if { $col2 eq "end" } {
            set col2 [Word GetNumColumns $tableId]
        }

        set cellId1 [$tableId Cell $row1 $col1]
        set cellId2 [$tableId Cell $row2 $col2]
        $cellId1 Merge $cellId2
        set rangeId [$cellId1 Range]

        Word::ShowAlerts $appId true

        Cawt Destroy $cellId1
        Cawt Destroy $cellId2
        Cawt Destroy $appId

        return $rangeId 
    }

    proc AddPageBreak { rangeId } {
        # Add a page break to a text range.
        #
        # rangeId - Identifier of the text range.
        #
        # Returns no value.
        #
        # See also: AddParagraph

        $rangeId Collapse $Word::wdCollapseEnd
        $rangeId InsertBreak [expr { int ($Word::wdPageBreak) }]
        $rangeId Collapse $Word::wdCollapseEnd
    }

    proc AddBookmark { rangeId name } {
        # Add a bookmark to a text range.
        #
        # rangeId - Identifier of the text range.
        # name    - Name of the bookmark.
        #
        # Returns the bookmark identifier.
        #
        # See also: SetLinkToBookmark GetBookmarkName

        set docId [Word GetDocumentId $rangeId]
        set bookmarks [$docId Bookmarks]
        # Create valid bookmark names.
        set validName [regsub -all { } $name {_}]
        set validName [regsub -all -- {-} $validName {_}]
        set bookmarkId [$bookmarks Add $validName $rangeId]

        Cawt Destroy $bookmarks
        Cawt Destroy $docId
        return $bookmarkId
    }

    proc GetBookmarkName { bookmarkId } {
        # Get the name of a bookmark.
        #
        # bookmarkId - Identifier of the bookmark.
        #
        # Returns the name of the bookmark.
        #
        # See also: AddBookmark SetLinkToBookmark

        return [$bookmarkId Name]
    }

    proc GetBookmarkNames { docId args } {
        # Get the names of all bookmarks of a document.
        #
        # docId - Identifier of the document.
        # args  - Options described below.
        #
        # -showhidden <bool> - Show hidden bookmarks. Default value is false.
        #
        # Returns a list containing the names of all bookmarks of the document.
        #
        # See also: AddBookmark SetLinkToBookmark GetHyperlinksAsDict

        set opts [dict create \
            -showhidden false \
        ]
        foreach { key value } $args {
            if { [dict exists $opts $key] } {
                if { $value eq "" } {
                    error "GetBookmarkNames: No value specified for key \"$key\""
                }
                dict set opts $key $value
            } else {
                error "GetBookmarkNames: Unknown option \"$key\" specified"
            }
        }

        set nameList [list]
        set showHidden [Cawt TclBool [dict get $opts "-showhidden"]]
        $docId -with { Bookmarks } ShowHidden $showHidden
        set bookmarks [$docId Bookmarks]
        $bookmarks -iterate bookmark {
            lappend nameList [$bookmark Name]
            Cawt Destroy $bookmark
        }
        Cawt Destroy $bookmarks
        return $nameList
    }

    proc GetListGalleryId { appId galleryType } {
        # Get one of the 3 predefined list galleries.
        #
        # appId       - Identifier of the Word instance.
        # galleryType - Value of enumeration type [Enum::WdListGalleryType].
        #
        # Returns the identifier of the specified list gallery.
        #
        # See also: GetListTemplateId InsertList

        return [$appId -with { ListGalleries } Item [Word GetEnum $galleryType]]
    }

    proc GetListTemplateId { galleryId listType } {
        # Get one of the 7 predefined list templates.
        #
        # galleryId - Identifier of the Word gallery.
        # listType  - Value of enumeration type [Enum::WdListType].
        #
        # Returns the identifier of the specified list template.
        #
        # See also: GetListGalleryId InsertList

        return [$galleryId -with { ListTemplates } Item [Word GetEnum $listType]]
    }

    proc InsertList { rangeId stringList \
                      { galleryType wdBulletGallery } \
                      { listType wdListListNumOnly } } {
        # Insert a Word list.
        #
        # rangeId     - Identifier of the text range.
        # stringList  - List of text strings building up the Word list.
        # galleryType - Value of enumeration type [Enum::WdListGalleryType].
        # listType    - Value of enumeration type [Enum::WdListType].
        #
        # Returns the range of the Word list.
        #
        # See also: GetListGalleryId GetListTemplateId InsertCaption InsertFile InsertImage InsertText

        foreach line $stringList {
            append listStr "$line\n"
        }
        set appId [Office GetApplicationId $rangeId]
        set listRangeId [Word AddText $rangeId $listStr]
        set listGalleryId  [Word GetListGalleryId $appId $galleryType]
        set listTemplateId [Word GetListTemplateId $listGalleryId $listType]
        $listRangeId -with { ListFormat } ApplyListTemplate $listTemplateId
        Cawt Destroy $listTemplateId
        Cawt Destroy $listGalleryId
        Cawt Destroy $appId
        return $listRangeId
    }

    proc GetVersion { objId { useString false } } {
        # Return the version of a Word application.
        #
        # objId     - Identifier of a Word object instance.
        # useString - If set to true, return the version name (ex. `Word 2000`).
        #             Otherwise return the version number (ex. `9.0`).
        #
        # Both version name and version number are returned as strings.
        # Version number is in a format, so that it can be evaluated as a
        # floating point number.
        #
        # Returns the version of the Word application.
        #
        # See also: GetCompatibilityMode GetExtString

        array set map {
            "7.0"  "Word 95"
            "8.0"  "Word 97"
            "9.0"  "Word 2000"
            "10.0" "Word 2002"
            "11.0" "Word 2003"
            "12.0" "Word 2007"
            "14.0" "Word 2010"
            "15.0" "Word 2013"
            "16.0" "Word 2016/2019"
        }
        set version [Office GetApplicationVersion $objId]
        if { $useString } {
            if { [info exists map($version)] } {
                return $map($version)
            } else {
                return "Unknown Word version $version"
            }
        } else {
            return $version
        }
    }

    proc GetCompatibilityMode { appId { version "" } } {
        # Return the compatibility version of a Word application.
        #
        # appId   - Identifier of the Word instance.
        # version - Word version number.
        #
        # Returns the compatibility mode of the current Word application, if
        # version is not specified or the empty string.
        # If version is a valid Word version as returned by [GetVersion], the
        # corresponding compatibility mode is returned.
        #
        # **Note:** The compatibility mode is a value of enumeration [Enum::WdCompatibilityMode].
        #
        # See also: GetVersion GetExtString

        if { $version eq "" } {
            return $Word::wdCurrent
        } else {
            array set map {
                "11.0" $Word::wdWord2003
                "12.0" $Word::wdWord2007
                "14.0" $Word::wdWord2010
                "15.0" $Word::wdWord2013
            }
            if { [info exists map($version)] } {
                return $map($version)
            } else {
                error "Unknown Word version $version"
            }
        }
    }

    proc GetExtString { appId } {
        # Return the default extension of a Word file.
        #
        # appId - Identifier of the Word instance.
        #
        # Starting with Word 12 (2007) this is the string `.docx`.
        # In previous versions it was `.doc`.
        #
        # Returns the default extension of a Word file.
        #
        # See also: GetCompatibilityMode GetVersion ::Office::GetOfficeType

        # appId is only needed, so we are sure, that wordVersion is initialized.

        variable wordVersion

        if { $wordVersion >= 12.0 } {
            return ".docx"
        } else {
            return ".doc"
        }
    }

    proc ToggleSpellCheck { appId onOff } {
        # Toggle checking of grammatical and spelling errors.
        #
        # appId - Identifier of the Word instance.
        # onOff - Switch spell checking on or off.
        #
        # Returns no value.
        #
        # See also: Open

        $appId -with { ActiveDocument } ShowGrammaticalErrors [Cawt TclBool $onOff]
        $appId -with { ActiveDocument } ShowSpellingErrors    [Cawt TclBool $onOff]
    }

    proc OpenNew { { visible true } { width -1 } { height -1 } } {
        # Open a new Word instance.
        #
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        # width   - Width of the application window. If negative, open with last used width.
        # height  - Height of the application window. If negative, open with last used height.
        #
        # Returns the identifier of the new Word application instance.
        #
        # See also: Open Quit Visible

        variable wordAppName
	variable wordVersion

        set appId [Cawt GetOrCreateApp $wordAppName false]
        set wordVersion [Word GetVersion $appId]
        Word Visible $appId $visible
        if { $width >= 0 } {
            $appId Width [expr $width]
        }
        if { $height >= 0 } {
            $appId Height [expr $height]
        }
        return $appId
    }

    proc Open { { visible true } { width -1 } { height -1 } } {
        # Open a Word instance. Use an already running instance, if available.
        #
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        # width   - Width of the application window. If negative, open with last used width.
        # height  - Height of the application window. If negative, open with last used height.
        #
        # Returns the identifier of the Word application instance.
        #
        # See also: OpenNew Quit Visible

        variable wordAppName
	variable wordVersion

        set appId [Cawt GetOrCreateApp $wordAppName true]
        set wordVersion [Word GetVersion $appId]
        Word Visible $appId $visible
        if { $width >= 0 } {
            $appId Width [expr $width]
        }
        if { $height >= 0 } {
            $appId Height [expr $height]
        }
        return $appId
    }

    proc ShowAlerts { appId onOff } {
        # Toggle the display of Word application alerts.
        #
        # appId - The application identifier.
        # onOff - Switch the alerts on or off.
        #
        # Returns no value.

        if { $onOff } {
            set alertLevel [expr $Word::wdAlertsAll]
        } else {
            set alertLevel [expr $Word::wdAlertsNone]
        }
        $appId DisplayAlerts $alertLevel
    }

    proc Quit { appId { showAlert true } } {
        # Quit a Word instance.
        #
        # appId     - Identifier of the Word instance.
        # showAlert - If set to true, show an alert window, if there are unsaved changes.
        #             Otherwise quit without saving any changes.
        #
        # Returns no value.
        #
        # See also: Open OpenNew

        Word::ShowAlerts $appId $showAlert
        if { ! $showAlert } {
            set numDocs [Word::GetNumDocuments $appId]
            for { set i 1 } { $i <= $numDocs } { incr i } {
                set docId [Word::GetDocumentIdByIndex $appId $i]
                Word::Close $docId
                Cawt Destroy $docId
            }
        }
        $appId Quit
    }

    proc Visible { appId visible } {
        # Toggle the visibility of a Word application window.
        #
        # appId   - Identifier of the Word instance.
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        #
        # Returns no value.
        #
        # See also: Open OpenNew IsVisible

        $appId Visible [Cawt TclInt $visible]
    }

    proc IsVisible { appId } {
        # Check the visibility of a Word application window.
        #
        # appId - Identifier of the Word instance.
        #
        # Returns true, if the Word application windows is visible.
        #
        # See also: Open OpenNew Visible

        if { [$appId Visible] } {
            return true
        } else {
            return false
        }
    }

    proc ScreenUpdate { appId onOff } {
        # Toggle the screen updating of a Word application window.
        #
        # appId - Identifier of the Word instance.
        # onOff - If set to true, update the application window.
        #         Otherwise do not update the application window.
        #
        # Returns no value.
        #
        # See also: Visible IsVisible

        $appId ScreenUpdating [Cawt TclBool $onOff]
    }

    proc Close { docId } {
        # Close a document without saving changes.
        #
        # docId - Identifier of the document.
        #
        # Use the [SaveAs] method before closing, if you want to save changes.
        #
        # Returns no value.
        #
        # See also: SaveAs

        $docId Close [Cawt TclBool false]
    }

    proc UpdateFields { docId } {
        # Update all fields as well as tables of content and figures of a document.
        #
        # docId - Identifier of the document.
        #
        # Returns no value.
        #
        # See also: SaveAs

        set stories [$docId StoryRanges]
        $stories -iterate story {
            lappend storyList $story
            $story -with { Fields } Update
            set nextStory [$story NextStoryRange]
            while { [Cawt IsComObject $nextStory] } {
                lappend storyList $nextStory
                $nextStory -with { Fields } Update
                set nextStory [$nextStory NextStoryRange]
            }
        }
        foreach story $storyList {
            Cawt Destroy $story
        }
        Cawt Destroy $stories

        set tocs [$docId TablesOfContents]
        $tocs -iterate toc {
            $toc Update
            Cawt Destroy $toc
        }
        Cawt Destroy $tocs

        set tofs [$docId TablesOfFigures]
        $tofs -iterate tof {
            $tof Update
            Cawt Destroy $tof
        }
        Cawt Destroy $tofs
    }

    proc SaveAs { docId fileName { fmt "" } } {
        # Save a document to a Word file.
        #
        # docId    - Identifier of the document to save.
        # fileName - Name of the Word file.
        # fmt      - Value of enumeration type [Enum::WdSaveFormat].
        #            If not given or the empty string, the file is stored in the native
        #            format corresponding to the used Word version.
        #
        # Returns no value.
        #
        # See also: SaveAsPdf

        variable wordVersion

        set fileName [file nativename [file normalize $fileName]]
        set appId [Office GetApplicationId $docId]
        Word::ShowAlerts $appId false
        if { $fmt eq "" } {
            if { $wordVersion >= 14.0 } {
                $docId SaveAs $fileName [expr $Word::wdFormatDocumentDefault]
            } else {
                $docId SaveAs $fileName
            }
        } else {
            $docId SaveAs $fileName [Word GetEnum $fmt]
        }
        Word::ShowAlerts $appId true
    }

    proc SaveAsPdf { docId fileName } {
        # Save a document to a PDF file.
        #
        # docId    - Identifier of the document to export.
        # fileName - Name of the PDF file.
        #
        # PDF export is supported since Word 2007.
        # If your Word version is older an error is thrown.
        #
        # **Note:**
        # For Word 2007 you need the Microsoft Office Add-in
        # `Microsoft Save as PDF or XPS` available from
        # <http://www.microsoft.com/en-us/download/details.aspx?id=7>
        #
        # Returns no value.
        #
        # See also: SaveAs

        variable wordVersion

        if { $wordVersion < 12.0 } {
            error "PDF export available only in Word 2007 or newer. Running [Word GetVersion $docId true]."
        }

        set fileName [file nativename [file normalize $fileName]]
        set appId [Office GetApplicationId $docId]

        Word::ShowAlerts $appId false
        $docId -callnamedargs ExportAsFixedFormat \
               OutputFileName $fileName \
               ExportFormat $Word::wdExportFormatPDF \
               OpenAfterExport [Cawt TclBool false] \
               OptimizeFor $Word::wdExportOptimizeForPrint \
               Range $Word::wdExportAllDocument \
               From [expr 1] \
               To [expr 1] \
               Item $Word::wdExportDocumentContent \
               IncludeDocProps [Cawt TclBool true] \
               KeepIRM [Cawt TclBool true] \
               CreateBookmarks $Word::wdExportCreateHeadingBookmarks \
               DocStructureTags [Cawt TclBool true] \
               BitmapMissingFonts [Cawt TclBool true] \
               UseISO19005_1 [Cawt TclBool false]
        Word::ShowAlerts $appId true
    }

    proc SetCompatibilityMode { docId { mode wdWord2010 } } {
        # Set the compatibility mode of a document.
        #
        # docId - Identifier of the document.
        # mode  - Compatibility mode of the document.
        #         Value of enumeration type [Enum::WdCompatibilityMode].
        #
        # Available only for Word 2010 and up.
        #
        # Returns no value.
        #
        # See also: GetCompatibilityMode

        variable wordVersion

        if { $wordVersion >= 14.0 } {
            $docId SetCompatibilityMode [Word GetEnum $mode]
        }
    }

    proc AddDocument { appId { type "" } { visible true } } {
        # Add a new empty document to a Word instance.
        #
        # appId   - Identifier of the Word instance.
        # type    - Value of enumeration type [Enum::WdNewDocumentType].
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        #
        # Returns the identifier of the new document.
        #
        # See also: OpenDocument SetPageSetup

        if { $type eq "" } {
            set type $Word::wdNewBlankDocument
        }
        set docs [$appId Documents]
        # Add([Template], [NewTemplate], [DocumentType], [Visible]) As Document
        set docId [$docs -callnamedargs Add \
                         DocumentType [Word GetEnum $type] \
                         Visible [Cawt TclInt $visible]]
        Cawt Destroy $docs
        return $docId
    }

    proc GetNumDocuments { appId } {
        # Return the number of documents in a Word application.
        #
        # appId - Identifier of the Word instance.
        #
        # Returns the number of documents in the Word application.
        #
        # See also: AddDocument OpenDocument
        # GetNumCharacters GetNumColumns GetNumImages GetNumHyperlinks
        # GetNumPages GetNumRows GetNumSubdocuments GetNumTables

        return [$appId -with { Documents } Count]
    }

    proc OpenDocument { appId fileName args } {
        # Open a document, i.e. load a Word file.
        #
        # appId    - Identifier of the Word instance.
        # fileName - Name of the Word file.
        # args     - Options described below.
        #
        # -readonly <bool> - If set to true, open the document in read-only mode.
        #                    Default is to open the document in read-write mode.
        # -embed <frame>   - Embed the document into a Tk frame. This frame must
        #                    exist and must be created with option `-container true`. 
        #
        # Returns the identifier of the opened document. If the document was 
        # already open, activate that document and return the identifier to 
        # that document.
        #
        # See also: AddDocument SetPageSetup

        set opts [dict create \
            -readonly false   \
            -embed    ""      \
        ]
        if { [llength $args] == 1 } {
            # Old mode with optional boolean parameter readOnly
            dict set opts -readonly [lindex $args 0]
        } else {
            foreach { key value } $args {
                if { [dict exists $opts $key] } {
                    if { $value eq "" } {
                        error "OpenDocument: No value specified for key \"$key\"."
                    }
                    dict set opts $key $value
                } else {
                    error "OpenDocument: Unknown option \"$key\" specified."
                }
            }
        }

        set nativeName [file nativename [file normalize $fileName]]
        set docs [$appId Documents]
        set retVal [catch {[$docs Item [file tail $fileName]] Activate} d]
        if { $retVal == 0 } {
            set docId [$docs Item [file tail $fileName]]
        } else {
            # Open(FileName, [ConfirmConversions], [ReadOnly],
            # [AddToRecentFiles], [PasswordDocument], [PasswordTemplate],
            # [Revert], [WritePasswordDocument], [WritePasswordTemplate],
            # [Format], [Encoding], [Visible], [OpenAndRepair],
            # [DocumentDirection], [NoEncodingDialog], [XMLTransform])
            # As Document
            set docId [$docs -callnamedargs Open \
                             FileName $nativeName \
                             ConfirmConversions [Cawt TclBool false] \
                             ReadOnly [Cawt TclInt [dict get $opts "-readonly"]]]
        }
        Cawt Destroy $docs
        set embedFrame [dict get $opts "-embed"]
        if { $embedFrame ne "" } {
            set docWindows [$docId Windows]
            $docWindows -iterate window {
                set windowHndl [$window Hwnd]
                set windowId   [list $windowHndl HWND]
                break
            }
            Cawt Destroy $docWindows
            Cawt EmbedApp $embedFrame -appid [Office GetApplicationId $docId] -window $windowId
        }
        return $docId
    }

    proc GetDocumentIdByIndex { appId index } {
        # Find a document by its index.
        #
        # appId - Identifier of the Word instance.
        # index - Index of the document to find.
        #
        # Returns the identifier of the found document.
        # If the index is out of bounds an error is thrown.
        #
        # See also: GetNumDocuments GetDocumentId GetDocumentName

        set count [Word GetNumDocuments $appId]

        if { $index < 1 || $index > $count } {
            error "GetDocumentIdByIndex: Invalid index $index given."
        }
        return [$appId -with { Documents } Item $index]
    }

    proc GetDocumentId { componentId } {
        # Get the document identifier of a Word component.
        #
        # componentId - The identifier of a Word component.
        #
        # Returns the document identifier of a Word component.
        #
        # Word components having the Document property are ex. ranges, panes.
        #
        # See also: GetNumDocuments GetDocumentName

        return [$componentId Document]
    }

    proc GetDocumentName { docId } {
        # Get the name of a document.
        #
        # docId - Identifier of the document.
        #
        # Returns the name of the document (i.e. the full path name of the
        # corresponding Word file) as a string.
        #
        # See also: GetNumDocuments GetDocumentId

        return [$docId FullName]
    }

    proc AppendParagraph { docId { spaceAfter -1 } } {
        # Append a paragraph at the end of the document.
        #
        # docId      - Identifier of the document.
        # spaceAfter - Spacing after the range.
        #
        # The spacing value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: GetEndRange AddParagraph

        set endRange [Word GetEndRange $docId]
        $endRange InsertParagraphAfter
        set spaceAfter [Cawt ValueToPoints $spaceAfter]
        if { $spaceAfter >= 0 } {
            $endRange -with { ParagraphFormat } SpaceAfter $spaceAfter
        }
        return $endRange
    }

    proc AddParagraph { rangeId { spaceAfter -1 } } {
        # Add a new paragraph to a document.
        #
        # rangeId    - Identifier of the text range.
        # spaceAfter - Spacing after the range.
        #
        # The spacing value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns the new extended range.
        #
        # See also: AppendParagraph

        $rangeId InsertParagraphAfter
        set spaceAfter [Cawt ValueToPoints $spaceAfter]
        if { $spaceAfter >= 0 } {
            $rangeId -with { ParagraphFormat } SpaceAfter $spaceAfter
        }
        return $rangeId
    }

    proc InsertText { docId text { addParagraph false } { style wdStyleNormal } } {
        # Insert text in a Word document.
        #
        # docId        - Identifier of the document.
        # text         - Text string to be inserted.
        # addParagraph - Add a paragraph after the text.
        # style        - Value of enumeration type [Enum::WdBuiltinStyle].
        #
        # The text string is inserted at the start of the document with given style.
        #
        # Returns the new text range.
        #
        # See also: AddText AppendText AddParagraph SetRangeStyle
        # InsertCaption InsertFile InsertImage InsertList

        set newRange [Word CreateRange $docId 0 0]
        $newRange InsertAfter $text
        if { $addParagraph } {
            $newRange InsertParagraphAfter
        }
        Word SetRangeStyle $newRange $style
        return $newRange
    }

    proc AppendText { docId text { addParagraph false } { style wdStyleNormal } } {
        # Append text to a Word document.
        #
        # docId        - Identifier of the document.
        # text         - Text string to be appended.
        # addParagraph - Add a paragraph after the text.
        # style        - Value of enumeration type [Enum::WdBuiltinStyle].
        #
        # The text string is appended at the end of the document with given style.
        #
        # Returns the new text range.
        #
        # See also: GetEndRange AddText InsertText AppendParagraph SetRangeStyle

        set newRange [Word GetEndRange $docId]
        $newRange InsertAfter $text
        if { $addParagraph } {
            $newRange InsertParagraphAfter
        }
        Word SetRangeStyle $newRange $style
        return $newRange
    }

    proc AddText { rangeId text { addParagraph false } { style wdStyleNormal } } {
        # Add text to a Word document.
        #
        # rangeId      - Identifier of the text range.
        # text         - Text string to be added.
        # addParagraph - Add a paragraph after the text.
        # style        - Value of enumeration type [Enum::WdBuiltinStyle].
        #
        # The text string is appended to the supplied text range with given style.
        #
        # Returns the new text range.
        #
        # See also: AddText InsertText AppendParagraph SetRangeStyle

        set newStartIndex [$rangeId End]
        set docId [Word GetDocumentId $rangeId]
        set newRange [Word CreateRange $docId $newStartIndex $newStartIndex]
        $newRange InsertAfter $text
        if { $addParagraph } {
            $newRange InsertParagraphAfter
        }
        Word SetRangeStyle $newRange $style
        Cawt Destroy $docId
        return $newRange
    }

    proc GetNumHyperlinks { docId } {
        # Return the number of hyperlinks of a Word document.
        #
        # docId - Identifier of the document.
        #
        # Returns the number of hyperlinks of the Word document.
        # This counts both `internal`, `file` and `url` links, see 
        # [GetHyperlinksAsDict] for an explanation of link types.
        #
        # See also: SetHyperlink GetHyperlinksAsDict GetBookmarkNames
        # GetNumCharacters GetNumColumns GetNumDocuments GetNumImages
        # GetNumPages GetNumRows GetNumSubdocuments GetNumTables

        return [$docId -with { Hyperlinks } Count]
    }

    proc SetHyperlink { rangeId link { textDisplay "" } } {
        # Insert an external hyperlink into a Word document.
        #
        # rangeId     - Identifier of the text range.
        # link        - URL of the hyperlink.
        # textDisplay - Text to be displayed instead of the URL.
        #
        # URL's are specified as strings:
        # * `file://myLinkedFile` specifies a link to a local file.
        # * `http://myLinkedWebpage` specifies a link to a web address.
        #
        # Returns no value.
        #
        # See also: SetHyperlinkToFile SetLinkToBookmark SetInternalHyperlink

        if { $textDisplay eq "" } {
            set textDisplay $link
        }

        set docId [Word GetDocumentId $rangeId]
        set hyperlinks [$docId Hyperlinks]
        # Add(Anchor As Object, [Address], [SubAddress], [ScreenTip],
        # [TextToDisplay], [Target]) As Hyperlink
        set hyperlink [$hyperlinks -callnamedargs Add \
                 Anchor  $rangeId \
                 Address $link \
                 TextToDisplay $textDisplay]
        Cawt Destroy $hyperlink
        Cawt Destroy $hyperlinks
        Cawt Destroy $docId
    }

    proc SetHyperlinkToFile { rangeId fileName { textDisplay "" } } {
        # Insert a hyperlink to a file into a Word document.
        #
        # rangeId     - Identifier of the text range.
        # fileName    - Path name of the linked file.
        # textDisplay - Text to be displayed instead of the file name.
        #
        # Returns no value.
        #
        # See also: SetHyperlink SetLinkToBookmark SetInternalHyperlink

        if { [file pathtype $fileName] eq "relative" } {
            set address [format "file:./%s" [file nativename $fileName]]
        } else {
            set address [format "file://%s" [file nativename [file normalize $fileName]]]
            set appId [Office GetApplicationId $rangeId]
            $appId -with { DefaultWebOptions } UpdateLinksOnSave [Cawt TclBool false]
            Cawt Destroy $appId
        }
        SetHyperlink $rangeId $address $textDisplay
    }

    proc SetInternalHyperlink { rangeId subAddress { textDisplay "" } } {
        # Insert an internal hyperlink into a Word document.
        #
        # rangeId     - Identifier of the text range.
        # subAddress  - Internal reference.
        # textDisplay - Text to be displayed instead of the URL.
        #
        # Returns no value.
        #
        # See also: SetLinkToBookmark SetHyperlink SetHyperlinkToFile

        if { $textDisplay eq "" } {
            set textDisplay $subAddress
        }

        set docId [Word GetDocumentId $rangeId]
        set hyperlinks [$docId Hyperlinks]
        # Add(Anchor As Object, [Address], [SubAddress], [ScreenTip],
        # [TextToDisplay], [Target]) As Hyperlink
        $hyperlinks -callnamedargs Add \
                 Anchor  $rangeId \
                 SubAddress $subAddress \
                 TextToDisplay $textDisplay
        Cawt Destroy $hyperlinks
        Cawt Destroy $docId
    }

    proc SetLinkToBookmark { rangeId bookmarkId { textDisplay "" } } {
        # Insert an internal link to a bookmark into a Word document.
        #
        # rangeId     - Identifier of the text range.
        # bookmarkId  - Identifier of the bookmark to link to.
        # textDisplay - Text to be displayed instead of the bookmark name.
        #
        # Returns no value.
        #
        # See also: AddBookmark GetBookmarkName SetHyperlink SetInternalHyperlink

        set bookmarkName [Word GetBookmarkName $bookmarkId]
        if { $textDisplay eq "" } {
            set textDisplay $bookmarkName
        }

        set docId [Word GetDocumentId $rangeId]
        set hyperlinks [$docId Hyperlinks]
        # Add(Anchor As Object, [Address], [SubAddress], [ScreenTip],
        # [TextToDisplay], [Target]) As Hyperlink
        $hyperlinks -callnamedargs Add \
                 Anchor        $rangeId \
                 Address       "" \
                 SubAddress    $bookmarkName \
                 TextToDisplay $textDisplay
        Cawt Destroy $hyperlinks
        Cawt Destroy $docId
    }

    proc InsertFile { rangeId fileName { pasteFormat "" } } {
        # Insert a file into a Word document.
        #
        # rangeId     - Identifier of the text range.
        # fileName    - Name of the file to insert.
        # pasteFormat - Value of enumeration type [Enum::WdRecoveryType].
        #
        # Insert an external file at the text range identified by $rangeId. If $pasteFormat is
        # not specified or an empty string, the Word method `InsertFile` is used.
        # Otherwise the external file is opened in a new Word document, copied to the clipboard
        # and pasted into the text range. For pasting the Word method `PasteAndFormat` is used, so it is
        # possible to merge the new text from the external file into the Word document in different ways.
        #
        # Returns no value.
        #
        # See also: SetHyperlink InsertCaption InsertImage InsertList InsertText

        if { $pasteFormat ne "" } {
            set tmpAppId [Office GetApplicationId $rangeId]
            set tmpDocId [Word OpenDocument $tmpAppId $fileName false]
            set tmpRangeId [Word GetStartRange $tmpDocId]
            $tmpRangeId WholeStory
            $tmpRangeId Copy

            Cawt WaitClipboardReady
            $rangeId PasteAndFormat [Word GetEnum $pasteFormat]

            # Workaround: Select a small portion of text and copy it to clipboard
            # to avoid an alert message regarding lots of data in clipboard.
            # Setting DisplayAlerts to false does not help here.
            set dummyRange [Word CreateRange $tmpDocId 0 1]
            $dummyRange Copy
            Cawt Destroy $dummyRange

            Word Close $tmpDocId
            Cawt Destroy $tmpRangeId
            Cawt Destroy $tmpDocId
            Cawt Destroy $tmpAppId
        } else {
            # InsertFile(FileName, Range, ConfirmConversions, Link, Attachment)
            $rangeId InsertFile [file nativename [file normalize $fileName]] \
                                "" \
                                [Cawt TclBool false] \
                                [Cawt TclBool false] \
                                [Cawt TclBool false]
        }
    }

    proc GetNumImages { docId { useInlineShapesOnly true } } {
        # Return the number of images of a Word document.
        #
        # docId               - Identifier of the document.
        # useInlineShapesOnly - Only consider InlineShapes as images.
        #
        # Returns the number of images of the Word document.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # See also: InsertImage ReplaceImage GetImageId GetImageList SetImageName
        # GetNumCharacters GetNumColumns GetNumDocuments GetNumHyperlinks
        # GetNumPages GetNumRows GetNumSubdocuments GetNumTables

        set numImgs 0

        set inlineShapes [$docId InlineShapes]
        $inlineShapes -iterate inlineShape {
            if { [$inlineShape Type] == $::Word::wdInlineShapeLinkedPicture || \
                 [$inlineShape Type] == $::Word::wdInlineShapePicture } {
                incr numImgs
            }
            Cawt Destroy $inlineShape
        }
        Cawt Destroy $inlineShapes

        if { ! $useInlineShapesOnly } {
            set shapes [$docId Shapes]
            $shapes -iterate shape {
                if { [$shape Type] == $::Office::msoPicture || \
                     [$shape Type] == $::Office::msoLinkedPicture } {
                    incr numImgs
                }
                Cawt Destroy $shape
            }
            Cawt Destroy $shapes
        }
        return $numImgs
    }

    proc InsertImage { rangeId imgFileName { linkToFile false } { saveWithDoc true } } {
        # Insert an image into a range of a document.
        #
        # rangeId     - Identifier of the text range.
        # imgFileName - File name of the image.
        # linkToFile  - Insert a link to the image file.
        # saveWithDoc - Embed the image into the document.
        #
        # Returns the identifier of the inserted image as an InlineShape.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # See also: GetNumImages ScaleImage CropImage InsertFile InsertCaption
        # InsertList InsertText

        if { ! $linkToFile && ! $saveWithDoc } {
            error "InsertImage: linkToFile and saveWithDoc are both set to false."
        }

	set fileName [file nativename [file normalize $imgFileName]]
        set shapeId [$rangeId -with { InlineShapes } AddPicture $fileName \
                  [Cawt TclInt $linkToFile] \
                  [Cawt TclInt $saveWithDoc]]
        return $shapeId
    }

    proc GetImageList { docId args } {
        # Get a list of images of a Word document.
        #
        # docId - Identifier of the document.
        # args  - Options described below.
        #
        # -inlineshapes <bool> - Consider InlineShapes as images. Default value is true.
        # -shapes <bool>       - Consider Shapes as images. Default value is true.
        #
        # Returns a list of shape identifiers of the images of the Word document.
        #
        # **Note:**
        # If both InlineShapes and Shapes are returned in one list,
        # all InlineShapes come first, followed by the Shapes.
        #
        # Images are either InlineShapes of enumeration [Enum::WdInlineShapeType] 
        # (`wdInlineShapePicture`, `wdInlineShapeLinkedPicture`) or Shapes of
        # enumeration [::Office::Enum::MsoShapeType] (`msoInlinePicture`, `msoLinkedPicture`).
        #
        # See also: GetNumImages InsertImage ReplaceImage GetImageId SetImageName

        set opts [dict create \
            -inlineshapes true \
            -shapes       true \
        ]
        foreach { key value } $args {
            if { $value eq "" } {
                error "GetImageList: No value specified for key \"$key\""
            }
            if { [dict exists $opts $key] } {
                dict set opts $key $value
            } else {
                error "GetImageList: Unknown option \"$key\" specified"
            }
        }
        set imgIdList [list]

        if { [dict get $opts "-inlineshapes"] } {
            set inlineShapes [$docId InlineShapes]
            $inlineShapes -iterate inlineShape {
                if { [$inlineShape Type] == $::Word::wdInlineShapeLinkedPicture || \
                     [$inlineShape Type] == $::Word::wdInlineShapePicture } {
                    lappend imgIdList $inlineShape
                } else {
                    Cawt Destroy $inlineShape
                }
            }
            Cawt Destroy $inlineShapes
        }

        if { [dict get $opts "-shapes"] } {
            set shapes [$docId Shapes]
            $shapes -iterate shape {
                if { [$shape Type] == $::Office::msoPicture || \
                     [$shape Type] == $::Office::msoLinkedPicture } {
                    lappend imgIdList $shape
                } else {
                    Cawt Destroy $shape
                }
            }
            Cawt Destroy $shapes
        }
        return $imgIdList
    }

    proc GetImageId { docId indexOrName } {
        # Find an image by its index or name.
        #
        # docId       - Identifier of the document.
        # indexOrName - Index or name of the image to find.
        #
        # Returns the identifier of the found InlineShape.
        #
        # Image names are supported since Word 2010.
        # If your Word version is older, an error is thrown.
        #
        # If the index is out of bounds or the specified name
        # does not exists, an error is thrown.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # See also: GetNumImages GetImageList InsertImage ReplaceImage SetImageName

        variable wordVersion

        set count [Word::GetNumImages $docId]

        if { [string is integer -strict $indexOrName] } {
            set index [expr int($indexOrName)]
            if { $index < 1 || $index > $count } {
                error "GetImageId: Invalid index $index given."
            }
            return [$docId -with { InlineShapes } Item $index]
        } else {
            if { $wordVersion < 14.0 } {
                error "Image names available only in Word 2010 or newer. Running [Word GetVersion $docId true]."
            }
            for { set i 1 } { $i <= $count } { incr i } {
                set imgId [$docId -with { InlineShapes } Item $i]
                if { [Word::GetImageName $imgId] eq $indexOrName } {
                    return $imgId
                }
                Cawt Destroy $imgId
            }
            error "GetImageId: No image with name \"$indexOrName\" found."
        }
    }

    proc _AssignWrapFormat { fromShapeId toShapeId } {
        #$toShapeId LeftRelative [$fromShapeId LeftRelative]
        #$toShapeId TopRelative [$fromShapeId TopRelative]
        #$toShapeId WidthRelative [$fromShapeId WidthRelative]
        #$toShapeId HeightRelative [$fromShapeId HeightRelative]

        #$toShapeId RelativeHorizontalPosition [$fromShapeId RelativeHorizontalPosition]
        #$toShapeId RelativeHorizontalSize [$fromShapeId RelativeHorizontalSize]

        #$toShapeId RelativeVerticalPosition [$fromShapeId RelativeVerticalPosition]
        #$toShapeId RelativeVerticalSize [$fromShapeId RelativeVerticalSize]

        $toShapeId -with { WrapFormat } DistanceBottom [$fromShapeId -with { WrapFormat } DistanceBottom]
        $toShapeId -with { WrapFormat } DistanceTop    [$fromShapeId -with { WrapFormat } DistanceTop]
        $toShapeId -with { WrapFormat } DistanceLeft   [$fromShapeId -with { WrapFormat } DistanceLeft]
        $toShapeId -with { WrapFormat } DistanceRight  [$fromShapeId -with { WrapFormat } DistanceRight]
        $toShapeId -with { WrapFormat } AllowOverlap   [$fromShapeId -with { WrapFormat } AllowOverlap]
        $toShapeId -with { WrapFormat } Side           [$fromShapeId -with { WrapFormat } Side]
        $toShapeId -with { WrapFormat } Type           [$fromShapeId -with { WrapFormat } Type]
    }

    proc ReplaceImage { shapeId imgFileName args } {
        # Replace an existing image.
        #
        # shapeId     - Identifier of the image InlineShape or Shape.
        # imgFileName - File name of the new image (as absolute path).
        # args        - Options described below.
        #
        # -keepsize <bool> - Keep original image size. Default value is false.
        #
        # Returns the identifier of the new image.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # **Note:**
        # Replacing Shape images does not work correctly yet.
        # Images are replaced, but the layout is disturbed.
        #
        # See also: InsertImage GetImageList GetNumImages SetImageName

        set opts [dict create \
            -keepsize false \
        ]
        foreach { key value } $args {
            if { $value eq "" } {
                error "ReplaceImage: No value specified for key \"$key\""
            }
            if { [dict exists $opts $key] } {
                dict set opts $key $value
            } else {
                error "ReplaceImage: Unknown option \"$key\" specified"
            }
        }

        set width  [$shapeId Width]
        set height [$shapeId Height]
        set title  [$shapeId Title]

        set fileName [file nativename [file normalize $imgFileName]]

        if { [Word::IsInlineShape $shapeId] } {
            set rangeId [$shapeId Range]
            set newShapeId [$rangeId -with { InlineShapes } AddPicture $fileName]
        } else {
            $shapeId RelativeHorizontalPosition $::Word::wdRelativeHorizontalPositionPage
            $shapeId RelativeVerticalPosition   $::Word::wdRelativeVerticalPositionPage
            set width  [$shapeId Width]
            set height [$shapeId Height]
            set top  [$shapeId Top]
            set left [$shapeId Left]
            set docId [$shapeId Parent]
            set anchor [$shapeId -with { Anchor } Duplicate]
            set newShapeId [$docId -with { Shapes } AddPicture $fileName]
            Word::_AssignWrapFormat $shapeId $newShapeId
            $newShapeId Left [expr $left - [GetPageSetup $docId -left]]
            $newShapeId Top  [expr $top  - [GetPageSetup $docId -top]]
        }
        $shapeId Delete
        Cawt Destroy $shapeId

        $newShapeId Title $title

        if { [dict get $opts "-keepsize"] } {
            $newShapeId Width  $width
            $newShapeId Height $height
        }
        return $newShapeId
    }

    proc GetImageName { shapeId } {
        # Return the name of an image.
        #
        # shapeId - Identifier of the image InlineShape or Shape.
        #
        # Image names are supported since Word 2010.
        # If your Word version is older, an error is thrown.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # Returns the name of the image.
        #
        # See also: GetNumImages SetImageName InsertImage GetImageId GetImageList

        variable wordVersion

        if { $wordVersion < 14.0 } {
            error "Image names available only in Word 2010 or newer. Running [Word GetVersion $shapeId true]."
        }
        return [$shapeId Title]
    }

    proc SetImageName { shapeId name } {
        # Set the name of an image.
        #
        # shapeId - Identifier of the image InlineShape or Shape.
        #
        # Returns no value.
        #
        # Image names are supported since Word 2010.
        # If your Word version is older, an error is thrown.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # See also: GetNumImages GetImageName InsertImage GetImageId GetImageList

        variable wordVersion

        if { $wordVersion < 14.0 } {
            error "Image names available only in Word 2010 or newer. Running [Word GetVersion $shapeId true]."
        }
        $shapeId Title $name
    }

    proc ScaleImage { shapeId scaleWidth scaleHeight } {
        # Scale an image.
        #
        # shapeId     - Identifier of the image InlineShape.
        # scaleWidth  - Horizontal scale factor.
        # scaleHeight - Vertical scale factor.
        #
        # The scale factors are floating point values. 1.0 means no scaling.
        #
        # Returns no value.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # See also: GetNumImages InsertImage ReplaceImage CropImage

        $shapeId LockAspectRatio [Cawt TclInt false]
        $shapeId ScaleWidth  [expr { 100.0 * double($scaleWidth) }]
        $shapeId ScaleHeight [expr { 100.0 * double($scaleHeight) }]
    }

    proc CropImage { shapeId { cropBottom 0.0 } { cropTop 0.0 } { cropLeft 0.0 } { cropRight 0.0 } } {
        # Crop an image at the four borders.
        #
        # shapeId    - Identifier of the image InlineShape.
        # cropBottom - Crop amount at the bottom border.
        # cropTop    - Crop amount at the top border.
        # cropLeft   - Crop amount at the left border.
        # cropRight  - Crop amount at the right border.
        #
        # The crop values may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See [GetImageList] for a description of InlineShapes and Shapes.
        #
        # See also: GetNumImages InsertImage ScaleImage

        $shapeId -with { PictureFormat } CropBottom [Cawt ValueToPoints $cropBottom]
        $shapeId -with { PictureFormat } CropTop    [Cawt ValueToPoints $cropTop]
        $shapeId -with { PictureFormat } CropLeft   [Cawt ValueToPoints $cropLeft]
        $shapeId -with { PictureFormat } CropRight  [Cawt ValueToPoints $cropRight]
    }

    proc InsertCaption { rangeId labelId text { pos wdCaptionPositionBelow } } {
        # Insert a caption into a range of a document.
        #
        # rangeId - Identifier of the text range.
        # labelId - Value of enumeration type [Enum::WdCaptionLabelID].
        #           Possible values: `wdCaptionEquation`, `wdCaptionFigure`, `wdCaptionTable`.
        # text    - Text of the caption.
        # pos     - Value of enumeration type [Enum::WdCaptionPosition].
        #
        # Returns the new extended range.
        #
        # See also: ConfigureCaption InsertFile InsertImage InsertList InsertText

        $rangeId InsertCaption [Word GetEnum $labelId] $text "" [Word GetEnum $pos] 0
        return $rangeId
    }

    proc ConfigureCaption { appId labelId chapterStyleLevel { includeChapterNumber true } \
                            { numberStyle wdCaptionNumberStyleArabic } \
                            { separator wdSeparatorHyphen } } {
        # Configure style of a caption type identified by its label identifier.
        #
        # appId                - Identifier of the Word instance.
        # labelId              - Value of enumeration type [Enum::WdCaptionLabelID].
        #                        Possible values: `wdCaptionEquation`, `wdCaptionFigure`, `wdCaptionTable`.
        # chapterStyleLevel    - 1 corresponds to `Heading1`, 2 corresponds to `Heading2`, ...
        # includeChapterNumber - Flag indicating whether to include the chapter number.
        # numberStyle          - Value of enumeration type [Enum::WdCaptionNumberStyle].
        # separator            - Value of enumeration type [Enum::WdSeparatorType].
        #
        # Returns no value.
        #
        # See also: InsertCaption

        set captionItem [$appId -with { CaptionLabels } Item [Word GetEnum $labelId]]
        $captionItem ChapterStyleLevel    [expr $chapterStyleLevel]
        $captionItem IncludeChapterNumber [Cawt TclBool $includeChapterNumber]
        $captionItem NumberStyle          [Word GetEnum $numberStyle]
        $captionItem Separator            [Word GetEnum $separator]
    }

    proc AddTable { rangeId numRows numCols { spaceAfter -1 } } {
        # Add a new table in a text range.
        #
        # rangeId    - Identifier of the text range.
        # numRows    - Number of rows of the new table.
        # numCols    - Number of columns of the new table.
        # spaceAfter - Spacing in points after the table.
        #
        # The spacing value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns the identifier of the new table.
        #
        # See also: DeleteTable GetNumTables GetNumRows GetNumColumns

        set docId [Word GetDocumentId $rangeId]
        set tableId [$docId -with { Tables } Add $rangeId $numRows $numCols]
        set spaceAfter [Cawt ValueToPoints $spaceAfter]
        if { $spaceAfter >= 0 } {
            $tableId -with { Range ParagraphFormat } SpaceAfter $spaceAfter
        }
        Cawt Destroy $docId
        return $tableId
    }

    proc DeleteTable { tableId } {
        # Delete a table.
        #
        # tableId - Identifier of the Word table.
        #
        # Returns no value.
        #
        # See also: AddTable GetNumTables

        $tableId Delete
    }

    proc GetNumTables { docId } {
        # Return the number of tables of a Word document.
        #
        # docId - Identifier of the document.
        #
        # Returns the number of tables of the Word document.
        #
        # See also: AddTable GetNumCharacters GetNumColumns GetNumDocuments 
        # GetNumImages GetNumHyperlinks GetNumPages GetNumRows GetNumSubdocuments

        return [$docId -with { Tables } Count]
    }

    proc GetTableIdByIndex { docId index } {
        # Find a table by its index.
        #
        # docId - Identifier of the document.
        # index - Index of the table to find.
        #
        # Returns the identifier of the found table.
        # If the index is out of bounds an error is thrown.
        #
        # See also: GetTableIdByName GetNumTables

        set count [Word GetNumTables $docId]

        if { $index < 1 || $index > $count } {
            error "GetTableIdByIndex: Invalid index $index given."
        }
        return [$docId -with { Tables } Item $index]
    }

    proc GetTableIdByName { docId name } {
        # Find table(s) by its name.
        #
        # docId - Identifier of the document.
        # name  - Name of the table(s) to find.
        #
        # Returns a list of identifiers of the found table(s).
        # If no tables with given name exist, an empty list is returned.
        #
        # Table names are supported since Word 2010.
        # If your Word version is older, an error is thrown.
        #
        # See also: GetTableIdByIndex GetNumTables

        variable wordVersion

        if { $wordVersion < 14.0 } {
            error "Table names available only in Word 2010 or newer. Running [Word GetVersion $docId true]."
        }

        set tableIdList [list]
        set count [Word GetNumTables $docId]
        for { set i 1 } { $i <= $count } { incr i } {
            set tableId [$docId -with { Tables } Item [expr $i]]
            if { $name eq [Word::GetTableName $tableId] } {
                lappend tableIdList $tableId
            } else {
                Cawt Destroy $tableId
            }
        }
        return $tableIdList
    }

    proc GetTableName { tableId } {
        # Return the name of a table.
        #
        # tableId - Identifier of the Word table.
        #
        # Table names are supported since Word 2010.
        # If your Word version is older, an error is thrown.
        #
        # Returns the name of the table.
        #
        # See also: SetTableName GetNumTables AddTable

        variable wordVersion

        if { $wordVersion < 14.0 } {
            error "Table names available only in Word 2010 or newer. Running [Word GetVersion $tableId true]."
        }
        return [$tableId Title]
    }

    proc SetTableName { tableId name } {
        # Set the name of a table.
        #
        # tableId - Identifier of the Word table.
        # name    - Name of the table.
        #
        # Returns no value.
        #
        # **Note:**
        # Table names are supported since Word 2010.
        # If your Word version is older, an error is thrown.
        # Setting the table name also does not work, if using
        # a Word version greater than 2010, but working with a
        # document in old `.doc` format.
        #
        # See also: GetTableName GetNumTables AddTable

        variable wordVersion

        if { $wordVersion < 14.0 } {
            error "Table names available only in Word 2010 or newer. Running [Word GetVersion $tableId true]."
        }
        $tableId Title $name
    }

    proc SetTableBorderLineStyle { tableOrRangeId \
              { outsideLineStyle wdLineStyleSingle } \
              { insideLineStyle  wdLineStyleSingle } } {
        # Set the border line styles of a Word table or cell range.
        #
        # tableOrRangeId   - Identifier of the Word table or cell range.
        # outsideLineStyle - Outside border style.
        # insideLineStyle  - Inside border style.
        #
        # Returns no value.
        #
        # The values of $outsideLineStyle and $insideLineStyle must
        # be of enumeration type [Enum::WdLineStyle] (see WordConst.tcl).
        #
        # See also: AddTable SetTableBorderLineWidth GetCellRange

        set border [$tableOrRangeId Borders]
        $border OutsideLineStyle [Word GetEnum $outsideLineStyle]
        $border InsideLineStyle  [Word GetEnum $insideLineStyle]
        Cawt Destroy $border
    }

    proc SetTableBorderLineWidth { tableOrRangeId \
              { outsideLineWidth wdLineWidth050pt } \
              { insideLineWidth  wdLineWidth050pt } } {
        # Set the border line widths of a Word table or cell range.
        #
        # tableOrRangeId   - Identifier of the Word table or cell range.
        # outsideLineWidth - Outside border line width.
        # insideLineWidth  - Inside border line width.
        #
        # Returns no value.
        #
        # The values of $outsideLineWidth and $insideLineWidth must
        # be of enumeration type [Enum::WdLineWidth] (see WordConst.tcl).
        #
        # See also: AddTable SetTableBorderLineStyle GetCellRange

        set border [$tableOrRangeId Borders]
        $border OutsideLineWidth [Word GetEnum $outsideLineWidth]
        $border InsideLineWidth  [Word GetEnum $insideLineWidth]
        Cawt Destroy $border
    }

    proc SetTableAlignment { tableId align } {
        # Set the alignment of a Word table.
        #
        # tableId - Identifier of the Word table.
        # align   - Value of enumeration type [Enum::WdRowAlignment]
        #           or any of the following strings: `left`, `right`, `center`.
        #
        # Returns no value.
        #
        # See also: AddTable SetTableName SetTableBorderLineStyle

        if { $align eq "center" } {
            set alignEnum $Word::wdAlignRowCenter
        } elseif { $align eq "left" } {
            set alignEnum $Word::wdAlignRowLeft
        } elseif { $align eq "right" } {
            set alignEnum $Word::wdAlignRowRight
        } else {
            set alignEnum [Word GetEnum $align]
        }
        $tableId -with { Rows } Alignment $alignEnum
    }

    proc SetTableOptions { tableId args } {
        # Set miscellaneous table options.
        #
        # tableId - Identifier of the Word table.
        # args    - Options described below.
        #
        # -bottom <size>  - Set the amount of space to add below the contents of a
        #                   single cell or all the cells in a table.
        # -left <size>    - Set the amount of space to add to the left of the 
        #                   contents of all the cells in a table.
        # -right <size>   - Set the amount of space to add to the right of the
        #                   contents of all the cells in a table.
        # -top <size>     - Set the amount of space to add above the contents
        #                   of all the cells in a table.
        # -spacing <size> - Set the spacing between the cells in a table.
        # -autofit <bool> - Allow Word to automatically resize cells in a table
        #                   to fit their contents.
        # -width <size>   - Set the preferred width of a table.
        #                   The width can also be specified in percent, ex. `50%`.
        #
        # The size values may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # If both `-autofit` and `-width` are specified, the last specified
        # option takes precedence.
        #
        # Returns no value.
        #
        # See also: SetTableName SetTableAlignment

        foreach { key value } $args {
            if { $value eq "" } {
                error "SetTableOptions: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-bottom"  { $tableId BottomPadding [Cawt ValueToPoints $value] }
                "-left"    { $tableId LeftPadding   [Cawt ValueToPoints $value] }
                "-right"   { $tableId RightPadding  [Cawt ValueToPoints $value] }
                "-top"     { $tableId TopPadding    [Cawt ValueToPoints $value] }
                "-spacing" { $tableId Spacing       [Cawt ValueToPoints $value] }
                "-autofit" {
                             if { $value } {
                                 $tableId -with { Columns } AutoFit 
                             }
                           }
                "-width"   { 
                               if { [string match "*%" $value] } {
                                   scan $value "%f" percent
                                   $tableId PreferredWidthType $Word::wdPreferredWidthPercent
                                   $tableId PreferredWidth $percent
                               } else {
                                   $tableId PreferredWidthType $Word::wdPreferredWidthPoints
                                   $tableId PreferredWidth [Cawt ValueToPoints $value]
                               }
                           }
                default    { error "SetTableOptions: Unknown key \"$key\" specified" }
            }
        }
    }

    proc GetNumRows { tableId } {
        # Return the number of rows of a Word table.
        #
        # tableId - Identifier of the Word table.
        #
        # Returns the number of rows of the Word table.
        #
        # See also: GetNumCharacters GetNumColumns GetNumDocuments GetNumImages
        # GetNumHyperlinks GetNumPages GetNumSubdocuments GetNumTables

        return [$tableId -with { Rows } Count]
    }

    proc GetNumColumns { tableId } {
        # Return the number of columns of a Word table.
        #
        # tableId - Identifier of the Word table.
        #
        # Returns the number of columns of the Word table.
        #
        # See also: GetNumCharacters GetNumDocuments GetNumImages GetNumHyperlinks
        # GetNumPages GetNumRows GetNumSubdocuments GetNumTables

        return [$tableId -with { Columns } Count]
    }

    proc AddRow { tableId { beforeRowNum end } { numRows 1 } } {
        # Add one or more rows to a table.
        #
        # tableId      - Identifier of the Word table.
        # beforeRowNum - Insertion row number. Row numbering starts with 1.
        #                The new row is inserted before the given row number.
        #                If not specified or `end`, the new row is appended at
        #                the end.
        # numRows      - Number of rows to be inserted.
        #
        # Returns no value.
        #
        # See also: DeleteRow GetNumRows

        Cawt PushComObjects

        set rowsId [$tableId Rows]
        if { $beforeRowNum eq "end" } {
            for { set r 1 } { $r <= $numRows } {incr r } {
                $rowsId Add
            }
        } else {
            if { $beforeRowNum < 1 || $beforeRowNum > [Word GetNumRows $tableId] } {
                error "AddRow: Invalid row number $beforeRowNum given."
            }
            set rowId [$tableId -with { Rows } Item $beforeRowNum]
            for { set r 1 } { $r <= $numRows } {incr r } {
                $rowsId Add $rowId
            }
        }

        Cawt PopComObjects
    }

    proc DeleteRow { tableId { row end } } {
        # Delete a row of a table.
        #
        # tableId - Identifier of the Word table.
        # row     - Row number. Row numbering starts with 1.
        #           If not specified or `end`, the last row
        #           is deleted.
        #
        # Returns no value.
        #
        # See also: AddRow GetNumRows

        if { $row eq "end" } {
            set row [Word GetNumRows $tableId]
        } else {
            if { $row < 1 || $row > [Word GetNumRows $tableId] } {
                error "DeleteRow: Invalid row number $row given."
            }
        }
        Cawt PushComObjects
        set rowsId [$tableId Rows]
        set rowId  [$tableId -with { Rows } Item $row]
        $rowId Delete
        Cawt PopComObjects
    }

    proc GetCellRange { tableId row1 col1 { row2 -1 } { col2 -1 } } {
        # Return a cell or cells of a Word table as a range.
        #
        # tableId - Identifier of the Word table.
        # row1    - Row number of upper-left corner of the cell range.
        # col1    - Column number of upper-left corner of the cell range.
        # row2    - Row number of lower-right corner of the cell range.
        # col2    - Column number of lower-right corner of the cell range.
        #
        # Row and column numbering starts with 1.
        #
        # Returns a range consisting of 1 cell of a Word table.
        #
        # See also: GetRowRange GetColumnRange

        set cellId1  [$tableId Cell $row1 $col1]
        set rangeId1 [$cellId1 Range]
        Cawt Destroy $cellId1
        if { $row2 >= $row1 && $col2 >= $col1 } {
            set cellId2  [$tableId Cell $row2 $col2]
            set rangeId2 [$cellId2 Range]
            Word SetRangeEndIndex $rangeId1 [Word GetRangeEndIndex $rangeId2]
            Cawt Destroy $cellId2
            Cawt Destroy $rangeId2
        }
        return $rangeId1
    }

    proc GetRowId { tableId row } {
        # Return identifier of a Word table row.
        #
        # tableId - Identifier of the Word table.
        # row     - Row number. Row numbering starts with 1.
        #           If set to `end`, the last row of the table is used.
        #
        # Returns the identifier of the specified row.
        #
        # See also: GetRowRange GetCellRange GetColumnRange

        set numRows [Word GetNumRows $tableId]
        if { $row eq "end" } {
            set row $numRows
        } elseif { $row < 1 } {
            error "GetRowId: Row number ($row) must be greater than zero."
        } elseif { $row > $numRows } {
            error "GetRowId: Row number ($row) is greater than available rows ($numRows)."
        }
        return [$tableId -with { Rows } Item $row]
    }

    proc GetRowRange { tableId row1 { row2 "" } } {
        # Return rows of a Word table as a range.
        #
        # tableId - Identifier of the Word table.
        # row1    - Row range start number.
        # row2    - Row range end number.
        #           If not specified, only $row1 is used.
        #           If set to `end`, the last row of the table is used.
        #
        # Row numbering starts with 1.
        #
        # Returns a range consisting of all cells of the specified rows.
        #
        # See also: GetRowId GetCellRange GetColumnRange

        if { $row1 eq "end" } {
            set row1 [Word GetNumRows $tableId]
        }
        if { $row2 eq "" } {
            set rowId [$tableId -with { Rows } Item $row1]
            set rangeId [$rowId Range]
            Cawt Destroy $rowId
            return $rangeId
        }

        if { $row2 eq "end" } {
            set row2 [Word GetNumRows $tableId]
        }
        set rowId1 [$tableId -with { Rows } Item $row1]
        set rowId2 [$tableId -with { Rows } Item $row2]
        set rangeId1 [$rowId1 Range]
        set rangeId2 [$rowId2 Range]
        Word SetRangeEndIndex $rangeId1 [Word GetRangeEndIndex $rangeId2]
        Cawt Destroy $rowId1
        Cawt Destroy $rowId2
        Cawt Destroy $rangeId2
        return $rangeId1
    }

    proc GetColumnRange { tableId col } {
        # Return a column of a Word table as a selection.
        #
        # tableId - Identifier of the Word table.
        # col     - Column number. Column numbering starts with 1.
        #
        # Returns a selection consisting of all cells of a column.
        #
        # **Note:**
        # A selection is returned and not a range,
        # because columns do not have a range property.
        #
        # See also: GetCellRange GetRowRange

        set colId [$tableId -with { Columns } Item $col]
        $colId Select
        set selectId [$tableId -with { Application } Selection]
        $selectId SelectColumn
        Cawt Destroy $colId
        return $selectId
    }

    proc SetTableVerticalAlignment { tableId align } {
        # Set the vertical alignment of all Word table cells.
        #
        # tableId - Identifier of the Word table.
        # align   - Value of enumeration type [Enum::WdCellVerticalAlignment]
        #           or any of the following strings: `top`, `bottom`, `center`.
        #
        # Returns no value.
        #
        # See also: SetTableOptions SetCellVerticalAlignment

        if { $align eq "center" } {
            set alignEnum $Word::wdCellAlignVerticalCenter
        } elseif { $align eq "top" } {
            set alignEnum $Word::wdCellAlignVerticalTop
        } elseif { $align eq "bottom" } {
            set alignEnum $Word::wdCellAlignVerticalBottom
        } else {
            set alignEnum [Word GetEnum $align]
        }

        $tableId Select
        set selectId [$tableId -with { Application } Selection]
        $selectId -with { Cells } VerticalAlignment $alignEnum
        Cawt Destroy $selectId
    }

    proc SetCellVerticalAlignment { tableId row col align } {
        # Set the vertical alignment of a Word table cell.
        #
        # tableId - Identifier of the Word table.
        # row     - Row number. Row numbering starts with 1.
        # col     - Column number. Column numbering starts with 1.
        # align   - Value of enumeration type [Enum::WdCellVerticalAlignment]
        #           or any of the following strings: `top`, `bottom`, `center`.
        #
        # Returns no value.
        #
        # See also: SetCellValue SetRangeHorizontalAlignment

        if { $align eq "center" } {
            set alignEnum $Word::wdCellAlignVerticalCenter
        } elseif { $align eq "top" } {
            set alignEnum $Word::wdCellAlignVerticalTop
        } elseif { $align eq "bottom" } {
            set alignEnum $Word::wdCellAlignVerticalBottom
        } else {
            set alignEnum [Word GetEnum $align]
        }

        set cellId [$tableId Cell $row $col]
        $cellId VerticalAlignment $alignEnum
        Cawt Destroy $cellId
    }

    proc SetCellValue { tableId row col val } {
        # Set the value of a Word table cell.
        #
        # tableId - Identifier of the Word table.
        # row     - Row number. Row numbering starts with 1.
        # col     - Column number. Column numbering starts with 1.
        # val     - String value of the cell.
        #
        # Returns no value.
        #
        # See also: GetCellValue SetRowValues SetMatrixValues

        set rangeId [Word GetCellRange $tableId $row $col]
        $rangeId Text $val
        Cawt Destroy $rangeId
    }

    proc IsValidCell { tableId row col } {
        # Check, if a Word table cell is valid.
        #
        # tableId - Identifier of the Word table.
        # row     - Row number. Row numbering starts with 1.
        # col     - Column number. Column numbering starts with 1.
        #
        # Returns true, if the cell is valid, otherwise false.
        #
        # See also: GetCellValue

        set retVal [catch { $tableId Cell $row $col } errMsg]
        if { $retVal == 0 } {
            Cawt Destroy $errMsg
            return true
        } else {
            return false
        }
    }

    proc GetCellValue { tableId row col } {
        # Return the value of a Word table cell.
        #
        # tableId - Identifier of the Word table.
        # row     - Row number. Row numbering starts with 1.
        # col     - Column number. Column numbering starts with 1.
        #
        # Returns the value of the specified cell as a string.
        #
        # See also: SetCellValue IsValidCell

        set rangeId [Word GetCellRange $tableId $row $col]
        set val [Word::TrimString [$rangeId Text]]
        Cawt Destroy $rangeId
        return $val
    }

    proc SetRowValues { tableId row valList { startCol 1 } { numVals 0 } } {
        # Insert row values from a Tcl list.
        #
        # tableId  - Identifier of the Word table.
        # row      - Row number. Row numbering starts with 1.
        # valList  - List of values to be inserted.
        # startCol - Column number of insertion start. Column numbering starts with 1.
        # numVals  - If negative or zero, all list values are inserted.
        #            If positive, $numVals columns are filled with the list values
        #            (starting at list index 0).
        #
        # Returns no value. If $valList is an empty list, an error is thrown.
        #
        # See also: GetRowValues SetColumnValues SetCellValue

        set len [llength $valList]
        if { $numVals > 0 } {
            if { $numVals < $len } {
                set len $numVals
            }
        }
        set ind 0
        for { set c $startCol } { $c < [expr {$startCol + $len}] } { incr c } {
            SetCellValue $tableId $row $c [lindex $valList $ind]
            incr ind
        }
    }

    proc SetRowHeight { tableId row { height 0 } } {
        # Set the height of a table row.
        #
        # tableId - Identifier of the Word table.
        # row     - Row number. Row numbering starts with 1.
        # height  - A positive value specifies the row's height.
        #           A value of zero specifies that the rows's height
        #           fits automatically the height of all elements in the row.
        #
        # The height value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: SetRowValues

        set rowId [Word GetRowId $tableId $row]
        set height [Cawt ValueToPoints $height]
        if { $height == 0 } {
            $rowId HeightRule $::Word::wdRowHeightAuto
        } else {
            $rowId HeightRule $::Word::wdRowHeightExactly
            $rowId Height $height
        }
        Cawt Destroy $rowId
    }

    proc GetRowValues { tableId row { startCol 1 } { numVals 0 } } {
        # Return row values of a Word table as a Tcl list.
        #
        # tableId  - Identifier of the Word table.
        # row      - Row number. Row numbering starts with 1.
        # startCol - Column number of start. Column numbering starts with 1.
        # numVals  - If negative or zero, all available row values are returned.
        #            If positive, only numVals values of the row are returned.
        #
        # Returns the values of the specified row or row range as a Tcl list.
        #
        # See also: SetRowValues GetColumnValues GetCellValue

        if { $numVals <= 0 } {
            set len [Word GetNumColumns $tableId]
        } else {
            set len $numVals
        }
        set valList [list]
        set col $startCol
        set ind 0
        while { $ind < $len } {
            set val [Word GetCellValue $tableId $row $col]
            lappend valList $val
            incr ind
            incr col
        }
        return $valList
    }

    proc SetColumnWidth { tableId col width } {
        # Set the width of a table column.
        #
        # tableId - Identifier of the Word table.
        # col     - Column number. Column numbering starts with 1.
        # width   - Column width.
        #
        # $width may be specified in a format acceptable by procedure
        # [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        # $width may also be specified in percent, ex. `50%`.
        #
        # Returns no value.
        #
        # See also: SetColumnsWidth

        set colId [$tableId -with { Columns } Item $col]
        if { [string match "*%" $width] } {
            scan $width "%f" percent
            $colId PreferredWidthType $Word::wdPreferredWidthPercent
            $colId PreferredWidth $percent
        } else {
            $colId Width [Cawt ValueToPoints $width]
        }
        Cawt Destroy $colId
    }

    proc SetColumnsWidth { tableId startCol endCol width } {
        # Set the width of a range of table columns.
        #
        # tableId  - Identifier of the Word table.
        # startCol - Range start column number. Column numbering starts with 1.
        # endCol   - Range end column number. Column numbering starts with 1.
        # width    - Column width.
        #
        # $width may be specified in a format acceptable by procedure
        # [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        # $width may also be specified in percent, ex. `50%`.
        #
        # Returns no value.
        #
        # See also: SetColumnWidth

        for { set c $startCol } { $c <= $endCol } { incr c } {
            SetColumnWidth $tableId $c $width
        }
    }

    proc SetColumnValues { tableId col valList { startRow 1 } { numVals 0 } } {
        # Insert column values into a Word table.
        #
        # tableId  - Identifier of the Word table.
        # col      - Column number. Column numbering starts with 1.
        # valList  - List of values to be inserted.
        # startRow - Row number of insertion start. Row numbering starts with 1.
        # numVals  - If negative or zero, all list values are inserted.
        #            If positive, $numVals rows are filled with the list values
        #            (starting at list index 0).
        #
        # Returns no value.
        #
        # See also: GetColumnValues SetRowValues SetCellValue

        set len [llength $valList]
        if { $numVals > 0 } {
            if { $numVals < $len } {
                set len $numVals
            }
        }
        set ind 0
        for { set r $startRow } { $r < [expr {$startRow + $len}] } { incr r } {
            SetCellValue $tableId $r $col [lindex $valList $ind]
            incr ind
        }
    }

    proc GetColumnValues { tableId col { startRow 1 } { numVals 0 } } {
        # Return column values of a Word table as a Tcl list.
        #
        # tableId  - Identifier of the Word table.
        # col      - Column number. Column numbering starts with 1.
        # startRow - Row number of start. Row numbering starts with 1.
        # numVals  - If negative or zero, all available column values are returned.
        #            If positive, only $numVals values of the column are returned.
        #
        # Returns the values of the specified column or column range as a Tcl list.
        #
        # See also: SetColumnValues GetRowValues GetCellValue

        if { $numVals <= 0 } {
            set len [GetNumRows $tableId]
        } else {
            set len $numVals
        }
        set valList [list]
        set row $startRow
        set ind 0
        while { $ind < $len } {
            set val [GetCellValue $tableId $row $col]
            if { $val eq "" } {
                set val2 [GetCellValue $tableId [expr {$row+1}] $col]
                if { $val2 eq "" } {
                    break
                }
            }
            lappend valList $val
            incr ind
            incr row
        }
        return $valList
    }

    proc GetHeaderText { docId { type $Word::wdHeaderFooterPrimary } } {
        # Get the text of the document header.
        #
        # docId - Identifier of the document.
        # type  - Value of enumeration type [Enum::WdHeaderFooterIndex].
        #
        # Returns the header text.
        #
        # See also: GetFooterText

        set headerType [Word GetEnum $type]
        set sections [$docId Sections]
        $sections -iterate section {
            set headers [$section Headers]
            set header  [$headers Item $headerType]
            set text    [$header -with { Range } Text]
            Cawt Destroy $header
            Cawt Destroy $headers
            break
        }
        Cawt Destroy $sections
        return  [Word::TrimString $text]
    }

    proc GetFooterText { docId { type $Word::wdHeaderFooterPrimary } } {
        # Get the text of the document footer.
        #
        # docId - Identifier of the document.
        # type  - Value of enumeration type [Enum::WdHeaderFooterIndex].
        #
        # Returns the footer text.
        #
        # See also: GetHeaderText

        set footerType [Word GetEnum $type]
        set sections [$docId Sections]
        $sections -iterate section {
            set footers [$section Footers]
            set footer  [$footers Item $footerType]
            set text    [$footer -with { Range } Text]
            Cawt Destroy $footer
            Cawt Destroy $footers
            break
        }
        Cawt Destroy $sections
        return  [Word::TrimString $text]
    }

    proc GetNumSubdocuments { docId } {
        # Return the number of subdocuments in a Word document.
        #
        # docId - Identifier of the document.
        #
        # Returns the number of subdocuments in the Word document.
        #
        # See also: GetSubdocumentPath ExpandSubdocuments DeleteSubdocumentLinks
        # GetNumCharacters GetNumColumns GetNumImages GetNumHyperlinks
        # GetNumPages GetNumRows GetNumTables

        return [$docId -with { Subdocuments } Count]
    }

    proc GetSubdocumentPath { docId index } {
        # Return the file path of a subdocument.
        #
        # docId - Identifier of the document.
        # index - Index of the subdocument. Indices start at 1.
        #
        # Returns the normalized path of the subdocument.
        #
        # See also: GetNumSubdocuments ExpandSubdocuments DeleteSubdocumentLinks

        set count [Word GetNumSubdocuments $docId]

        if { $index < 1 || $index > $count } {
            error "GetSubdocumentPath: Invalid index $index given."
        }

        set subDocId [$docId -with { Subdocuments } Item $index]
        set path [$subDocId Path]
        set name [$subDocId Name]
        Cawt Destroy $subDocId
        return [file normalize [file join $path $name]]
    }

    proc ExpandSubdocuments { docId { onOff true } } {
        # Expand all subdocuments in a Word document.
        #
        # docId - Identifier of the document.
        # onOff - Switch expansion on or off.
        #
        # Returns no value.
        #
        # See also: GetNumSubdocuments GetSubdocumentPath DeleteSubdocumentLinks

        variable wordVersion

        if { $wordVersion < 14.0 } {
            error "ExpandSubdocuments available only in Word 2010 or newer. Running [Word GetVersion $docId true]."
        }

        $docId -with { ActiveWindow ActivePane View } Type $::Word::wdOutlineView
        $docId -with { Subdocuments } Expanded [Cawt TclBool $onOff]
    }

    proc DeleteSubdocumentLinks { docId } {
        # Delete all subdocument links from a Word document.
        #
        # docId - Identifier of the document.
        #
        # Returns no value.
        #
        # See also: GetNumSubdocuments GetSubdocumentPath ExpandSubdocuments

        variable wordVersion

        if { $wordVersion < 14.0 } {
            error "DeleteSubdocumentLinks available only in Word 2010 or newer. Running [Word GetVersion $docId true]."
        }

        $docId -with { Subdocuments } Delete
    }

    proc GetCrossReferenceItems { docId refType } {
        # Get all cross reference items of a given type.
        #
        # docId   - Identifier of the document.
        # refType - Value of enumeration type [Enum::WdReferenceType].
        #
        # Returns the texts of the cross reference items as a list.
        #
        # See also: GetHeadingRanges

        set pureRefList [$docId GetCrossReferenceItems [Word GetEnum $refType]]
        # The cross reference items might contain whitespaces at the left.
        set refList [list]
        foreach ref $pureRefList {
            lappend refList [Word::TrimString $ref]
        }
        return $refList
    }

    proc GetHeadingRanges { docId level } {
        # Get the ranges of a specific heading level.
        #
        # docId - Identifier of the document.
        # level - Level(s) to retrieve. 
        #         The level(s) can be specified in the following ways:<br/>
        #         Value of enumeration type [Enum::WdOutlineLevel].<br/>
        #         A list of integer numbers between 1 and 9.<br/>
        #         Keyword `all` to get all levels.<br/>
        #
        # Returns the ranges and the corresponding level index
        # of the specified heading levels as a Tcl list.
        #
        # See also: GetCrossReferenceItems GetHeadingsAsDict

        set searchLevelList [list]
        if { $level eq "all" } {
            set searchLevelList [list 1 2 3 4 5 6 7 8 9]
        } else {
            set enumVal [Word GetEnum $level]
            if { $enumVal ne "" } {
                set searchLevelList [list $enumVal]
            } else {
                foreach lev $level {
                    lappend searchLevelList $lev
                }
            }
        }

        set rangeIdList    [list]
        set tmpRangeIdList [list]
        set headingRangeId [Word GetStartRange $docId]
        while { true } {
            set currentIndex [Word GetRangeStartIndex $headingRangeId]
            set headingRangeId [$headingRangeId GoTo $::Word::wdGoToHeading $::Word::wdGoToNext]
            if { [Word GetRangeStartIndex $headingRangeId] == $currentIndex } {
                # We haven't moved, so there are no more headings.
                Cawt Destroy $headingRangeId
                break
            }
            set paragraphId [$headingRangeId -with { Paragraphs } Item 1]
            set foundLevel [$paragraphId OutlineLevel]
            Cawt Destroy $paragraphId
            if { [lsearch -exact -integer $searchLevelList $foundLevel] >= 0 } {
                $headingRangeId Expand $::Word::wdParagraph
                lappend rangeIdList $headingRangeId
                lappend rangeIdList $foundLevel
            } else {
                lappend tmpRangeIdList $headingRangeId
            }
        }
        foreach rangeId $tmpRangeIdList {
            Cawt Destroy $rangeId
        }
        return $rangeIdList
    }
}
