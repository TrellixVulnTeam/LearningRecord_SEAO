# Test CawtCore procedures for checking URL addresses.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

Cawt CheckBoolean true \
    [Cawt IsValidUrlAddress "http://www.cawt.tcl3d.org"] \
    "Hyperlink to valid URL"

Cawt CheckBoolean true \
     [Cawt IsValidUrlAddress "http://www.cawt.tcl3d.org/download/CawtReference_Cawt.html#::Cawt::CheckBoolean"] \
     "Hyperlink to valid URL index"

Cawt CheckBoolean false \
     [Cawt IsValidUrlAddress "http://www.cawt.tcl3d.org/download/CawtReference_Cawt.html#::Cawt::CheckInvalidProc"] \
     "Hyperlink to invalid URL index"

Cawt CheckBoolean false \
    [Cawt IsValidUrlAddress "http://www.cawt.tcl3d.org/dummy.html"] \
    "Hyperlink to invalid URL"

Cawt CheckBoolean false \
    [Cawt IsValidUrlAddress "http://www.wrongcawt.tcl3d.org/index.html"] \
    "Hyperlink to invalid domain"

Cawt CheckBoolean true \
     [Cawt IsValidUrlAddress "https://sourceforge.net/projects/cawt/files/Official Releases/"] \
     "Hyperlink to valid URL with spaces"

Cawt CheckBoolean true \
     [Cawt IsValidUrlAddress "https://sourceforge.net/projects/cawt/files/Official%20Releases/"] \
     "Hyperlink to valid URL with spaces masked with %20"

Cawt CheckBoolean true \
     [Cawt IsValidUrlAddress "http://www.bawt.tcl3d.org/download/Bootstrap-Windows/gcc7.2.0_x86_64-w64-mingw32.7z"] \
     "Hyperlink to valid URL with large file"

Cawt CheckBoolean true \
     [Cawt IsValidUrlAddress "https://sourceforge.net/projects/cawt/files/Official Releases/CAWT 2.8.2/Cawt-2.8.2-win64.exe"] \
     "Hyperlink to valid URL with executable file"

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Cawt Destroy
    exit 0
}
Cawt Destroy
