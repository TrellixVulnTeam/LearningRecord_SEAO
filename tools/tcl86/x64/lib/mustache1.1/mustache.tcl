## -*- tcl -*-
# # ## ### ##### ######## #############
## (c) 2019-2021 Andreas Kupries

# @@ Meta Begin
# Package mustache 1.1
# Meta author      {Andreas Kupries}
# Meta category    Template Processing
# Meta description Implementation of mustache, user commands
# Meta location    http:/core.tcl.tk/akupries/mustache
# Meta platform    tcl
# Meta summary     Mustache, logic-less templates
# Meta subject     mustache template logic-less
# Meta require     {Tcl 8.5-}
# Meta require     debug
# Meta require     debug::caller
# Meta require     mustache::parse
# Meta require     mustache::render
# @@ Meta End

package require Tcl 8.5
package require debug
package require debug::caller

package require mustache::parse  1
package require mustache::render 1

package provide mustache 1.1

# # ## ### ##### ######## #############

namespace eval ::mustache {
    namespace export mustache mustache/pt
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################

debug define mustache/mustache
debug level  mustache/mustache
debug prefix mustache/mustache {[debug caller] | }

# # ## ### ##### ######## #############
## API

proc ::mustache::mustache {template context} {
    debug.mustache/mustache {}

    variable result {}
    render \
	[parse $template] \
	$context \
	{::append ::mustache::result}
    set tmp $result
    unset result
    return $tmp
}

proc ::mustache::mustache/pt {parsed_template context} {
    debug.mustache/mustache {}

    variable result {}
    render \
	$parsed_template \
	$context \
	{::append ::mustache::result}
    set tmp $result
    unset result
    return $tmp
}

# # ## ### ##### ######## #############
return
