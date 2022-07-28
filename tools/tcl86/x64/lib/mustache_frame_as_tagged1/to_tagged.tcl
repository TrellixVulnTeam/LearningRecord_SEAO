## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2021 Andreas Kupries

# @@ Meta Begin
# Package mustache::frame::as::tagged 1
# Meta author      {Andreas Kupries}
# Meta category    Template Processing
# Meta description Conversion of data frames to a tagged data structure
# Meta description acceptable by TclYAML's (v0.5) writeTags command.
# Meta location    http:/core.tcl.tk/akupries/mustache
# Meta platform    tcl
# Meta summary     Mustache, logic-less templates
# Meta subject     mustache template logic-less conversion {tagged structure}
# Meta require     {Tcl 8.5-}
# Meta require     debug
# Meta require     debug::caller
# @@ Meta End

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller

package provide mustache::frame::as::tagged 1

# # ## ### ##### ######## ############# #####################

namespace eval ::mustache::frame::as::tagged {
    namespace export bool float int null string scalar sequence mapping
    namespace ensemble create
}
namespace eval ::mustache::frame::as::tagged::sequence {
    namespace export start exit
    namespace ensemble create
}
namespace eval ::mustache::frame::as::tagged::mapping {
    namespace export start exit
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################

debug define mustache/frame/as/tagged
debug level  mustache/frame/as/tagged
debug prefix mustache/frame/as/tagged {[debug caller] | }

# # ## ### ##### ######## ############# #####################
## This ensemble converts a data frame (tree) into a tagged data
## structure as accepted by TclYAML's (v0.5) `writeTags` command. It
## assumes that it is driven by the data frame's `visit` method.

# NOTES
# - bool, float, int, null, string: These are TclYAML v0.5+ tags
# - scalar:                         A TclYAML v0.4- tag.

proc ::mustache::frame::as::tagged::bool {self value} {
    debug.mustache/frame/as/tagged {}
    list bool $value
}

proc ::mustache::frame::as::tagged::float {self value} {
    debug.mustache/frame/as/tagged {}
    list float $value
}

proc ::mustache::frame::as::tagged::int {self value} {
    debug.mustache/frame/as/tagged {}
    list int $value
}

proc ::mustache::frame::as::tagged::null {self value} {
    debug.mustache/frame/as/tagged {}
    list null {}
}

proc ::mustache::frame::as::tagged::string {self value} {
    debug.mustache/frame/as/tagged {}
    list string $value
}

proc ::mustache::frame::as::tagged::scalar {self value} {
    debug.mustache/frame/as/tagged {}
    list string $value
}

proc ::mustache::frame::as::tagged::sequence::start {self} {
    debug.mustache/frame/as/tagged {}
}

proc ::mustache::frame::as::tagged::sequence::exit {self children} {
    debug.mustache/frame/as/tagged {}
    list sequence $children
}

proc ::mustache::frame::as::tagged::mapping::start {self} {
    debug.mustache/frame/as/tagged {}
}

proc ::mustache::frame::as::tagged::mapping::exit {self children} {
    debug.mustache/frame/as/tagged {}
    # Scalarize the keys.
    list mapping [concat {*}[lmap {k child} $children {
	list [list string $k] $child
    }]]
}

# # ## ### ##### ######## ############# #####################
return
