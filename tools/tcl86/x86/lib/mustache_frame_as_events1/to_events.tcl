## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2021 Andreas Kupries

# @@ Meta Begin
# Package mustache::frame::as::events 1
# Meta author      {Andreas Kupries}
# Meta category    Template Processing
# Meta description Conversion of data frames to a list of events
# Meta description similar to what is returned by TclYAML's stream
# Meta description parser
# Meta location    http:/core.tcl.tk/akupries/mustache
# Meta platform    tcl
# Meta summary     Mustache, logic-less templates
# Meta subject     mustache template logic-less conversion {event list}
# Meta require     {Tcl 8.5-}
# Meta require     debug
# Meta require     debug::caller
# @@ Meta End

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller

package provide mustache::frame::as::events 1

# # ## ### ##### ######## ############# #####################

namespace eval ::mustache::frame::as::events {
    namespace export bool float int null string scalar sequence mapping
    namespace ensemble create
}
namespace eval ::mustache::frame::as::events::sequence {
    namespace export start exit
    namespace ensemble create
}
namespace eval ::mustache::frame::as::events::mapping {
    namespace export start exit
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################

debug define mustache/frame/as/events
debug level  mustache/frame/as/events
debug prefix mustache/frame/as/events {[debug caller] | }

# # ## ### ##### ######## ############# #####################
## This ensemble converts a data frame (tree) into a events data
## structure as accepted by TclYAML's (v0.5) `writeTags` command. It
## assumes that it is driven by the data frame's `visit` method.

# NOTES
# - bool, float, int, null, string: These are TclYAML v0.5+ tags
# - scalar:                         A TclYAML v0.4- tag.

proc ::mustache::frame::as::events::bool {self value} {
    debug.mustache/frame/as/events {}
    list [list bool $value]
}

proc ::mustache::frame::as::events::float {self value} {
    debug.mustache/frame/as/events {}
    list [list float $value]
}

proc ::mustache::frame::as::events::int {self value} {
    debug.mustache/frame/as/events {}
    list [list int $value]
}

proc ::mustache::frame::as::events::null {self value} {
    debug.mustache/frame/as/events {}
    list [list null {}]
}

proc ::mustache::frame::as::events::string {self value} {
    debug.mustache/frame/as/events {}
    list [list string $value]
}

proc ::mustache::frame::as::events::scalar {self value} {
    debug.mustache/frame/as/events {}
    list [list string $value]
}

proc ::mustache::frame::as::events::sequence::start {self} {
    debug.mustache/frame/as/events {}
}

proc ::mustache::frame::as::events::sequence::exit {self children} {
    debug.mustache/frame/as/events {}

    lappend r sequence-start
    foreach child $children {
	lappend r {*}$child
    }
    lappend r sequence-end
    return $r
}

proc ::mustache::frame::as::events::mapping::start {self} {
    debug.mustache/frame/as/events {}
}

proc ::mustache::frame::as::events::mapping::exit {self children} {
    debug.mustache/frame/as/events {}

    lappend r mapping-start
    foreach {k child} $children {
	lappend r [list string $k]
	lappend r {*}$child
    }
    lappend r mapping-end
    return $r
}

# # ## ### ##### ######## ############# #####################
return
