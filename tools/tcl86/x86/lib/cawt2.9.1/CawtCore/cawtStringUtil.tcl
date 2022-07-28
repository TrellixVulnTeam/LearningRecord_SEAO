# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Cawt {

    namespace ensemble create

    namespace export CountWords

    proc _StringLenCompare { a b } {
        set aLen [string length $a]
        set bLen [string length $b]
        if { $aLen < $bLen } {
            return -1
        } elseif { $aLen > $bLen } {
            return 1
        } else {
            return 0
        }
    }

    proc CountWords { str args } {
        # Count words contained in a string.
        #
        # str  - String to be searched.
        # args - Options described below.
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
        # Returns a key-value list containing the found words and their
        # corresponding count.
        #
        # Count words contained in a string.
        #
        # Notes:
        #  * The definition of a word is like in Tcl command `string wordend`.
        #  * This procedure can be called as a coroutine. It yields 
        #    every 1000 bytes processed. The yield return value is the
        #    number of bytes already processed.
        #    See test script `Core-04_String.tcl` for an usage example.
        #
        # See also: ::Word::CountWords

        set opts [dict create \
            -sortmode    "length" \
            -minlength   -1 \
            -maxlength   -1 \
            -shownumbers true \
        ]
        foreach { key value } $args {
            if { $value eq "" } {
                error "CountWords: No value specified for key \"$key\""
            }
            if { [dict exists $opts $key] } {
                dict set opts $key $value
            } else {
                error "CountWords: Unknown option \"$key\" specified"
            }
        }

        set wordStart 0
        set wordEnd   0

        set strLen [string length $str]
        set percent 0
        if { [info coroutine] ne "" } {
            yield 0
        }
        set thousands 1000
        set minLength [dict get $opts "-minlength"]
        set maxLength [dict get $opts "-maxlength"]
        while { $wordEnd < $strLen } {
            set wordEnd   [string wordend $str $wordStart]
            set foundWord [string trim [string range $str $wordStart [expr { $wordEnd - 1}]]]
            set wordStart $wordEnd
            set wordLen [string length $foundWord]
            if { ( $minLength < 0 || $wordLen >= $minLength ) && \
                 ( $maxLength < 0 || $wordLen <= $maxLength ) } {
                if { ! [dict get $opts "-shownumbers"] && [string is digit $foundWord] } {
                    continue
                }
                incr wordHash($foundWord)
            }
            if { $wordEnd > $thousands } {
                incr thousands 1000
                if { [info coroutine] ne "" } {
                    yield $wordEnd
                }
            }
        }
        if { [info coroutine] ne "" } {
            yield $strLen
        }

        set sortedList [lsort -dictionary [array names wordHash]]
        if { [dict get $opts "-sortmode"] eq "length" } {
            set sortedList [lsort -command Cawt::_StringLenCompare $sortedList]
        }

        set keyValueList [list]
        foreach word $sortedList {
            lappend keyValueList $word $wordHash($word)
        }
        if { [dict get $opts "-sortmode"] eq "increasing" } {
            return [lsort -stride 2 -index 1 -integer -increasing $keyValueList]
        } elseif { [dict get $opts "-sortmode"] eq "decreasing" } {
            return [lsort -stride 2 -index 1 -integer -decreasing $keyValueList]
        } else {
            return $keyValueList
        }
    }
}
