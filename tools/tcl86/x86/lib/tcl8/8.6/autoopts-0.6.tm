# autoopts v0.6.0
#
# This module automatically processes command line arguments and generates a
# usage message based on the arguments that your main proc takes. To use it,
# source this file and call [::autoopts::go ?description? ?your-main-proc?]
#
# Copyright (c) 2017, 2020 D. Bohdan.
# License: MIT.

namespace eval ::autoopts {
    variable version 0.6.0

    variable jim [expr {
        [info exists ::tcl_platform(engine)]
        && $::tcl_platform(engine) eq {Jim}
    }]
    variable usageMessage {usage: %s}
}
if {!$::autoopts::jim} {
    package require Tcl 8.5
    package require msgcat
}


proc ::autoopts::has-prefix name {
    return [regexp ^--? $name]
}


proc ::autoopts::args-with-defaults proc {
    variable jim

    if {$jim} { return [info args $proc] }

    set result {}
    foreach arg [info args $proc] {
        if {[info default $proc $arg default]} {
            lappend result [list $arg $default]
        } else {
            lappend result [list $arg]
        }
    }

    return $result
}


# Generate a command line argument spec based on the arguments the proc $proc
# takes.  The spec has the format
#
# {
#     flags {flag1 flagInfo1 ... flagN flagInfoN}
#     named {named1 namedInfo1 ... namedM nameInfoM}
#     positional {
#         positional1 positionalInfo1
#         ...
#         positionalP positionalInfoP
#     }
# }
#
# where flagI, namedJ, and positionalK are the literal flags and every *Info*
# is a dictionary {?default bar?}.
#
# Whether a proc argument becomes as flag or a named argument depends on its
# default value.  A flag must have the default value "false", "no", or "off".
proc ::autoopts::generate-spec proc {
    variable jim

    set spec {flags {} named {} positional {}}

    foreach argWithDefault [args-with-defaults $proc] {
        lassign $argWithDefault arg default
        set haveDefault [expr { [llength $argWithDefault] == 2 }]

        set info [dict create]

        if {$haveDefault} {
            dict set info default $default
        }
        if {$arg eq {args}} {
            dict set info default {}
        }

        if {[has-prefix $arg]} {
            if {$default in {false off no}} {
                dict set spec flags $arg $info
            } else {
                dict set spec named $arg $info
            }
        } else {
            dict set spec positional $arg $info
        }
    }

    return $spec
}


proc ::autoopts::me {} {
    return [file tail [info script]]
}


# Take a spec generated by [generate-spec] and return a human-readable usage
# message.
proc ::autoopts::generate-usage spec {
    variable jim
    variable usageMessage

    set usage [me]

    dict for {name info} [dict get $spec flags] {
        lappend usage "\[$name\]"
    }

    dict for {name info} [dict get $spec named] {
        if {[dict exists $info default]} {
            set default [dict get $info default]

            if {$default eq {} || [regexp {\s} $default]} {
                set default '$default'
            }

            lappend usage "\[$name $default\]"
        } else {
            lappend usage "$name [string toupper [string trimleft $name -]]"
        }
    }

    if {[llength [dict get $spec positional]] > 0} {
        append usage { [--]}

        dict for {name info} [dict get $spec positional] {
            if {$name eq {args}} {
                lappend usage "\[arg ...\]"
            } elseif {[dict exists $info default]} {
                lappend usage \[$name\]
            } else {
                lappend usage $name
            }
        }
    }

    set proc [expr { $jim ? {format} : {::msgcat::mc} }]
    return [$proc $usageMessage [join $usage]]
}


# Parse the command line argument list $arguments according to the spec $spec.
# Returns a dictionary {arg1 value1 ... argN valueN}.
proc ::autoopts::parse {spec arguments} {
    set flags [dict get $spec flags]
    set named [dict get $spec named]
    set positional [dict get $spec positional]

    set flagsKeys [dict keys $flags]
    set namedKeys [dict keys $named]
    set positionalKeys [dict keys $positional]

    set count [llength $arguments]
    set eon 0 ;# End of named arguments.
    set pos 0 ;# Number of positional arguments encountered.
    set values {} ;# Result.

    for {set i 0} {$i < $count} {incr i} {
        set arg [lindex $arguments $i]

        if {[has-prefix $arg] && !$eon} {
            if {$arg eq {--}} {
                set eon 1
                continue
            }

            if {$arg in $namedKeys} {
                if {$i + 1 < $count} {
                    dict set values $arg [lindex $arguments $i+1]
                } else {
                    error [list missing value for option $arg]
                }

                incr i
                continue
            }

            if {$arg in $flagsKeys} {
                dict set values $arg [string map {
                    false  true
                    off    on
                    no     yes
                } [dict get $flags $arg default]]

                continue
            }

            error [list unknown option: $arg]
        } else {
            if {$pos >= [dict size $positional]} {
                error {too many positional arguments}
            }

            set name [lindex $positionalKeys $pos]

            if {$name eq {args}} {
                dict lappend values $name $arg
            } else {
                dict set values $name $arg
                incr pos
            }
        }
    }

    set keys [dict keys $values]

    dict for {name info} [lrange $positional [expr { 2 * $pos }] end] {
        if {[dict exists $info default]} {
            dict set values $name [dict get $info default]
        } else {
            error {too few positional arguments}
        }
    }

    dict for {name info} $named {
        if {$name ni $keys} {
            if {[dict exists $info default]} {
                dict set values $name [dict get $info default]
            } else {
                error [list missing required option $name]
            }
        }
    }

    return $values
}


# Inspect proc $proc for argument names and call it in the [invoke] caller's
# frame with the argument values in the dictionary $values.
proc ::autoopts::invoke {proc values} {
    set procArgs {}
    foreach argWithDefault [args-with-defaults $proc] {
        lassign $argWithDefault arg default
        set haveDefault [expr { [llength $argWithDefault] == 2 }]

        if {$arg eq {args}} {
            lappend procArgs {*}[dict get $values $arg]
        } elseif {[dict exists $values $arg]} {
            lappend procArgs [dict get $values $arg]
        } elseif {$haveDefault} {
            lappend procArgs $default
        } else {
            error [list no value for argument $arg]
        }
    }
    uplevel 1 $proc {*}$procArgs
}


# Invoke $proc with arguments based on $::argv.  If some mandatory command line
# arguments are missing or there are too many of them,  print an error message
# and usage to stderr and exit with exit status 1.  If $::argv consists of just
# one of {/? -? -h -help --help}, print usage to stderr and exit with status
# 0.  The proc is invoked in the caller's frame.
proc ::autoopts::go {{description {}} {proc main}} {
    set spec [generate-spec $proc]
    if {[string trim $::argv] in {/? -? -h -help --help}} {
        puts stderr $description
        puts stderr [generate-usage $spec]
        exit 0
    }
    if {[catch {
        set values [parse $spec $::argv]
    } err]} {
        puts stderr $err
        puts stderr [generate-usage $spec]
        exit 1
    }
    uplevel 1 [list [namespace current]::invoke $proc $values]
}


# Testing.

proc ::autoopts::assert-equal {actual expected} {
    if {$actual ne $expected} {
        error [list expected $expected but got $actual]
    }
}


proc ::autoopts::test {} {
    variable jim

    proc ::autoopts::foo {-n --hello} {
        return [list ${-n} ${--hello}]
    }
    proc ::autoopts::bar {
        inputfile
        {outputfile -}
        {--compress no}
        {--format pdf}
    } {
        return [list $inputfile $outputfile ${--compress} ${--format}]
    }
    proc ::autoopts::baz {{-encoding {}} filename args} {
        return [list ${-encoding} $filename $args]
    }
    proc ::autoopts::flagship {{-a false} {-b no} {-c off} {-n 0}} {
        return [list ${-a} ${-b} ${-c} ${-n}]
    }
    namespace eval ::stpootua {}
    proc ::stpootua::qux {args} {
        return [list [info level] $args]
    }

    set fooSpec {flags {} named {-n {} --hello {}} positional {}}
    set barSpec [list \
        flags {--compress {default no}} \
        named {--format {default pdf}} \
        positional {inputfile {} outputfile {default -}} \
    ]
    set bazSpec [list \
        flags {} \
        named {-encoding {default {}}} \
        positional {filename {} args {default {}}} \
    ]
    set flagshipSpec [list \
        flags {-a {default false} -b {default no} -c {default off}} \
        named {-n {default 0}} \
        positional {} \
    ]


    # [generate-spec] and [generate-usage].

    set spec [generate-spec foo]
    assert-equal $spec $fooSpec
    assert-equal [generate-usage $spec] "usage: [me] -n N --hello HELLO"

    set spec [generate-spec bar]
    assert-equal $spec $barSpec
    assert-equal [generate-usage $spec] \
                 "usage: [me] \[--compress\] \[--format pdf\] \[--\]\
                  inputfile \[outputfile\]"

    set spec [generate-spec baz]
    assert-equal $spec $bazSpec
    assert-equal [generate-usage $spec] \
                 "usage: [me] \[-encoding ''\] \[--\] filename \[arg ...\]"

    set spec [generate-spec flagship]
    assert-equal $spec $flagshipSpec
    assert-equal [generate-usage $spec] \
                 "usage: [me] \[-a\] \[-b\] \[-c\] \[-n 0\]"


    # [generate-usage] localization.

    if {!$jim} {
        set locale [::msgcat::mclocale]
        set source {usage: %s}
        ::msgcat::mclocale en_US_meh
        ::msgcat::mcset en_US_meh $source {meh... use %s or something}

        set spec [generate-spec baz]
        assert-equal [generate-usage $spec] \
                     "meh... use [me] \[-encoding ''\] \[--\] filename\
                      \[arg ...\] or something"
        ::msgcat::mclocale $locale
    }

    # [parse].

    catch {parse $fooSpec {}} err
    assert-equal $err {missing required option -n}

    catch {parse $fooSpec {-n 5}} err
    assert-equal $err {missing required option --hello}

    catch {parse $fooSpec foo} err
    assert-equal $err {too many positional arguments}

    catch {parse $fooSpec {-n 5 --hello world --with-cheese}} err
    assert-equal $err {unknown option: --with-cheese}

    catch {parse $fooSpec {-n 5 --hello world --with-cheese no}} err
    assert-equal $err {unknown option: --with-cheese}

    assert-equal [parse $fooSpec {-n 5 --hello world}] {-n 5 --hello world}


    catch {parse $barSpec {}} err
    assert-equal $err {too few positional arguments}

    catch {parse $barSpec {x y z}} err
    assert-equal $err {too many positional arguments}

    catch {parse $barSpec {x --what? z}} err
    assert-equal $err {unknown option: --what?}

    assert-equal [parse $barSpec foo.doc] \
                 {inputfile foo.doc outputfile - --format pdf}

    assert-equal [parse $barSpec {foo.doc bar.pdf}] \
                 {inputfile foo.doc outputfile bar.pdf --format pdf}

    assert-equal [parse $barSpec {foo.doc bar.xlsx --format xlsx}] \
                 {inputfile foo.doc outputfile bar.xlsx --format xlsx}

    assert-equal [parse $bazSpec {test.tcl}] \
                 {filename test.tcl args {} -encoding {}}

    assert-equal [parse $bazSpec {-encoding utf-8 test.tcl}] \
                 {-encoding utf-8 filename test.tcl args {}}


    assert-equal [parse $flagshipSpec {}] \
                 {-n 0}

    assert-equal [parse $flagshipSpec {-a -b -c}] \
                 {-a true -b yes -c on -n 0}


    # [invoke].

    assert-equal [invoke foo {-n 42 --hello universe}] {42 universe}
    assert-equal [invoke bar {
        inputfile /dev/zero
        outputfile /dev/null
        --compress yes
        --format N/A
    }] {/dev/zero /dev/null yes N/A}
    assert-equal [invoke baz {
        -encoding utf-8 filename test.tcl args {arg1 arg2 arg3}
    }] {utf-8 test.tcl {arg1 arg2 arg3}}
    assert-equal [uplevel #0 {::autoopts::invoke ::stpootua::qux {args hello}}]\
                 {1 hello}

    # [go].

    set backup $::argv
    set ::argv hi
    assert-equal [go {} ::autoopts::bar] {hi - no pdf}
    set ::argv $backup

    rename ::autoopts::foo {}
    rename ::autoopts::bar {}
    rename ::autoopts::baz {}
    rename ::autoopts::flagship {}
    rename ::stpootua::qux {}
    namespace delete ::stpootua
}


# If this is the main script...
if {[info exists argv0] && ([file tail [info script]] eq [file tail $argv0])} {
    ::autoopts::test
}
package provide autoopts 0.6 