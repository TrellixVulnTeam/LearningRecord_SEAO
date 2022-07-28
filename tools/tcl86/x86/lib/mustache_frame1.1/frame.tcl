## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2019-2021 Andreas Kupries

# @@ Meta Begin
# Package mustache::frame 1.1
# Meta author      {Andreas Kupries}
# Meta category    Template Processing
# Meta description Implementation of mustache, data frames
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

package provide mustache::frame 1.1

# # ## ### ##### ######## ############# #####################

namespace eval ::mustache {
    namespace export frame
    namespace ensemble create
}
namespace eval ::mustache::frame {
    namespace export \
	bool float int null string mapping sequence \
	fromTags
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################

debug define mustache/frame
debug level  mustache/frame
debug prefix mustache/frame {[debug caller] | }

# # ## ### ##### ######## ############# #####################
## This command converts a tagged data structure as delivered by
## TclYAML's readTags into an equivalent hierarchy of frame objects.
## It does this by using the tags as commands which convert their
## argument(s)

proc ::mustache::frame::fromTags {spec} {
    debug.mustache/frame {}
    return [FT {*}$spec]
}

namespace eval ::mustache::frame::FT {
    namespace export bool float int null string scalar sequence mapping
    namespace ensemble create
}

# NOTES
# - bool, float, int, null, string: These are TclYAML v0.5+ tags
# - scalar:                         A TclYAML v0.4- tag.

proc ::mustache::frame::FT::bool {val} {
    debug.mustache/frame {}
    mustache frame bool new $val
}

proc ::mustache::frame::FT::float {val} {
    debug.mustache/frame {}
    mustache frame float new $val
}

proc ::mustache::frame::FT::int {val} {
    debug.mustache/frame {}
    mustache frame int new $val
}

proc ::mustache::frame::FT::null {{val {}}} {
    debug.mustache/frame {}
    mustache frame null new $val
}

proc ::mustache::frame::FT::string {val} {
    debug.mustache/frame {}
    mustache frame string new $val
}

proc ::mustache::frame::FT::scalar {val} {
    debug.mustache/frame {}
    mustache frame string new $val
}

proc ::mustache::frame::FT::sequence {val} {
    debug.mustache/frame {}
    mustache frame sequence new [arg-sequence $val]
}

proc ::mustache::frame::FT::mapping {val} {
    debug.mustache/frame {}
    mustache frame mapping new [arg-mapping $val]
}

# # ## ### ##### ######## ############# #####################

proc ::mustache::frame::FT::arg-sequence {val} {
    debug.mustache/frame {}
    lmap el $val {
	debug.mustache/frame {- ($el)}
	{*}$el
    }
}

proc ::mustache::frame::FT::arg-mapping {val} {
    debug.mustache/frame {}
    set tmp {}
    foreach {k v} $val {
	lassign $k kt kv
	if {$kt ni {bool float int null string scalar}} {
	    return -code error \
		-errorcode {MUSTACHE FRAME FROM-TAGS MAP KEY TYPE} \
		"Bad type $kt for map key, expected one of bool, float, int, null, string, or scalar"
	}
	debug.mustache/frame {- ($kv) --> ($v)}
	dict set tmp $kv [{*}$v]
    }
    return $tmp
}

# # ## ### ##### ######## ############# #####################
## API - Frame methods
# - type        Type of value in this frame object
# - field K	Get frame for field with name K
# - has? K	Do you know a field with name K
# - iter C S    Iterate your children, run script S with each child
#               as dot in C.
# - iterable?   Are you a non-empty list ? (check nil? first)
# - nil?        Are you false, or an empty list ?
# - value       Return your value
# - visit       Walk the frame tree (interleaved bottom-up and top-down)

# # ## ### ##### ######## ############# #####################
## Abstract base class.

oo::class create ::mustache::frame::base {
    method type      {args} { my UNDEFINED type }
    method visit     {args} { my UNDEFINED visit }
    method field     {args} { my UNDEFINED field }
    method iter      {args} { my UNDEFINED iter }
    method has?      {args} { my UNDEFINED has? }
    method iterable? {args} { my UNDEFINED iterable? }
    method nil?      {args} { my UNDEFINED nil? }
    method value     {args} { my UNDEFINED value }

    method UNDEFINED {m} {
	my E "Method '$m' not defined by frame class" METHODE UNDEFINED
    }
    method E {msg args} {
	return -code error \
	    -errorcode [linsert $args 0 MUSTACHE FRAME] \
	    "Mustache frame: $msg"
    }

    # Generic conversion method for a tree of frames. Expects to be
    # able to get the conversion support command from a package, by
    # name, then invokes it via a walk over the tree.
    method as {type} {
	debug.mustache/frame {}
	package require mustache::frame::as::$type
	my visit ::mustache::frame::as::$type
    }
}

# # ## ### ##### ######## ############# #####################
## Base class for scalar values.

oo::class create ::mustache::frame::scalar {
    superclass ::mustache::frame::base

    constructor {t v} {
	debug.mustache/frame {}
	set type  $t
	set value $v
	return
    }

    destructor {
	debug.mustache/frame {}
	return
    }

    method type {} {
	debug.mustache/frame {}
	return $type
    }

    method visit {args} {
	debug.mustache/frame {}
	uplevel #0 [list {*}$args $type [self] $value]
    }

    method field {k} {
	debug.mustache/frame {}
	my E "A $type has no fields" SCALAR FIELD
    }

    method has? {k} {
	debug.mustache/frame {}
	return 0
    }

    method iter {context script} {
	debug.mustache/frame {}
	my E "A $type cannot be iterated over" SCALAR ITER
    }

    method iterable? {} {
	debug.mustache/frame {}
	return 0
    }

    method value {} {
	debug.mustache/frame {}
	return $value
    }

    # - - -- --- ----- -------- -------------
    ## State variables

    variable value	;# Frame data
    variable type       ;# Value type

    # - - -- --- ----- -------- -------------
}

oo::class create ::mustache::frame::bool {
    superclass ::mustache::frame::scalar

    constructor {val} {
	debug.mustache/frame {}
	if {![string is bool -strict $val]} {
	    my E "Expected a boolean, got \"$val\"" BOOL INVALID
	}
	next bool $val
    }

    method nil? {} {
	debug.mustache/frame {bool ([my value]) - [expr {[string is boolean -strict [my value]] && ![my value]}]}
	# Yes for a boolean representing false.
	expr {[string is boolean -strict [my value]] && ![my value]}
    }
}

oo::class create ::mustache::frame::float {
    superclass ::mustache::frame::scalar

    constructor {val} {
	debug.mustache/frame {}
	if {![string is double -strict $val]} {
	    my E "Expected a double, got \"$val\"" FLOAT INVALID
	}
	if {$val ni {-Inf Inf -NaN NaN}} {
	    set val [expr $val]
	}
	next float $val
    }

    method nil? {} {
	debug.mustache/frame {float (never)}
	# Never for a floating point number
	return 0
    }
}

oo::class create ::mustache::frame::int {
    superclass ::mustache::frame::scalar

    constructor {val} {
	debug.mustache/frame {}
	if {![string is int -strict $val]} {
	    my E "Expected an integer, got \"$val\"" INT INVALID
	}
	next int [expr $val]
    }

    method nil? {} {
	debug.mustache/frame {int (never)}
	expr {[my value] == 0}
    }
}

oo::class create ::mustache::frame::null {
    superclass ::mustache::frame::scalar

    constructor {{val {}}} {
	debug.mustache/frame {}
	if {$val ne {}} {
	    my E "Expected a null, got \"$val\"" NULL INVALID
	}
	next null {}
    }

    method nil? {} {
	debug.mustache/frame {null (always)}
	# Always for null i.e. nil
	return 1
    }
}

oo::class create ::mustache::frame::string {
    superclass ::mustache::frame::scalar

    constructor {val} {
	debug.mustache/frame {}
	# Normalize double string. This is a mustache (ruby?) thing.
	if {[string is double -strict $val]} {
	    set val [expr $val]
	}
	next string $val
    }

    method nil? {} {
	debug.mustache/frame {string ([my value]) - [expr {[my value] eq {}}]}
	# Yes for an empty string. And also if the string is treatable
	# as a boolean, and representing a false. This is mustache
	# (ruby?) thing.
	expr {([my value] eq {}) || ([string is boolean -strict [my value]] && ![my value])}
    }
}

# # ## ### ##### ######## ############# #####################
## List/sequence value. Of frames.

oo::class create ::mustache::frame::sequence {
    superclass ::mustache::frame::base

    constructor {val} {
	# val :: list (frame-object)
	# Container owns the objects given to it.
	debug.mustache/frame {}
	set value $val
	return
    }

    destructor {
	# Container destroys the owned elements.
	debug.mustache/frame {}
	foreach el $value { $el destroy }
	return
    }

    method type {} {
	debug.mustache/frame {}
	return sequence
    }

    method for {valv script} {
	debug.mustache/frame {}
	upvar 1 $valv child
	foreach child $value {
	    set code [catch { uplevel 1 $script } result]
	    #    0 - the body executed successfully
	    #    1 - the body raised an error
	    #    2 - the body invoked [return]
	    #    3 - the body invoked [break]
	    #    4 - the body invoked [continue]
	    # else - return and pass on the results
	    switch -exact -- $code {
		0 - 4   {}
		3       { return }
		1       { return -errorcode $::errorCode -code error $result }
		default { return -code $code $result }
	    }
	}
	return
    }

    method visit {args} {
	debug.mustache/frame {}

	# Invoke self for start of sequence, then invoke the children,
	# at last invoke self a second time to indicate exit. The
	# second call is given the results from the children.

	uplevel #0 [list {*}$args sequence start [self]]
	uplevel #0 [list {*}$args sequence exit [self] \
	    [lmap child $value {
		$child visit {*}$args
	    }]]
    }

    method field {k} {
	debug.mustache/frame {}
	return -code error \
	    -errorcode {MUSTACHE FRAME SEQUENCE FIELD} \
	    "Sequence has no fields"
    }

    method has? {k} {
	debug.mustache/frame {}
	return 0
    }

    method iter {context script} {
	debug.mustache/frame {}
	foreach el $value {
	    $context push $el
	    uplevel 1 $script
	    $context pop
	}
	return
    }

    method iterable? {} {
	debug.mustache/frame {}
	# The double negation ensures that the result is a bool in
	# {0,1}, and not leaking the actual length of the value for
	# true.
	expr {!![llength $value]}
    }

    method nil? {} {
	debug.mustache/frame {sequence ($value) - [expr {![llength $value]}]}
	# Yes for an empty sequence.
	expr {![llength $value]}
    }

    method value {} {
	debug.mustache/frame {}
	# stringify - memoize ?
	return [lmap v $value { $v value }]
    }

    # - - -- --- ----- -------- -------------
    ## State variables

    variable value	;# Frame data (list, sequence)

    # - - -- --- ----- -------- -------------
}

# # ## ### ##### ######## ############# #####################
## Dictionary/map value. Keys mapping to frames.

oo::class create ::mustache::frame::mapping {
    superclass ::mustache::frame::base

    constructor {val} {
	debug.mustache/frame {}
	# val :: dict (key -> frame-object)
	# Container owns the objects given to it.
	set value $val
	return
    }

    destructor {
	# Container destroys the owned elements.
	debug.mustache/frame {}
	dict for {k el} $value { $el destroy }
	return
    }

    method type {} {
	debug.mustache/frame {}
	return mapping
    }

    method for {keyv valv script} {
	debug.mustache/frame {}
	upvar 1 $keyv key $valv child
	foreach {key child} $value {
	    set code [catch { uplevel 1 $script } result]
	    #    0 - the body executed successfully
	    #    1 - the body raised an error
	    #    2 - the body invoked [return]
	    #    3 - the body invoked [break]
	    #    4 - the body invoked [continue]
	    # else - return and pass on the results
	    switch -exact -- $code {
		0 - 4   {}
		3       { return }
		1       { return -errorcode $::errorCode -code error $result }
		default { return -code $code $result }
	    }
	}
	return
    }

    method visit {args} {
	debug.mustache/frame {}

	# Invoke self for start of mapping, then invoke the children,
	# at last invoke self a second time to indicate exit. The
	# second call is given the results from the children, in a
	# proper dictionary.

	uplevel #0 [list {*}$args mapping start [self]]
	uplevel #0 [list {*}$args mapping exit [self] \
	    [concat {*}[lmap {key child} $value {
		list $key [$child visit {*}$args]
	    }]]]
    }

    method field {k} {
	debug.mustache/frame {}
	if {![my has? $k]} {
	    return -code error \
		-errorcode {MUSTACHE FRAME MAPPING FIELD} \
		"Field '$k' is not known"
	}
	return [dict get $value $k]
    }

    method has? {k} {
	debug.mustache/frame {}
	dict exists $value $k
    }

    method iter {context script} {
	debug.mustache/frame {}
	return -code error \
	    -errorcode {MUSTACHE FRAME MAPPING ITER} \
	    "Mapping cannot be iterated over"
    }

    method iterable? {} {
	debug.mustache/frame {}
	return 0
    }

    method nil? {} {
	debug.mustache/frame {mapping ($value) - [expr {![dict size $value]}]}
	# Yes for an empty map.
	expr {![dict size $value]}
    }

    method value {} {
	debug.mustache/frame {}
	# stringify - memoize ?
	set r {}
	dict for {k v} $value { lappend r $k [$v value] }
	return $r
    }

    # - - -- --- ----- -------- -------------
    ## State variables

    variable value	;# Frame data (dictionary, map)

    # - - -- --- ----- -------- -------------
}

# # ## ### ##### ######## ############# #####################
return
