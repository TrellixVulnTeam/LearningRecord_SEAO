## -*- tcl -*-
# # ## ### ##### ######## #############
## (c) 2019 Andreas Kupries

# @@ Meta Begin
# Package mustache::render 1
# Meta author      {Andreas Kupries}
# Meta category    Template Processing
# Meta description Implementation of mustache, rendering
# Meta location    http:/core.tcl.tk/akupries/mustache
# Meta platform    tcl
# Meta summary     Mustache, logic-less templates
# Meta subject     mustache template logic-less
# Meta require     {Tcl 8.5-}
# Meta require     debug
# Meta require     debug::caller
# Meta require     mustache::parse
# @@ Meta End

package require Tcl 8.5
package require debug
package require debug::caller

package require mustache::parse 1

package provide mustache::render 1

# # ## ### ##### ######## #############

namespace eval ::mustache {
    namespace export render
    namespace ensemble create
}
namespace eval ::mustache::R {
    namespace export all lit var var.dot var/escaped.dot dot \
	section isection partial
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################

debug define mustache/render
debug level  mustache/render
debug prefix mustache/render {[debug caller] | }

# # ## ### ##### ######## #############
## API

proc ::mustache::render {template context writer} {
    debug.mustache/render {}
    # template :: children
    # children :: list (node)
    # node     :: list (tag args...)
    # tag in:
    # [ok] dot			:: list (tag _)
    # [ok] dot/escaped		:: list (tag _)
    # [ok] isection		:: list (tag pos field children)
    # [ok] lit			:: list (tag literal-text)
    # [ok] partial		:: list (tag pos field)
    # [ok] section		:: list (tag pos field children)
    # [ok] var			:: list (tag _ field)
    # [ok] var/escaped		:: list (tag _ field)
    ##
    # Each tag see above is implemented as a procedure in the internal
    # helper namespace/ensemble, `R`.
    ##

    R all $template $context $writer
    return
}

# # ## ### ##### ######## #############
## Internals

proc ::mustache::R::all {template context writer} {
    debug.mustache/render {}
    foreach node $template {
	{*}$node $context $writer
    }
    return
}

proc ::mustache::R::lit {text context writer} {
    debug.mustache/render {}
    D $writer $text
    return
}

proc ::mustache::R::var {_ field context writer} {
    debug.mustache/render {}
    # Ignore missing field
    if {![D $context has? $field]} return
    # Write field value, it is dot for but a moment.
    D $context focus $field
    D $writer [D $context value]
    D $context pop
    return
}

proc ::mustache::R::var/escaped {_ field context writer} {
    debug.mustache/render {}
    # Ignore missing field
    if {![D $context has? $field]} return
    # Write field value, it is dot for but a moment.
    D $context focus $field
    D $writer [HTMLEscape [D $context value]]
    D $context pop
    return
}

proc ::mustache::R::dot {_ _ context writer} {
    debug.mustache/render {}
    D $writer [D $context value]
    return
}

proc ::mustache::R::dot/escaped {_ _ context writer} {
    debug.mustache/render {}
    D $writer [HTMLEscape [D $context value]]
    return
}

proc ::mustache::R::section {pos field children context writer} {
    debug.mustache/render {}

    if {$field eq "."} {
	# Special operation when the section
	# refers to dot, i.e. the current focus.
	Section $children $context $writer
	# TODO Consider to re-inline
	return
    }

    # For a missing field skip the section.
    if {![D $context has? $field]} return

    # The field is the new context.
    D $context focus $field

    Section $children $context $writer
    # TODO Consider to re-inline

    D $context pop
    return
}

proc ::mustache::R::isection {pos field children context writer} {
    debug.mustache/render {}
    # Render once if field missing, false, or empty list.
    if {[D $context has? $field]} {
	D $context focus $field
	if {![D $context nil?]} {
	    D $context pop
	    return
	}
	D $context pop
    }

    all $children $context $writer
    return
}

proc ::mustache::R::partial {pos field padding context writer} {
    debug.mustache/render {}

    # field = symbolic name of the template to render here.
    if {![D $context template? $field]} return

    # TODO: handle different delimiters.
    # TODO: memoize part (per delimiter) to avoid re-parsing.

    # Get the part, parse it, render it.
    set part [D $context template $field]
    debug.mustache/render {raw => '[mustache::X $part]'}

    # Note: Prevent indenting after a trailing EOL.
    set restore 0
    if {[string index $part end] eq "\n"} {
	set restore 1
	set part [string range $part 0 end-1]
    }
    set part [string map [list \n \n$padding] $part]
    if {$restore} { append part \n }

    debug.mustache/render {pad => '[mustache::X $part]'}

    set part [mustache parse $padding$part]
    all $part $context $writer
    return
}

# # ## ### ##### ######## #############
## Shared behaviour

proc ::mustache::R::Section {children context writer} {
    debug.mustache/render {}

    # section behaviour:
    # false? - skip                \ nil?
    # true? - list? - empty ? skip /
    #                 iterate list
    #         once

    # Skip section if dot is false, or empty list.
    if {[D $context nil?]} return

    # Iterate a non-empty list.
    if {[D $context iterable?]} {
	D $context iter {
	    all $children $context $writer
	}
	return
    }

    # Not a list, not false either => Render once
    all $children $context $writer
    return
}

# # ## ### ##### ######## #############
## Internal support

proc ::mustache::R::D {prefix args} {
    debug.mustache/render {}
    uplevel 1 [list {*}$prefix {*}$args]
}

proc ::mustache::R::HTMLEscape {text} {
    # Not exported, not structure tag
    debug.mustache/render {}
    string map {
	&    &amp;
	<    &lt;
	>    &gt;
	"\"" &quot;
        '    &#39;
    } $text
}

# # ## ### ##### ######## #############
return
