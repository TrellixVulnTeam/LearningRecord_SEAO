## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2021 Andreas Kupries

# @@ Meta Begin
# Package mustache::frame::as::json 1
# Meta author      {Andreas Kupries}
# Meta category    Template Processing
# Meta description Conversion of data frames to a JSON value
# Meta location    http:/core.tcl.tk/akupries/mustache
# Meta platform    tcl
# Meta summary     Mustache, logic-less templates
# Meta subject     mustache template logic-less conversion json
# Meta require     {Tcl 8.5-}
# Meta require     debug
# Meta require     debug::caller
# @@ Meta End

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller

package provide mustache::frame::as::json 1

# # ## ### ##### ######## ############# #####################

namespace eval ::mustache::frame::as::json {
    namespace export bool float int null string scalar sequence mapping
    namespace ensemble create
}
namespace eval ::mustache::frame::as::json::sequence {
    namespace export start exit
    namespace ensemble create
}
namespace eval ::mustache::frame::as::json::mapping {
    namespace export start exit
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################

debug define mustache/frame/as/json
debug level  mustache/frame/as/json
debug prefix mustache/frame/as/json {[debug caller] | }

# # ## ### ##### ######## ############# #####################
## This ensemble converts a data frame (tree) into a json data
## structure as accepted by TclYAML's (v0.5) `writeTags` command. It
## assumes that it is driven by the data frame's `visit` method.

# NOTES
# - bool, float, int, null, string: These are TclYAML v0.5+ tags
# - scalar:                         A TclYAML v0.4- tag.

proc ::mustache::frame::as::json::bool {self value} {
    debug.mustache/frame/as/json {}
    return [expr {$value ? "true" : "false"}]
}

proc ::mustache::frame::as::json::float {self value} {
    debug.mustache/frame/as/json {}
    return $value
}

proc ::mustache::frame::as::json::int {self value} {
    debug.mustache/frame/as/json {}
    return $value
}

proc ::mustache::frame::as::json::null {self value} {
    debug.mustache/frame/as/json {}
    return null
}

proc ::mustache::frame::as::json::string {self value} {
    debug.mustache/frame/as/json {}
    return "\"${value}\""
}

proc ::mustache::frame::as::json::scalar {self value} {
    debug.mustache/frame/as/json {}
    return "\"${value}\""
}

# Note: `string cat` is not available in 8.5 yet, thus the use of
# `append` and `set` with disposable variables as a substitute.

proc ::mustache::frame::as::json::sequence::start {self} {
    debug.mustache/frame/as/json {}
}

proc ::mustache::frame::as::json::sequence::exit {self children} {
    debug.mustache/frame/as/json {}
    append _ "\[" [join $children ,] "\]"
}

proc ::mustache::frame::as::json::mapping::start {self} {
    debug.mustache/frame/as/json {}
}

proc ::mustache::frame::as::json::mapping::exit {self children} {
    debug.mustache/frame/as/json {}
    append _ "\{" [join [lmap {k child} $children {
	set __ "\"$k\":$child"
    }] ,] "\}"
}

# # ## ### ##### ######## ############# #####################
return
