# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Word {

    namespace ensemble create

    namespace export AddImageTable
    namespace export CountWords
    namespace export DiffWordFiles
    namespace export FormatHeaderRow
    namespace export GetHeadingsAsDict
    namespace export GetHyperlinksAsDict
    namespace export GetMatrixValues
    namespace export PrintHeadingDict
    namespace export PrintHyperlinkDict
    namespace export SetHeaderRow
    namespace export SetHeadingFormat
    namespace export SetMatrixValues

    proc CountWords { docId args } {
        # Count words contained in a Word document.
        #
        # docId - Identifier of the document.
        # args  - Options described below.
        #
        # -sortmode <string>  - Sorting mode of output list.
        #                       Default: length.
        #                       Possible values: dictionary, length, increasing, decreasing.
        # -minlength <int>    - Only count words having more than minlength characters.
        #                       Default: No limit.
        # -maxlength <int>    - Only count words having less than maxlength characters.
        #                       Default: No limit.
        # -shownumbers <bool> - If set to false, only count words which are no numbers.
        #
        # This procedure is used in the CAWT application `WordAbbrCheck`
        # to get a list of words contained in a Word document.
        #
        # Returns a key-value list containing the found words and their
        # corresponding count.
        #
        # See also: ::Cawt::CountWords

        set rangeId [Word GetStartRange $docId]
        Word SetRangeStartIndex $rangeId "begin"
        Word SetRangeEndIndex   $rangeId "end"

        set docText [$rangeId Text]

        set wordCountList [Cawt CountWords $docText {*}$args]
        Cawt Destroy $rangeId
        return $wordCountList
    }

    proc GetHyperlinksAsDict { docId args } {
        # Get a dictionary with hyperlinks of a document.
        #
        # docId - Identifier of the document.
        # args  - Options described below.
        #
        # -type <string> - Consider only hyperlinks of specified type.
        #                  Possible values: `internal`, `file`, `url`.
        #                  This option may be specified multiple times.
        #                  If this option is not specified, all hyperlinks
        #                  are returned.
        # -check <bool>  - Check hyperlinks for validity. Default: No check.
        # -valid <bool>  - If checking is enabled, return either valid or invalid links.
        #                  Default: Return all matching hyperlinks.
        # -file <string> - If checking is enabled, the full path of the Word document.
        #                  This option is only needed when checking relative
        #                  file links and the document is not saved yet.
        #                  If not specified, Word property `FullName` is used for
        #                  checking relative file links. If the property is
        #                  not set, the current working directory is used.
        #
        # Returns a dictionary containing the hyperlinks matching the search
        # criterias.
        #
        # The dictionary is structured as follows:
        #     Key:    Hyperlink number
        #     Values: address text type start end valid
        #
        # * `Key` is the link number formatted as "%06d" integer.
        # * `address` stores the address the link points to.
        # * `subaddress` stores the sub address the link points to.
        # * `text` stores the text displayed for the link.
        # * `type` stores the type of the link (`internal`, `file`, `url`).
        # * `start` stores the numerical start range of the link.
        # * `end` stores the numerical end range of the link.
        # * `valid` stores the validity of the link.
        #    0 for invalid link. 
        #    1 for valid link.
        #    -1 if the validity was not checked.
        #
        # Note:
        #  * This procedure can be called as a coroutine. It yields 
        #    every 10 hyperlinks processed. The yield return value 
        #    is the number of hyperlinks already processed.
        #
        # See also: SetHyperlink SetLinkToBookmark PrintHyperlinkDict GetBookmarkNames
        # GetNumHyperlinks ::Cawt::IsValidUrlAddress

        set useTypeList   [list]
        set checkLinks    false
        set useValidMode  -1
        set wordFileName  ""

        foreach { key value } $args {
            if { $value eq "" } {
                error "GetHyperlinksAsDict: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-type"  { lappend useTypeList $value }
                "-check" { set checkLinks      $value }
                "-valid" { if { $value } {
                               set useValidMode 1
                           } else {
                               set useValidMode 0
                           } 
                         }
                "-file"  { set wordFileName $value }
                default  { error "GetHyperlinksAsDict: Unknown option \"$key\" specified" }
            }
        }
        if { [llength $useTypeList] == 0 } {
            set useTypeList [list "internal" "file" "url"]
        }

        # Need to set the display of field codes off. (Alt-F9).
        # Otherwise the displayed text is not retrieved correctly.
        set fieldCodeFlag [$docId -with { ActiveWindow ActivePane View } ShowFieldCodes]
        $docId -with { ActiveWindow ActivePane View } ShowFieldCodes [Cawt TclBool false]

        if { [info coroutine] ne "" } {
            yield 0
        }

        set bookmarkList [list]
        if { $checkLinks } {
            if { [lsearch -exact $useTypeList "url"] >= 0 } {
                # Needed to check http and https links.
                package require http
                http::register https 443 [list ::twapi::tls_socket]
            }

            if { [lsearch -exact $useTypeList "internal"] >= 0 } {
                set bookmarkList [lsort -dictionary [Word GetBookmarkNames $docId -showhidden true]]
            }
        }

        set hyperlinks [$docId Hyperlinks]
        set countAdded 1
        set curLinkNum 0
        set linkDict [dict create]
        set numLinks [Word::GetNumHyperlinks $docId]

        # Using "$hyperlinks -iterate hyperlink" instead of
        # the for loop throws an error when running as a coroutine:
        # cannot yield: C stack busy
        for { set i 1 } { $i <= $numLinks } { incr i } {
            set hyperlink [$hyperlinks Item $i]
            set address    [$hyperlink Address]
            set subAddress [$hyperlink SubAddress]
            if { $address eq "" } {
                set address $subAddress
                set type "internal"
            } else {
                if { [string first "http" $address] == 0 } {
                    set type "url"
                } else {
                    set type "file"
                }
            }
            if { [lsearch -exact $useTypeList $type] >= 0 } {
                if { $checkLinks } {
                    set addLink false
                    set valid   0
                    if { $type eq "internal" } {
                        if { [lsearch -exact $bookmarkList $address] >= 0 } {
                            set valid 1
                        }
                        if { ( $useValidMode == -1 ) || \
                             ( $valid == 1 && $useValidMode == 1 ) || \
                             ( $valid == 0 && $useValidMode == 0 ) } {
                            set addLink true
                        }
                    } elseif { $type eq "file" } {
                        set fileName $address
                        if { [file pathtype $address] eq "relative" } {
                            if { $wordFileName eq "" } {
                                set fullName [$docId FullName]
                                if { [file exists $fullName] } {
                                    set path [file dirname $fullName]
                                } else {
                                    set path [pwd]
                                }
                            } else {
                                set path [file dirname $wordFileName]
                            }
                            set fileName [file join $path $address]
                        }
                        if { [file exists $fileName] } {
                            set valid 1
                        }
                        if { ( $useValidMode == -1 ) || \
                             ( $valid == 1 && $useValidMode == 1 ) || \
                             ( $valid == 0 && $useValidMode == 0 ) } {
                            set addLink true
                        }
                    } elseif { $type eq "url" } {
                        set foundInCache false
                        if { $subAddress eq "" } {
                            set catchVal [catch { \
                                http::geturl $address -validate true -strict false } token]
                        } else {
                            if { [info exists sUrlCache($address,$subAddress)] } {
                                set foundInCache true
                                set catchVal 0
                            } else {
                                set catchVal [catch { http::geturl $address } token]
                                if { $catchVal == 0 } {
                                    set htmlData [http::data $token]
                                    # Search for <a name="subAddress"> occurences.
                                    set exp {<[\s]*a[\s]+name=([^\s>]+)[\s]*>}
                                    set matchList [regexp -all -inline -nocase -- $exp $htmlData]
                                    set catchVal 1
                                    foreach { overall match } $matchList {
                                        set matchStr [string trim $match "\"\'"]
                                        set sUrlCache($address,$matchStr) 1
                                        if { $matchStr eq $subAddress } {
                                            set catchVal 0
                                        }
                                    }
                                }
                            }
                        }
                        if { $catchVal != 0 } {
                            set valid 0
                            if { ( $useValidMode == -1 ) || \
                                 ( $valid == 1 && $useValidMode == 1 ) || \
                                 ( $valid == 0 && $useValidMode == 0 ) } {
                                set addLink true
                            }
                        } else {
                            if { $foundInCache || [http::ncode $token] < 400 } {
                                set valid 1
                            }
                            if { ( $useValidMode == -1 ) || \
                                 ( $valid == 1 && $useValidMode == 1 ) || \
                                 ( $valid == 0 && $useValidMode == 0 ) } {
                                set addLink true
                            }
                        }
                        if { ! $foundInCache } {
                            http::cleanup $token
                        }
                    }
                } else {
                    set valid   -1
                    set addLink true
                }

                if { $addLink } {
                    set text    [$hyperlink TextToDisplay]
                    set rangeId [$hyperlink Range]
                    set startRange [Word GetRangeStartIndex $rangeId]
                    set endRange   [Word GetRangeEndIndex $rangeId]
                    if { $text eq "" } {
                        set text [$rangeId Text]
                    }
                    Cawt Destroy $rangeId

                    set key [format "%06d" $countAdded]
                    dict set linkDict $key address    $address
                    dict set linkDict $key subaddress $subAddress
                    dict set linkDict $key text       $text
                    dict set linkDict $key type       $type
                    dict set linkDict $key start      $startRange
                    dict set linkDict $key end        $endRange
                    dict set linkDict $key valid      $valid
                    incr countAdded
                }
            }
            Cawt Destroy $hyperlink
            incr curLinkNum
            if { $curLinkNum % 10 == 0 } {
                if { [info coroutine] ne "" } {
                    yield $curLinkNum
                }
            }
        }

        $docId -with { ActiveWindow ActivePane View } ShowFieldCodes $fieldCodeFlag
        Cawt Destroy $hyperlinks

        if { [info coroutine] ne "" } {
            yield $numLinks
        }

        return $linkDict
    }
    
    proc PrintHyperlinkDict { hyperlinkDict } {
        # Print the contents of a hyperlink dictionary onto stdout.
        #
        # hyperlinkDict - Dictionary as returned by GetHyperlinksAsDict
        #
        # Returns no value.
        #
        # See also: GetHyperlinksAsDict GetNumHyperlinks

        dict for { id info } $hyperlinkDict {
            puts "Hyperlink $id"
            dict with info {
                puts "  address   : $address"
                puts "  subaddress: $subaddress"
                puts "  text      : $text"
                puts "  type      : $type"
                puts "  start     : $start"
                puts "  end       : $end"
                puts "  valid     : $valid"
            }
        }
    }

    proc GetHeadingsAsDict { docId args } {
        # Get a dictionary with headings of a document.
        #
        # docId - Identifier of the document.
        # args  - Numbers between 1 and 9 specifying the heading levels to be retrieved.
        #         If empty, all heading levels from 1 to 9 are returned. 
        #
        # Returns a dictionary containing the headings matching the specified
        # level criterias.
        #
        # The dictionary is structured as follows:
        #     Key:    Heading number
        #     Values: text level start end
        #
        # * `Key` is a unique heading number formatted as "%06d" integer.
        # * `text` stores the heading text.
        # * `level` stores the heading level.
        # * `start` stores the numerical start range of the heading.
        # * `end` stores the numerical end range of the heading.
        #
        # Note:
        #  * This procedure can be called as a coroutine. It yields 
        #    every 10 headings processed. The yield return value 
        #    is the number of headings already processed.
        #
        # See also: GetHeadingRanges GetHyperlinksAsDict PrintHeadingDict GetBookmarkNames

        set levelList [list]
        if { [llength $args] == 0 } {
            set levelList [list 1 2 3 4 5 6 7 8 9]
        } else {
            foreach level $args {
                lappend levelList $level
            }
        }

        if { [info coroutine] ne "" } {
            yield 0
        }

        Cawt PushComObjects

        set countAdded 1
        set curHeadingNum 0
        set headingDict [dict create]

        foreach level $levelList {
            set styleName [format "wdStyleHeading%d" $level]

            set rangeId [Word GetStartRange $docId]
            set rangeId [Word ExtendRange $rangeId 0 end]

            while { 1 } {
                set myFind [$rangeId Find]
                $myFind Style [Word GetEnum $styleName]
                set retVal [$myFind -callnamedargs Execute Forward True]
                if { ! $retVal } {
                    break
                }
                set startRange [Word GetRangeStartIndex $rangeId]
                set endRange   [Word GetRangeEndIndex   $rangeId]
                set rangeText  [Word GetRangeText       $rangeId]

                set key [format "%06d" $countAdded]
                dict set headingDict $key text       $rangeText
                dict set headingDict $key level      $level
                dict set headingDict $key start      $startRange
                dict set headingDict $key end        $endRange
                incr countAdded

                Word CollapseRange $rangeId end

                incr curHeadingNum
                if { $curHeadingNum % 10 == 0 } {
                    if { [info coroutine] ne "" } {
                        yield $curHeadingNum
                    }
                }
            }
        }

        if { [info coroutine] ne "" } {
            yield $curHeadingNum
        }
        Cawt PopComObjects
        return $headingDict
    }

    proc PrintHeadingDict { headingDict } {
        # Print the contents of a heading dictionary onto stdout.
        #
        # headingDict - Dictionary as returned by GetHeadingAsDict
        #
        # Returns no value.
        #
        # See also: GetHyperlinksAsDict GetHeadingsAsDict

        dict for { id info } $headingDict {
            puts "Heading $id"
            dict with info {
                puts "  text : $text"
                puts "  level: $level"
                puts "  start: $start"
                puts "  end  : $end"
            }
        }
    }

    proc SetHeaderRow { tableId headerList { row 1 } { startCol 1 } } {
        # Insert row values into a Word table and format as a header row.
        #
        # tableId    - Identifier of the Word table.
        # headerList - List of values to be inserted as header.
        # row        - Row number. Row numbering starts with 1.
        # startCol   - Column number of insertion start. Column numbering starts with 1.
        #
        # Returns no value. If headerList is an empty list, an error is thrown.
        #
        # See also: SetRowValues FormatHeaderRow SetHeadingFormat

        set len [llength $headerList]
        Word SetRowValues $tableId $row $headerList $startCol $len
        Word FormatHeaderRow $tableId $row $startCol [expr {$startCol + $len -1}]
    }

    proc FormatHeaderRow { tableId row startCol endCol } {
        # Format a row as a header row.
        #
        # tableId  - Identifier of the Word table.
        # row      - Row number. Row numbering starts with 1.
        # startCol - Column number of formatting start. Column numbering starts with 1.
        # endCol   - Column number of formatting end. Column numbering starts with 1.
        #
        # The cell values of a header are formatted as bold text with both vertical and
        # horizontal centered alignment.
        #
        # Returns no value.
        #
        # See also: SetHeaderRow SetHeadingFormat

        set header [Word GetRowRange $tableId $row]
        Word SetRangeHorizontalAlignment $header $Word::wdAlignParagraphCenter
        Word SetRangeBackgroundColorByEnum $header $Word::wdColorGray25
        Word SetRangeFontBold $header
    }

    proc SetHeadingFormat { tableId onOff args } {
        # Set the HeadingFormat flag of table rows.
        #
        # tableId - Identifier of the Word table.
        # onOff   - Heading format flag.
        # args    - List of row numbers for which the heading format flag should be set.
        #           Row numbering starts with 1.
        #           If no row numbers are specified, row number 1 is used.
        #
        # If $onOff is set to true, the specified row is formatted as a table heading.
        # Rows formatted as table headings are repeated when a table spans more than one page.
        #
        # Returns no value.
        #
        # See also: SetHeaderRow FormatHeaderRow

        set numRows [Word GetNumRows $tableId]
        set flag 0
        if { $onOff } {
            # HeadingFormat is a Long and true must be specified as -1.
            set flag -1
        }
        if { [llength $args] == 0 } {
            set args [list 1]
        }
        foreach rowNum $args {
            if { [string is integer -strict $rowNum] && $rowNum >= 1 && $rowNum <= $numRows } {
                set rowId [$tableId -with { Rows } Item [expr int($rowNum)]]
                $rowId HeadingFormat $flag
                Cawt Destroy $rowId
            } else {
                error "SetHeadingFormat: Invalid row number $rowNum given."
            }
        }
    }

    proc SetMatrixValues { tableId matrixList { startRow 1 } { startCol 1 } } {
        # Insert matrix values into a Word table.
        #
        # tableId    - Identifier of the Word table.
        # matrixList - Matrix with table data.
        # startRow   - Row number of insertion start. Row numbering starts with 1.
        # startCol   - Column number of insertion start. Column numbering starts with 1.
        #
        # The matrix data must be stored as a list of lists. Each sub-list contains
        # the values for the row values.
        # The main (outer) list contains the rows of the matrix.
        #
        # Example:
        #     { { R1_C1 R1_C2 R1_C3 } { R2_C1 R2_C2 R2_C3 } }
        #
        # Returns no value.
        #
        # See also: GetMatrixValues

        set curRow $startRow
        foreach rowList $matrixList {
            Word SetRowValues $tableId $curRow $rowList $startCol
            incr curRow
        }
    }

    proc GetMatrixValues { tableId row1 col1 row2 col2 } {
        # Return table values as a matrix.
        #
        # tableId - Identifier of the Word table.
        # row1    - Row number of upper-left corner of the cell range.
        # col1    - Column number of upper-left corner of the cell range.
        # row2    - Row number of lower-right corner of the cell range.
        # col2    - Column number of lower-right corner of the cell range.
        #
        # Returns table values as a matrix.
        #
        # See also: SetMatrixValues

        set numVals [expr {$col2-$col1+1}]
        for { set row $row1 } { $row <= $row2 } { incr row } {
            lappend matrixList [Word GetRowValues $tableId $row $col1 $numVals]
        }
        return $matrixList
    }

    proc DiffWordFiles { wordBaseFile wordNewFile } {
        # Compare two Word files visually.
        #
        # wordBaseFile - Name of the base Word file.
        # wordNewFile  - Name of the new Word file.
        #
        # The two files are opened in Word's compare mode.
        #
        # Returns the identifier of the new Word application instance.
        #
        # See also: OpenNew

        variable wordVersion

        if { ! [file exists $wordBaseFile] } {
            error "Diff: Base file $wordBaseFile does not exists"
        }
        if { ! [file exists $wordNewFile] } {
            error "Diff: New file $wordNewFile does not exists"
        }
        if { [file normalize $wordBaseFile] eq [file normalize $wordNewFile] } {
            error "Diff: Base and new file are equal. Cannot compare."
        }

        set appId [Word OpenNew true]

        if { $wordVersion >= 12.0 } {
            # From Word 2007 and up, change order of files.
            set tmpFile $wordBaseFile
            set wordBaseFile $wordNewFile
            set wordNewFile $tmpFile
        }

        set newDocId [Word OpenDocument $appId $wordNewFile -readonly true]
        $newDocId -with { ActiveWindow View } Type $Word::wdNormalView

        $newDocId Compare [file nativename [file normalize $wordBaseFile]] \
                  "CawtDiff" $Word::wdCompareTargetNew true true

        $appId -with { ActiveDocument } Saved [Cawt TclBool true]
        Word Close $newDocId

        return $appId
    }

    proc AddImageTable { rangeId numCols imgList { captionList {} } } {
        # Add a new table and fill the cells with images.
        #
        # rangeId     - Identifier of the text range.
        # numCols     - Number of columns of the new table.
        # imgList     - List of image file names.  
        # captionList - List of caption texts.  
        # 
        # Returns the identifier of the new table.
        #
        # See also: AddTable InsertImage

        set numImgs  [llength $imgList]
        set numTexts [llength $captionList]

        if { $numCols <= 0 } {
            error "AddImageTable: Number of columns must be greater than zero."
        }

        set numRowsToAdd 1
        if { $numTexts > 0 } {
            incr numRowsToAdd
        }
        set tableId [Word AddTable $rangeId $numRowsToAdd $numCols]

        set curRow  1
        set curCol  1
        set curElem 0
        foreach img $imgList {
            set caption ""
            if { $curElem < $numTexts } {
                set caption [lindex $captionList $curElem]
            }
            if { $numTexts > 0 } {
                Word SetCellValue $tableId [expr { $curRow + 1}] $curCol $caption
            }
            set rangeId [Word GetCellRange $tableId $curRow $curCol]
            Word InsertImage $rangeId $img
            Cawt Destroy $rangeId
            incr curCol
            incr curElem
            if { $curCol > $numCols } {
                set curCol 1
                incr curRow $numRowsToAdd
                if { $curElem < $numImgs } {
                    Word AddRow $tableId end $numRowsToAdd
                }
            }
        }
        return $tableId
    }
}
