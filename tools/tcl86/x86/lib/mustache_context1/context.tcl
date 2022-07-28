## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2019 Andreas Kupries

# @@ Meta Begin
# Package mustache::context 1
# Meta author      {Andreas Kupries}
# Meta category    Template Processing
# Meta description Implementation of mustache, context
# Meta location    http:/core.tcl.tk/akupries/mustache
# Meta platform    tcl
# Meta summary     Mustache, logic-less templates
# Meta subject     mustache template logic-less
# Meta require     {Tcl 8.5-}
# Meta require     debug
# Meta require     debug::caller
# @@ Meta End

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller

package provide mustache::context 1

# # ## ### ##### ######## ############# #####################

namespace eval ::mustache {
    namespace export context
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################

debug define mustache/context
debug level  mustache/context
debug prefix mustache/context {[debug caller] | }

# # ## ### ##### ######## ############# #####################
## API

oo::class create ::mustache::context {

    # - - -- --- ----- -------- -------------
    ## State
    # - A Stack Of Frames
    # - A Current Frame (Top Of Stack) - Term "dot".
    # - The last frame searched for and found (name, and object)
    # - A dictionary of sub-ordinate named templates ready for inclusion.

    # - - -- --- ----- -------- -------------
    ## API to support testing
    # - depth		Depth of frame stack
    # - dot		Return the dot object

    # - - -- --- ----- -------- -------------
    ## Public API
    # - focus K		Make field with name K the new "dot" (current focus)
    # - has? K		Do you know a field with name K ?
    # - iter S		Invoke S for all children of "dot"
    # - iterable?	Is "dot" a non-empty list ? (check nil? first)
    # - nil?		Is "dot" false, or an empty list ?
    # - pop		Return to previous "dot"
    # - push F		Make frame F the new "dot"
    # - template K	Get template ?(render structure) with name K
    # - template: K T	Declare template named K, and unparsed definition T.
    # - template? K	Do you know a template with name K
    # - value		Return "dot"'s value.

    # - - -- --- ----- -------- -------------
    ## API implementation

    constructor {frame} {
	debug.mustache/context {}
	# The context now owns the frame.
	my push $frame
	my __clear
	set parts {}
	return
    }

    destructor {
	# Destroy the owned frames.
	#
	# - While all frames on the stack should have come from the
	#   root frame at index 0 and its destruction should have
	#   destroyed the remainder on the stack, there is the `push`
	#   method which can add arbitrary frames. We have to destroy
	#   them as well.
	#
	#   Note that popping such arbitrary frames de-owns them
	#   again.
	#
	# - We catch any errors, given that a frame destroys its
	#   children, which may be on the stack as well.
	foreach frame $frames {
	    catch {
		$frame destroy
	    }
	}
	return
    }

    method focus {field} {
	debug.mustache/context {}
	# Fast bail OK for reference to dot. No stack changes.
	if {$field eq "."} { return }

	if {(($field ne $lastfield) && ![my has? $field]) ||
	    (($field eq $lastfield) && ($lastframe eq {}))} {
	    my __unknown $field
	}
	my push $lastframe
	my __clear
	return
    }

    method has? {field} {
	debug.mustache/context {}
	# Fast bail OK for reference to dot.
	if {$field eq "."} { return 1 }

	if {[string first . $field] >= 0} {
	    set nested [lassign [split $field .] first]
	    if {[my __find $first]} {
		# Process each nested field relative to the `last` in
		# the cache, i.e. its parent.
		foreach child $nested {
		    debug.mustache/context {walk to '$child' (in $lastframe)}
		    if {![{*}$lastframe has? $child]} {
			my __found $field {}
			debug.mustache/context {miss}
			return 0
		    }
		    # Walk into the child
		    my __found $field [{*}$lastframe field $child]
		    debug.mustache/context {move to '$field' (=> $lastframe)}
		}
		debug.mustache/context {hit}
		return 1
	    } else {
		debug.mustache/context {}
		return 0
	    }
	}

	debug.mustache/context {no dots, simple}
	return [my __find $field]
    }

    # iter, iterable?, nil?, value
    # - While it would be nice, we cannot simply forward, as `dot` is
    #   dynamically changing.

    method iter {script} {
	debug.mustache/context {}
	{*}$dot iter [self] {
	    uplevel 1 $script
	}
	return
    }

    method iterable? {} {
	debug.mustache/context {}
	{*}$dot iterable?
    }

    method nil? {} {
	debug.mustache/context {}
	{*}$dot nil?
    }

    method pop {} {
	debug.mustache/context {}
	if {[llength $frames] <= 1} {
	    return -code error \
		-errorcode {MUSTACHE CONTEXT UNDERFLOW} \
		"Stack underflow, cannot pop root frame"
	}
	set frames [lreplace $frames end end]
	set dot    [lindex   $frames end]
	return
    }

    method push {frame} {
	debug.mustache/context {}
	lappend frames $frame
	set     dot    $frame
	return
    }

    method template {name} {
	debug.mustache/context {}
	if {![dict exists $parts $name]} {
	    return -code error \
		-errorcode {MUSTACHE CONTEXT TEMPLATE} \
		"Template \"$name\" not known"
	}
	return [dict get $parts $name]
    }

    method template: {name template} {
	debug.mustache/context {}
	dict set parts $name $template
	return
    }

    method template? {name} {
	debug.mustache/context {}
	return [dict exists $parts $name]
    }

    method value {} {
	debug.mustache/context {}
	{*}$dot value
    }

    # - - -- --- ----- -------- -------------
    ## Test support

    method depth {} {
	debug.mustache/context {}
	return [llength $frames]
    }

    method dot {} {
	debug.mustache/context {}
	return $dot
    }

    # - - -- --- ----- -------- -------------
    ## State variables

    variable frames	   ;# stack of frame(object)s, TOS at end
    variable dot	   ;# TOS frame(object)
    variable lastfield	   ;# Name   of last field searched in all frames and found.
    variable lastframe	   ;# Object of ...
    variable parts	   ;# Map: name -> template (partials, includables)

    # - - -- --- ----- -------- -------------
    ## Internal helpers

    method __find {field} {
	debug.mustache/context {}
	# Basic search through the entire stack of frames, from dot on down to the root.
	# Assumes an undotted field name.
	# Leaves the result in the `last`-cache.
	foreach frame [lreverse $frames] {
	    debug.mustache/context {check '$field' (in $frame)}
	    if {![{*}$frame has? $field]} continue
	    my __found $field [{*}$frame field $field]
	    debug.mustache/context {hit (=> $lastframe)}
	    return 1
	}
	my __found $field {}
	debug.mustache/context {miss}
	return 0
    }


    method __unknown {field} {
	return -code error \
	    -errorcode {MUSTACHE CONTEXT UNKNOWN} \
	    "Unable to focus on unknown field \"$field\""
    }

    method __found {field frame} {
	set lastfield $field
	set lastframe $frame
    }

    method __clear {} {
	my __found {} {}
    }

    # - - -- --- ----- -------- -------------
}

# # ## ### ##### ######## ############# #####################
return
