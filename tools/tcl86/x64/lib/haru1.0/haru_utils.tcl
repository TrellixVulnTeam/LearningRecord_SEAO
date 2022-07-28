# Copyright (c) 2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl binding for libharu (http://libharu.org/) PDF library.

namespace eval haru {}

proc haru::hpdf_encode {text {hpdf_encoding "null"}} {
    # Credit to Ashok P. Nadkarni https://www.magicsplat.com
    #
    # Text encode follow hpdf encoding
    #
    # Returns text encoded
    switch -exact -- $hpdf_encoding {
        "null"             -
        "StandardEncoding" {set encode cp1252}
        "MacRomanEncoding" {set encode macroman}
        "WinAnsiEncoding"  {set encode cp1252}
        "ISO8859-2"        {set encode iso8859-2}
        "ISO8859-3"        {set encode iso8859-3}
        "ISO8859-4"        {set encode iso8859-4}
        "ISO8859-5"        {set encode iso8859-5}
        "ISO8859-9"        {set encode iso8859-9}
        "ISO8859-10"       {set encode iso8859-10}
        "ISO8859-13"       {set encode iso8859-13}
        "ISO8859-14"       {set encode iso8859-14}
        "ISO8859-15"       {set encode iso8859-15}
        "ISO8859-16"       {set encode iso8859-16}
        "CP1250"           {set encode cp1250}
        "CP1251"           {set encode cp1251}
        "CP1252"           {set encode cp1252}
        "CP1254"           {set encode cp1254}
        "CP1257"           {set encode cp1257}
        "KOI8-R"           {set encode koi8-r}
        "Symbol-Set"       {set encode symbol}
        "ZapfDingbats-Set" {set encode dingbats}
        "shiftjis"         {set encode shiftjis} ; # special case for jpfont_demo.tcl
        default {error "unrecognized encoding name"}
    }

    # Note: two nulls appended in case encoding is double-byte
    append encoded [encoding convertto $encode $text] "\0\0"
    return $encoded
}

proc haru::DegreesToRadians {degrees} {
    # Degree to radian function
    #
    # Returns radian value
    set degToRad [expr {3.141592 / 180.0}]
    return [expr {$degrees * $degToRad}]
    
}