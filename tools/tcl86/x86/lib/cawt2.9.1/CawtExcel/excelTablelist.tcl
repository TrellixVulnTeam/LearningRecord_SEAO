# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Excel {

    namespace ensemble create

    namespace export GetTablelistHeader
    namespace export GetTablelistValues
    namespace export SetTablelistHeader
    namespace export SetTablelistValues
    namespace export TablelistToWorksheet
    namespace export WorksheetToTablelist

    proc GetTablelistHeader { tableId } {
        # Return the header line of a tablelist as a list.
        #
        # tableId - Identifier of the tablelist.
        #
        # Returns the header line of the tablelist as a list.
        #
        # See also: TablelistToWorksheet WorksheetToTablelist
        # SetTablelistHeader GetTablelistValues

        set numCols [$tableId columncount]
        for { set col 0 } { $col < $numCols } { incr col } {
            lappend headerList [$tableId columncget $col -title]
        }
        return $headerList
    }

    proc GetTablelistValues { tableId } {
        # Return the values of a tablelist as a matrix.
        #
        # tableId - Identifier of the tablelist.
        #
        # Returns the values of the tablelist as a matrix.
        #
        # See also: TablelistToWorksheet WorksheetToTablelist
        # SetTablelistValues GetTablelistHeader

        return [$tableId get 0 end]
    }

    proc SetTablelistHeader { tableId headerList } {
        # Insert header values into a tablelist.
        #
        # tableId    - Identifier of the tablelist.
        # headerList - List with table header data.
        #
        # Returns no value.
        #
        # See also: TablelistToWorksheet WorksheetToTablelist
        # SetTablelistValues GetTablelistHeader

        foreach title $headerList {
            $tableId insertcolumns end 0 $title left
        }
    }

    proc SetTablelistValues { tableId matrixList } {
        # Insert matrix values into a tablelist.
        #
        # tableId    - Identifier of the tablelist.
        # matrixList - Matrix with table data.
        #
        # Returns no value.
        #
        # See also: TablelistToWorksheet WorksheetToTablelist
        # SetTablelistHeader GetTablelistValues

        foreach rowList $matrixList {
            $tableId insert end $rowList
        }
    }

    proc TablelistToWorksheet { tableId worksheetId { useHeader true } { startRow 1 } } {
        # Insert the values of a tablelist into a worksheet.
        #
        # tableId     - Identifier of the tablelist.
        # worksheetId - Identifier of the worksheet.
        # useHeader   - If set to true, insert the header of the tablelist as first row.
        #               Otherwise only transfer the tablelist data.
        # startRow    - Row number of insertion start. Row numbering starts with 1.
        #
        # **Note:** 
        # The contents of hidden columns are transfered to Excel and are hidden there, too.
        # If the tablelist contains a column with automatic line numbering, this column is
        # transfered to Excel, too. If this behaviour is not wished, use the [DeleteColumn]
        # procedure to delete the corresponding column in Excel.
        #
        # Returns no value.
        #
        # See also: WorksheetToTablelist SetMatrixValues
        # WikitFileToWorksheet MediaWikiFileToWorksheet MatlabFileToWorksheet
        # RawImageFileToWorksheet WordTableToWorksheet

        set curRow $startRow
        set numCols [$tableId columncount]
        if { $useHeader } {
            set headerList [list]
            for { set col 0 } { $col < $numCols } { incr col } {
                lappend headerList [$tableId columncget $col -title]
            }
            Excel SetHeaderRow $worksheetId $headerList $curRow
            incr curRow
        }
        set matrixList [$tableId get 0 end]
        Excel SetMatrixValues $worksheetId $matrixList $curRow 1
        for { set col 0 } { $col < $numCols } { incr col } {
            if { [$tableId columncget $col -hide] } {
                Excel HideColumn $worksheetId [expr {$col + 1}]
            }
        }
    }

    proc WorksheetToTablelist { worksheetId tableId args } {
        # Insert the values of a worksheet into a tablelist.
        #
        # worksheetId - Identifier of the worksheet.
        # tableId     - Identifier of the tablelist.
        # args        - Options described below.
        #
        # -header <bool>    - If set to true, use the first row of the worksheet as 
        #                     header labels of the tablelist. Default: false.
        # -rownumber <bool> - If set to true, use the first column of the tablelist
        #                     to display the row number. Default: false.
        # -maxrows <int>    - Specify the maximum number of Excel rows being transfered
        #                     to the tablelist. Default: All used rows.
        # -maxcols <int>    - Specify the maximum number of Excel columns being transfered
        #                     to the tablelist. Default: All used columns.
        # -selection <bool> - Transfer the selected Excel cell range. Overwrites values
        #                     specified by `-maxrows`and `-maxcols`.
        #
        # **Note:**
        # The tablelist is cleared before transfer.
        # The contents of hidden columns are transfered from Excel to the tablelist
        # and are hidden there, too.
        #
        # Returns no value.
        #
        # See also: TablelistToWorksheet GetMatrixValues
        # WorksheetToWikitFile WorksheetToMediaWikiFile WorksheetToMatlabFile
        # WorksheetToRawImageFile WorksheetToWordTable

        set useHeader    false
        set useRowNum    false
        set useSelection false
        set maxRows      0
        set maxCols      0
        foreach { key value } $args {
            if { $key == 1 || $key == 0 || $key == true || $key == false } {
                set useHeader $key
                puts "WorksheetToTablelist: Signature has been changed. Use -header <bool> instead."
                continue
            }
            if { $value eq "" } {
                error "WorksheetToTablelist: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-header"    { set useHeader    $value }
                "-selection" { set useSelection $value }
                "-rownumber" { set useRowNum    $value }
                "-maxrows"   { set maxRows      $value }
                "-maxcols"   { set maxCols      $value }
                default      { error "WorksheetToTablelist: Unknown key \"$key\" specified" }
            }
        }

        set numRows [Excel GetLastUsedRow $worksheetId]
        set numCols [Excel GetLastUsedColumn $worksheetId]
        if { $maxRows > 0 && $maxRows < $numRows } {
            set numRows $maxRows
        }
        if { $maxCols > 0 && $maxCols < $numCols } {
            set numCols $maxCols
        }
        set startRow 1
        set startCol 1
        set endRow   $numRows
        set endCol   $numCols
        if { $useSelection } {
            set appId [Office GetApplicationId $worksheetId]
            set selection [$appId Selection]
            set selectionRange [Excel GetRangeAsIndex $selection]
            if { [llength $selectionRange] == 2 } {
                set startRow [lindex $selectionRange 0]
                set startCol [lindex $selectionRange 1]
                set endRow   $startRow
                set endCol   $startCol
                set numRows  1
                set numCols  1
            } else {
                set startRow [lindex $selectionRange 0]
                set startCol [lindex $selectionRange 1]
                set endRow   [lindex $selectionRange 2]
                set endCol   [lindex $selectionRange 3]
                set numRows  [expr { $endRow - $startRow + 1 }]
                set numCols  [expr { $endCol - $startCol + 1 }]
            }
        }
        set columnList [list]
        if { $useRowNum } {
            lappend columnList 0 "#" left
        }
        if { $useHeader } {
            set headerList [Excel GetRowValues $worksheetId 1 $startCol $numCols]
            foreach title $headerList {
                lappend columnList 0 $title left
            }
            if { ! $useSelection } {
                incr startRow
            }
        } else {
            for { set col $startCol } { $col <= $endCol } { incr col } {
                lappend columnList 0 [ColumnIntToChar $col] left
            }
        }

        # Delete table content and all columns.
        $tableId delete 0 end
        if { [$tableId columncount] > 0 } {
            $tableId deletecolumns 0 end
        }

        $tableId insertcolumnlist end $columnList
        set excelList [Excel GetMatrixValues $worksheetId $startRow $startCol $endRow $endCol]
        if { $useRowNum } {
            foreach rowList $excelList {
                $tableId insert end [list "" {*}$rowList]
            }
        } else {
            foreach rowList $excelList {
                $tableId insert end $rowList
            }
        }
        set colAdd 0
        if { $useRowNum } {
            $tableId columnconfigure 0 -showlinenumbers true
            set colAdd 1
        }
        foreach col [Excel GetHiddenColumns $worksheetId] {
            $tableId columnconfigure [expr {$col + $colAdd - 1}] -hide true
        }
    }
}
