#! /usr/bin/env tclsh
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020-2021 D. Bohdan
# License: MIT

package require Tcl 8.6-10
package require cmdline
package require snit 2
package require sqlite3

namespace eval ::sqawk {
    variable version 0.23.1
}

# The following comment is used by Assemble when bundling Sqawk's source code in
# a single file. Do not remove it.
interp alias {} ::source+ {} ::source

# ============================= lib/tabulate.tcl ===============================
#! /usr/bin/env tclsh
# Tabulate -- turn standard input into a table.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT
namespace eval ::tabulate {
    variable version 0.11.0
}
namespace eval ::tabulate::style {
    variable default {
        top {
            left ┌
            padding ─
            separator ┬
            right ┐
        }
        separator {
            left ├
            padding ─
            separator ┼
            right ┤
        }
        row {
            left │
            padding { }
            separator │
            right │
        }
        bottom {
            left └
            padding ─
            separator ┴
            right ┘
        }
    }
    variable loFi {
        top {
            left +
            padding -
            separator +
            right +
        }
        separator {
            left +
            padding -
            separator +
            right +
        }
        row {
            left |
            padding { }
            separator |
            right |
        }
        bottom {
            left +
            padding -
            separator +
            right +
        }
    }
}

namespace eval ::tabulate::options {}

# Simulate named arguments in procedures that accept "args".
# Usage: process store <key in the caller's $tokens> in <name of a variable in
# the caller's scope> ?default <default value>? ?store ...?
proc ::tabulate::options::process args {
    set opts [lindex $args 0]
    set parsed [parse-dsl [lrange $args 1 end]]
    uplevel 1 [list ::tabulate::options::process-parsed $opts $parsed]
}

# Convert the human-readable options DSL (see the proc parse below for its
# syntax) into a machine-readable format (a list of dicts).
proc ::tabulate::options::parse-dsl tokens {
    set i 0 ;# $tokens index

    set result {}

    while {$i < [llength $tokens]} {
        switch -exact -- [current] {
            store {
                next

                set item {}
                dict set item useDefaultValue 0

                # Parse.
                dict set item flags [current]
                next
                while {[current] eq {or}} {
                    next
                    dict lappend item flags [current]
                    next
                }
                expect in
                next
                dict set item varName [current]
                next

                if {[current] eq {default}} {
                    next
                    dict set item useDefaultValue 1
                    dict set item defaultValue [current]
                    next
                }
            }
            default {
                error [list unknown keyword: [current]; expected store]
            }
        }
        lappend result $item
    }

    return $result
}

# Go to the next token in the proc parse-dsl.
proc ::tabulate::options::next {} {
    upvar 1 i i
    incr i
}

# Return the current token in the proc parse-dsl.
proc ::tabulate::options::current {} {
    upvar 1 i i
    upvar 1 tokens tokens
    return [lindex $tokens $i]
}

# Throw an error unless the current token equals $expected.
proc ::tabulate::options::expect expected {
    set current [uplevel 1 current]
    if {$current ne $expected} {
        error [list expected $expected but got $current]
    }
}

# Process the options in $opts and set the corresponding variables in the
# caller's scope. $declaredOptions is a list of dicts as returns by the proc
# parse-dsl.
proc ::tabulate::options::process-parsed {opts declaredOptions} {
    set possibleOptions {}

    foreach item $declaredOptions {
        # Store value in the caller's variable $varName.
        upvar 1 [dict get $item varName] var

        set flags [dict get $item flags]
        set currentOptionSynonyms [format-flag-synonyms $flags]
        lappend possibleOptions $currentOptionSynonyms
        # Do not use dict operations on $opts in order to produce a proper error
        # message manually below if $opts has an odd number of items.
        set found {}
        foreach flag $flags {
            set keyIndex [lsearch -exact $opts $flag]
            if {$keyIndex > -1} {
                if {$keyIndex + 1 == [llength $opts]} {
                    error [list no value given for option $flag]
                }
                set var [lindex $opts $keyIndex+1]

                # Remove $flag and the corresponding value from opts.
                set temp {}
                lappend temp {*}[lrange $opts 0 $keyIndex-1]
                lappend temp {*}[lrange $opts $keyIndex+2 end]
                set opts $temp

                lappend found $flag
            }
        }
        if {[llength $found] == 0} {
            if {[dict get $item useDefaultValue]} {
                set var [dict get $item defaultValue]
            } else {
                error [list no option $currentOptionSynonyms given]
            }
        } elseif {[llength $found] > 1} {
            error [list can't use the flags $found together]
        }

    }

    # Ensure $opts is empty.
    if {[llength $opts] > 0} {
        error [list unknown option(s): $opts; can use: $possibleOptions]
    }
}

# Return a formatted message listing flag synonyms for an option. The first flag
# is considered the main.
proc ::tabulate::options::format-flag-synonyms flags {
    set result \"[lindex $flags 0]\"
    if {[llength $flags] > 1} {
       append result " (\"[join [lrange $flags 1 end] {", "}]\")"
    }
    return $result
}

# Return a value from dictionary like [dict get] would if it is there.
# Otherwise return the default value.
proc ::tabulate::dict-get-default {dictionary default args} {
    if {[dict exists $dictionary {*}$args]} {
        dict get $dictionary {*}$args
    } else {
        return $default
    }
}

# Convert a list of lists into a string representing a table in pseudographics.
proc ::tabulate::tabulate args {
    options::process $args \
        store -data in data \
        store -style in style default $::tabulate::style::default \
        store -alignments or -align in alignments default {} \
        store -margins in margins default 0

    # Find out the maximum width of each column.
    set columnWidths {} ;# Dictionary.
    foreach row $data {
        for {set i 0} {$i < [llength $row]} {incr i} {
            set field [lindex $row $i]
            set currentLength [string length $field]
            set width [::tabulate::dict-get-default $columnWidths 0 $i]
            if {($currentLength > $width) || ($width == 0)} {
                dict set columnWidths $i $currentLength
            }
        }
    }

    # A dummy row for formatting the table's decorative elements with
    # [formatRow].
    set emptyRow {}
    for {set i 0} {$i < ([llength $columnWidths] / 2)} {incr i} {
        lappend emptyRow {}
    }

    set result {}
    set rowCount [llength $data]
    # Top of the table.
    lappend result [::tabulate::formatRow \
            -substyle [dict get $style top] \
            -row $emptyRow \
            -widths $columnWidths \
            -alignments $alignments \
            -margins $margins]
    # For each row...
    for {set i 0} {$i < $rowCount} {incr i} {
        set row [lindex $data $i]
        # Row.
        lappend result [::tabulate::formatRow \
                -substyle [dict get $style row] \
                -row $row \
                -widths $columnWidths \
                -alignments $alignments \
                -margins $margins]
        # Separator.
        if {$i < $rowCount - 1} {
            lappend result [::tabulate::formatRow \
                    -substyle [dict get $style separator] \
                    -row $emptyRow \
                    -widths $columnWidths \
                    -alignments $alignments \
                    -margins $margins]
        }
    }
    # Bottom of the table.
    lappend result [::tabulate::formatRow \
            -substyle [dict get $style bottom] \
            -row $emptyRow \
            -widths $columnWidths \
            -alignments $alignments \
            -margins $margins]

    return [join $result \n]
}

# Format a list as a table row. Does *not* append a newline after the row.
# $columnAlignments is a list that contains one alignment ("left", "right" or
# "center") for each column. If there are more columns than alignments in
# $columnAlignments "center" is assumed for those columns.
proc ::tabulate::formatRow args {
    options::process $args \
        store -substyle in substyle \
        store -row in row \
        store -widths in columnWidths \
        store -alignments or -align in columnAlignments default {} \
        store -margins in margins default 0

    set result {}
    append result [dict get $substyle left]
    set fieldCount [expr { [llength $columnWidths] / 2 }]
    for {set i 0} {$i < $fieldCount} {incr i} {
        set field [lindex $row $i]
        set padding [expr {
            [dict get $columnWidths $i] - [string length $field] + 2 * $margins
        }]
        set alignment [lindex $columnAlignments $i]
        switch -exact -- $alignment {
            {} -
            c -
            center {
                set leftPadding [expr { $padding / 2 }]
                set rightPadding [expr { $padding - $leftPadding }]
            }
            l -
            left {
                set leftPadding $margins
                set rightPadding [expr { $padding - $margins }]
            }
            r -
            right {
                set leftPadding [expr { $padding - $margins }]
                set rightPadding $margins
            }
            default {
                error [list unknown alignment: $alignment]
            }
        }
        append result [string repeat [dict get $substyle padding] $leftPadding]
        append result $field
        append result [string repeat [dict get $substyle padding] $rightPadding]
        if {$i < $fieldCount - 1} {
            append result [dict get $substyle separator]
        }
    }
    append result [dict get $substyle right]
    return $result
}

# Return the style value if $name is a valid style name.
proc ::tabulate::style::by-name name {
    if {[info exists ::tabulate::style::$name]} {
        return [set ::tabulate::style::$name]
    } else {
        set message {}
        lappend message "Unknown style name: \"$name\"; can use"
        foreach varName [info vars ::tabulate::style::*] {
            lappend message "   - \"[namespace tail $varName]\""
        }
        error [join $message \n]
    }
}

# Read the input, process the command line options and output the result.
proc ::tabulate::main {argv0 argv} {
    options::process $argv \
        store -FS in FS default {} \
        store -style in style default default \
        store -alignments or -align in alignments default {} \
        store -margins in margins default 0
    set data [lrange [split [read stdin] \n] 0 end-1]

    # Input field separator. If none is given treat each line of input as a Tcl
    # list.
    if {$FS ne {}} {
        set updateData {}
        foreach line $data {
            lappend updateData [split $line $FS]
        }
        set data $updateData
    }
    # Accept style names rather than style *values* that ::tabulate::tabulate
    # normally takes.
    set styleName [::tabulate::dict-get-default $argv default -style]

    puts [tabulate -data $data \
            -style [::tabulate::style::by-name $style] \
            -alignments $alignments \
            -margins $margins]
}


# =========================== end lib/tabulate.tcl =============================

# ============================== lib/utils.tcl =================================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk {}

# If key $key is absent in the dictionary variable $dictVarName set it to
# $value.
proc ::sqawk::dict-ensure-default {dictVarName key value} {
    upvar 1 $dictVarName dictionary
    set dictionary [dict merge [list $key $value] $dictionary]
}

# Return a subdictionary of $dictionary with only the keys in $keyList and the
# corresponding values.
proc ::sqawk::filter-keys {dictionary keyList {mustExist 1}} {
    set result {}
    foreach key $keyList {
        if {!$mustExist && ![dict exists $dictionary $key]} {
            continue
        }
        dict set result $key [dict get $dictionary $key]
    }
    return $result
}

# Override the values for the existing keys in $dictionary but do add any new
# keys to it.
proc ::sqawk::override-keys {dictionary override} {
    dict for {key _} $dictionary {
        if {[dict exists $override $key]} {
            dict set dictionary $key [dict get $override $key]
        }
    }
    return $dictionary
}

# Helper procs to use as functions in SQLite.
proc ::sqawk::dict-exists {dict args} {
    return [dict exists $dict {*}$args]
}

proc ::sqawk::dict-get {dict args} {
    return [dict get $dict {*}$args]
}

# ============================ end lib/utils.tcl ===============================

# =========================== lib/parsers/awk.tcl ==============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk::parsers::awk {
    variable formats {
        awk
    }
    variable options {
        FS {}
        RS {}
        fields auto
        trim none
    }
}

# Split $str on separators that match $regexp. Returns a list consisting of
# fields and, if $includeSeparators is 1, the separators after each.
proc ::sqawk::parsers::awk::sepsplit {str regexp {includeSeparators 1}} {
    if {$str eq {}} {
        return {}
    }
    if {$regexp eq {}} {
        return [split $str {}]
    }
    # Thanks to KBK for the idea.
    if {[regexp $regexp {}]} {
        error [list splitting on regexp $regexp would cause infinite loop]
    }

    # Split $str into a list of fields and separators.
    set fieldsAndSeps {}
    set offset 0
    while {[regexp -start $offset -indices -- $regexp $str match]} {
        lassign $match matchStart matchEnd
        lappend fieldsAndSeps \
                [string range $str $offset [expr {$matchStart - 1}]]
        if {$includeSeparators} {
            lappend fieldsAndSeps \
                    [string range $str $matchStart $matchEnd]
        }
        set offset [expr {$matchEnd + 1}]
    }
    # Handle the remainder of $str after all the separators.
    set tail [string range $str $offset end]
    if {$tail eq {}} {
        # $str ended on a separator.
        if {!$includeSeparators} {
            lappend fieldsAndSeps {}
        }
    } else {
        lappend fieldsAndSeps $tail
        if {$includeSeparators} {
            lappend fieldsAndSeps {}
        }
    }

    return $fieldsAndSeps
}

# Returns $record trimmed according to $mode.
proc ::sqawk::parsers::awk::trim-record {record mode} {
    switch -exact -- $mode {
        both    { set record [string trim $record]      }
        left    { set record [string trimleft $record]  }
        right   { set record [string trimright $record] }
        none    {}
        default { error [list unknown mode: $mode]      }
    }
    return $record
}

# Return a list of columns.
# The format of $fieldsAndSeps is {field1 sep1 field2 sep2 ...}.
# The format of $fieldMap is {range1 range2 ... rangeN ?"auto"?}.
# For each field range in $fieldMap add an item to the list that consists of
# the merged contents of the fields in $fieldsAndSeps that fall into this range.
# E.g., for the range {1 5} an item with the contents of fields 1 through 5 (and
# the separators between them) will be added. The string "auto" as rangeN in
# $fieldMap causes [map] to add one column per field for every field in
# $fieldsAndSeps starting with fieldN and then return immediately.
proc ::sqawk::parsers::awk::map {fieldsAndSeps fieldMap} {
    set columns {}
    set currentColumn 0
    foreach mapping $fieldMap {
        if {$mapping eq {auto}} {
            foreach {field _} \
                    [lrange $fieldsAndSeps [expr {$currentColumn*2}] end] {
                lappend columns $field
            }
            break
        } elseif {[regexp {^[0-9]+\s+(?:end|[0-9]+)$} $mapping]} {
            lassign $mapping from to
            set from [expr {($from - 1)*2}]
            if {$to ne {end}} {
                set to [expr {($to - 1)*2}]
            }
            lappend columns [join [lrange $fieldsAndSeps $from $to] {}]
        } else {
            error [list unknown mapping: $mapping]
        }

        incr currentColumn
    }

    return $columns
}

# Parse a string like 1,2,3-5,auto into a list where each item is either a
# field range or the string "auto".
proc ::sqawk::parsers::awk::parseFieldMap fields {
    set itemRegExp {(auto|([0-9]+)(?:-(end|[0-9]+))?)}
    set ranges {}
    set start 0
    set length [string length $fields]
    while {($start < $length - 1) &&
            [regexp -indices -start $start ${itemRegExp}(,|$) $fields \
                    overall item rangeFrom rangeTo]} {
        set item [string range $fields {*}$item]

        if {$item eq {auto}} {
            lappend ranges auto
        } elseif {[string is integer -strict $item]} {
            lappend ranges [list $item $item]
        } elseif {($rangeFrom ne {-1 -1}) && ($rangeTo ne {-1 -1})} {
            lappend ranges [list \
                    [string range $fields {*}$rangeFrom] \
                    [string range $fields {*}$rangeTo]]
        } else {
            error [list can't parse item $item]
        }
        lassign $overall _ start
    }
    return $ranges
}

# Convert raw text data into a list of database rows using regular
# expressions.
::snit::type ::sqawk::parsers::awk::parser {
    variable RS
    variable FS
    variable fieldMap
    variable trim

    variable ch
    variable len
    variable offset 0
    variable buf {}

    variable step [expr {1024 * 1024}]

    constructor {channel options} {
        set ch $channel

        set RS [dict get $options RS]
        set FS [dict get $options FS]
        set fieldMap [::sqawk::parsers::awk::parseFieldMap \
                [dict get $options fields]]
        set trim [dict get $options trim]

        # Thanks to KBK for the idea.
        if {[regexp $RS {}]} {
            error [list splitting on RS regexp $RS would cause infinite loop]
        }
        if {[regexp $FS {}]} {
            error [list splitting on FS regexp $FS would cause infinite loop]
        }
    }

    method next {} {
        # Truncate the buffer.
        if {$offset >= $step} {
            set buf [string range $buf $offset end]
            set offset 0
        }
        # Fill up the buffer until we have at least one record.
        while {!([set regExpMatched \
                        [regexp -start $offset -indices -- $RS $buf match]]
                || [eof $ch])} {
            append buf [read $ch $step]
        }
        set len [string length $buf]
        if {$regExpMatched} {
            lassign $match matchStart matchEnd
            set record [string range $buf $offset [expr {$matchStart - 1}]]
            set offset [expr {$matchEnd + 1}]
        } elseif {$offset < $len} {
            set record [string range $buf $offset end]
            set offset $len
        } else {
            return -code break {}
        }

        set record [::sqawk::parsers::awk::trim-record $record $trim]

        if {($fieldMap eq {auto})} {
            return [list \
                    $record {*}[::sqawk::parsers::awk::sepsplit $record $FS 0]]
        } else {
            set columns [::sqawk::parsers::awk::map \
                    [::sqawk::parsers::awk::sepsplit $record $FS] \
                    $fieldMap]
            return [list $record {*}$columns]
        }
    }
}

# ========================= end lib/parsers/awk.tcl ============================

# =========================== lib/parsers/csv.tcl ==============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk::parsers::csv {
    variable formats {
        csv csv2 csvalt
    }
    variable options {
        format csv
        csvsep ,
        csvquote \"
    }
}

# Convert CSV data into a list of database rows.
::snit::type ::sqawk::parsers::csv::parser {
    variable separator
    variable quote
    variable altMode

    variable ch

    constructor {channel options} {
        package require csv

        set ch $channel

        set separator [dict get $options csvsep]
        set quote [dict get $options csvquote]
        set altMode [expr {
            [dict get $options format] in {csv2 csvalt}
        }]
    }

    method next {} {
        if {[gets $ch line] < 0} {
            return -code break {}
        }

        try {
            set row [list $line {*}[::csv::split \
                {*}[expr {$altMode ? {-alternate} : {}}] \
                $line \
                $separator \
                $quote \
            ]]
        } on error {errorMessage errorOptions} {
            dict set errorOptions -errorinfo [list \
                CSV decoding error: \
                [dict get $errorOptions -errorinfo] \
            ]
            return -options $errorOptions $errorMessage
        }
        return $row
    }
}

# ========================= end lib/parsers/csv.tcl ============================

# =========================== lib/parsers/json.tcl =============================
# Sqawk, an SQL Awk.
# Copyright (c) 2020 D. Bohdan
# License: MIT

package require json

namespace eval ::sqawk::parsers::json {
    variable formats {
        json
    }
    variable options {
        kv 1
        lines 0
    }
}

::snit::type ::sqawk::parsers::json::parser {
    variable kv
    variable linesMode

    variable ch
    variable data
    variable i
    variable keys
    variable len

    constructor {channel options} {
        set kv [dict get $options kv]
        set linesMode [dict get $options lines]
        set i [expr { $kv ? -1 : 0 }]

        if {$linesMode} {
            if {$kv} {
                set lines [split [string trim [read $channel]] \n]
                set data [lmap line $lines {
                    if {[regexp {^\s*$} $line]} continue
                    json::json2dict $line
                }]
            } else {
                # We ignore $data and $len in non-kv lines mode.
                set ch $channel
                set data %NEVER_USED%
            }
        } else {
            set data [json::json2dict [read $channel]]
        }

        set len [llength $data]
    }

    method next {} {
        if {$i == $len} {
            return -code break
        }

        if {!$kv} {
            if {$linesMode} {
                set line {}
                while {[set blank [regexp {^\s*$} $line]] && ![eof $ch]} {
                    gets $ch line
                }

                if {$blank && [eof $ch]} {
                    return -code break
                }

                set array [json::json2dict $line]
            } else {
                set array [lindex $data $i]
                incr i
            }

            return [list $array {*}$array]
        }

        if {$i == -1} {
            set allKeys [lsort -unique [concat {*}[lmap record $data {
                dict keys $record
            }]]]

            # Order the keys like they are ordered in the first row for
            # ergonomics.  Keys that aren't in the first row follow in
            # alphabetical order after those that are.
            set keys [dict keys [lindex $data 0]]
            foreach key $allKeys {
                if {$key ni $keys} {
                    lappend keys $key
                }
            }

            incr i
            return [list $keys {*}$keys]
        }

        set record [lindex $data $i]
        set row [list $record]
        foreach key $keys {
            if {[dict exists $record $key]} {
                lappend row [dict get $record $key]
            } else {
                lappend row {}
            }
        }

        incr i
        return $row
    }
}

# ========================= end lib/parsers/json.tcl ===========================

# =========================== lib/parsers/tcl.tcl ==============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk::parsers::tcl {
    variable formats {
        tcl
    }
    variable options {
        kv 0
        lines 0
    }
}

::snit::type ::sqawk::parsers::tcl::parser {
    variable kv
    variable linesMode

    variable ch
    variable data
    variable i
    variable keys
    variable len

    constructor {channel options} {
        set kv [dict get $options kv]
        set linesMode [dict get $options lines]

        set i [expr { $kv ? -1 : 0 }]
        if {$linesMode} {
            if {$kv} {
                set lines [split [string trim [read $channel]] \n]
                set data [lmap line $lines {
                    if {[regexp {^\s*$} $line]} continue
                    set line
                }]
            } else {
                set ch $channel
                set data %NEVER_USED%
            }
        } else {
            set data [read $channel]
        }
        set len [llength $data]
    }

    method next {} {
        if {$i == $len} {
            return -code break
        }

        if {!$kv} {
            if {$linesMode} {
                set line {}
                while {[set blank [regexp {^\s*$} $line]] && ![eof $ch]} {
                    gets $ch line
                }

                if {$blank && [eof $ch]} {
                    return -code break
                }

                set list $line
            } else {
                set list [lindex $data $i]
                incr i
            }

            return [list $list {*}$list]
        }

        if {$i == -1} {
            set allKeys [lsort -unique [concat {*}[lmap record $data {
                dict keys $record
            }]]]

            # Order the keys like they are ordered in the first row for
            # ergonomics.  Keys that aren't in the first row follow in
            # alphabetical order after those that are.
            set keys [dict keys [lindex $data 0]]
            foreach key $allKeys {
                if {$key ni $keys} {
                    lappend keys $key
                }
            }

            incr i
            return [list $keys {*}$keys]
        }

        set record [lindex $data $i]
        set row [list $record]
        foreach key $keys {
            if {[dict exists $record $key]} {
                lappend row [dict get $record $key]
            } else {
                lappend row {}
            }
        }

        incr i
        return $row
    }
}

# ========================= end lib/parsers/tcl.tcl ============================

# ========================= lib/serializers/awk.tcl ============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018 D. Bohdan
# License: MIT

namespace eval ::sqawk::serializers::awk {
    variable formats {
        awk
    }
    variable options {
        ofs {}
        ors {}
    }
}

# Convert records to text.
::snit::type ::sqawk::serializers::awk::serializer {
    variable ch
    variable OFS
    variable ORS

    constructor {channel options} {
        set ch $channel
        set OFS [dict get $options ofs]
        set ORS [dict get $options ors]
    }

    method serialize record {
        puts -nonewline $ch [join [dict values $record] $OFS]$ORS
    }
}

# ======================= end lib/serializers/awk.tcl ==========================

# ========================= lib/serializers/csv.tcl ============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018 D. Bohdan
# License: MIT

namespace eval ::sqawk::serializers::csv {
    variable formats {
        csv
    }
    variable options {}
}

# Convert records to CSV.
::snit::type ::sqawk::serializers::csv::serializer {
    variable ch

    constructor {channel options} {
        package require csv

        set ch $channel
    }

    method serialize record {
        puts $ch [::csv::join [dict values $record]]
    }
}

# ======================= end lib/serializers/csv.tcl ==========================

# ========================= lib/serializers/json.tcl ===========================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk::serializers::json {
    variable formats {
        json
    }
    variable options {
        pretty 0
        kv 1
    }
}

# Convert records to JSON.
::snit::type ::sqawk::serializers::json::serializer {
    variable ch
    variable first 1
    variable initalized 0
    variable kv

    constructor {channel options} {
        package require json::write

        set ch $channel
        set kv [dict get $options kv]
        ::json::write indented [dict get $options pretty]

        puts -nonewline $ch \[
        set initalized 1
    }

    method serialize record {
        set fragment [expr {$first ? {} : {,}}]
        set first 0

        set object {}
        foreach {key value} $record {
            lappend object $key [::json::write string $value]
        }

        if {$kv} {
            append fragment [::json::write object {*}$object]
        } else {
            append fragment [::json::write array {*}[dict values $object]]
        }

        puts -nonewline $ch $fragment
    }

    destructor {
        if {$initalized} {
            puts $ch \]
        }
    }
}

# ======================= end lib/serializers/json.tcl =========================

# ======================== lib/serializers/table.tcl ===========================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk::serializers::table {
    variable formats {
        table
    }
    variable options {
        align {}
        alignments {}
        margins 0
        style default
    }
}

::snit::type ::sqawk::serializers::table::serializer {
    variable ch

    variable alignments
    variable margins
    variable style
    variable tableData {}

    variable initialized 0

    constructor {channel options} {
        set ch $channel

        if {([dict get $options align] ne {}) &&
                ([dict get $options alignments] ne {})} {
            error {can't use synonym options "align" and "alignments"\
                   together}
        } elseif {[dict get $options align] ne {}} {
            set alignments [dict get $options align]
        } else {
            set alignments [dict get $options alignments]
        }
        set margins [dict get $options margins]
        set style [dict get $options style]

        set initialized 1
    }

    method serialize record {
        lappend tableData [dict values $record]
    }

    destructor {
        if {$initialized} {
            puts $ch [::tabulate::tabulate \
                    -data $tableData \
                    -alignments $alignments \
                    -margins $margins \
                    -style [::tabulate::style::by-name $style]]
        }
    }
}

# ====================== end lib/serializers/table.tcl =========================

# ========================= lib/serializers/tcl.tcl ============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk::serializers::tcl {
    variable formats {
        tcl
    }
    variable options {
        kv 0
        pretty 0
    }
}

# A (near) pass-through serializer.
::snit::type ::sqawk::serializers::tcl::serializer {
    variable ch
    variable kv
    variable pretty

    variable first 1
    variable initialized 0

    constructor {channel options} {
        set ch $channel
        set kv [dict get $options kv]
        set pretty [dict get $options pretty]
        set initialized 1
    }

    method serialize record {
        set s [expr {$pretty || $first ? {} : { }}]
        set first 0

        if {$kv} {
            append s [list $record]
        } else {
            append s [list [dict values $record]]
        }

        if {$pretty} {
            append s \n
        }

        puts -nonewline $ch $s
    }

    destructor {
        if {$initialized && !$pretty} {
            puts $ch {}
        }
    }
}

# ======================= end lib/serializers/tcl.tcl ==========================

# ========================== lib/classes/sqawk.tcl =============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk {}

# Performs SQL queries on files and channels.
::snit::type ::sqawk::sqawk {
    # Internal object state.
    variable tables {}
    variable defaultTableNames [split abcdefghijklmnopqrstuvwxyz ""]
    variable formatToParser
    variable formatToSerializer

    # Options.
    option -database
    option -ofs
    option -ors

    option -destroytables -default true
    option -outputformat -default awk
    option -parsers -default {} -configuremethod Set-and-update-format-list
    option -serializers -default {} -configuremethod Set-and-update-format-list

    # Methods.
    constructor {} {
        # Register parsers and serializers.
        $self configure -parsers [namespace children ::sqawk::parsers]
        $self configure -serializers [namespace children ::sqawk::serializers]
    }

    destructor {
        if {[$self cget -destroytables]} {
            dict for {_ tableObj} $tables {
                $tableObj destroy
            }
        }
    }

    # Update the related format dictionary when the parser or the serializer
    # list option is set.
    method Set-and-update-format-list {option value} {
        set optToDict {
            -parsers formatToParser
            -serializers formatToSerializer
        }
        set possibleOpts [dict keys $optToDict]
        if {$option ni $possibleOpts} {
            error [list Set-and-update-format-list can't set option $option]
        }
        set options($option) $value

        set dictName [dict get $optToDict $option]
        set $dictName {}
        # For each parser/serializer...
        foreach ns $value {
            foreach format [set ${ns}::formats] {
                dict set $dictName $format $ns
            }
        }
    }

    # Create a parser object for the format $format.
    method Make-parser {format channel fileOptions} {
        try {
            set ns [dict get $formatToParser $format]
        } on error {} {
            error [list unknown input format: $format]
        }
        set parseOptions [set ${ns}::options]

        try {
            ${ns}::parser create %AUTO% \
                                 $channel \
                                 [::sqawk::override-keys $parseOptions \
                                                         $fileOptions]
        } on error {errorMessage errorOptions} {
            regsub {^Error in constructor: } $errorMessage {} errorMessage
            return -options $errorOptions $errorMessage
        } on ok parser {}

        return $parser
    }

    # Create a serializer object for the format $format.
    method Make-serializer {format channel sqawkOptions} {
        # Parse $format.
        set splitFormat [split $format ,]
        set formatName [lindex $splitFormat 0]
        set formatOptions {}
        foreach option [lrange $splitFormat 1 end] {
            lassign [split $option =] key value
            lappend formatOptions $key $value
        }
        try {
            set ns [dict get $formatToSerializer $formatName]
        } on error {} {
            error [list unknown output format: $formatName]
        }

        # Get the dict containing the options the serializer accepts with their
        # default values.
        set so [set ${ns}::options]
        # Set the two main options for the "awk" serializer. "awk" is a special
        # case: its options are set based on separate command line arguments
        # whose values are passed to us in $sqawkOptions.
        if {$formatName eq {awk}} {
            if {[dict exists $formatOptions ofs]} {
                error {to set the field separator for the "awk" output format\
                        please use the command line option "-OFS" instead of\
                        the format option "ofs"}
            }
            if {[dict exists $formatOptions ors]} {
                error {to set the record separator for the "awk" output format\
                        please use the command line option "-OFS" instead of\
                        the format option "ofs"}
            }
            dict set so ofs [dict get $sqawkOptions -ofs]
            dict set so ors [dict get $sqawkOptions -ors]
        }
        # Check if all the serializer options we have been given in $format are
        # valid. Replace the default values with the actual values.
        foreach {key value} $formatOptions {
            if {[dict exists $so $key]} {
                dict set so $key $value
            } else {
                error [list unknown option $key for output format $formatName]
            }
        }

        return [${ns}::serializer create %AUTO% $channel $so]
    }

    # Read data from a file or a channel into a new database table. The filename
    # or channel to read from and the options for how to read and store the data
    # are in all set in the dictionary $fileOptions.
    method read-file fileOptions {
        # Set the default table name ("a", "b", "c", ..., "z").
        set defaultTableName [lindex $defaultTableNames [dict size $tables]]
        # Set the default column name prefix equal to the table name.
        ::sqawk::dict-ensure-default fileOptions table $defaultTableName
        ::sqawk::dict-ensure-default fileOptions F0 1
        ::sqawk::dict-ensure-default fileOptions csvquote \"
        ::sqawk::dict-ensure-default fileOptions csvsep ,
        ::sqawk::dict-ensure-default fileOptions format awk
        ::sqawk::dict-ensure-default fileOptions prefix \
                [dict get $fileOptions table]

        array set metadata $fileOptions

        # Read the data.
        if {[info exists metadata(channel)]} {
            set ch $metadata(channel)
        } elseif {$metadata(filename) eq "-"} {
            set ch stdin
        } else {
            set ch [open $metadata(filename)]
        }

        set parser [$self Make-parser $metadata(format) $ch $fileOptions]

        # Create and configure a new table object.
        set newTable [::sqawk::table create %AUTO%]
        $newTable configure \
                -database [$self cget -database] \
                -dbtable $metadata(table) \
                -columnprefix $metadata(prefix) \
                -f0 $metadata(F0) \
                -maxnf $metadata(NF) \
                -modenf $metadata(MNF)
        # Configure datatypes.
        if {[info exists metadata(datatypes)]} {
            $newTable configure -datatypes [split $metadata(datatypes) ,]
        }
        # Configure column names.
        set header {}
        if {[info exists metadata(header)] && $metadata(header)} {
            # Remove the header from the input. Strip the first field
            # (a0/b0/...) from the header.
            set header [lrange [$parser next] 1 end]
        }
        # Override the header with custom column names.
        if {[info exists metadata(columns)]} {
            set customColumnNames [split $metadata(columns) ,]
            set header [list \
                    {*}[lrange $customColumnNames \
                            0 [llength $customColumnNames]-1] \
                    {*}[lrange $header \
                            [llength $customColumnNames] end]]
        }
        $newTable configure -header $header

        $newTable initialize

        $newTable insert-rows [list $parser next]
        $parser destroy
        if {$ch ne {stdin}} {
            close $ch
        }

        dict set tables $metadata(table) $newTable
        return $newTable
    }

    # Perform query $query and output the result to $channel.
    method eval {query {channel stdout}} {
        set sqawkOptions {}
        foreach option [$self info options] {
            dict set sqawkOptions $option [$self cget $option]
        }

        set serializer [$self Make-serializer \
                [$self cget -outputformat] stdout $sqawkOptions]

        # For each row returned...
        [$self cget -database] eval $query results {
            set outputRecord {}
            set keys $results(*)
            foreach key $keys {
                lappend outputRecord $key $results($key)
            }
            $serializer serialize $outputRecord
        }
        $serializer destroy
    }
}

# ======================== end lib/classes/sqawk.tcl ===========================

# ========================== lib/classes/table.tcl =============================
# Sqawk, an SQL Awk.
# Copyright (c) 2015-2018, 2020 D. Bohdan
# License: MIT

namespace eval ::sqawk {}

# Creates and populates an SQLite3 table with a specific format.
::snit::type ::sqawk::table {
    option -database
    option -dbtable
    option -columnprefix
    option -f0 true
    option -maxnf
    option -modenf -validatemethod Check-modenf -default error
    option -header -validatemethod Check-header -default {}
    option -datatypes {}

    destructor {
        [$self cget -database] eval "DROP TABLE [$self cget -dbtable]"
    }

    method Check-header {option value} {
        foreach item $value {
            if {[string match *`* $item]} {
                error {column names can't contain grave accents (`)}
            }
        }
    }

    method Check-modenf {option value} {
        if {$value ni {crop error expand}} {
            error [list invalid MNF value: $value]
        }
    }

    # Return the column name for column number $i, custom (if present) or
    # automatically generated.
    method column-name i {
        set customColName [lindex [$self cget -header] $i-1]
        if {($i > 0) && ($customColName ne "")} {
            return `$customColName`
        } else {
            return [$self cget -columnprefix]$i
        }
    }

    # Return the column datatype for column number $i, custom (if present) or
    # "INTEGER" otherwise.
    method column-datatype i {
        set customColDatatype [lindex [$self cget -datatypes] $i-1]
        if {$customColDatatype ne ""} {
            return $customColDatatype
        } else {
            return INTEGER
        }
    }

    # Create a database table for the table object.
    method initialize {} {
        set fields {}
        if {[$self cget -f0]} {
            lappend fields "[$self column-name 0] TEXT"
        }
        for {set i 1} {$i <= [$self cget -maxnf]} {incr i} {
            lappend fields "[$self column-name $i] [$self column-datatype $i]"
        }

        set colPrefix [$self cget -columnprefix]
        set command "CREATE TABLE IF NOT EXISTS [$self cget -dbtable] ("
        append command "\n    ${colPrefix}nr INTEGER PRIMARY KEY,"
        append command "\n    ${colPrefix}nf INTEGER"
        if {$fields ne {}} {
            append command ",\n    [join $fields ",\n    "]"
        }
        append command )

        [$self cget -database] eval $command
    }

    # Insert each row returned when you run the script $next into the database
    # table in a transaction. Finish when the script returns with -code
    # break.
    method insert-rows next {
        set db [$self cget -database]
        set colPrefix [$self cget -columnprefix]
        set tableName [$self cget -dbtable]

        set maxNF [$self cget -maxnf]
        set modeNF [$self cget -modenf]
        set curNF 0
        set f0 [$self cget -f0]
        set startF [expr {$f0 ? 0 : 1}]

        $db transaction {
            while 1 {
                set nf 0
                # [{*}$next] must return -code break when it runs out of data to
                # pass to us. That's how we leave this [while] loop.
                foreach field [{*}$next] {
                    set row($nf) $field
                    incr nf
                    # Crop (truncate row) if needed.
                    if {$modeNF eq "crop" && $nf > $maxNF} {
                        break
                    }
                }

                # Prepare the statement unless it's already been prepared and
                # cached. If the current row contains more fields than exist
                # alter the table adding columns.
                if {$nf != $curNF} {
                    set curNF $nf

                    if {[info exists rowInsertCommand($nf)]} {
                        set statement $rowInsertCommand($nf)
                    } else {
                        set insertColumnNames [list ${colPrefix}nf]
                        set insertValues [list \$nf]
                        for {set i $startF} {$i < $nf} {incr i} {
                            lappend insertColumnNames [$self column-name $i]
                            lappend insertValues \$row($i)
                        }

                        # Expand (alter) table if needed.
                        if {$modeNF eq "expand" && $nf - 1 > $maxNF} {
                            for {set i $maxNF; incr i} {$i < $nf} {incr i} {
                                $db eval "ALTER TABLE $tableName ADD COLUMN\
                                        [$self column-name $i]\
                                        [$self column-datatype $i]"
                            }
                            $self configure -maxnf [set maxNF [incr i -1]]
                        }

                        # Create a prepared statement.
                        set statement [set rowInsertCommand($nf) "
                        INSERT INTO $tableName ([join $insertColumnNames ,])
                        VALUES ([join $insertValues ,])
                        "]
                    }
                }

                incr nf -1
                $db eval $statement
                if {$nf > $startF} {
                    unset row
                }
            }
        }
    }
}

# ======================== end lib/classes/table.tcl ===========================

namespace eval ::sqawk::script {
    variable debug 0
    variable profile 0
    if {$profile} {
        package require profiler
        ::profiler::init
    }
}

# Process $argv into a list of per-file options.
proc ::sqawk::script::process-options argv {
    set options {
        {FS.arg {[ \t]+} "Input field separator for all files (regexp)"}
        {RS.arg {\n} "Input record separator for all files (regexp)"}
        {OFS.arg { } "Output field separator"}
        {ORS.arg {\n} "Output record separator"}
        {NF.arg 10 "Maximum NF value for all files"}
        {MNF.arg {expand} "NF mode (expand, normal or crop)"}
        {dbfile.arg {:memory:} "The SQLite3 database file to create"}
        {noinput "Do not read from stdin when no filenames are given"}
        {output.arg {awk} "Output format"}
        {v "Print version"}
        {1 "One field only. A shortcut for -FS 'x^'"}
    }

    set usage {[options] script [[setting=value ...] filename ...]}
    # ::cmdline::getoptions exits with a nonzero status if it sees a help flag.
    # We catch its help flags (plus {--help}) early to prevents this.
    if {$argv in {{} -h -help --help -? /?}} {
        puts stderr [::cmdline::usage $options $usage]
        exit [expr {$argv eq {} ? 1 : 0}]
    }

    try {
        ::cmdline::getoptions argv $options $usage
    } on error err {
        puts stderr $err
        exit 1
    } on ok cmdOptions {}

    # Report version.
    if {[dict get $cmdOptions v]} {
        puts stderr $::sqawk::version
        exit 0
    }

    set argv [lassign $argv script]

    if {[dict get $cmdOptions 1]} {
        dict set cmdOptions FS x^
    }

    # Substitute slashes.  (In FS and RS the regexp engine will do this for
    # us.)
    foreach option {OFS ORS} {
        dict set cmdOptions $option [subst \
            -nocommands \
            -novariables \
            [dict get $cmdOptions $option] \
        ]
    }

    # Settings that affect the program in general and Sqawk object itself.
    set globalOptions [::sqawk::filter-keys $cmdOptions {
        dbfile noinput OFS ORS output
    }]

    # Filenames and individual file settings.
    set fileOptions [process-file-options \
        $cmdOptions \
        $globalOptions \
        $argv \
    ]

    return [list $script $globalOptions $fileOptions]
}

proc ::sqawk::script::process-file-options {cmdOptions globalOptions argv} {
    set awkKeys { FS RS }
    set defaultKeys { NF MNF }
    set universalKeys { columns datatypes F0 header prefix table }

    set default [::sqawk::filter-keys $cmdOptions $defaultKeys]

    set all {}
    set current $default

    while {[llength $argv] > 0} {
        set argv [lassign $argv elem]

        # setting=value
        if {[regexp {([^=]+)=(.*)} $elem _ key value]} {
            dict set current $key $value
        } else {
            # Filename.
            if {[file exists $elem] || $elem eq "-"} {
                dict set current filename $elem
                lappend all $current
                set current $default
            } else {
                error [list can't find file $elem]
            }
        }
    }

    # If no files are given add "-" (standard input) with the current settings
    # to all.
    if {[llength $all] == 0 && ![dict get $globalOptions noinput]} {
        dict set current filename -
        lappend all $current
    }

    # Verify the file options and add in the "awk" parser defaults.
    set awkDefault [::sqawk::filter-keys $cmdOptions $awkKeys]
    set validFormats {}
    foreach ns [namespace children ::sqawk::parsers] {
        foreach format [set ${ns}::formats] {
            dict set validFormats $format $ns
        }
    }

    set all [lmap current $all {
        set format awk
        if {[dict exists $current format]} {
            set format [dict get $current format]
            if {![dict exists $validFormats $format]} {
                error [list unknown input format: $format]
            }
        }

        if {$format eq {awk}} {
            set current [dict merge $awkDefault $current]
        }

        set ns [dict get $validFormats $format]
        set parserKeys [dict keys [set ${ns}::options]]
        dict for {key value} $current {
            if {$key in {filename format}} continue
            if {$key ni $parserKeys
                && $key ni $universalKeys
                && $key ni $defaultKeys
                && !($format eq {awk} && $key in $awkKeys)} {
                error [list unknown option $key for input format $format]
            }
        }

        set current
    }]

    return $all
}

# Create an SQLite3 database for ::sqawk::sqawk to use.
proc ::sqawk::script::create-database {database file} {
    variable debug
    if {$debug} {
        ::sqlite3 $database.real $file
        proc ::$database args {
            set me [dict get [info frame 0] proc]
            puts "DEBUG: $me $args"
            return [uplevel 1 [list $me.real {*}$args]]
        }
    } else {
        ::sqlite3 $database $file
    }

    foreach {name script} {
        dict_exists       ::sqawk::dict-exists
        dict_get          ::sqawk::dict-get
        lindex            ::lindex
        llength           ::llength
        lrange            ::lrange
        regexp            ::regexp
        regsub            ::regsub
    } {
        # Compatibility.
        try {
            $database function $name -deterministic $script
        } on error {} {
            $database function $name $script
        }
    }
}

proc ::sqawk::script::main {argv0 argv {databaseHandle db}} {
    # Try to process the command line options.
    try {
        lassign [::sqawk::script::process-options $argv] \
                script options allFileOptions
    } on error msg {
        puts stderr "error: $msg"
        exit 1
    }

    # Initialize Sqawk and the corresponding database.
    set dbfile [dict get $options dbfile]
    ::sqawk::script::create-database $databaseHandle $dbfile
    set sqawkObj [::sqawk::sqawk create %AUTO%]
    $sqawkObj configure \
            -database $databaseHandle \
            -destroytables [expr {$dbfile eq {:memory}}] \
            -ofs [dict get $options OFS] \
            -ors [dict get $options ORS] \
            -outputformat [dict get $options output]

    foreach file $allFileOptions {
        $sqawkObj read-file $file
    }

    try {
        $sqawkObj eval $script
    } trap {POSIX EPIPE} {} {
    } on error msg {
        regsub {^Error in constructor: } $msg {} msg
        puts stderr "error: $msg"
        exit 1
    }
    $sqawkObj destroy
    $databaseHandle close
}

# If this is the main script...
if {[info exists argv0] && ([file tail [info script]] eq [file tail $argv0])} {
    ::sqawk::script::main $argv0 $argv
    if {$::sqawk::script::profile} {
        foreach line [::profiler::sortFunctions exclusiveRuntime] {
            puts stderr $line
        }
    }
}


