# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Excel {

    namespace ensemble create

    namespace export ExcelFileToHtmlFile
    namespace export WorksheetToHtmlFile
    namespace export WriteHtmlFile

    proc _GetCellHoriAlign { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set align [Excel GetRangeHorizontalAlignment $cellId]
        Cawt Destroy $cellId
        if { $align == $Excel::xlHAlignRight } {
            return "right" 
        } elseif { $align == $Excel::xlHAlignCenter } {
            return "center"
        } elseif { $align == $Excel::xlHAlignJustify } {
            return "justify"
        } else {
            return "left"
        }
    }

    proc _GetCellVertAlign { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set align [Excel GetRangeVerticalAlignment $cellId]
        Cawt Destroy $cellId
        if { $align == $Excel::xlVAlignCenter } {
            return "middle" 
        } elseif { $align == $Excel::xlVAlignTop } {
            return "top" 
        } else {
            return "bottom" 
        }
    }

    proc _GetCellForegroundColor { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set rgb  [Excel GetRangeTextColor $cellId]
        Cawt Destroy $cellId

        return [format "#%02X%02X%02X" [lindex $rgb 0] [lindex $rgb 1] [lindex $rgb 2]]
    }

    proc _GetCellBackgroundColor { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set rgb  [Excel GetRangeFillColor $cellId]
        Cawt Destroy $cellId

        return [format "#%02X%02X%02X" [lindex $rgb 0] [lindex $rgb 1] [lindex $rgb 2]]
    }

    proc _GetCellFontBold { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set isBold [Excel GetRangeFontBold $cellId]
        Cawt Destroy $cellId

        return $isBold
    }

    proc _GetCellFontItalic { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set isItalic [Excel GetRangeFontItalic $cellId]
        Cawt Destroy $cellId

        return $isItalic
    }

    proc _GetCellFontUnderline { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set isUnderline [Excel GetRangeFontUnderline $cellId]
        Cawt Destroy $cellId

        return $isUnderline
    }

    proc _GetCellFontSize { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set fontSize [Excel GetRangeFontSize $cellId]
        Cawt Destroy $cellId

        return $fontSize
    }

    proc _GetCellFontName { worksheetId row col } {
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set fontName [Excel GetRangeFontName $cellId]
        Cawt Destroy $cellId

        return $fontName
    }

    proc _GetCellHyperlink { worksheetId row col } {
        set link ""
        set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
        set hyperlinksId [$cellId Hyperlinks]
        set numLinks [$hyperlinksId Count]
        if { $numLinks > 0 } {
            set hyperId [$hyperlinksId Item 1]
            set link [$hyperId Address]
            set sub  [$hyperId SubAddress]
            if { $sub ne "" } {
                set link [format "%s#%s" $link $sub]
            }
        }
        Cawt Destroy $cellId
        Cawt Destroy $hyperlinksId

        return $link
    }

    proc _GetRowBackgroundColor { worksheetId row numCols } {
        for { set col 1 } { $col <= $numCols } { incr col } {
            lappend rowColor [Excel::_GetCellBackgroundColor $worksheetId $row $col]
        }
        return $rowColor
    }

    proc _GetRowSpan { worksheetId row numCols } {
        set col 1
        while { $col <= $numCols } { 
            set cellId [Excel GetCellIdByIndex $worksheetId $row $col]
            if { [$cellId MergeCells] } {
                set spanCount [$cellId -with {MergeArea Cells} Count]
                if { $spanCount > 0 } {
                    lappend spanList $spanCount
                    for { set c 0 } { $c < [expr $spanCount -1] } { incr c } {
                        lappend spanList 0
                        incr col
                    }
                } else {
                    lappend spanList 1
                }
            } else {
                lappend spanList 1
            }
            Cawt Destroy $cellId
            incr col
        }
        return $spanList
    }

    proc _WriteTableBegin { fp } {
        puts $fp "<table border=\"1\">"
    }

    proc _WriteTableEnd { fp } {
        puts $fp "</table>"
    }

    proc _WriteRowBegin { fp { bgColor "" } } {
        set bgColorStr ""
        if { $bgColor ne "" } {
            set bgColorStr "style=\"background-color:$bgColor\""
        }
        puts $fp "  <tr $bgColorStr>"
    }

    proc _WriteRowEnd { fp } {
        puts $fp "  </tr>"
    }

    proc _WriteSimpleGenericTableRow { fp tag rowValues } {
        Excel::_WriteRowBegin $fp
        foreach val $rowValues {
            puts $fp "    <$tag>$val</$tag>"
        }
        Excel::_WriteRowEnd $fp
    }

    proc _WriteSimpleTableHeader { fp rowValues } {
        Excel::_WriteSimpleGenericTableRow $fp "th" $rowValues
    }

    proc _WriteSimpleTableRow { fp rowValues } {
        Excel::_WriteSimpleGenericTableRow $fp "td" $rowValues
    }

    proc _WriteTableCell { worksheetId row col fp { bgColor "" } { colspan 0 } { useTarget true } } {
        set styleStr ""
        set spanStr  ""
        set linkPre  ""
        set linkPost ""

        set val [Excel GetCellValue $worksheetId $row $col]
        if { $val ne "" } {
            set horiAlign  [Excel::_GetCellHoriAlign       $worksheetId $row $col]
            set vertAlign  [Excel::_GetCellVertAlign       $worksheetId $row $col]
            set fgColor    [Excel::_GetCellForegroundColor $worksheetId $row $col]
            set isBold     [Excel::_GetCellFontBold        $worksheetId $row $col]
            set isItalic   [Excel::_GetCellFontItalic      $worksheetId $row $col]
            set underline  [Excel::_GetCellFontUnderline   $worksheetId $row $col]
            set fontSize   [Excel::_GetCellFontSize        $worksheetId $row $col]
            set fontName   [Excel::_GetCellFontName        $worksheetId $row $col]
            set hyperlink  [Excel::_GetCellHyperlink       $worksheetId $row $col]

            set isUnderline false
            if { $underline != $Excel::xlUnderlineStyleNone } {
                set isUnderline true
            }
            set fontPercent [expr {int ($fontSize * 10.0)}]

            append styleStr "style=\" "

            append styleStr " color:$fgColor ; "
            append styleStr " text-align:$horiAlign ; "
            append styleStr " vertical-align:$vertAlign ; "
            append styleStr " font-size:${fontPercent}% ; "
            append styleStr " font-family:\'${fontName}\',monospace ; "

            if { $isBold } {
                append styleStr " font-weight:bold ; "
            }
            if { $isItalic } {
                append styleStr " font-style:italic ; "
            }
            if { $isUnderline } {
                append styleStr " text-decoration:underline ; "
            }

            if { $bgColor ne "" } {
                append styleStr " background-color:$bgColor ; "
            }
            append styleStr " \""

            if { $hyperlink ne "" } {
                if { $useTarget } {
                    set linkPre  "<a href=\"$hyperlink\" target=\"Cell_${row}_${col}\">"
                } else {
                    set linkPre  "<a href=\"$hyperlink\">"
                }
                set linkPost "</a>"
            }
        }

        if { $colspan > 1 } {
            set spanStr " colspan=\"$colspan\" "
        }
        puts $fp "    <td $spanStr $styleStr>${linkPre}${val}${linkPost}</td>"
    }

    proc _WriteTableRow { worksheetId row numCols fp bgColors spanList useTarget } {
        set uniqueBgColors [lsort -unique $bgColors]
        if { [llength $uniqueBgColors] == 1 } {
            set haveUniqueRowBgColor true
            set bgColors [lrepeat $numCols ""]
        } else {
            set haveUniqueRowBgColor false
        }

        if { $haveUniqueRowBgColor } {
            Excel::_WriteRowBegin $fp [lindex $uniqueBgColors 0]
        } else {
            Excel::_WriteRowBegin $fp
        }
        set col 1
        foreach bgColor $bgColors span $spanList {
            if { $span > 0 } {
                Excel::_WriteTableCell $worksheetId $row $col $fp $bgColor $span $useTarget
            }
            incr col
        }
        Excel::_WriteRowEnd $fp
    }

    proc WriteHtmlFile { matrixList htmlFileName { useHeader true } } {
        # Write the values of a matrix into a Html table file.
        #
        # matrixList    - Matrix with table data.
        # htmlFileName  - Name of the HTML file.
        # useHeader     - If set to true, use first row of the matrix as header of the
        #                 HTML table.
        #
        # See [SetMatrixValues] for the description of a matrix representation.
        #
        # Returns no value.
        #
        # See also: WorksheetToHtmlFile

        set catchVal [catch {open $htmlFileName w} fp]
        if { $catchVal != 0 } {
            error "Could not open file \"$htmlFileName\" for writing."
        }

        Excel::_WriteTableBegin $fp
        set curRow 1
        foreach rowList $matrixList {
            if { $useHeader && $curRow == 1 } {
                Excel::_WriteSimpleTableHeader $fp $rowList
            } else {
                Excel::_WriteSimpleTableRow $fp $rowList
            }
            incr curRow
        }
        Excel::_WriteTableEnd $fp
        close $fp
    }

    proc WorksheetToHtmlFile { worksheetId htmlFileName { useTarget true } } {
        # Write the values of a worksheet into a HTML table file.
        #
        # worksheetId  - Identifier of the worksheet.
        # htmlFileName - Name of the HTML file.
        # useTarget    - If set to true, generate a target attribute for hyperlinks.
        #                Otherwise, no target attribute for hyperlinks, i.e. link opens in same tab.
        #
        # The following attributes are exported to the HTML file:
        # * Font: Name, size, style (bold, italic, underline).
        # * Column span across a row.
        # * Text and background color.
        # * Horizontal and vertical text alignment.
        # * Hyperlinks.
        #
        # Returns no value.
        #
        # See also: GetMatrixValues ExcelFileToHtmlFile
        # WorksheetToMediaWikiFile WorksheetToWikitFile WorksheetToWordTable
        # WorksheetToMatlabFile WorksheetToRawImageFile WorksheetToTablelist

        set numRows [Excel GetLastUsedRow $worksheetId]
        set numCols [Excel GetLastUsedColumn $worksheetId]
        set startRow 1
        set catchVal [catch {open $htmlFileName w} fp]
        if { $catchVal != 0 } {
            error "Could not open file \"$htmlFileName\" for writing."
        }
        
        Excel::_WriteTableBegin $fp
        for { set row $startRow } { $row <= $numRows } { incr row } {
            set spanList  [Excel::_GetRowSpan            $worksheetId $row $numCols]
            set bgColors  [Excel::_GetRowBackgroundColor $worksheetId $row $numCols]
            Excel::_WriteTableRow $worksheetId $row $numCols $fp $bgColors $spanList $useTarget
        }
        Excel::_WriteTableEnd $fp
        close $fp
    }

    proc ExcelFileToHtmlFile { excelFileName htmlFileName args } {
        # Convert an Excel file to a HTML table file.
        #
        # excelFileName - Name of the Excel input file.
        # htmlFileName  - Name of the HTML output file.
        # args          - Options described below.
        #
        # -worksheet <int> - Set the worksheet name or index to convert. 
        #                    Default value: 0
        # -quit <bool>     - Set to true to quit the Excel instance after generation of output file.
        #                    Otherwise leave the Excel instance open after generation of output file.
        #                    Default value: true.
        # -target <bool>   - Set to true to generate a target attribute for hyperlinks.
        #                    Otherwise no target attribute for hyperlinks, i.e. link opens in same tab.
        #                    Default value: true.
        #
        # Note, that the Excel Workbook is opened in read-only mode.
        #
        # Returns the Excel application identifier, if `-quit` is false.
        # Otherwise no return value.
        #
        # See also: WorksheetToHtmlFile WriteHtmlFile MediaWikiFileToExcelFile WikitFileToExcelFile

        set opts [dict create \
            -worksheet 0 \
            -quit      true \
            -target    true \
        ]
        foreach { key value } $args {
            if { $value eq "" } {
                error "ExcelFileToHtmlFile: No value specified for key \"$key\""
            }
            if { [dict exists $opts $key] } {
                dict set opts $key $value
            } else {
                error "ExcelFileToHtmlFile: Unknown option \"$key\" specified"
            }
        }

        set worksheetNameOrIndex [dict get $opts "-worksheet"]

        set appId [Excel OpenNew true]
        set workbookId [Excel OpenWorkbook $appId $excelFileName -readonly true]
        if { [string is integer $worksheetNameOrIndex] } {
            set worksheetId [Excel GetWorksheetIdByIndex $workbookId [expr int($worksheetNameOrIndex)]]
        } else {
            set worksheetId [Excel GetWorksheetIdByName $workbookId $worksheetNameOrIndex]
        }
        Excel WorksheetToHtmlFile $worksheetId $htmlFileName [dict get $opts "-target"]
        if { [dict get $opts "-quit"] } {
            Excel Quit $appId
        } else {
            return $appId
        }
    }
}
