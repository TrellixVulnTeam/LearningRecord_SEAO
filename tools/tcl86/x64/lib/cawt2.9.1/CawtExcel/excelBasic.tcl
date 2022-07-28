# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Excel {

    namespace ensemble create

    namespace export AddWorkbook
    namespace export AddWorksheet
    namespace export ArrangeWindows
    namespace export Close
    namespace export ColumnCharToInt
    namespace export ColumnIntToChar
    namespace export CopyColumn
    namespace export CopyRange
    namespace export CopyWorksheet
    namespace export CopyWorksheetAfter
    namespace export CopyWorksheetBefore
    namespace export CreateRangeString
    namespace export DeleteColumn
    namespace export DeleteRow
    namespace export DeleteWorksheet
    namespace export DeleteWorksheetByIndex
    namespace export DuplicateColumn
    namespace export DuplicateRow
    namespace export FreezePanes
    namespace export GetActiveWorkbook
    namespace export GetCellComment
    namespace export GetCellIdByIndex
    namespace export GetCellRange
    namespace export GetCellValue
    namespace export GetCellValueA1
    namespace export GetCellsId
    namespace export GetColumnNumber
    namespace export GetColumnRange
    namespace export GetColumnValues
    namespace export GetCurrencyFormat
    namespace export GetDecimalSeparator
    namespace export GetExtString
    namespace export GetFirstUsedColumn
    namespace export GetFirstUsedRow
    namespace export GetFloatSeparator
    namespace export GetHiddenColumns
    namespace export GetHiddenRows
    namespace export GetLangNumberFormat
    namespace export GetLastUsedColumn
    namespace export GetLastUsedRow
    namespace export GetMatrixValues
    namespace export GetMaxColumns
    namespace export GetMaxRows
    namespace export GetNamedRange
    namespace export GetNamedRangeNames
    namespace export GetNumberFormat
    namespace export GetNumColumns
    namespace export GetNumRows
    namespace export GetNumStyles
    namespace export GetNumUsedColumns
    namespace export GetNumUsedRows
    namespace export GetNumWorksheets
    namespace export GetRangeAsIndex
    namespace export GetRangeAsString
    namespace export GetRangeCharacters
    namespace export GetRangeFillColor
    namespace export GetRangeFontAttributes
    namespace export GetRangeFontBold
    namespace export GetRangeFontItalic
    namespace export GetRangeFontName
    namespace export GetRangeFontSize
    namespace export GetRangeFontSubscript
    namespace export GetRangeFontSuperscript
    namespace export GetRangeFontUnderline
    namespace export GetRangeFormat
    namespace export GetRangeHorizontalAlignment
    namespace export GetRangeTextColor
    namespace export GetRangeValues
    namespace export GetRangeVerticalAlignment
    namespace export GetRangeWrapText
    namespace export GetRowValues
    namespace export GetStyleId
    namespace export GetThousandsSeparator
    namespace export GetVersion
    namespace export GetWorkbookIdByName
    namespace export GetWorkbookName
    namespace export GetWorksheetAsMatrix
    namespace export GetWorksheetIdByIndex
    namespace export GetWorksheetIdByName
    namespace export GetWorksheetIndexByName
    namespace export GetWorksheetName
    namespace export HideColumn
    namespace export HideRow
    namespace export Import
    namespace export InsertColumn
    namespace export InsertImage
    namespace export InsertRow
    namespace export IsWorkbookId
    namespace export IsWorkbookOpen
    namespace export IsWorkbookProtected
    namespace export IsWorksheetEmpty
    namespace export IsWorksheetProtected
    namespace export IsWorksheetVisible
    namespace export MapWorksheetName
    namespace export Open
    namespace export OpenNew
    namespace export OpenWorkbook
    namespace export Quit
    namespace export SaveAs
    namespace export SaveAsCsv
    namespace export ScaleImage
    namespace export ScreenUpdate
    namespace export SelectAll
    namespace export SelectCellByIndex
    namespace export SelectRangeByIndex
    namespace export SelectRangeByString
    namespace export SetCellValue
    namespace export SetColumnValues
    namespace export SetColumnWidth
    namespace export SetColumnsWidth
    namespace export SetCommentDisplayMode
    namespace export SetCommentSize
    namespace export SetHyperlink
    namespace export SetHyperlinkToCell
    namespace export SetHyperlinkToFile
    namespace export SetLinkToCell
    namespace export SetMatrixValues
    namespace export SetNamedRange
    namespace export SetRangeBorder
    namespace export SetRangeBorders
    namespace export SetRangeComment
    namespace export SetRangeFillColor
    namespace export SetRangeFontAttributes
    namespace export SetRangeFontBold
    namespace export SetRangeFontItalic
    namespace export SetRangeFontName
    namespace export SetRangeFontSize
    namespace export SetRangeFontSubscript
    namespace export SetRangeFontSuperscript
    namespace export SetRangeFontUnderline
    namespace export SetRangeFormat
    namespace export SetRangeHorizontalAlignment
    namespace export SetRangeMergeCells
    namespace export SetRangeTextColor
    namespace export SetRangeTooltip
    namespace export SetRangeValues
    namespace export SetRangeVerticalAlignment
    namespace export SetRangeWrapText
    namespace export SetRowHeight
    namespace export SetRowValues
    namespace export SetRowsHeight
    namespace export SetWindowState
    namespace export SetWorksheetFooter
    namespace export SetWorksheetHeader
    namespace export SetWorksheetFitToPages
    namespace export SetWorksheetName
    namespace export SetWorksheetOrientation
    namespace export SetWorksheetPrintOptions
    namespace export SetWorksheetPaperSize
    namespace export SetWorksheetTabColor
    namespace export SetWorksheetMargins
    namespace export SetWorksheetZoom
    namespace export ShowAlerts
    namespace export ShowCellByIndex
    namespace export ShowWorksheet
    namespace export ToggleAutoFilter
    namespace export UnhideWorksheet
    namespace export Visible

    variable excelVersion     "0.0"
    variable excelAppName     "Excel.Application"
    variable decimalSeparator ""

    variable _ruff_preamble {
        The `Excel` namespace provides commands to control Microsoft Excel.
    }

    proc _setFloatSeparator { appId } {
        variable excelVersion
        variable decimalSeparator

        # Method DecimalSeparator is only available in Excel 2003 and up.
        if { $excelVersion >= 11.0 } {
            set decimalSeparator [$appId DecimalSeparator]
        } else {
            # Set variable decimalSeparator to ",", if using German versions
            # of Excel older than 2003.
            # Note, that these older versions are not supported anymore.
            set decimalSeparator "."
            # set decimalSeparator ","
        }
    }

    proc GetFloatSeparator {} {
        # Obsolete: Replaced with [GetDecimalSeparator] in version 2.1.0
        #
        # Only valid, after a call of [Open] or [OpenNew].
        # 
        # Note, that this procedure has been superseeded with [GetDecimalSeparator] in version 2.1.0.
        # Only use it, if using an Excel version older than 2007.
        #
        # See also: GetVersion GetDecimalSeparator GetThousandsSeparator

        variable decimalSeparator

        return $decimalSeparator
    }

    proc GetDecimalSeparator { appId } {
        # Return the decimal separator used by Excel.
        #
        # appId - Identifier of the Excel instance.
        #
        # Returns the decimal separator used by Excel.
        #
        # See also: GetVersion GetThousandsSeparator

        return [$appId DecimalSeparator]
    }

    proc GetThousandsSeparator { appId } {
        # Return the thousands separator used by Excel.
        #
        # appId - Identifier of the Excel instance.
        #
        # Returns the thousands separator used by Excel.
        #
        # See also: GetVersion GetDecimalSeparator

        return [$appId ThousandsSeparator]
    }

    proc GetLangNumberFormat { pre post { floatSep "" } } {
        # Obsolete: Replaced with [GetNumberFormat] in version 2.1.0
        #
        # pre      - Number of digits before the decimal point.
        # post     - Number of digits after the decimal point.
        # floatSep - Specify the floating point separator character.
        #
        # The number of digits is specified as a string containing as
        # many zeros as wanted digits.
        # If no floating point separator is specified or the empty string, the
        # floating point separator of Excel is used.
        #
        # Example: 
        #     [GetLangNumberFormat "0" "0000"] will return the Excel format string
        #     to show floating point values with 4 digits after the decimal point.
        #
        # See also: SetRangeFormat GetNumberFormat

        if { $floatSep eq "" } {
            set floatSep [Excel GetFloatSeparator]
        }
        return [format "%s%s%s" $pre $floatSep $post]
    }

    proc GetNumberFormat { appId pre post { floatSep "" } } {
        # Return an Excel number format string.
        #
        # appId    - Identifier of the Excel instance.
        # pre      - Number of digits before the decimal point.
        # post     - Number of digits after the decimal point.
        # floatSep - Specify the floating point separator character.
        #
        # The number of digits is specified as a string containing as
        # many zeros as wanted digits.
        # If no floating point separator is specified or the empty string, the
        # floating point separator of Excel is used.
        #
        # Example:
        #     [GetNumberFormat "0" "0000"] will return the Excel format string
        #     to show floating point values with 4 digits after the decimal point.
        #
        # Returns the corresponding Excel number format string.
        #
        # See also: SetRangeFormat GetCurrencyFormat

        if { $floatSep eq "" } {
            set floatSep [Excel GetDecimalSeparator $appId]
        }
        return [format "%s%s%s" $pre $floatSep $post]
    }

    proc GetCurrencyFormat { appId currency { pre "0" } { post "00" } { floatSep "" } } {
        # Return an Excel number format string for currencies.
        #
        # appId    - Identifier of the Excel instance.
        # currency - String identifying the currency symbol.
        # pre      - Number of digits before the decimal point.
        # post     - Number of digits after the decimal point.
        # floatSep - Specify the floating point separator character.
        #
        # The currency may be specified either by using one of the predefined names
        # (Dollar, Euro, Pound, Yen, DM) or by specifying an Unicode character.
        #
        # Example:
        #      [GetCurrencyFormat "\u20B0" "0" "00"] will return the Excel format string
        #      to show floating point values with 2 digits after the decimal point
        #      and a German Penny Sign as currency symbol.
        #
        # Returns the corresponding Excel number format string for currencies.
        #
        # See also: SetRangeFormat GetNumberFormat

        set numberFormat [Excel GetNumberFormat $appId $pre $post $floatSep]
        switch -exact -nocase -- $currency {
            "Dollar" { append numberFormat " \\\u0024" }
            "Euro"   { append numberFormat " \\\u20AC" }
            "Pound"  { append numberFormat " \\\u00A3" }
            "Yen"    { append numberFormat " \\\u00A5" }
            "DM"     { append numberFormat " \\D\\M" }
            default  { append numberFormat " \\$currency" }
        }
        return $numberFormat
    }

    proc ColumnCharToInt { colChar } {
        # Return an Excel column string as a column number.
        #
        # colChar - Column string.
        #
        # Example: 
        #     [Excel ColumnCharToInt A] returns 1.
        #     [Excel ColumnCharToInt Z] returns 26.
        #
        # Returns the corresponding column number.
        #
        # See also: GetColumnNumber ColumnIntToChar

        set abc {- A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
        set int 0
        foreach char [split $colChar ""] {
            set int [expr {$int*26 + [lsearch $abc $char]}]
        }
        return $int
    }

    proc GetColumnNumber { colStrOrInt } {
        # Return an Excel column string or number as a column number.
        #
        # colStrOrInt - Column string.
        #
        # Returns the corresponding column number.
        #
        # See also: ColumnCharToInt

        if { [string is integer $colStrOrInt] } {
            return [expr int($colStrOrInt)]
        } else {
            return [Excel ColumnCharToInt $colStrOrInt]
        }
    }

    proc ColumnIntToChar { col } {
        # Return a column number as an Excel column string.
        #
        # col - Column number.
        #
        # Example:
        #     [Excel ColumnIntToChar 1]  returns "A".
        #     [Excel ColumnIntToChar 26] returns "Z".
        #
        # Returns the corresponding column string.
        #
        # See also: ColumnCharToInt

        if { $col <= 0 } {
            error "Column number $col is invalid."
        }
        set dividend $col
        set columnName ""
        while { $dividend > 0 } {
            set modulo [expr { ($dividend - 1) % 26 } ]
            set columnName [format "%c${columnName}" [expr { 65 + $modulo} ] ]
            set dividend [expr { ($dividend - $modulo) / 26 } ]
        }
        return $columnName
    }

    proc GetCellRange { row1 col1 row2 col2 } {
        # Return a numeric cell range as an Excel range string in A1 notation.
        #
        # row1 - Row number of upper-left corner of the cell range.
        # col1 - Column number of upper-left corner of the cell range.
        # row2 - Row number of lower-right corner of the cell range.
        # col2 - Column number of lower-right corner of the cell range.
        #
        # Example:
        #     [GetCellRange 1 2  5 7] returns string "B1:G5".
        #
        # Returns the numeric cell range as an Excel range string in A1 notation.
        #
        # See also: GetColumnRange

        set range [format "%s%d:%s%d" \
                   [Excel ColumnIntToChar $col1] $row1 \
                   [Excel ColumnIntToChar $col2] $row2]
        return $range
    }

    proc GetColumnRange { col1 col2 } {
        # Return a numeric column range as an Excel range string.
        #
        # col1 - Column number of the left-most column.
        # col2 - Column number of the right-most column.
        #
        # Example: 
        #     [GetColumnRange 2 7] returns string "B:G".
        #
        # Returns the numeric column range as an Excel range string.
        #
        # See also: GetCellRange

        set range [format "%s:%s" \
                   [Excel ColumnIntToChar $col1] \
                   [Excel ColumnIntToChar $col2]]
        return $range
    }

    proc GetMaxRows { appId } {
        # Return the maximum number of rows of an Excel table.
        #
        # appId - Identifier of the Excel instance.
        #
        # Returns the maximum number of rows of an Excel table.
        #
        # See also: GetNumRows

        # appId is only needed, so we are sure, that excelVersion is initialized.

        variable excelVersion

        if { $excelVersion < 12.0 } {
            return 65536
        } else {
            return 1048576
        }
    }

    proc GetNumRows { rangeId } {
        # Return the number of rows of a cell range.
        #
        # rangeId - Identifier of a range, cells collection or a worksheet.
        #
        # If specifying a worksheetId or cellsId, the maximum number of rows
        # of a worksheet will be returned.
        # The maximum number of rows is 65.536 for Excel versions before 2007.
        # Since 2007 the maximum number of rows is 1.048.576.
        #
        # Returns the number of rows of a cell range.
        #
        # See also: GetMaxRows GetNumUsedRows GetFirstUsedRow GetLastUsedRow GetNumColumns

        return [$rangeId -with { Rows } Count]
    }

    proc GetNumUsedRows { worksheetId } {
        # Return the number of used rows of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Note, that this procedure returns 1, even if the worksheet is empty.
        # Use IsWorksheetEmpty to determine, if a worksheet is totally empty.
        #
        # Returns the number of used rows of a worksheet.
        #
        # See also: GetNumRows GetFirstUsedRow GetLastUsedRow GetNumUsedColumns

        return [$worksheetId -with { UsedRange Rows } Count]
    }

    proc GetFirstUsedRow { worksheetId } {
        # Return the index of the first used row of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the index of the first used row of a worksheet.
        #
        # See also: GetNumRows GetNumUsedRows GetLastUsedRow GetNumUsedColumns

        return [$worksheetId -with { UsedRange } Row]
    }

    proc GetLastUsedRow { worksheetId } {
        # Return the index of the last used row of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the index of the last used row of a worksheet.
        #
        # See also: GetNumRows GetNumUsedRows GetFirstUsedRow GetNumUsedColumns

        return [expr { [Excel GetFirstUsedRow $worksheetId] + \
                       [Excel GetNumUsedRows $worksheetId] - 1 }]
    }

    proc GetMaxColumns { appId } {
        # Return the maximum number of columns of an Excel table.
        #
        # appId - Identifier of the Excel instance.
        #
        # Returns the maximum number of columns of an Excel table.
        #
        # See also: GetNumColumns

        # appId is only needed, so we are sure, that excelVersion is initialized.

        variable excelVersion

        if { $excelVersion < 12.0 } {
            return 256
        } else {
            return 16384
        }
    }

    proc GetNumColumns { rangeId } {
        # Return the number of columns of a cell range.
        #
        # rangeId - Identifier of a range, cells collection or a worksheet.
        #
        # If specifying a $worksheetId or $cellsId, the maximum number of columns
        # of a worksheet will be returned.
        # The maximum number of columns is 256 for Excel versions before 2007.
        # Since 2007 the maximum number of columns is 16.384.
        #
        # Returns the number of columns of a cell range.
        #
        # See also: GetMaxColumns GetNumUsedColumns GetFirstUsedColumn GetLastUsedColumn GetNumRows

        return [$rangeId -with { Columns } Count]
    }

    proc GetNumUsedColumns { worksheetId } {
        # Return the number of used columns of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Note, that this procedure returns 1, even if the worksheet is empty.
        # Use [IsWorksheetEmpty] to determine, if a worksheet is totally empty.
        #
        # Returns the number of used columns of a worksheet.
        #
        # See also: GetNumColumns GetFirstUsedColumn GetLastUsedColumn GetNumUsedRows

        return [$worksheetId -with { UsedRange Columns } Count]
    }

    proc GetFirstUsedColumn { worksheetId } {
        # Return the index of the first used column of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the index of the first used column of a worksheet.
        #
        # See also: GetNumColumns GetNumUsedColumns GetLastUsedColumn GetNumUsedRows

        return [$worksheetId -with { UsedRange } Column]
    }

    proc GetLastUsedColumn { worksheetId } {
        # Return the index of the last used column of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the index of the last used column of a worksheet.
        #
        # See also: GetNumColumns GetNumUsedColumns GetFirstUsedColumn GetNumUsedRows

        return [expr { [Excel GetFirstUsedColumn $worksheetId] + \
                       [Excel GetNumUsedColumns $worksheetId] - 1 }]
    }

    proc GetRangeAsString { rangeId } {
        # Get address of a cell range as Excel range string in A1 notation.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns address of a cell range as Excel range string in A1 notation.
        #
        # See also: SelectRangeByString GetCellRange

        set rangeStr [string map { "$" "" } [$rangeId Address]]
        return $rangeStr
    }

    proc GetRangeAsIndex { rangeId } {
        # Get address of a cell range as list of row/column indices.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns address of a cell range as a 2 or 4 element list of integers:
        #
        # If the range represents a single cell, the list consists of 2 elements,
        # representing the row and column index of the cell.
        #
        # If the range represents more than one cell, the list consists of 4 elements.
        # The first two elements represent the row and column indices of the top-left cell of the range.
        # The last two elements represent the row and column indices of the bottom-right cell of the range.
        #
        # See also: SelectRangeByIndex GetCellRange

        set rangeStr [Excel GetRangeAsString $rangeId]
        if { [string first ":" $rangeStr] > 0 } {
            regexp {([[:alpha:]]+)([[:digit:]]+):([[:alpha:]]+)([[:digit:]]+)} $rangeStr -> colStr1 row1 colStr2 row2
            set col1 [Excel ColumnCharToInt $colStr1]
            set col2 [Excel ColumnCharToInt $colStr2]
            return [list $row1 $col1 $row2 $col2]
        } else {
            regexp {([[:alpha:]]+)([[:digit:]]+)} $rangeStr -> colStr row
            set col [Excel ColumnCharToInt $colStr]
            return [list $row $col]
        }
    }

    proc CreateRangeString { args } {
        # Create a range string in A1 notation.
        #
        # args - List of quadruples specifying cell ranges.
        #
        # The first two elements of each quadruple represent the row and column indices of the top-left cell of each range.
        # The last two elements of each quadruple represent the row and column indices of the bottom-right cell of the range.
        #
        # Example:
        #      CreateRangeString 1 1 2 3  4 2 6 3 returns A1:C2;B4:C6
        #
        # Returns range string in A1 notation.
        #
        # See also: SelectRangeByIndex SelectRangeByString

        set numEntries [llength $args]
        if { $numEntries % 4 != 0 } {
            error "CreateRangeString: Number of parameters must be divisible by four."
        }
        set numRanges [expr { $numEntries / 4 }]
        set ind 0
        foreach { row1 col1 row2 col2 } $args {
            set rangeStr [Excel GetCellRange $row1 $col1 $row2 $col2]
            append extendedRangeStr $rangeStr
            if { $ind != $numRanges-1 } {
                append extendedRangeStr ";"
            }
            incr ind
        }
        return $extendedRangeStr
    }

    proc SelectRangeByString { worksheetId rangeStr { visSel false } } {
        # Select a range by specifying an Excel range string in A1 notation.
        #
        # worksheetId - Identifier of the worksheet.
        # rangeStr    - String specifying a cell range, ex. `A8:C10`.
        # visSel      - If set to true, see the selection in the user interface.
        #               Otherwise the selection is not visible.
        #
        # Returns the range identifier of the cell range.
        #
        # See also: SelectRangeByIndex GetCellRange

        set cellsId [Excel GetCellsId $worksheetId]
        set rangeId [$cellsId Range $rangeStr]
        if { $visSel } {
            $rangeId Select
        }
        Cawt Destroy $cellsId
        return $rangeId
    }

    proc SelectRangeByIndex { worksheetId row1 col1 row2 col2 { visSel false } } {
        # Select a range by specifying a numeric cell range.
        #
        # worksheetId - Identifier of the worksheet.
        # row1        - Row number of upper-left corner of the cell range.
        # col1        - Column number of upper-left corner of the cell range.
        # row2        - Row number of lower-right corner of the cell range.
        # col2        - Column number of lower-right corner of the cell range.
        # visSel      - If set to true, see the selection in the user interface.
        #               Otherwise the selection is not visible.
        #
        # Returns the range identifier of the cell range.
        #
        # See also: SelectRangeByString SelectCellByIndex GetCellRange

        set rangeStr [Excel GetCellRange $row1 $col1 $row2 $col2]
        return [Excel SelectRangeByString $worksheetId $rangeStr $visSel]
    }

    proc SelectAll { worksheetId } {
        # Select all cells of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the cells collection of the selected cells.
        #
        # See also: CopyWorksheet

        set appId [Office GetApplicationId $worksheetId]
        set cellsId [$appId Cells]
        Cawt Destroy $appId
        return $cellsId
    }

    proc GetRangeCharacters { rangeId { start 1 } { length -1 } } {
        # Return characters of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # start   - Start of the character range.
        # length  - The number of characters after start.
        #
        # Returns all or a range of characters of a cell range.
        # If no optional parameters are specified, all characters of the cell range are
        # returned.
        #
        # See also: SelectRangeByIndex SelectRangeByString

        if { $length < 0 } {
            return [$rangeId Characters $start]
        } else {
            return [$rangeId Characters $start $length]
        }
    }

    proc GetRangeFontAttributes { rangeId args } {
        # Get the font attibutes of a cell or character range.
        #
        # rangeId - Identifier of the cell range.
        # args    - Options described below.
        #
        # -bold          - Boolean.
        # -fontstyle     - Font stye as string.
        # -italic        - Boolean.
        # -name          - Font name as string.
        # -outlinefont   - Boolean.
        # -size          - Font size in points.
        # -shadow        - Boolean.
        # -strikethrough - Boolean.
        # -subscript     - Boolean.
        # -superscript   - Boolean.
        # -underline     - Enumeration of type [Enum::XlUnderlineStyle]
        # -themecolor    - Enumeration of type [Enum::XlThemeColor].
        # -themefont     - Enumeration of type [Enum::XlThemeFont].
        # -tintandshade  - Floating point number from -1 (darkest) to 1 (lightest). Zero is neutral.
        #
        # Example:
        #     lassign [GetRangeFontAttributes $rangeId -name -size] name size
        #     returns the font name and the font size.
        #
        # Returns the specified font attributes as a list.
        #
        # See also: SetRangeFontAttributes SelectRangeByIndex
        # GetRangeFontBold GetRangeFontItalic GetRangeFontName GetRangeFontSize
        # GetRangeFontSubscript GetRangeFontSuperscript GetRangeFontUnderline

        set fontId [$rangeId Font]
        set valList [list]
        foreach key $args {
            switch -exact -nocase -- $key {
                "-bold"          { lappend valList [$fontId Bold] }
                "-fontstyle"     { lappend valList [$fontId FontStyle] }
                "-italic"        { lappend valList [$fontId Italic] }
                "-name"          { lappend valList [$fontId Name] }
                "-outlinefont"   { lappend valList [$fontId OutlineFont] }
                "-size"          { lappend valList [$fontId Size] }
                "-shadow"        { lappend valList [$fontId Shadow] }
                "-strikethrough" { lappend valList [$fontId Strikethrough] }
                "-subscript"     { lappend valList [$fontId Subscript] }
                "-superscript"   { lappend valList [$fontId Superscript] }
                "-underline"     { lappend valList [$fontId Underline] }
                "-themecolor"    { lappend valList [$fontId ThemeColor] }
                "-themefont"     { lappend valList [$fontId ThemeFont] }
                "-tintandshade"  { lappend valList [$fontId TintAndShade] }
                default          { error "GetRangeFontAttributes: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $fontId
        return $valList
    }

    proc SetRangeFontAttributes { rangeId args } {
        # Set the font attibutes of a cell or character range.
        #
        # rangeId - Identifier of the cell range.
        # args    - Options described below.
        #
        # -bold <bool>          - Switch attribute on or off.
        # -fontstyle <string>   - Font style as string.
        # -italic <bool>        - Switch attribute on or off.
        # -name <string>        - Font name as string.
        # -outlinefont <bool>   - Switch attribute on or off.
        # -size <size>          - Font size in points.
        # -shadow <bool>        - Switch attribute on or off.
        # -strikethrough <bool> - Switch attribute on or off.
        # -subscript <bool>     - Switch attribute on or off.
        # -superscript <bool>   - Switch attribute on or off.
        # -underline <enum>     - Enumeration of type [Enum::XlUnderlineStyle]
        # -themecolor <enum>    - Enumeration of type [Enum::XlThemeColor].
        # -themefont <enum>     - Enumeration of type [Enum::XlThemeFont].
        # -tintandshade <float> - Floating point number from -1 (darkest) to 1 (lightest). Zero is neutral.
        #
        # The size value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Example:
        #     SetRangeFontAttributes $rangeId -size 2c -bold true
        #     sets the font size to 2 centimeters and the enables the Bold attribute.
        #
        # Returns no value.
        #
        # See also: GetRangeFontAttributes SelectRangeByIndex
        # SetRangeFontBold SetRangeFontItalic SetRangeFontName SetRangeFontSize
        # SetRangeFontSubscript SetRangeFontSuperscript SetRangeFontUnderline

        set fontId [$rangeId Font]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetRangeFontAttributes: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-bold"          { $fontId Bold [Cawt TclBool $value] }
                "-fontstyle"     { $fontId FontStyle $value }
                "-italic"        { $fontId Italic [Cawt TclBool $value] }
                "-name"          { $fontId Name $value }
                "-outlinefont"   { $fontId OutlineFont [Cawt TclBool $value] }
                "-size"          { $fontId Size [Cawt ValueToPoints $value] }
                "-shadow"        { $fontId Shadow [Cawt TclBool $value] }
                "-strikethrough" { $fontId Strikethrough [Cawt TclBool $value] }
                "-subscript"     { $fontId Subscript [Cawt TclBool $value] }
                "-superscript"   { $fontId Superscript [Cawt TclBool $value] }
                "-underline"     { $fontId Underline [Excel GetEnum $value] }
                "-themecolor"    { $fontId ThemeColor [Excel GetEnum $value] }
                "-themefont"     { $fontId ThemeFont [Excel GetEnum $value] }
                "-tintandshade"  { $fontId TintAndShade [expr double( $value )] }
                default          { error "SetRangeFontAttributes: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $fontId
    }

    proc GetRangeFontName { rangeId } {
        # Get the font name of a cell or character range.
        #
        # rangeId  - Identifier of the cell range.
        #
        # Returns the font name in specified cell range as a string.
        #
        # See also: SetRangeFontName SelectRangeByIndex GetRangeFontAttributes

        return [$rangeId -with { Font } Name]
    }

    proc SetRangeFontName { rangeId fontName } {
        # Set the font name of a cell or character range.
        #
        # rangeId  - Identifier of the cell range.
        # fontName - Name of the font as a string.
        #
        # Returns no value.
        #
        # See also: GetRangeFontName SelectRangeByIndex SetRangeFontAttributes

        $rangeId -with { Font } Name $fontName
    }

    proc GetRangeFontSubscript { rangeId } {
        # Get the subscript font style of a cell or character range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns true, if the font in specified cell range has the subscript flag set.
        #
        # See also: SetRangeFontSubscript SelectRangeByIndex GetRangeFontAttributes

        return [$rangeId -with { Font } Subscript]
    }

    proc SetRangeFontSubscript { rangeId { onOff true } } {
        # Set the subscript font style of a cell or character range.
        #
        # rangeId - Identifier of the cell range.
        # onOff   - If set to true, set subscript style on.
        #           Otherwise set subscript style off.
        #
        # Returns no value.
        #
        # See also: GetRangeFontSubscript SelectRangeByIndex SetRangeFontAttributes

        $rangeId -with { Font } Subscript [Cawt TclBool $onOff]
    }

    proc GetRangeFontSuperscript { rangeId } {
        # Get the superscript font style of a cell or character range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns true, if the font in specified cell range has the superscript flag set.
        #
        # See also: SetRangeFontSuperscript SelectRangeByIndex GetRangeFontAttributes

        return [$rangeId -with { Font } Superscript]
    }

    proc SetRangeFontSuperscript { rangeId { onOff true } } {
        # Set the superscript font style of a cell or character range.
        #
        # rangeId - Identifier of the cell range.
        # onOff   - If set to true, set superscript style on.
        #           Otherwise set superscript style off.
        #
        # Returns no value.
        #
        # See also: GetRangeFontSuperscript SelectRangeByIndex SetRangeFontAttributes

        $rangeId -with { Font } Superscript [Cawt TclBool $onOff]
    }

    proc GetRangeFontSize { rangeId } {
        # Get the font size of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns the size of the font in specified cell range measured in points.
        #
        # See also: SetRangeFontSize SelectRangeByIndex GetRangeFontAttributes

        return [$rangeId -with { Font } Size]
    }

    proc SetRangeFontSize { rangeId size } {
        # Set the font size of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # size    - Font size.
        #
        # The size value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: GetRangeFontSize SelectRangeByIndex SetRangeFontAttributes

        $rangeId -with { Font } Size [Cawt ValueToPoints $size]
    }

    proc GetRangeFontBold { rangeId } {
        # Get the bold font style of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns true, if the font in specified cell range has the bold flag set.
        #
        # See also: SetRangeFontBold SelectRangeByIndex GetRangeFontAttributes

        return [$rangeId -with { Font } Bold]
    }

    proc SetRangeFontBold { rangeId { onOff true } } {
        # Set the bold font style of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # onOff   - If set to true, set bold style on.
        #           Otherwise set bold style off.
        #
        # Returns no value.
        #
        # See also: GetRangeFontBold SelectRangeByIndex SetRangeFontAttributes

        $rangeId -with { Font } Bold [Cawt TclBool $onOff]
    }

    proc GetRangeFontItalic { rangeId } {
        # Get the italic font style of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns true, if the font in specified cell range has the italic flag set.
        #
        # See also: SetRangeFontItalic SelectRangeByIndex GetRangeFontAttributes

        return [$rangeId -with { Font } Italic]
    }

    proc SetRangeFontItalic { rangeId { onOff true } } {
        # Set the italic font style of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # onOff   - If set to true, set italic style on.
        #           Otherwise set italic style off.
        #
        # Returns no value.
        #
        # See also: GetRangeFontItalic SelectRangeByIndex SetRangeFontAttributes

        $rangeId -with { Font } Italic [Cawt TclBool $onOff]
    }

    proc GetRangeFontUnderline { rangeId } {
        # Get the underline font style of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns the underline style of specified cell range.
        # The returned value is of enumeration type [Enum::XlUnderlineStyle].
        #
        # See also: SetRangeFontUnderline SelectRangeByIndex GetRangeFontAttributes

        return [$rangeId -with { Font } Underline]
    }

    proc SetRangeFontUnderline { rangeId { style xlUnderlineStyleSingle } } {
        # Set the underline font style of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # style   - Value of enumeration type [Enum::XlUnderlineStyle].
        #
        # Returns no value.
        #
        # See also: GetRangeFontUnderline SelectRangeByIndex SetRangeFontAttributes

        $rangeId -with { Font } Underline [Excel GetEnum $style]
    }

    proc SetRangeMergeCells { rangeId { onOff true } } {
        # Merge/Unmerge a range of cells.
        #
        # rangeId - Identifier of the cell range.
        # onOff   - If set to true, set cell merge on.
        #           Otherwise set cell merge off.
        #
        # Returns no value.
        #
        # See also: SetRangeVerticalAlignment SelectRangeByIndex SelectRangeByString

        set appId [Office GetApplicationId $rangeId]
        Excel::ShowAlerts $appId false
        $rangeId MergeCells [Cawt TclBool $onOff]
        Excel::ShowAlerts $appId true
        Cawt Destroy $appId
    }

    proc GetRangeHorizontalAlignment { rangeId } {
        # Get the horizontal alignment of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns the horizontal alignment as a value of enumeration type [Enum::XlHAlign].
        #
        # See also: SetRangeHorizontalAlignment SelectRangeByIndex SelectRangeByString

        return [$rangeId HorizontalAlignment]
    }

    proc SetRangeHorizontalAlignment { rangeId align } {
        # Set the horizontal alignment of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # align   - Value of enumeration type [Enum::XlHAlign].
        #
        # Returns no value.
        #
        # See also: GetRangeHorizontalAlignment SetRangeVerticalAlignment
        # SelectRangeByIndex SelectRangeByString

        $rangeId HorizontalAlignment [Excel GetEnum $align]
    }

    proc GetRangeVerticalAlignment { rangeId } {
        # Get the vertical alignment of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns the vertical alignment as a value of enumeration type [Enum::XlVAlign].
        #
        # See also: SetRangeVerticalAlignment SelectRangeByIndex SelectRangeByString

        return [$rangeId VerticalAlignment]
    }

    proc SetRangeVerticalAlignment { rangeId align } {
        # Set the vertical alignment of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # align   - Value of enumeration type [Enum::XlVAlign].
        #
        # Returns no value.
        #
        # See also: SetRangeHorizontalAlignment SelectRangeByIndex SelectRangeByString

        $rangeId VerticalAlignment [Excel GetEnum $align]
    }

    proc GetRangeWrapText { rangeId } {
        # Get the wrap text mode of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns true, if the specified cell range has the wrap text flag set.
        #
        # See also: SetRangeWrapText GetRangeHorizontalAlignment GetRangeTextColor SelectRangeByIndex

        return [$rangeId WrapText]
    }

    proc SetRangeWrapText { rangeId { onOff true } } {
        # Set the text wrapping mode of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # onOff   - If set to true, set text wrapping on.
        #           Otherwise set text wrapping off.
        #
        # Returns no value.
        #
        # See also: GetRangeWrapText SetRangeHorizontalAlignment SetRangeTextColor SelectRangeByIndex

        $rangeId WrapText [Cawt TclBool $onOff]
    }

    proc ToggleAutoFilter { rangeId } {
        # Toggle the AutoFilter switch of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns no value.
        #
        # See also: SelectRangeByIndex SelectRangeByString

        $rangeId AutoFilter
    }

    proc GetRangeFillColor { rangeId } {
        # Get the fill color of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns the fill color as a list of r, b and b values.
        # The values are returned as integers in the range \[0, 255\].
        #
        # See also: SetRangeFillColor ::Cawt::OfficeColorToRgb SelectRangeByIndex SelectRangeByString

        set colorNum [$rangeId -with { Interior } Color]
        return [Cawt OfficeColorToRgb $colorNum]
    }

    proc SetRangeFillColor { rangeId args } {
        # Set the fill color of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # args    - Background fill color.
        #
        # Color value may be specified in a format acceptable by procedure [::Cawt::GetColor],
        # i.e. color name, hexadecimal string, Office color number or a list of 3 integer RGB values.
        #
        # Returns no value.
        #
        # See also: SetRangeTextColor SelectRangeByIndex SelectRangeByString

        set color [Cawt GetColor {*}$args]
        $rangeId -with { Interior } Color $color
        $rangeId -with { Interior } Pattern $Excel::xlSolid
    }

    proc GetRangeTextColor { rangeId } {
        # Get the text color of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # The r, g and b values are returned as integers in the
        # range \[0, 255\].
        #
        # Returns the text color as a list of r, b and b values.
        #
        # See also: SetRangeTextColor ::Cawt::OfficeColorToRgb SelectRangeByIndex SelectRangeByString

        set colorNum [$rangeId -with { Font } Color]
        return [Cawt OfficeColorToRgb $colorNum]
    }

    proc SetRangeTextColor { rangeId args } {
        # Set the text color of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # args    - Text color.
        #
        # Color value may be specified in a format acceptable by procedure [::Cawt::GetColor],
        # i.e. color name, hexadecimal string, Office color number or a list of 3 integer RGB values.
        #
        # Returns no value.
        #
        # See also: SetRangeFillColor SelectRangeByIndex SelectRangeByString

        set color [Cawt GetColor {*}$args]
        $rangeId -with { Font } Color $color
    }

    proc SetRangeBorder { rangeId side { weight xlThin } { lineStyle xlContinuous } args } {
        # Set the attributes of one border of a cell range.
        #
        # rangeId   - Identifier of the cell range.
        # side      - Value of enumeration type [Enum::XlBordersIndex].
        #             Typical values: `xlEdgeLeft`, `xlEdgeTop`, `xlEdgeBottom`, `xlEdgeRight`.
        # weight    - Value of enumeration type [Enum::XlBorderWeight].
        #             Typical values: `xlThin`, `xlMedium`, `xlThick`.
        # lineStyle - Value of enumeration type [Enum::XlLineStyle].
        #             Typical values: `xlContinuous`, `xlDash`, `xlDot`.
        # args      - Border color.
        #
        # Color value may be specified in a format acceptable by procedure [::Cawt::GetColor],
        # i.e. color name, hexadecimal string, Office color number or a list of 3 integer RGB values.
        #
        # If no border color is specified, it is set to black.
        #
        # Returns no value.
        #
        # See also: SetRangeBorders SelectRangeByIndex SelectRangeByString

        if { [llength $args] == 0 } {
            set borderColor [Cawt GetColor "black"]
        } else {
            set borderColor [Cawt GetColor {*}$args]
        }

        set borders [$rangeId Borders]
        set sideInt [Excel GetEnum $side]
        set border [$borders Item $sideInt]
        $border Weight    [Excel GetEnum $weight]
        $border LineStyle [Excel GetEnum $lineStyle]
        $border Color     $borderColor
        Cawt Destroy $border
        Cawt Destroy $borders
    }

    proc SetRangeBorders { rangeId \
                          { weight xlThin } \
                          { lineStyle xlContinuous } \
                          { r 0 } { g 0 } { b 0 } } {
        # Set the attributes of all borders of a cell range.
        #
        # rangeId   - Identifier of the cell range.
        # weight    - Value of enumeration type [Enum::XlBorderWeight].
        #             Typical values: `xlThin`, `xlMedium`, `xlThick`.
        # lineStyle - Value of enumeration type [Enum::XlLineStyle].
        #             Typical values: `xlContinuous`, `xlDash`, `xlDot`.
        # r         - Red component of the border color.
        # g         - Green component of the border color.
        # b         - Blue component of the border color.
        #
        # The r, g and b values are specified as integers in the
        # range \[0, 255\].
        #
        # Returns no value.
        #
        # See also: SetRangeBorder SelectRangeByIndex SelectRangeByString

        Excel SetRangeBorder $rangeId xlEdgeLeft   $weight $lineStyle $r $g $b
        Excel SetRangeBorder $rangeId xlEdgeRight  $weight $lineStyle $r $g $b
        Excel SetRangeBorder $rangeId xlEdgeBottom $weight $lineStyle $r $g $b
        Excel SetRangeBorder $rangeId xlEdgeTop    $weight $lineStyle $r $g $b
    }

    proc GetRangeFormat { rangeId } {
        # Get the number format of a cell range.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns the number format in Excel style.
        #
        # See also: SetRangeFormat SelectRangeByIndex SelectRangeByString

        return [$rangeId NumberFormat]
    }

    proc SetRangeFormat { rangeId fmt { subFmt "" } } {
        # Set the number format of a cell range.
        #
        # rangeId - Identifier of the cell range.
        # fmt     - Format of the cell range.  Possible values: "text", "int", "real".
        # subFmt  - Sub-format of the cell range. Only valid, if fmt is "real". Then it
        #           specifies the number of digits before and after the decimal point.
        #           Use the [GetNumberFormat] procedure for specifying the sub-format.
        #           If subFmt is the empty string 2 digits after the decimal point are used.
        #
        # If parameter $fmt is not any of the predefined values, it is interpreted as a 
        # custom number format specified in Excel style.
        #
        # Returns no value.
        #
        # See also: GetRangeFormat SelectRangeByIndex SelectRangeByString

        if { $fmt eq "text" } {
            set numberFormat "@"
        } elseif { $fmt eq "int" } {
            set numberFormat "0"
        } elseif { $fmt eq "real" } {
            if { $subFmt eq "" } {
                set appId  [Office GetApplicationId $rangeId]
                set subFmt [Excel GetNumberFormat $appId "0" "00"]
                Cawt Destroy $appId
            }
            set numberFormat $subFmt
        } else {
            set numberFormat $fmt
        }
        $rangeId NumberFormat [Cawt TclString $numberFormat]
    }

   proc CopyRange { fromRangeId toRangeId { pasteType xlPasteAll } } {
        # Copy the contents of a cell range into another cell range.
        #
        # fromRangeId - Identifier of the source range.
        # toRangeId   - Identifier of the destination range.
        # pasteType   - Value of enumeration type [Enum::XlPasteType].
        #               Typical values are: `xlPasteAll`, `xlPasteAllExceptBorders`, `xlPasteValues`.
        #
        # Note, that the contents of the destination range are overwritten.
        #
        # Returns no value.
        #
        # See also: SelectAll CopyWorksheet CopyColumn

        $fromRangeId Copy
        $toRangeId PasteSpecial [Excel GetEnum $pasteType]
    }

    proc CopyColumn { fromWorksheetId fromCol toWorksheetId toCol \
                     { fromRow 1 } { toRow 1 } { pasteType xlPasteAll } } {
        # Copy the contents of a column into another column.
        #
        # fromWorksheetId - Identifier of the source worksheet.
        # fromCol         - Source column number. Column numbering starts with 1.
        # toWorksheetId   - Identifier of the destination worksheet.
        # toCol           - Destination column number. Column numbering starts with 1.
        # fromRow         - Start row of source column.
        # toRow           - Start row of destination column.
        # pasteType       - Value of enumeration type [Enum::XlPasteType].
        #                   Typical values are: `xlPasteAll`, `xlPasteAllExceptBorders`, `xlPasteValues`.
        #
        # Note, that the contents of the destination column are overwritten.
        #
        # Returns no value.
        #
        # See also: CopyRange CopyWorksheet

        set numRows     [Excel GetNumUsedRows $fromWorksheetId]
        set fromRangeId [Excel SelectRangeByIndex $fromWorksheetId \
                                $fromRow $fromCol \
                                [expr {$numRows + $fromRow -1}] $fromCol]
        set toRangeId   [Excel SelectRangeByIndex $toWorksheetId \
                                $toRow $toCol \
                                [expr {$numRows + $toRow -1}] $toCol]
        Excel CopyRange $fromRangeId $toRangeId
        Cawt Destroy $fromRangeId
        Cawt Destroy $toRangeId
    }

    proc SetCommentDisplayMode { appId { showComment false } { showIndicator true } } {
        # Set the global display mode of comments.
        #
        # appId         - Identifier of the Excel instance.
        # showComment   - If set to true, show the comments.
        #                 Otherwise do not show the comments.
        # showIndicator - If set to true, show an indicator for the comments.
        #                 Otherwise do not show an indicator.
        #
        # Returns no value.
        #
        # See also: SetRangeComment SetCommentSize GetCellComment

        if { $showComment && $showIndicator } {
            $appId DisplayCommentIndicator $Excel::xlCommentAndIndicator
        } elseif { $showIndicator } {
            $appId DisplayCommentIndicator $Excel::xlCommentIndicatorOnly
        } else {
            $appId DisplayCommentIndicator $Excel::xlNoIndicator
        }
    }

    proc SetRangeComment { rangeId comment { imgFileName "" } { addUserName true } { visible false } } {
        # Set the comment text of a cell range.
        #
        # rangeId     - Identifier of the cell range.
        # comment     - Comment text.
        # imgFileName - File name of an image used as comment background.
        # addUserName - Automatically add user name before comment text.
        # visible     - If set to true, show the comment window.
        #               Otherwise hide the comment window.
        #
        # Note, that an already existing comment is overwritten.
        #
        # A comment may be used as a mouse-over tooltip, if parameter showComments of
        # [SetCommentDisplayMode] is set to false. For a selection tooltip, use [SetRangeTooltip].
        #
        # Returns the comment identifier.
        #
        # See also: SetCommentDisplayMode SetCommentSize GetCellComment 
        # SelectRangeByIndex SelectRangeByString SetRangeTooltip ::Office::GetUserName

        set commentId [$rangeId Comment]
        if { ! [Cawt IsComObject $commentId] } {
            set commentId [$rangeId AddComment]
        }
        $commentId Visible [Cawt TclBool $visible]
        if { $addUserName } {
            set userName [Office GetUserName [$commentId Application]]
            set msg [format "%s:\n%s" $userName $comment]
        } else {
            set msg $comment
        }
        $commentId Text $msg
        if { $imgFileName ne "" } {
            set fileName [file nativename [file normalize $imgFileName]]
            $commentId -with { Shape Fill } UserPicture $fileName
        }
        return $commentId
    }

    proc SetCommentSize { commentId width height } {
        # Set the shape size of a comment.
        #
        # commentId - Identifier of the comment.
        # width     - Width of the comment.
        # height    - Height of the comment.
        #
        # The size values may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: SetRangeComment SetCommentDisplayMode GetCellComment

        $commentId -with { Shape } LockAspectRatio [Cawt TclInt 0]
        $commentId -with { Shape } Height [Cawt ValueToPoints $width]
        $commentId -with { Shape } Width  [Cawt ValueToPoints $height]
    }

    proc GetCellComment { worksheetId row col } {
        # Return the comment text of a cell.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        #
        # If the cell does not contain a comment, an empty string is returned.
        #
        # Returns the comment text of a cell.
        #
        # See also: SetRangeComment SetCommentDisplayMode SetCommentSize GetCellValue

        set rangeId [Excel SelectCellByIndex $worksheetId $row $col]
        set commentId [$rangeId Comment]
        set commentText ""
        if { [Cawt IsComObject $commentId] } {
            set commentText [$commentId Text]
        }
        Cawt Destroy $commentId
        Cawt Destroy $rangeId
        return $commentText
    }

    proc SetRangeTooltip { rangeId tooltipMessage { tooltipTitle "" } } {
        # Set a selection based tooltip for a cell range.
        #
        # rangeId        - Identifier of the cell range.
        # tooltipMessage - The tooltip message string.
        # tooltipTitle   - The optional tooltip title string.
        #
        # The tooltip will be shown, if the cell is selected by the user. It is implemented by using
        # the data validation functionality of Excel.
        # If a mouse-over tooltip is needed, use [SetRangeComment].
        #
        # Returns the validation identifier.
        #
        # See also: SelectRangeByIndex SelectRangeByString SetRangeComment

        set validationId [$rangeId Validation]
        $validationId Add $Excel::xlValidateInputOnly
        $validationId InputMessage $tooltipMessage
        if { $tooltipTitle ne "" } {
            $validationId InputTitle $tooltipTitle
        }
        $validationId ShowInput [Cawt TclBool true]
        return $validationId
    }

    proc GetVersion { objId { useString false } } {
        # Return the version of an Excel application.
        #
        # objId     - Identifier of an Excel object instance.
        # useString - If set to true, return the version name (ex. `Excel 2000`).
        #             Otherwise return the version number (ex. `9.0`).
        #
        # Both version name and version number are returned as strings.
        # Version number is in a format, so that it can be evaluated as a
        # floating point number.
        #
        # Returns the version of an Excel application.
        #
        # See also: GetDecimalSeparator GetExtString

        array set map {
            "8.0"  "Excel 97"
            "9.0"  "Excel 2000"
            "10.0" "Excel 2002"
            "11.0" "Excel 2003"
            "12.0" "Excel 2007"
            "14.0" "Excel 2010"
            "15.0" "Excel 2013"
            "16.0" "Excel 2016/2019"
        }
        set version [Office GetApplicationVersion $objId]

        if { $useString } {
            if { [info exists map($version)] } {
                return $map($version)
            } else {
                return "Unknown Excel version"
            }
        } else {
            return $version
        }
        return $version
    }

    proc GetExtString { appId } {
        # Return the default extension of an Excel file.
        #
        # appId - Identifier of the Excel instance.
        #
        # Starting with Excel 12 (2007) this is the string `.xlsx`.
        # In previous versions it was `.xls`.
        #
        # Returns the default extension of an Excel file.
        #
        # See also: ::Office::GetOfficeType

        # appId is only needed, so we are sure, that excelVersion is initialized.

        variable excelVersion

        if { $excelVersion >= 12.0 } {
            return ".xlsx"
        } else {
            return ".xls"
        }
    }

    proc OpenNew { { visible true } { width -1 } { height -1 } } {
        # Open a new Excel instance.
        #
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        # width   - Width of the application window. If negative, open with last used width.
        # height  - Height of the application window. If negative, open with last used height.
        #
        # Returns the identifier of the new Excel application instance.
        #
        # See also: Open Quit Visible

        variable excelAppName
        variable excelVersion

        set appId [Cawt GetOrCreateApp $excelAppName false]
        set excelVersion [Excel GetVersion $appId]
        Excel::_setFloatSeparator $appId
        Excel Visible $appId $visible
        if { $width >= 0 } {
            $appId Width [expr $width]
        }
        if { $height >= 0 } {
            $appId Height [expr $height]
        }
        return $appId
    }

    proc Open { { visible true } { width -1 } { height -1 } } {
        # Open an Excel instance. Use an already running instance, if available.
        #
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        # width   - Width of the application window. If negative, open with last used width.
        # height  - Height of the application window. If negative, open with last used height.
        #
        # Returns the identifier of the Excel application instance.
        #
        # See also: OpenNew Quit Visible

        variable excelAppName
        variable excelVersion

        set appId [Cawt GetOrCreateApp $excelAppName true]
        set excelVersion [Excel GetVersion $appId]
        Excel::_setFloatSeparator $appId
        Excel Visible $appId $visible
        if { $width >= 0 } {
            $appId Width [expr $width]
        }
        if { $height >= 0 } {
            $appId Height [expr $height]
        }
        return $appId
    }

    proc Import { rangeId fileName args } {
        # Import data from an external data source.
        #
        # rangeId  - Identifier of the cell range.
        # fileName - File name of the data source.
        # args     - Options described below.
        #
        # -delimiter <char>          - Delimiter character. Possible values: `"\t" " " ";" ","`.
        # -decimalseparator <char>   - Decimal separator character.
        # -thousandsseparator <char> - Thousands separator character.
        #
        # Returns no value.
        #
        # See also: OpenWorkbook SaveAsCsv

        set worksheetId [$rangeId Worksheet]
        set queryTableId [$worksheetId -with { QueryTables } Add \
            "TEXT;$fileName" $rangeId]
        Cawt Destroy $worksheetId
        $queryTableId TextFileConsecutiveDelimiter [Cawt TclBool true]
        foreach { key value } $args {
            if { $value eq "" } {
                error "Import: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-delimiter" { 
                    if { $value eq "," } {
                        $queryTableId TextFileCommaDelimiter [Cawt TclBool true]
                    }
                    if { $value eq ";" } {
                        $queryTableId TextFileSemicolonDelimiter [Cawt TclBool true]
                    }
                    if { $value eq "\t" } {
                        $queryTableId TextFileTabDelimiter [Cawt TclBool true]
                    }
                    if { $value eq " " } {
                        $queryTableId TextFileSpaceDelimiter [Cawt TclBool true]
                    }
                }
                "-decimalseparator" {
                    $queryTableId TextFileDecimalSeparator $value 
                }
                "-thousandsseparator" {
                    $queryTableId TextFileThousandsSeparator $value 
                }
                default {
                    error "Import: Unknown key \"$key\" specified" 
                }
            }
        }
        $queryTableId Refresh
        Cawt Destroy $queryTableId
    }

    proc ShowAlerts { appId onOff } {
        # Toggle the display of Excel application alerts.
        #
        # appId - The application identifier.
        # onOff - Switch the alerts on or off.
        #
        # Returns no value.

        if { $onOff } {
            set alertLevel [expr 1]
        } else {
            set alertLevel [expr 0]
        }
        $appId DisplayAlerts $alertLevel
    }

    proc Quit { appId { showAlert true } } {
        # Quit an Excel instance.
        #
        # appId     - Identifier of the Excel instance.
        # showAlert - If set to true, show an alert window, if there are unsaved changes.
        #             Otherwise quit without asking and saving any changes.
        #
        # Returns no value.
        #
        # See also: Open OpenNew

        Excel::ShowAlerts $appId $showAlert
        $appId Quit
    }

    proc Visible { appId { visible "" } } {
        # Set or query the visibility of an Excel application window.
        #
        # appId   - Identifier of the Excel instance.
        # visible - If set to true, show the application window.
        #           If set to false, hide the application window.
        #           If empty, return the visbility status.
        #
        # If parameter $visible is not set or the empty string, the visibility status
        # is returned as a boolean value.
        # Otherwise no return value.
        #
        # See also: Open OpenNew SetWindowState ArrangeWindows

        if { $visible eq "" } {
            return [$appId Visible]
        }
        $appId Visible [Cawt TclInt $visible]
    }

    proc ScreenUpdate { appId onOff } {
        # Toggle the screen updating of an Excel application window.
        #
        # appId - Identifier of the Excel instance.
        # onOff - If set to true, update the application window.
        #         Otherwise do not update the application window.
        #
        # Returns no value.
        #
        # See also: Visible SetWindowState ArrangeWindows

        $appId ScreenUpdating [Cawt TclBool $onOff]
    }

    proc SetWindowState { appId { windowState xlNormal } } {
        # Set the window state of an Excel application.
        #
        # appId       - Identifier of the Excel instance.
        # windowState - Value of enumeration type [Enum::XlWindowState].
        #               Typical values are: `xlMaximized`, `xlMinimized`, `xlNormal`.
        #
        # Returns no value.
        #
        # See also: Open Visible ArrangeWindows

        $appId -with { Application } WindowState [Excel GetEnum $windowState]
    }

    proc ArrangeWindows { appId { arrangeStyle xlArrangeStyleVertical } } {
        # Arrange the windows of an Excel application.
        #
        # appId        - Identifier of the Excel instance.
        # arrangeStyle - Value of enumeration type [Enum::XlArrangeStyle].
        #                Typical values are: `xlArrangeStyleHorizontal`,
        #                `xlArrangeStyleTiled`, `xlArrangeStyleVertical`.
        #
        # Returns no value.
        #
        # See also: Open Visible SetWindowState

        $appId -with { Windows } Arrange [Excel GetEnum $arrangeStyle]
    }

    proc Close { workbookId } {
        # Close a workbook without saving changes.
        #
        # workbookId - Identifier of the workbook.
        #
        # Use the [SaveAs] method before closing, if you want to save changes.
        #
        # Returns no value.
        #
        # See also: SaveAs OpenWorkbook

        $workbookId Close [Cawt TclBool false]
    }

    proc SaveAs { workbookId fileName { fmt "" } { backup false } } {
        # Save a workbook to an Excel file.
        #
        # workbookId - Identifier of the workbook to save.
        # fileName   - Name of the Excel file.
        # fmt        - Value of enumeration type [Enum::XlFileFormat].
        #              If not given or the empty string, the file is stored in the
        #              native format corresponding to the used Excel version.
        # backup     - If set to true, create a backup file before saving.
        #              Otherwise do not create a backup file.
        #
        # Note, that if you have read a `CSV` file with [OpenWorkbook] and save it with
        # this procedure without specifying a format, the saved file will be in `CSV`
        # format, too. Specify `xlWorkbookDefault` as format, if the file should be
        # an Excel file.
        #
        # Returns no value.
        #
        # See also: SaveAsCsv Close OpenWorkbook

        set fileName [file nativename [file normalize $fileName]]
        set appId [Office GetApplicationId $workbookId]
        Excel::ShowAlerts $appId false
        if { $fmt eq "" } {
            $workbookId SaveAs $fileName
        } else {
            # SaveAs([Filename], [FileFormat], [Password],
            # [WriteResPassword], [ReadOnlyRecommended], [CreateBackup],
            # [AccessMode As XlSaveAsAccessMode = xlNoChange],
            # [ConflictResolution], [AddToMru], [TextCodepage],
            # [TextVisualLayout], [Local])
            $workbookId -callnamedargs SaveAs \
                        FileName $fileName \
                        FileFormat [Excel GetEnum $fmt] \
                        CreateBackup [Cawt TclInt $backup]
        }
        Excel::ShowAlerts $appId true
        Cawt Destroy $appId
    }

    proc SaveAsCsv { workbookId worksheetId fileName { fmt xlCSV } } {
        # Save a worksheet to file in `CSV` format.
        #
        # workbookId  - Identifier of the workbook containing the worksheet.
        # worksheetId - Identifier of the worksheet to save.
        # fileName    - Name of the `CSV` file.
        # fmt         - Value of enumeration type [Enum::XlFileFormat].
        #
        # Returns no value.
        #
        # See also: SaveAs Close OpenWorkbook

        set fileName [file nativename [file normalize $fileName]]
        set appId [Office GetApplicationId $workbookId]
        Excel::ShowAlerts $appId false
        # SaveAs(Filename As String, [FileFormat], [Password],
        # [WriteResPassword], [ReadOnlyRecommended], [CreateBackup],
        # [AddToMru], [TextCodepage], [TextVisualLayout], [Local])
        $worksheetId -callnamedargs SaveAs \
                     Filename $fileName \
                     FileFormat [Excel GetEnum $fmt]
        Excel::ShowAlerts $appId true
        Cawt Destroy $appId
    }

    proc AddWorkbook { appId { type xlWBATWorksheet } } {
        # Add a new workbook with one worksheet.
        #
        # appId - Identifier of the Excel instance.
        # type  - Value of enumeration type [Enum::XlWBATemplate].
        #         Possible values: `xlWBATChart`, `xlWBATExcel4IntlMacroSheet`,
        #         `xlWBATExcel4MacroSheet`, `xlWBATWorksheet`.
        #
        # Returns the identifier of the new workbook.
        #
        # See also: OpenWorkbook Close SaveAs

        return [$appId -with { Workbooks } Add [Excel GetEnum $type]]
    }

    proc OpenWorkbook { appId fileName args } {
        # Open a workbook, i.e. load an Excel file.
        #
        # appId    - Identifier of the Excel instance.
        # fileName - Name of the Excel file.
        # args     - Options described below.
        #
        # -readonly <bool> - If set to true, open the workbook in read-only mode.
        #                    Default is to open the workbook in read-write mode.
        # -embed <frame>   - Embed the workbook into a Tk frame. This frame must
        #                    exist and must be created with option `-container true`. 
        #
        # Returns the identifier of the opened workbook. If the workbook was
        # already open, activate that workbook and return the identifier to
        # that workbook.
        #
        # See also: AddWorkbook Close SaveAs

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
                        error "OpenWorkbook: No value specified for key \"$key\"."
                    }
                    dict set opts $key $value
                } else {
                    error "OpenWorkbook: Unknown option \"$key\" specified."
                }
            }
        }

        if { [Excel IsWorkbookOpen $appId $fileName] } {
            set workbookId [Excel GetWorkbookIdByName $appId $fileName]
            $workbookId Activate
        } else {
            set workbooks [$appId Workbooks]
            # Open(Filename As String, [UpdateLinks], [ReadOnly], [Format],
            # [Password], [WriteResPassword], [IgnoreReadOnlyRecommended],
            # [Origin], [Delimiter], [Editable], [Notify], [Converter],
            # [AddToMru], [Local], [CorruptLoad])
            set workbookId [$workbooks -callnamedargs Open \
                                       Filename [file nativename [file normalize $fileName]] \
                                       ReadOnly [Cawt TclInt [dict get $opts "-readonly"]]]
            Cawt Destroy $workbooks
        }
        set embedFrame [dict get $opts "-embed"]
        if { $embedFrame ne "" } {
            set workbookWindows [$workbookId Windows]
            $workbookWindows -iterate window {
                set windowHndl [$window Hwnd]
                set windowId   [list $windowHndl HWND]
                break
            }
            Cawt Destroy $workbookWindows
            Cawt EmbedApp $embedFrame -appid [Office GetApplicationId $workbookId] -window $windowId
        }
        return $workbookId
    }

    proc GetWorkbookName { workbookId } {
        # Return the name of a workbook.
        #
        # workbookId - Identifier of the workbook.
        #
        # Returns the name of the workbook.
        #
        # See also: AddWorkbook

        return [$workbookId Name]
    }

    proc GetActiveWorkbook { appId } {
        # Return the active workbook of an application.
        #
        # appId - Identifier of the Excel instance.
        #
        # Returns the identifier of the active workbook.
        #
        # See also: OpenWorkbook

        return [$appId ActiveWorkbook]
    }

    proc GetWorkbookIdByName { appId workbookName } {
        # Find an open workbook by its name.
        #
        # appId        - Identifier of the Excel instance.
        # workbookName - Name of the workbook to find.
        #
        # Returns the identifier of the found workbook.
        # If a workbook with given name does not exist an error is thrown.
        #
        # See also: OpenWorkbook GetActiveWorkbook GetWorkbookName GetWorksheetIdByName

        set workbooks [$appId Workbooks]
        set shortName [file tail $workbookName]
        $workbooks -iterate workbookId {
            if { [$workbookId Name] eq $shortName } {
                Cawt Destroy $workbooks
                return $workbookId
            }
        }
        Cawt Destroy $workbooks
        error "GetWorkbookIdByName: No open workbook with name $shortName"
    }

    proc IsWorkbookOpen { appId workbookName } {
        # Check, if a workbook is open.
        #
        # appId        - Identifier of the Excel instance.
        # workbookName - Name of the workbook to find.
        #
        # Returns true, if the workbook is open, otherwise false.
        #
        # See also: OpenWorkbook IsWorkbookProtected

        set retVal [catch {Excel GetWorkbookIdByName $appId $workbookName} errMsg]
        if { $retVal == 0 } {
            return true
        } else {
            return false
        }
    }

    proc IsWorkbookProtected { workbookId } {
        # Check, if a workbook is protected.
        #
        # workbookId - Identifier of the workbook to be checked.
        #
        # Returns true, if the workbook is protected, otherwise false.
        #
        # See also: OpenWorkbook IsWorkbookOpen

        if { [$workbookId ProtectWindows] } {
            return true
        } else {
            return false
        }
    }

    proc IsWorkbookId { objId } {
        # Check, if Excel object is a workbook identifier.
        #
        # objId - The identifier of an Excel object.
        #
        # Returns true, if $objId is a valid Excel workbook identifier.
        # Otherwise returns false.
        #
        # See also: ::Cawt::IsComObject ::Office::GetApplicationId

        set retVal [catch {$objId ActiveSheet} errMsg]
        # ActiveSheet is a property of the workbook class.
        if { $retVal == 0 } {
            return true
        } else {
            return false
        }
    }

    proc GetNumStyles { workbookId } {
        # Return the number of styles in a workbook.
        #
        # workbookId - Identifier of the workbook.
        #
        # Returns the number of styles in the workbook.
        #
        # See also: GetStyleId

        return [$workbookId -with { Styles } Count]
    }

    proc GetStyleId { workbookId indexOrName } {
        # Find a style by its index or name.
        #
        # workbookId  - Identifier of the workbook.
        # indexOrName - Index or name of the style to find.
        #
        # Indices start at 1.
        # If the index is out of bounds or a style with given name is
        # not available, an error is thrown.
        #
        # For details on style properties see the official [Microsoft documentation]
        # (https://docs.microsoft.com/en-us/office/vba/api/excel.style)
        #
        # Returns the identifier of the found style.
        #
        # See also: GetNumStyles

        if { [string is integer $indexOrName] } {
            set count [Excel GetNumStyles $workbookId]
            if { $indexOrName < 1 || $indexOrName > $count } {
                error "GetStyleId: Invalid style index $indexOrName given."
            }
            set styleId [$workbookId -with { Styles } Item [expr int($indexOrName)]]
        } else {
            set retVal [catch {$workbookId -with { Styles } Item [Cawt TclString $indexOrName]} styleId]
            if { $retVal != 0 } {
                error "GetStyleId: Invalid style name $indexOrName"
            }
        }
        return $styleId
    }

    proc AddWorksheet { workbookId name args } {
        # Add a new worksheet to the end of a workbook.
        #
        # workbookId - Identifier of the workbook containing the new worksheet.
        # name       - Name of the new worksheet.
        # args       - Options described below.
        # 
        # -visible <enum> - Value of enumeration type [Enum::XlSheetVisibility].
        #                   Possible values: `xlSheetVisible`, `xlSheetHidden`, `xlSheetVeryHidden`.
        #                   Default: `xlSheetVisible`.
        # -mapproc <proc> - Procedure for mapping worksheet names to Excel constraints.
        #                   Default: [MapWorksheetName]
        #                   See [MapWorksheetName] for mapping details.
        #
        # Returns the identifier of the new worksheet.
        #
        # See also: GetNumWorksheets DeleteWorksheet 
        # SetWorksheetName MapWorksheetName

        set opts [dict create \
            -visible xlSheetVisible \
            -mapproc Excel::MapWorksheetName \
        ]
        if { [llength $args] == 1 } {
            # Old mode with optional parameter visibleType
            dict set opts -visible [lindex $args 0]
        } else {
            foreach { key value } $args {
                if { [dict exists $opts $key] } {
                    if { $value eq "" } {
                        error "AddWorksheet: No value specified for key \"$key\"."
                    }
                    dict set opts $key $value
                } else {
                    error "AddWorksheet: Unknown option \"$key\" specified."
                }
            }
        }

        set worksheets [$workbookId Worksheets]
        set lastWorksheetId [$worksheets Item [$worksheets Count]]
        set worksheetId [$worksheets -callnamedargs Add After $lastWorksheetId]
        Excel SetWorksheetName $worksheetId $name -mapproc [dict get $opts "-mapproc"]
        $worksheetId Visible [Excel GetEnum [dict get $opts "-visible"]]
        Cawt Destroy $lastWorksheetId
        Cawt Destroy $worksheets
        return $worksheetId
    }

    proc ShowWorksheet { worksheetId } {
        # Show a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # 
        # See also: GetNumWorksheets GetWorksheetIdByName AddWorksheet

        $worksheetId Activate
    }

    proc DeleteWorksheet { workbookId worksheetId } {
        # Delete a worksheet.
        #
        # workbookId  - Identifier of the workbook containing the worksheet.
        # worksheetId - Identifier of the worksheet to delete.
        #
        # If the number of worksheets before deletion is 1, an error is thrown.
        #
        # Returns no value.
        #
        # See also: DeleteWorksheetByIndex GetWorksheetIdByIndex AddWorksheet

        set count [$workbookId -with { Worksheets } Count]

        if { $count == 1 } {
            error "DeleteWorksheet: Cannot delete last worksheet."
        }

        # Delete the specified worksheet.
        # This will cause alert dialogs to be displayed unless
        # they are turned off.
        set appId [Office GetApplicationId $workbookId]
        Excel::ShowAlerts $appId false
        $worksheetId Delete
        # Turn the alerts back on.
        Excel::ShowAlerts $appId true
        Cawt Destroy $appId
    }

    proc DeleteWorksheetByIndex { workbookId index } {
        # Delete a worksheet identified by its index.
        #
        # workbookId - Identifier of the workbook containing the worksheet.
        # index      - Index of the worksheet to delete.
        #
        # Returns no value.
        #
        # The left-most worksheet has index 1.
        # If the index is out of bounds, or the number of worksheets before deletion is 1,
        # an error is thrown.
        #
        # See also: GetNumWorksheets GetWorksheetIdByIndex AddWorksheet

        set count [Excel GetNumWorksheets $workbookId]

        if { $count == 1 } {
            error "DeleteWorksheetByIndex: Cannot delete last worksheet."
        }
        if { $index < 1 || $index > $count } {
            error "DeleteWorksheetByIndex: Invalid index $index given."
        }
        # Delete the specified worksheet.
        # This will cause alert dialogs to be displayed unless
        # they are turned off.
        set appId [Office GetApplicationId $workbookId]
        Excel::ShowAlerts $appId false
        set worksheetId [$workbookId -with { Worksheets } Item [expr $index]]
        $worksheetId Delete
        # Turn the alerts back on.
        Excel::ShowAlerts $appId true
        Cawt Destroy $worksheetId
        Cawt Destroy $appId
    }

    proc CopyWorksheet { fromWorksheetId toWorksheetId } {
        # Copy the contents of a worksheet into another worksheet.
        #
        # fromWorksheetId - Identifier of the source worksheet.
        # toWorksheetId   - Identifier of the destination worksheet.
        #
        # Note, that the contents of worksheet $toWorksheetId are overwritten.
        #
        # Returns no value.
        #
        # See also: SelectAll CopyWorksheetBefore CopyWorksheetAfter AddWorksheet

        $fromWorksheetId Activate
        set rangeId [Excel SelectAll $fromWorksheetId]
        $rangeId Copy

        $toWorksheetId Activate
        $toWorksheetId Paste

        Cawt Destroy $rangeId
    }

    proc CopyWorksheetBefore { fromWorksheetId beforeWorksheetId { worksheetName "" } } {
        # Copy the contents of a worksheet before another worksheet.
        #
        # fromWorksheetId   - Identifier of the source worksheet.
        # beforeWorksheetId - Identifier of the destination worksheet.
        # worksheetName     - Name of the new worksheet. If no name is specified,
        #                     or an empty string, the naming is done by Excel.
        #
        # Instead of using the identifier of $beforeWorksheetId, it is also possible
        # to use the numeric index or the special word `end` for specifying the
        # last worksheet.
        #
        # Note, that a new worksheet is generated before worksheet $beforeWorksheetId,
        # while [CopyWorksheet] overwrites the contents of an existing worksheet.
        # The new worksheet is set as the active sheet.
        #
        # Returns the identifier of the new worksheet.
        #
        # See also: SelectAll CopyWorksheet CopyWorksheetAfter AddWorksheet

        set fromWorkbookId   [$fromWorksheetId   Parent]
        set beforeWorkbookId [$beforeWorksheetId Parent]

        if { $beforeWorksheetId eq "end" } {
            set beforeWorksheetId [Excel GetWorksheetIdByIndex $fromWorkbookId "end"]
        } elseif { [string is integer $beforeWorksheetId] } {
            set index [expr int($beforeWorksheetId)]
            set beforeWorksheetId [Excel GetWorksheetIdByIndex $fromWorkbookId ]
        }

        $fromWorksheetId -callnamedargs Copy Before $beforeWorksheetId

        set beforeName [Excel GetWorksheetName $beforeWorksheetId]
        set beforeWorksheetIndex [Excel GetWorksheetIndexByName $beforeWorkbookId $beforeName]
        set newWorksheetIndex [expr { $beforeWorksheetIndex - 1 }]
        set newWorksheetId [Excel GetWorksheetIdByIndex $beforeWorkbookId $newWorksheetIndex]

        if { $worksheetName ne "" } {
            Excel SetWorksheetName $newWorksheetId $worksheetName
        }
        $newWorksheetId Activate

        Cawt Destroy $beforeWorkbookId
        Cawt Destroy $fromWorkbookId
        return $newWorksheetId
    }

    proc CopyWorksheetAfter { fromWorksheetId afterWorksheetId { worksheetName "" } } {
        # Copy the contents of a worksheet after another worksheet.
        #
        # fromWorksheetId  - Identifier of the source worksheet.
        # afterWorksheetId - Identifier of the destination worksheet.
        # worksheetName    - Name of the new worksheet. If no name is specified,
        #                    or an empty string, the naming is done by Excel.
        #
        # Instead of using the identifier of $afterWorksheetId, it is also possible
        # to use the numeric index or the special word `end` for specifying the
        # last worksheet.
        #
        # Note, that a new worksheet is generated after worksheet $afterWorksheetId,
        # while [CopyWorksheet] overwrites the contents of an existing worksheet.
        # The new worksheet is set as the active sheet.
        #
        # Returns the identifier of the new worksheet.
        #
        # See also: SelectAll CopyWorksheet CopyWorksheetBefore AddWorksheet

        set fromWorkbookId  [$fromWorksheetId  Parent]
        set afterWorkbookId [$afterWorksheetId Parent]

        if { $afterWorksheetId eq "end" } {
            set afterWorksheetId [Excel GetWorksheetIdByIndex $fromWorkbookId "end"]
        } elseif { [string is integer $afterWorksheetId] } {
            set index [expr int($afterWorksheetId)]
            set afterWorksheetId [Excel GetWorksheetIdByIndex $fromWorkbookId ]
        }

        $fromWorksheetId -callnamedargs Copy After $afterWorksheetId

        set afterName [Excel GetWorksheetName $afterWorksheetId]
        set afterWorksheetIndex [Excel GetWorksheetIndexByName $afterWorkbookId $afterName]
        set newWorksheetIndex [expr { $afterWorksheetIndex + 1 }]
        set newWorksheetId [Excel GetWorksheetIdByIndex $afterWorkbookId $newWorksheetIndex]

        if { $worksheetName ne "" } {
            Excel SetWorksheetName $newWorksheetId $worksheetName
        }
        $newWorksheetId Activate

        Cawt Destroy $afterWorkbookId
        Cawt Destroy $fromWorkbookId
        return $newWorksheetId
    }

    proc GetWorksheetIdByIndex { workbookId index { activate true } } {
        # Find a worksheet by its index.
        #
        # workbookId - Identifier of the workbook containing the worksheet.
        # index      - Index of the worksheet to find.
        # activate   - If set to true, activate the found worksheet.
        #              Otherwise just return the identifier.
        #
        # The left-most worksheet has index 1.
        # Instead of using the numeric index the special word `end` may
        # be used to specify the last worksheet.
        # If the index is out of bounds an error is thrown.
        #
        # Returns the identifier of the found worksheet.
        #
        # See also: GetNumWorksheets GetWorksheetIdByName AddWorksheet

        set count [Excel GetNumWorksheets $workbookId]
        if { $index eq "end" } {
            set index $count
        } else {
            if { $index < 1 || $index > $count } {
                error "GetWorksheetIdByIndex: Invalid index $index given."
            }
        }
        set worksheetId [$workbookId -with { Worksheets } Item [expr $index]]
        if { $activate } {
            $worksheetId Activate
        }
        return $worksheetId
    }

    proc GetWorksheetIdByName { workbookId worksheetName { activate true } } {
        # Find a worksheet by its name.
        #
        # workbookId    - Identifier of the workbook containing the worksheet.
        # worksheetName - Name of the worksheet to find.
        # activate      - If set to true, activate the found worksheet.
        #                 Otherwise just return the identifier.
        #
        # Returns the identifier of the found worksheet.
        # If a worksheet with given name does not exist an error is thrown.
        #
        # See also: GetNumWorksheets GetWorksheetIndexByName GetWorksheetIdByIndex AddWorksheet
        # GetWorkbookIdByName

        set worksheets [$workbookId Worksheets]
        set count [$worksheets Count]

        for { set i 1 } { $i <= $count } { incr i } {
            set worksheetId [$worksheets Item [expr $i]]
            if { $worksheetName eq [$worksheetId Name] } {
                Cawt Destroy $worksheets
                if { $activate } {
                    $worksheetId Activate
                }
                return $worksheetId
            }
            Cawt Destroy $worksheetId
        }
        error "GetWorksheetIdByName: No worksheet with name $worksheetName"
    }

    proc GetWorksheetIndexByName { workbookId worksheetName { activate true } } {
        # Find a worksheet index by its name.
        #
        # workbookId    - Identifier of the workbook containing the worksheet.
        # worksheetName - Name of the worksheet to find.
        # activate      - If set to true, activate the found worksheet.
        #                 Otherwise just return the index.
        #
        # The left-most worksheet has index 1.
        # If a worksheet with given name does not exist an error is thrown.
        #
        # Returns the index of the found worksheet.
        #
        # See also: GetNumWorksheets GetWorksheetIdByIndex GetWorksheetIdByName AddWorksheet

        set worksheets [$workbookId Worksheets]
        set count [$worksheets Count]

        for { set i 1 } { $i <= $count } { incr i } {
            set worksheetId [$worksheets Item [expr $i]]
            if { $worksheetName eq [$worksheetId Name] } {
                Cawt Destroy $worksheets
                if { $activate } {
                    $worksheetId Activate
                }
                return $i
            }
            Cawt Destroy $worksheetId
        }
        error "GetWorksheetIdByName: No worksheet with name $worksheetName"
    }

    proc MapWorksheetName { name } {
        # Map the name of a worksheet to confirm to Excel constraints.
        #
        # name - Name of the worksheet.
        #
        # The following characters are not allowed in worksheet names
        # and are thus mapped as follows:
        #     [ to (
        #     ] to )
        #     \ to _
        #     / to _
        #     ? to |
        #     * to +
        #     : to ;
        #
        # After mapping, the string is truncated to 31 characters,
        # which is the maximum length of a worksheet name.
        #
        # Returns the mapped worksheet name.
        #
        # See also: SetWorksheetName AddWorksheet

        set mapped [string map { "\[" "("  "\]" ")"  "\\" "_"  "/" "_"  "?" "|"  "*" "+"  ":" ";" } $name]
        set sheetName [string range $mapped 0 30]
        return $sheetName
    }

    proc SetWorksheetName { worksheetId name args } {
        # Set the name of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # name        - Name of the worksheet.
        # args        - Options described below.
        # 
        # -mapproc <proc> - Procedure for mapping worksheet names to Excel constraints.
        #                   Default: [MapWorksheetName]
        #                   See [MapWorksheetName] for mapping details.
        #
        # If $name is the empty string, the worksheet name is automatically
        # assigned by Excel.
        #
        # Returns no value.
        #
        # See also: GetWorksheetName AddWorksheet MapWorksheetName

        if { $name eq "" } {
            return
        }
        set opts [dict create \
            -mapproc Excel::MapWorksheetName \
        ]
        foreach { key value } $args {
            if { [dict exists $opts $key] } {
                if { $value eq "" } {
                    error "SetWorksheetName: No value specified for key \"$key\"."
                }
                dict set opts $key $value
            } else {
                error "SetWorksheetName: Unknown option \"$key\" specified."
            }
        }
        set sheetName $name
        set mapproc [dict get $opts "-mapproc"]
        if { $mapproc ne "" } {
            set sheetName [$mapproc $name]
        }
        $worksheetId Name $sheetName
    }

    proc GetWorksheetName { worksheetId } {
        # Return the name of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the name of the worksheet.
        #
        # See also: SetWorksheetName AddWorksheet

        return [$worksheetId Name]
    }

    proc SetNamedRange { rangeId rangeName { useWorksheet true } } {
        # Set the name of a cell range.
        #
        # rangeId      - Identifier of the cell range.
        # rangeName    - Name of the cell range. Must not contain spaces.
        # useWorksheet - If set to true, set the name at the worksheet level. 
        #                Otherwise set it at the workbook level.
        #
        # Returns no value.
        #
        # See also: GetNamedRange GetNamedRangeNames

        set worksheetId [$rangeId Parent]
        set worksheetName [Excel GetWorksheetName $worksheetId]
        Cawt Destroy $worksheetId

        if { $useWorksheet } {
            set rangeName [format "%s!%s" $worksheetName $rangeName]
        }
        $rangeId Name $rangeName
    }

    proc GetNamedRange { objId rangeName } {
        # Get the identifier of a named range.
        #
        # objId     - Identifier of a workbook or worksheet.
        # rangeName - Name of range to get.
        #
        # Returns the range identifier of the named range.
        #
        # See also: SelectRangeByIndex GetNamedRangeNames SetNamedRange

        set names [$objId Names]
        $names -iterate name {
            if { [string match "*$rangeName" [$name Name]] } {
                set rangeId [$name RefersToRange]
                Cawt Destroy $name
                return $rangeId
            }
            Cawt Destroy $name
        }
        error "Range name $rangeName not found."
    }

    proc GetNamedRangeNames { objId } {
        # Get the names of named ranges.
        #
        # objId - Identifier of a workbook or worksheet.
        #
        # Returns a sorted list of all names.
        #
        # See also: GetNamedRange SetNamedRange

        set nameList [list]
        set names [$objId Names]
        $names -iterate name {
            lappend nameList [$name Name]
            Cawt Destroy $name
        }
        Cawt Destroy $names
        return [lsort -dictionary $nameList]
    }

    proc IsWorksheetEmpty { worksheetId } {
        # Check, if a worksheet is empty.
        #
        # worksheetId - Identifier of the worksheet to be checked.
        #
        # Returns true, if the worksheet is empty, otherwise false.
        #
        # See also: GetNumUsedRows GetNumUsedColumns GetFirstUsedRow GetLastUsedRow

        if { [GetLastUsedRow    $worksheetId] == 1 && \
             [GetLastUsedColumn $worksheetId] == 1 && \
             [GetCellValue $worksheetId 1 1] eq "" } {
            return true
        }
        return false
    }

    proc IsWorksheetProtected { worksheetId } {
        # Check, if a worksheet is content protected.
        #
        # worksheetId - Identifier of the worksheet to be checked.
        #
        # Returns true, if the worksheet is protected, otherwise false.
        #
        # See also: AddWorksheet

        if { [$worksheetId ProtectContents] } {
            return true
        } else {
            return false
        }
    }

    proc IsWorksheetVisible { worksheetId } {
        # Check, if a worksheet is visible.
        #
        # worksheetId - Identifier of the worksheet to be checked.
        #
        # Returns true, if the worksheet is visible, otherwise false.
        #
        # See also: AddWorksheet

        if { [$worksheetId Visible] == $Excel::xlSheetVisible } {
            return true
        } else {
            return false
        }
    }

    proc GetNumWorksheets { workbookId } {
        # Return the number of worksheets in a workbook.
        #
        # workbookId - Identifier of the workbook.
        #
        # Returns the number of worksheets in the workbook.
        #
        # See also: AddWorksheet OpenWorkbook

        return [$workbookId -with { Worksheets } Count]
    }
    
    proc SetWorksheetOrientation { worksheetId orientation } {
        # Set the orientation of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # orientation - Value of enumeration type [Enum::XlPageOrientation].
        #               Possible values: `xlLandscape` or `xlPortrait`.
        #
        # Returns no value.
        #
        # See also: SetWorksheetFitToPages SetWorksheetZoom SetWorksheetPrintOptions
        # SetWorksheetPaperSize SetWorksheetMargins
        # SetWorksheetHeader SetWorksheetFooter

        $worksheetId -with { PageSetup } Orientation [Excel GetEnum $orientation]
    }

    proc SetWorksheetFitToPages { worksheetId { wide 1 } { tall 1 } } {
        # Adjust a worksheet to fit onto given number of pages.
        #
        # worksheetId - Identifier of the worksheet.
        # wide        - The number of pages in horizontal direction.
        # tall        - The number of pages in vertical direction.
        #
        # Use zero for parameters $wide or $tall to automatically determine the
        # number of pages.
        # When using the default values for $wide and $tall, the worksheet is adjusted
        # to fit onto exactly one piece of paper.
        #
        # Returns no value.
        #
        # See also: SetWorksheetOrientation SetWorksheetZoom SetWorksheetPrintOptions
        # SetWorksheetPaperSize SetWorksheetMargins
        # SetWorksheetHeader SetWorksheetFooter

        if { $wide < 0 || $tall < 0 } {
            error "SetWorksheetFitToPages: Number of pages must be greater or equal to 0."
        }
        if { $wide == 0 } {
            set wideVar [Cawt TclBool false]
        } else {
            set wideVar [expr int($wide)]
        }
        if { $tall == 0 } {
            set tallVar [Cawt TclBool false]
        } else {
            set tallVar [expr int($tall)]
        }
        set pageSetup [$worksheetId PageSetup]
        $pageSetup Zoom [Cawt TclBool false]
        $pageSetup FitToPagesWide $wideVar
        $pageSetup FitToPagesTall $tallVar
        Cawt Destroy $pageSetup
    }

    proc SetWorksheetZoom { worksheetId { zoom 100 } } {
        # Set the zoom factor for printing of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # zoom        - The zoom factor in percent as an integer value.
        #
        # Valid zoom values are in the range \[10, 400\].
        #
        # Returns no value.
        #
        # See also: SetWorksheetOrientation SetWorksheetFitToPages SetWorksheetPrintOptions
        # SetWorksheetPaperSize SetWorksheetMargins
        # SetWorksheetHeader SetWorksheetFooter

        $worksheetId -with { PageSetup } Zoom [expr int($zoom)]
    }

    proc SetWorksheetPrintOptions { worksheetId args } {
        # Set printing options of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # args        - Options described below.
        #
        # -gridlines <bool> - Set the printing of grid lines.
        # -bw <bool>        - Set printing in black-white only.
        # -draft <bool>     - Set printing quality to draft mode.
        # -headings <bool>  - Set printing of headings.
        # -comments <enum>  - Set printing of comments. Enumeration of type [Enum::XlPrintLocation].
        #                     Typical values: `xlPrintInPlace`, `xlPrintNoComments`.
        # -errors <enum>    - Set printing of errors. Enumeration of type [Enum::XlPrintErrors].
        #                     Typical values: `xlPrintErrorsDisplayed`, `xlPrintErrorsBlank`.
        #
        # Returns no value.
        #
        # See also: SetWorksheetOrientation SetWorksheetFitToPages SetWorksheetZoom
        # SetWorksheetPaperSize SetWorksheetMargins
        # SetWorksheetHeader SetWorksheetFooter

        set pageSetup [$worksheetId PageSetup]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetWorksheetPrintOptions: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-gridlines" { $pageSetup PrintGridlines [Cawt TclBool $value] }
                "-bw"        { $pageSetup BlackAndWhite  [Cawt TclBool $value] }
                "-draft"     { $pageSetup Draft          [Cawt TclBool $value] }
                "-headings"  { $pageSetup PrintHeadings  [Cawt TclBool $value] }
                "-comments"  { $pageSetup PrintComments  [Excel GetEnum $value] }
                "-errors"    { $pageSetup PrintErrors    [Excel GetEnum $value] }
                default      { error "SetWorksheetPrintOptions: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $pageSetup
    }

    proc SetWorksheetPaperSize { worksheetId paperSize } {
        # Set the paper size of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # paperSize   - Value of enumeration type [Enum::XlPaperSize].
        #
        # Returns no value.
        #
        # See also: SetWorksheetOrientation SetWorksheetFitToPages SetWorksheetZoom
        # SetWorksheetPrintOptions SetWorksheetMargins
        # SetWorksheetHeader SetWorksheetFooter

        $worksheetId -with { PageSetup } PaperSize [Excel GetEnum $paperSize]
    }

    proc SetWorksheetMargins { worksheetId args } {
        # Set the margins of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # args        - Options described below.
        #
        # -top <size>    - Set the size of the top margin.
        # -bottom <size> - Set the size of the bottom margin.
        # -left <size>   - Set the size of the left margin.
        # -right <size>  - Set the size of the right margin.
        # -footer <size> - Set the size of the footer margin.
        # -header <size> - Set the size of the header margin.
        #
        # The margin values may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Example: 
        #     SetWorksheetMargins $worksheetId -top 1.5c -left 2i
        #     sets the top margin to 1.5 centimeters and the left margin to 2 inches.
        #
        # Returns no value.
        #
        # See also: SetWorksheetOrientation SetWorksheetFitToPages SetWorksheetZoom
        # SetWorksheetPrintOptions SetWorksheetPaperSize
        # SetWorksheetHeader SetWorksheetFooter

        set pageSetup [$worksheetId PageSetup]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetWorksheetMargins: No value specified for key \"$key\""
            }
            set pointValue [Cawt ValueToPoints $value]
            switch -exact -nocase -- $key {
                "-top"    { $pageSetup TopMargin    $pointValue }
                "-bottom" { $pageSetup BottomMargin $pointValue }
                "-left"   { $pageSetup LeftMargin   $pointValue }
                "-right"  { $pageSetup RightMargin  $pointValue }
                "-header" { $pageSetup HeaderMargin $pointValue }
                "-footer" { $pageSetup FooterMargin $pointValue }
                default   { error "SetWorksheetMargins: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $pageSetup
    }

    proc SetWorksheetHeader { worksheetId args } {
        # Set the texts of the header of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # args        - Options described below.
        #
        # -left <string>   - Set the text of the left header.
        # -center <string> - Set the text of the center header.
        # -right <string>  - Set the text of the right header.
        #
        # Returns no value.
        #
        # See also: SetWorksheetOrientation SetWorksheetFitToPages SetWorksheetZoom
        # SetWorksheetPrintOptions SetWorksheetPaperSize
        # SetWorksheetHeader SetWorksheetFooter

        set pageSetup [$worksheetId PageSetup]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetWorksheetHeader: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-left"   { $pageSetup LeftHeader   $value }
                "-center" { $pageSetup CenterHeader $value }
                "-right"  { $pageSetup RightHeader  $value }
                default   { error "SetWorksheetHeader: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $pageSetup
    }

    proc SetWorksheetFooter { worksheetId args } {
        # Set the texts of the footer of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # args        - Options described below.
        #
        # -left <string>   - Set the text of the left footer.
        # -center <string> - Set the text of the center footer.
        # -right <string>  - Set the text of the right footer.
        #
        # Returns no value.
        #
        # See also: SetWorksheetOrientation SetWorksheetFitToPages SetWorksheetZoom
        # SetWorksheetPrintOptions SetWorksheetPaperSize
        # SetWorksheetHeader SetWorksheetFooter

        set pageSetup [$worksheetId PageSetup]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetWorksheetFooter: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-left"   { $pageSetup LeftFooter   $value }
                "-center" { $pageSetup CenterFooter $value }
                "-right"  { $pageSetup RightFooter  $value }
                default   { error "SetWorksheetFooter: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $pageSetup
    }

    proc SetWorksheetTabColor { worksheetId args } {
        # Set the color of the tab of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # args        - Tab color.
        #
        # Color value may be specified in a format acceptable by procedure [::Cawt::GetColor],
        # i.e. color name, hexadecimal string, Office color number or a list of 3 integer RGB values.
        #
        # Returns no value.
        #
        # See also: SetRangeTextColor GetWorksheetIdByIndex

        set color [Cawt GetColor {*}$args]
        $worksheetId -with { Tab } Color $color
    }

    proc UnhideWorksheet { worksheetId } {
        # Unhide a worksheet, if it is hidden.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # If the worksheet is hidden, it is made visible.
        #
        # Returns no value.
        #
        # See also: SetWorksheetTabColor IsWorksheetVisible

        if { ! [Excel IsWorksheetVisible $worksheetId] } {
            if { [$worksheetId -with { Parent } ProtectStructure] } {
                error "Unable to unhide because the Workbook's structure is protected."
            } else {
                $worksheetId Visible $Excel::xlSheetVisible
            }
        }
    }

    proc GetCellsId { worksheetId } {
        # Return the cells identifier of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the range of all cells from the worksheet. This corresponds to the
        # method Cells() of the Worksheet object.

        set cellsId [$worksheetId Cells]
        return $cellsId
    }

    proc GetCellIdByIndex { worksheetId row col } {
        # Return a cell of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        #
        # Returns the cell identifier of the cell with index (row, col).
        #
        # See also: SelectCellByIndex AddWorksheet

        set cellsId [Excel GetCellsId $worksheetId]
        set cell [$cellsId Item [expr {int($row)}] [expr {int($col)}]]
        Cawt Destroy $cellsId
        return $cell
    }

    proc SelectCellByIndex { worksheetId row col { visSel false } } {
        # Select a cell by its row/column index.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        # visSel      - If set to true, see the selection in the user interface.
        #               Otheriwse the selection is not visible.
        #
        # Returns the identifier of the cell as a range identifier.
        #
        # See also: SelectRangeByIndex AddWorksheet

        return [Excel SelectRangeByIndex $worksheetId $row $col $row $col $visSel]
    }

    proc ShowCellByIndex { worksheetId row col } {
        # Show a cell identified by its row/column index.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        #
        # Set the scrolling, so that the cell is shown at the upper left corner.
        #
        # See also: SelectCellByIndex

        if { $row <= 0 } {
            error "Row number $row is invalid."
        }
        if { $col <= 0 } {
            error "Column number $col is invalid."
        }
        $worksheetId Activate
        set appId [Office GetApplicationId $worksheetId]
        set actWin [$appId ActiveWindow]
        $actWin ScrollColumn $col
        $actWin ScrollRow $row
        Cawt Destroy $actWin
        Cawt Destroy $appId
    }

    proc FreezePanes { worksheetId row col { onOff true } } {
        # Freeze a range in a worksheet identified by its row/column index.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        # onOff       - If set to true, freeze the range.
        #               Otherwise unfreeze the range.
        #
        # The rows and columns with indices lower than the specified values are freezed for scrolling.
        # If a row or a column should not be freezed, a value of zero for the corresponding parameter
        # should be given.
        #
        # See also: SelectCellByIndex

        $worksheetId Activate
        set appId [Office GetApplicationId $worksheetId]
        set actWin [$appId ActiveWindow]
        if { $onOff } {
            if { $col > 0 } {
                $actWin SplitColumn $col
            }
            if { $row > 0 } {
                $actWin SplitRow $row
            }
        }
        $actWin FreezePanes [Cawt TclBool $onOff]
        Cawt Destroy $actWin
        Cawt Destroy $appId
    }

    proc SetHyperlink { worksheetId row col link { textDisplay "" } } {
        # Insert a hyperlink into a cell.
        #
        # worksheetId - Identifier of the worksheet the hyperlink is inserted to.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        # link        - URL of the hyperlink.
        # textDisplay - Text to be displayed instead of the URL.
        #
        # URL's are specified as strings:
        # * `file://myLinkedFile` specifies a link to a local file.
        # * `http://myLinkedWebpage` specifies a link to a web address.
        #
        # Returns no value.
        #
        # See also: AddWorksheet SetHyperlinkToFile SetHyperlinkToCell SetLinkToCell

        variable excelVersion

        if { $textDisplay eq "" } {
            set textDisplay $link
        }

        set rangeId [Excel SelectCellByIndex $worksheetId $row $col]
        set hyperId [$worksheetId Hyperlinks]

        # Add(Anchor As Object, Address As String, [SubAddress],
        # [ScreenTip], [TextToDisplay]) As Object
        if { $excelVersion eq "8.0" } {
            $hyperId -callnamedargs Add \
                     Anchor $rangeId \
                     Address $link
        } else {
            $hyperId -callnamedargs Add \
                     Anchor $rangeId \
                     Address $link \
                     TextToDisplay $textDisplay
        }
        Cawt Destroy $hyperId
        Cawt Destroy $rangeId
    }

    proc SetHyperlinkToFile { worksheetId row col fileName { textDisplay "" } } {
        # Insert a hyperlink to a file into a cell.
        #
        # worksheetId - Identifier of the worksheet the hyperlink is inserted to.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        # fileName    - Path name of the linked file.
        # textDisplay - Text to be displayed instead of the file name.
        #
        # Returns no value.
        #
        # See also: AddWorksheet SetHyperlinkToCell SetHyperlink SetLinkToCell

        if { $textDisplay eq "" } {
            set textDisplay $fileName
        }

        set rangeId [Excel SelectCellByIndex $worksheetId $row $col]
        set hyperId [$worksheetId Hyperlinks]

        if { [file pathtype $fileName] eq "relative" } {
            set address [format "file:./%s" [file nativename $fileName]]
        } else {
            set address [format "file://%s" [file nativename [file normalize $fileName]]]
            set appId [Office GetApplicationId $worksheetId]
            $appId -with { DefaultWebOptions } UpdateLinksOnSave [Cawt TclBool false]
            Cawt Destroy $appId
        }

        # Add(Anchor As Object, Address As String, [SubAddress],
        # [ScreenTip], [TextToDisplay]) As Object
        $hyperId -callnamedargs Add \
                 Anchor $rangeId \
                 Address $address \
                 TextToDisplay $textDisplay
        Cawt Destroy $hyperId
        Cawt Destroy $rangeId
    }

    proc SetHyperlinkToCell { srcWorksheetId srcRow srcCol destWorksheetId destRow destCol { textDisplay "" } } {
        # Insert a hyperlink to a cell into another cell.
        #
        # srcWorksheetId  - Identifier of the worksheet the link points to.
        # srcRow          - Source row number. Row numbering starts with 1.
        # srcCol          - Source column number. Column numbering starts with 1.
        # destWorksheetId - Identifier of the worksheet the link is inserted into.
        # destRow         - Destination row number. Row numbering starts with 1.
        # destCol         - Destination column number. Column numbering starts with 1.
        # textDisplay     - Text to be displayed instead of the hyperlink.
        #
        # Returns no value.
        #
        # See also: AddWorksheet SetHyperlinkToFile SetHyperlink SetLinkToCell

        set rangeId [Excel SelectCellByIndex $destWorksheetId $destRow $destCol]
        set hyperId [$destWorksheetId Hyperlinks]

        set subAddress [format "'%s'!%s%d" \
                           [Excel GetWorksheetName $srcWorksheetId] \
                           [Excel ColumnIntToChar $srcCol] $srcRow]

        if { $textDisplay eq "" } {
            set textDisplay $subAddress
        }

        # Add(Anchor As Object, Address As String, [SubAddress],
        # [ScreenTip], [TextToDisplay]) As Object
        $hyperId -callnamedargs Add \
                 Anchor $rangeId \
                 Address "" \
                 SubAddress $subAddress \
                 TextToDisplay $textDisplay
        Cawt Destroy $hyperId
        Cawt Destroy $rangeId
    }

    proc SetLinkToCell { srcWorksheetId srcRow srcCol destWorksheetId destRow destCol } {
        # Insert an internal link to a cell into another cell.
        #
        # srcWorksheetId  - Identifier of the worksheet the link points to.
        # srcRow          - Source row number. Row numbering starts with 1.
        # srcCol          - Source column number. Column numbering starts with 1.
        # destWorksheetId - Identifier of the worksheet the link is inserted to.
        # destRow         - Destination row number. Row numbering starts with 1.
        # destCol         - Destination column number. Column numbering starts with 1.
        #
        # Note, that the number format of the source cell is used as number format of the 
        # destination cell.
        #
        # Returns no value.
        #
        # See also: SetHyperlinkToCell SetHyperlinkToFile SetHyperlink

        set srcRangeId  [Excel SelectCellByIndex $srcWorksheetId $srcRow $srcCol]
        set destRangeId [Excel SelectCellByIndex $destWorksheetId $destRow $destCol]

        $destRangeId NumberFormat [$srcRangeId NumberFormat]
        
        $srcRangeId Copy
        $destRangeId Select
        $destWorksheetId -callnamedargs Paste Link [Cawt TclBool true]

        Cawt Destroy $srcRangeId
        Cawt Destroy $destRangeId
    }

    proc InsertImage { worksheetId imgFileName { row 1 } { col 1 } { linkToFile false } { saveWithDoc true } } {
        # Insert an image into a worksheet.
        #
        # worksheetId - Identifier of the worksheet where the image is inserted.
        # imgFileName - File name of the image.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        # linkToFile  - Insert a link to the image file.
        # saveWithDoc - Embed the image into the document.
        #
        # The file name of the image must be an absolute pathname. Use a
        # construct like `[file join [pwd] "myImage.gif"]` to insert
        # images from the current directory.
        #
        # If both $linkToFile and $saveWithDoc are set to false, an error is thrown.
        #
        # Returns the identifier of the inserted image as a shape.
        #
        # See also: ScaleImage

        if { ! $linkToFile && ! $saveWithDoc } {
            error "InsertImage: linkToFile and saveWithDoc are both set to false."
        }

        set cellId [Excel SelectCellByIndex $worksheetId $row $col true]
        set fileName [file nativename [file normalize $imgFileName]]
        set shapeId [$cellId -with { Parent Shapes } AddPicture $fileName \
            [Cawt TclInt $linkToFile] \
            [Cawt TclInt $saveWithDoc] \
            [$cellId Left] [$cellId Top] -1 -1]
        Cawt Destroy $cellId
        return $shapeId
    }

    proc ScaleImage { shapeId scaleWidth scaleHeight } {
        # Scale an image.
        #
        # shapeId     - Identifier of the image shape.
        # scaleWidth  - Horizontal scale factor.
        # scaleHeight - Vertical scale factor.
        #
        # The scale factors are floating point values. 1.0 means no scaling.
        #
        # Returns no value.
        #
        # See also: InsertImage

        $shapeId LockAspectRatio [Cawt TclInt false]
        $shapeId ScaleWidth  [expr double($scaleWidth)]  [Cawt TclInt true]
        $shapeId ScaleHeight [expr double($scaleHeight)] [Cawt TclInt true]
    }

    proc SetCellValue { worksheetId row col val { fmt "text" } { subFmt "" } } {
        # Set the value of a cell.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        # val         - String value of the cell.
        # fmt         - Format of the cell. Possible values: `text`, `int`, `real`.
        # subFmt      - Formatting option of the floating-point value (see [SetRangeFormat]).
        #
        # The value to be inserted is interpreted either as string, integer or
        # floating-point number according to the formats specified in $fmt and $subFmt.
        #
        # Returns no value.
        #
        # See also: GetCellValue SetRowValues SetMatrixValues

        set cellsId [Excel GetCellsId $worksheetId]
        set cellId  [Excel GetCellIdByIndex $worksheetId $row $col]
        SetRangeFormat $cellId $fmt $subFmt
        if { $fmt eq "text" } {
            $cellsId Item [expr {int($row)}] [expr {int($col)}] [Cawt TclString $val]
        } elseif { $fmt eq "int" } {
            $cellsId Item [expr {int($row)}] [expr {int($col)}] [expr {int($val)}]
        } elseif { $fmt eq "real" } {
            $cellsId Item [expr {int($row)}] [expr {int($col)}] [expr {double($val)}]
        } else {
            error "SetCellValue: Unknown format $fmt"
        }
        Cawt Destroy $cellId
        Cawt Destroy $cellsId
    }

    proc GetCellValue { worksheetId row col { fmt "text" } } {
        # Return the value of a cell.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # col         - Column number. Column numbering starts with 1.
        # fmt         - Format of the cell. Possible values: `text`, `int`, `real`.
        #
        # Depending on the format the value of the cell is returned as a string,
        # integer number or a floating-point number.
        # If the value could not be retrieved, an error is thrown.
        #
        # Returns the value of the cell.
        #
        # See also: GetCellValueA1 SetCellValue ColumnCharToInt

        set cellsId [Excel GetCellsId $worksheetId]
        set cell [$cellsId Item [expr {int($row)}] [expr {int($col)}]]
        set retVal [catch {$cell Value} val]
        if { $retVal != 0 } {
            error "GetCellValue: Unable to get value of cell ($row, $col)"
        }
        Cawt Destroy $cell
        Cawt Destroy $cellsId
        if { $fmt eq "text" } {
            return $val
        } elseif { $fmt eq "int" } {
            return [expr {int ($val)}]
        } elseif { $fmt eq "real" } {
            return [expr {double ($val)}]
        } else {
            error "GetCellValue: Unknown format $fmt"
        }
    }

    proc GetCellValueA1 { worksheetId cellA1 { fmt "text" } } {
        # Return the value of a cell.
        #
        # worksheetId - Identifier of the worksheet.
        # cellA1      - Cell identifier in A1 notation.
        # fmt         - Format of the cell. Possible values: `text`, `int`, `real`.
        #
        # Depending on the format the value of the cell is returned as a string,
        # integer number or a floating-point number.
        # If the value could not be retrieved, an error is thrown.
        #
        # Returns the value of the cell.
        #
        # See also: GetCellValue SetCellValue ColumnCharToInt

        regexp {([[:alpha:]]+)([[:digit:]]+)} $cellA1 -> colStr row
        set col [Excel ColumnCharToInt $colStr]
        return [Excel GetCellValue $worksheetId $row $col $fmt]
    }

    proc SetRowValues { worksheetId row valList { startCol 1 } { numVals 0 } } {
        # Insert row values from a Tcl list.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # valList     - List of values to be inserted.
        # startCol    - Column number of insertion start. Column numbering starts with 1.
        # numVals     - If negative or zero, all list values are inserted.
        #               If positive, $numVals columns are filled with the list values
        #               (starting at list index 0).
        #
        # Returns no value. If $valList is an empty list, an error is thrown.
        #
        # See also: GetRowValues SetColumnValues SetCellValue ColumnCharToInt

        set len [llength $valList]
        if { $numVals > 0 } {
            if { $numVals < $len } {
                set len $numVals
            }
        }

        set cellId [Excel SelectRangeByIndex $worksheetId \
                    $row $startCol $row [expr {$startCol + $len -1}]]
        Excel SetRangeValues $cellId [list $valList]
        Cawt Destroy $cellId
    }

    proc GetRowValues { worksheetId row { startCol 0 } { numVals 0 } } {
        # Return row values as a Tcl list.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # startCol    - Column number of start. Column numbering starts with 1.
        #               If negative or zero, start at first available column.
        # numVals     - If negative or zero, all available row values are returned.
        #               If positive, only $numVals values of the row are returned.
        #
        # Note, that the functionality of this procedure has changed slightly with
        # CAWT versions greater than 1.0.5:
        # If $startCol is not specified, $startCol is not set to 1, but it is set to
        # the first available row.
        # Possible incompatibility.
        #
        # Returns the values of the specified row or row range as a Tcl list.
        #
        # See also: SetRowValues GetColumnValues GetCellValue ColumnCharToInt GetFirstUsedColumn

        if { $startCol <= 0 } {
            set startCol [Excel GetFirstUsedColumn $worksheetId]
        }
        if { $numVals <= 0 } {
            set numVals [expr { $startCol + [Excel GetLastUsedColumn $worksheetId] - 1 }]
        }
        set valList [list]
        set col $startCol
        set ind 0
        while { $ind < $numVals } {
            lappend valList [Excel GetCellValue $worksheetId $row $col]
            incr ind
            incr col
        }

        # Remove empty cell values from the end of the values list.
        incr ind -1
        while { $ind >= 0 && [lindex $valList $ind] eq "" } {
            incr ind -1
        }
        return [lrange $valList 0 $ind]
    }

    proc InsertRow { worksheetId row } {
        # Insert a new empty row.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        #
        # A new empty row is inserted at given row number.
        #
        # Returns no value.
        #
        # See also: DeleteRow DuplicateRow HideRow InsertColumn

        set cell [Excel SelectCellByIndex $worksheetId $row 1]
        $cell -with { EntireRow } Insert $::Excel::xlDown $::Excel::xlFormatFromLeftOrAbove
        Cawt Destroy $cell
    }

    proc DuplicateRow { worksheetId row } {
        # Duplicate a row.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        #
        # The specified row is duplicated with formatting and formulas.
        #
        # Returns no value.
        #
        # See also: InsertRow DeleteRow HideRow DuplicateColumn

        set cell [Excel SelectCellByIndex $worksheetId $row 1]
        $cell -with { EntireRow } Copy
        Cawt Destroy $cell

        set cell [Excel SelectCellByIndex $worksheetId [expr {$row + 1}] 1]
        $cell -with { EntireRow } Insert $::Excel::xlUp
        Cawt Destroy $cell
    }

    proc DeleteRow { worksheetId row } {
        # Delete a row.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        #
        # The specified row is deleted.
        #
        # Returns no value.
        #
        # See also: InsertRow DuplicateRow HideRow DeleteColumn DeleteWorksheet

        set cell [Excel SelectCellByIndex $worksheetId $row 1]
        $cell -with { EntireRow } Delete $::Excel::xlShiftUp
        Cawt Destroy $cell
    }

    proc HideRow { worksheetId row { hide true } } {
        # Hide or unhide a row.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # hide        - If set to true, the specified row is hidden,
        #               otherwise it is shown.
        #
        # Returns no value.
        #
        # See also: InsertRow DeleteRow DuplicateRow GetHiddenRows HideColumn

        set cell [Excel SelectCellByIndex $worksheetId $row 1]
        $cell -with { EntireRow } Hidden [Cawt TclBool $hide]
        Cawt Destroy $cell
    }

    proc GetHiddenRows { worksheetId } {
        # Return the hidden rows of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the hidden rows as a list of row numbers.
        # If no rows are hidden, an empty list is returned.
        # Row numbering starts with 1.
        #
        # See also: HideRow GetHiddenColumns ColumnCharToInt

        set numUsedRows [Excel GetNumUsedRows $worksheetId]
        set hiddenList  [list]
        for { set r 1 } { $r <= $numUsedRows } { incr r } {
            set cell [Excel SelectCellByIndex $worksheetId $r 1]
            set isHidden [$cell -with { EntireRow } Hidden]
            if { $isHidden } {
                lappend hiddenList $r
            }
            Cawt Destroy $cell
        }
        return $hiddenList
    }

    proc SetRowHeight { worksheetId row { height 0 } } {
        # Set the height of a row.
        #
        # worksheetId - Identifier of the worksheet.
        # row         - Row number. Row numbering starts with 1.
        # height      - A positive value specifies the row's height.
        #               A value of zero specifies that the rows's height
        #               fits automatically the height of all elements in the row.
        #
        # The height value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: SetRowsHeight SetColumnWidth ColumnCharToInt

        set cell [Excel SelectCellByIndex $worksheetId $row 1]
        set curRow [$cell EntireRow]
        set height [Cawt ValueToPoints $height]
        if { $height == 0 } {
            $curRow -with { Rows } AutoFit
        } else {
            $curRow RowHeight $height
        }
        Cawt Destroy $curRow
        Cawt Destroy $cell
    }

    proc SetRowsHeight { worksheetId startRow endRow { height 0 } } {
        # Set the height of a range of rows.
        #
        # worksheetId - Identifier of the worksheet.
        # startRow    - Range start row number. Row numbering starts with 1.
        # endRow      - Range end row number. Row numbering starts with 1.
        # height      - A positive value specifies the row's height.
        #               A value of zero specifies that the rows's height
        #               fits automatically the height of all elements in the row.
        #
        # The height value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: SetRowHeight SetColumnsWidth ColumnCharToInt

        for { set r $startRow } { $r <= $endRow } { incr r } {
            Excel SetRowHeight $worksheetId $r $height
        }
    }

    proc SetColumnWidth { worksheetId col { width 0 } } {
        # Set the width of a column.
        #
        # worksheetId - Identifier of the worksheet.
        # col         - Column number. Column numbering starts with 1.
        # width       - A positive value specifies the column's width in average-size characters
        #               of the widget's font. A value of zero specifies that the column's width
        #               fits automatically the width of all elements in the column.
        #
        # Returns no value.
        #
        # See also: SetColumnsWidth ColumnCharToInt

        set cell [Excel SelectCellByIndex $worksheetId 1 $col]
        set curCol [$cell EntireColumn]
        if { $width == 0 } {
            $curCol -with { Columns } AutoFit
        } else {
            $curCol ColumnWidth $width
        }
        Cawt Destroy $curCol
        Cawt Destroy $cell
    }

    proc SetColumnsWidth { worksheetId startCol endCol { width 0 } } {
        # Set the width of a range of columns.
        #
        # worksheetId - Identifier of the worksheet.
        # startCol    - Range start column number. Column numbering starts with 1.
        # endCol      - Range end column number. Column numbering starts with 1.
        # width       - A positive value specifies the column's width in average-size characters
        #               of the widget's font. A value of zero specifies that the column's width
        #               fits automatically the width of all elements in the column.
        #
        # Returns no value.
        #
        # See also: SetColumnWidth ColumnCharToInt

        for { set c $startCol } { $c <= $endCol } { incr c } {
            Excel SetColumnWidth $worksheetId $c $width
        }
    }

    proc InsertColumn { worksheetId col } {
        # Insert a new empty column.
        #
        # worksheetId - Identifier of the worksheet.
        # col         - Column number. Column numbering starts with 1.
        #
        # A new empty column is inserted at given column number.
        #
        # Returns no value.
        #
        # See also: DeleteColumn DuplicateColumn HideColumn InsertRow

        set cell [Excel SelectCellByIndex $worksheetId 1 $col]
        $cell -with { EntireColumn } Insert $::Excel::xlToRight $::Excel::xlFormatFromLeftOrAbove
        Cawt Destroy $cell
    }

    proc DuplicateColumn { worksheetId col } {
        # Duplicate a column.
        #
        # worksheetId - Identifier of the worksheet.
        # col         - Column number. Column numbering starts with 1.
        #
        # The specified column is duplicated with formatting and formulas.
        #
        # Returns no value.
        #
        # See also: InsertColumn DeleteColumn HideColumn DuplicateRow

        set cell [Excel SelectCellByIndex $worksheetId 1 $col]
        $cell -with { EntireColumn } Copy
        Cawt Destroy $cell

        set cell [Excel SelectCellByIndex $worksheetId 1 [expr {$col + 1}]]
        $cell -with { EntireColumn } Insert $::Excel::xlToRight
        Cawt Destroy $cell
    }

    proc DeleteColumn { worksheetId col } {
        # Delete a column.
        #
        # worksheetId - Identifier of the worksheet.
        # col         - Column number. Column numbering starts with 1.
        #
        # The specified column is deleted.
        #
        # Returns no value.
        #
        # See also: InsertColumn DuplicateColumn HideColumn DeleteRow DeleteWorksheet

        set cell [Excel SelectCellByIndex $worksheetId 1 $col]
        $cell -with { EntireColumn } Delete $::Excel::xlShiftToLeft
        Cawt Destroy $cell
    }

    proc HideColumn { worksheetId col { hide true } } {
        # Hide or unhide a column.
        #
        # worksheetId - Identifier of the worksheet.
        # col         - Column number. Column numbering starts with 1.
        # hide        - If set to true, the specified column is hidden,
        #               otherwise it is shown.
        #
        # Returns no value.
        #
        # See also: InsertColumn DeleteColumn DuplicateColumn GetHiddenColumns HideRow

        set cell [Excel SelectCellByIndex $worksheetId 1 $col]
        $cell -with { EntireColumn } Hidden [Cawt TclBool $hide]
        Cawt Destroy $cell
    }

    proc GetHiddenColumns { worksheetId } {
        # Return the hidden columns of a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the hidden columns as a list of column numbers.
        # If no columns are hidden, an empty list is returned.
        # Column numbering starts with 1.
        #
        # See also: HideColumn GetHiddenRows ColumnCharToInt

        set numUsedCols [Excel GetNumUsedColumns $worksheetId]
        set hiddenList  [list]
        for { set c 1 } { $c <= $numUsedCols } { incr c } {
            set cell [Excel SelectCellByIndex $worksheetId 1 $c]
            set isHidden [$cell -with { EntireColumn } Hidden]
            if { $isHidden } {
                lappend hiddenList $c
            }
            Cawt Destroy $cell
        }
        return $hiddenList
    }

    proc SetColumnValues { worksheetId col valList { startRow 1 } { numVals 0 } } {
        # Insert column values from a Tcl list.
        #
        # worksheetId - Identifier of the worksheet.
        # col         - Column number. Column numbering starts with 1.
        # valList     - List of values to be inserted.
        # startRow    - Row number of insertion start. Row numbering starts with 1.
        # numVals     - If negative or zero, all list values are inserted.
        #               If positive, $numVals rows are filled with the list values
        #               (starting at list index 0).
        #
        # Returns no value.
        #
        # See also: GetColumnValues SetRowValues SetCellValue ColumnCharToInt

        set len [llength $valList]
        if { $numVals > 0 } {
            if { $numVals < $len } {
                set len $numVals
            }
        }

        for { set i 0 } { $i < $len } { incr i } {
            lappend valListList [list [lindex $valList $i]]
        }
        set cellId [Excel SelectRangeByIndex $worksheetId \
                    $startRow $col [expr {$startRow + $len - 1}] $col]
        Excel SetRangeValues $cellId $valListList
        Cawt Destroy $cellId
    }

    proc GetColumnValues { worksheetId col { startRow 0 } { numVals 0 } } {
        # Return column values as a Tcl list.
        #
        # worksheetId - Identifier of the worksheet.
        # col         - Column number. Column numbering starts with 1.
        # startRow    - Row number of start. Row numbering starts with 1.
        #               If negative or zero, start at first available row.
        # numVals     - If negative or zero, all available column values are returned.
        #               If positive, only numVals values of the column are returned.
        #
        # Note, that the functionality of this procedure has changed slightly with
        # CAWT versions greater than 1.0.5:
        # If $startRow is not specified, $startRow is not set to 1, but it is set to
        # the first available row.
        # Possible incompatibility.
        #
        # Returns the values of the specified column or column range as a Tcl list.
        #
        # See also: SetColumnValues GetRowValues GetCellValue ColumnCharToInt GetFirstUsedRow

        if { $startRow <= 0 } {
            set startRow [Excel GetFirstUsedRow $worksheetId]
        }
        if { $numVals <= 0 } {
            set numVals [expr { $startRow + [Excel GetLastUsedRow $worksheetId] - 1 }]
        }
        set valList [list]
        set row $startRow
        set ind 0
        while { $ind < $numVals } {
            lappend valList [Excel GetCellValue $worksheetId $row $col]
            incr ind
            incr row
        }

        # Remove empty cell values from the end of the values list.
        incr ind -1
        while { $ind >= 0 && [lindex $valList $ind] eq "" } {
            incr ind -1
        }
        return [lrange $valList 0 $ind]
    }

    proc SetRangeValues { rangeId matrixList } {
        # Set range values from a matrix.
        #
        # rangeId    - Identifier of the cell range.
        # matrixList - Matrix with table data.
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
        # See also: GetRangeValues SetMatrixValues SetRowValues SetColumnValues SetCellValue

        $rangeId Value2 $matrixList
    }

    proc GetRangeValues { rangeId } {
        # Return range values as a matrix.
        #
        # rangeId - Identifier of the cell range.
        #
        # Returns the range values as a matrix.
        #
        # See also: SetRangeValues GetMatrixValues GetRowValues GetColumnValues GetCellValue

        return [$rangeId Value2]
    }

    proc SetMatrixValues { worksheetId matrixList { startRow 1 } { startCol 1 } } {
        # Insert matrix values into a worksheet.
        #
        # worksheetId - Identifier of the worksheet.
        # matrixList  - Matrix with table data.
        # startRow    - Row number of insertion start. Row numbering starts with 1.
        # startCol    - Column number of insertion start. Column numbering starts with 1.
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
        # See also: GetMatrixValues SetRowValues SetColumnValues

        set numRows [llength $matrixList]
        if { $numRows == 0 } {
            return
        }
        set numCols [llength [lindex $matrixList 0]]
        if { $numCols == 0 } {
            return
        }

        set cellId [Excel SelectRangeByIndex $worksheetId \
                    $startRow $startCol \
                    [expr {$startRow + $numRows -1}] [expr {$startCol + $numCols -1}]]
        Excel SetRangeValues $cellId $matrixList
        Cawt Destroy $cellId
    }

    proc GetMatrixValues { worksheetId row1 col1 row2 col2 } {
        # Return worksheet table values as a matrix.
        #
        # worksheetId - Identifier of the worksheet.
        # row1        - Row number of upper-left corner of the cell range.
        # col1        - Column number of upper-left corner of the cell range.
        # row2        - Row number of lower-right corner of the cell range.
        # col2        - Column number of lower-right corner of the cell range.
        #
        # Returns the worksheet table values as a matrix.
        #
        # See also: SetMatrixValues GetRowValues GetColumnValues

        set cellId [Excel SelectRangeByIndex $worksheetId $row1 $col1 $row2 $col2]
        set matrixList [Excel GetRangeValues $cellId]

        Cawt Destroy $cellId
        return $matrixList
    }

    proc GetWorksheetAsMatrix { worksheetId } {
        # Return worksheet table as a matrix.
        #
        # worksheetId - Identifier of the worksheet.
        #
        # Returns the range of the worksheet with valid data as
        # a matrix.
        #
        # See also: SetMatrixValues GetMatrixValues GetFirstUsedRow GetLastUsedRow

        return [Excel GetMatrixValues $worksheetId \
                   [Excel GetFirstUsedRow $worksheetId] \
                   [Excel GetFirstUsedColumn $worksheetId] \
                   [Excel GetLastUsedRow $worksheetId] \
                   [Excel GetLastUsedColumn $worksheetId]]
    }
}
