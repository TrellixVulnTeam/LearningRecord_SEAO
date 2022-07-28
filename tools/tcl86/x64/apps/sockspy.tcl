#!/bin/sh
# restart using wish    -*- mode: tcl; tab-width: 8; -*- \
exec wish $0 ${1+"$@"}

# sockspy: copyright tom poindexter 1998
# sockspy: copyright Keith Vetter 2002
#	    tpoindex@nyx.net
# version 1.0 - december 10, 1998
# version 2.0 - January, 2002 by Keith Vetter
# KPV Nov 01, 2002 - added proxy mode
# KPV Dec 21, 2002 - added extract window
# version 2.5 - February, 2003 by Don Libes
# DL Jan/Feb, 2003 - added date support, state save/restore, cmdline display
# Pat Thoyts - 2007 - added theming / ttk support.
# 
# spy on conversation between a tcp client and server
#
# usage: sockspy clientPort serverHost serverPort
#	   clientPort - port to which clients connect
#	   serverHost - machine where real server runs
#	   serverPort - port on which real server listens
#  -or-	 sockspy -proxy proxyPort
#  -or-  sockspy -socks socksPort
#
#  additional options:
#  -myaddr name    - localhost or 0.0.0.0 or some other interface
#  -timeformat fmt - set the time display format
#
#  e.g. to snoop on http connections to a web server:
#	sockspy 8080 www.some.com 80
#  then client web browser should use a url like:
#	 http://localhost:8080/index.html
#	 (or set your browser's proxy to use 8080 on the sockspy machine)

catch {package require uri}			;# Error handled below

# Handle the various versions of tile/ttk
variable useTile
if {[package provide Tk] ne ""} {
    if {![info exists useTile]} {
        variable useTile 1
        variable NS "::ttk"
        if {[llength [info commands ::ttk::*]] == 0} {
            if {![catch {package require tile 0.8}]} {
                # we're all good
            } elseif {![catch {package require tile 0.7}]} {
                # tile to ttk compatability
                interp alias {} ::ttk::style {} ::style
                interp alias {} ::ttk::setTheme {} ::tile::setTheme
                interp alias {} ::ttk::themes {} ::tile::availableThemes
                interp alias {} ::ttk::LoadImages {} ::tile::LoadImages
            } else {
                set useTile 0
                set NS "::tk"
            }
        } else {
            # we have ttk in tk85
        }
        if {$useTile && [tk windowingsystem] eq "aqua"} {
            # use native scrollbars on the mac
            if {[llength [info commands ::ttk::_scrollbar]] == 0} {
                rename ::ttk::scrollbar ::ttk::_scrollbar
                interp alias {} ::ttk::scrollbar {} ::tk::scrollbar
            }
        }
        # Ensure that Tk widgets are available in the tk namespace. This is useful
        # if we are using Ttk widgets as sometimes we need the originals.
        #
        if {[llength [info commands ::tk::label]] < 1} {
            foreach cmd { label entry text canvas menubutton button frame labelframe \
                              radiobutton checkbutton scale scrollbar} {
                rename ::$cmd ::tk::$cmd
                interp alias {} ::$cmd {} ::tk::$cmd
            }
        }
    }
}

array set state {
    version 2.6
    extract 0
    bbar 1
    ascii 1
    autoscroll 1
    autowrap 1
    capture 1
    showsockname 0
    msg ""
    fixed {}
    fixedbold {}
    fontSize 9
    playback ""
    gui 0
    listen ""
    title "not connected"
    proxy 0
    fname ""
    time 1
    timeFormat ""
    timeFormatDefault "%H:%M:%S "
    myaddr localhost
}

# variables to save across runs
set saveList {
    state(extract)
    state(bbar)
    state(ascii)
    state(autoscroll)
    state(autowrap)
    state(proxy)
    state(fname)
    state(time)
    state(timeFormat)
    state(fontSize)
    state(showsockname)
    state(myaddr)
    extract(client)
    extract(server)
    extract(meta2)
    SP(proxyPort)
    SP(clntPort)
    SP(servPort)
    SP(servHost)
}

array set colors {client green server cyan meta red meta2 yellow}
array set SP {proxyPort 8080 clntPort 8080 servHost "" servPort 80}

set extract(client) {^(GET |POST |HEAD )}
set extract(server) {^(HTTP/|Location: |Content-)}
set extract(meta2) {.}
#set extract(meta) {.}

proc ttk_toplevel {w args} {
    variable useTile
    eval [linsert $args 0 ::toplevel $w]
    if {[info exists useTile] && $useTile} {
        place [ttk::frame $w._toplevel_background] -x 0 -y 0 -relwidth 1 -relheight 1
    }
    return $w
}

##+##########################################################################
# 
# createMain -- Creates the display
# 
proc createMain {} {
    global state colors tcl_platform
    variable NS
    
    wm withdraw .

    # See if we can find a better font than the TkFixedFont or courier
    if {[lsearch -exact [font names] TkFixedFont] != -1} {
        eval [linsert [font configure TkFixedFont] 0 font create SockspyFont]
    } else {
        font create SockspyFont -family courier
    }
    set families [font families]
    switch -exact -- [tk windowingsystem] {
        aqua { set preferred {Monaco 9} }
        win32 { set preferred {ProFontWindows 8 Consolas 8} }
        default { set preferred {} }
    }
    foreach {family size} $preferred {
        if {[lsearch -exact $families $family] != -1} {
            font configure SockspyFont -family $family -size $size
            break
        }
    }
    
    font configure SockspyFont -size $state(fontSize)
    set state(fixed) SockspyFont
    set state(fixedbold) [eval [list font create SockspyBold] \
                              [font configure SockspyFont] -weight bold]


    wm title . "SockSpy -- $state(title)"
    wm resizable .  1 1
    wm protocol . WM_DELETE_WINDOW Shutdown	;# So we shut down cleanly

    #
    # Set up the menus
    #
    menu .m -tearoff 0
    . configure -menu .m
    .m add cascade -menu .m.file -label "File" -underline 0
    .m add cascade -menu .m.view -label "View" -underline 0
    .m add cascade -menu .m.help -label "Help" -underline 0
    
    menu .m.file -tearoff 0
    .m.file add command -label "Save ..." -underline 0 -command saveOutput
    .m.file add command -label "Reconnect ..." -underline 0 -command GetSetup
    .m.file add separator
    .m.file add command -label "Exit" -underline 1 -command Shutdown
    
    menu .m.view -tearoff 0
    .m.view add command -label " Clear" -underline 1 -command clearOutput
    .m.view add separator
    .m.view add checkbutton -label " ButtonBar" -variable state(bbar) \
	    -underline 1 -command ButtonBar
    .m.view add checkbutton -label " Extract Window" -variable state(extract) \
	    -underline 1 -command ToggleExtract
    .m.view add separator
    .m.view add command -label " + Font" -command [list doFont 1]
    .m.view add command -label " - Font" -command [list doFont -1]
    .m.view add separator
    .m.view add radiobutton -label " Hex" -underline 1 \
	    -variable state(ascii) -value 0 -command redraw
    .m.view add radiobutton -label " ASCII" -underline 1 \
	    -variable state(ascii) -value 1 -command redraw
    .m.view add separator
    .m.view add checkbutton -label " Autoscroll" -underline 5 \
	    -variable state(autoscroll)
    .m.view add checkbutton -label " Autowrap" -underline 5 \
	    -variable state(autowrap) -command ToggleWrap
    .m.view add checkbutton -label " Capture" -underline 5 \
	    -variable state(capture) -command ToggleCapture
    .m.view add separator
    .m.view add checkbutton -label " Socket names" \
	-variable state(showsockname) -command togglesockname
    .m.view add checkbutton -label " Time" \
	-variable state(time) -command redraw
    .m.view add command -label " Time Format ..." -command timestampWindow

    menu .m.help -tearoff 0
    .m.help add command -label Help -underline 1 -command Help
    .m.help add separator
    .m.help add command -label About -command About
    #
    # Title and status window
    #
    ${NS}::frame .bbar
    ${NS}::frame .cmd ;#-relief sunken -borderwidth 2
    ${NS}::radiobutton .cmd.hex -text Hex -variable state(ascii) \
	    -value 0 -command redraw
    ${NS}::radiobutton .cmd.ascii -text ASCII -variable state(ascii) \
	    -value 1 -command redraw
    ${NS}::checkbutton .cmd.autos -text Autoscroll -variable state(autoscroll)
    ${NS}::checkbutton .cmd.autow -text Autowrap -variable state(autowrap) \
	 -command ToggleWrap
    ${NS}::checkbutton .cmd.capture -text Capture -variable state(capture) \
	 -command ToggleCapture
    ${NS}::checkbutton .cmd.time -text Time -variable state(time) \
	 -command redraw
    ${NS}::button .cmd.clear -text Clear -command clearOutput -width -6
    #button .cmd.incr -text "+ Font" -command [list doFont 1]
    #button .cmd.decr -text "- Font" -command [list doFont -1]
    ${NS}::button .cmd.save -text Save -command saveOutput -width -6
    ${NS}::button .cmd.kill -text Exit -command Shutdown -width -6
    pack .cmd -side top -fill x -pady 2 -in .bbar
    pack .cmd.kill .cmd.save .cmd.clear .cmd.autow .cmd.autos .cmd.capture \
        .cmd.time -side right -padx 1 -pady 1
    #label .title -relief ridge -textvariable state(title)
    #.title config -font "[.title cget -font] bold"
    ${NS}::label .stat -textvariable state(msg) -anchor w

    #
    # Now for the output area of the display
    #
    ${NS}::scrollbar .yscroll -orient vertical -command {.out yview}
    ${NS}::scrollbar .xscroll -orient horizontal -command {.out xview}
    text .out -width 80 -height 43 -font $state(fixed) -background white -setgrid 1 \
	    -yscrollcommand ".yscroll set" -xscrollcommand ".xscroll set" -borderwidth 1
    foreach t [array names colors] {
	.out tag configure $t -background $colors($t) -borderwidth 1 \
	    -relief raised -lmargin1 5 -lmargin2 5
	.out tag configure time_$t -background $colors($t) -borderwidth 1 \
	    -relief raised -lmargin1 5 -lmargin2 5 -font $state(fixedbold)
    }
    .out tag configure sockname -elide 1
    .out tag configure client2 -font $state(fixedbold)
    .out tag raise sel				;# Selection is most prominent

    grid .bbar -       -row 0 -sticky ew
    grid .out .yscroll -row 1 -sticky news
    grid .xscroll      -row 2 -sticky ew
    grid .stat -       -row 3 -sticky ew
    grid rowconfigure	 . 1 -weight 1
    grid columnconfigure . 0 -weight 1

    bind .out <Control-l> clearOutput
    if {[tk windowingsystem] eq "win32"} {
        bind all <Alt-c> {console show}
        bind all <Control-F2> {console show}
    }
    focus .out
    wm geometry . +10+10
    wm deiconify .
}
##+##########################################################################
# 
# createExtract -- Creates the extract toplevel window.
# 
proc createExtract {} {
    global state colors
    variable NS

    set top .extract
    if {[winfo exists $top]} {
	wm deiconify $top
	return
    }

    ttk_toplevel $top
    wm withdraw $top
    wm title $top "SockSpy Extract"
    wm transient $top .
    wm protocol $top WM_DELETE_WINDOW [list ToggleExtract -1]
    if {[regexp {(\+[0-9]+)(\+[0-9]+)$} [wm geom .] => wx wy]} {
	wm geom $top "+[expr {$wx+35+[winfo width .]}]+[expr {$wy+15}]"
    }

    ${NS}::frame $top.top
    ${NS}::label $top.top.c  -text "Client Filter" -anchor e
    entry $top.top.ce -textvariable extract(client) -bg $colors(client)
    ${NS}::label $top.top.s  -text "Server Filter" -anchor e
    entry $top.top.se -textvariable extract(server) -bg $colors(server)
    ${NS}::label $top.top.m  -text "Metadata Filter" -anchor e
    entry $top.top.me -textvariable extract(meta2) -bg $colors(meta2)
    
    text $top.out -width 80 -height 20 -font $state(fixed) \
	-setgrid 1 -wrap none -yscrollcommand [list $top.yscroll set] \
	-xscrollcommand [list $top.xscroll set]
    foreach t [array names colors] {
	$top.out tag configure $t -background $colors($t) -borderwidth 2 \
	    -relief raised -lmargin1 5 -lmargin2 5
	$top.out tag configure time_$t -background $colors($t) -borderwidth 2 \
	    -relief raised -lmargin1 5 -lmargin2 5 -font $state(fixedbold)
    }
    $top.out tag raise sel			;# Selection is most prominent

    ${NS}::scrollbar $top.yscroll -orient vertical -command [list $top.out yview]
    ${NS}::scrollbar $top.xscroll -orient horizontal -command [list $top.out xview]
    grid $top.top - -row 0     -sticky ew -ipady 10
    grid $top.out $top.yscroll -sticky news
    grid $top.xscroll	       -sticky ew

    grid rowconfigure	 $top 1 -weight 1
    grid columnconfigure $top 0 -weight 1

    grid $top.top.c $top.top.ce -row 0 -sticky ew
    grid $top.top.s $top.top.se	       -sticky ew
    grid $top.top.m $top.top.me	       -sticky ew
    grid columnconfigure $top.top 1 -weight 1
    grid columnconfigure $top.top 2 -minsize 10
    wm deiconify $top
}
##+##########################################################################
# 
# doFont -- Changes the size of the font used for the display text
# 
proc doFont {delta} {
    global state

    incr state(fontSize) $delta
    font configure $state(fixed) -size $state(fontSize)
    font configure $state(fixedbold) -size $state(fontSize)
}
##+##########################################################################
# 
# clearOutput -- Erases the content of the output window
# 
proc clearOutput {} {
    global state
    if {$state(gui)} {
	.out delete 0.0 end
	catch {.extract.out delete 0.0 end}
    }
    set state(playback) ""
}
##+##########################################################################
# 
# redraw -- Redraws the contents of the output window.
#
# It does this by replaying the input stream.
# 
proc redraw {} {
    global state 

    set save_as $state(autoscroll)		;# Disable autoscrolling
    set state(autoscroll) 0

    set p $state(playback)			;# Save what gets displayed
    clearOutput					;# Erase current screen
    foreach {who data time} $p {		;# Replay the input stream
	insertData $who $data $time 1
    }
    set state(autoscroll) $save_as
}

proc togglesockname {} {
    global state
    .out tag configure sockname -elide [expr {!$state(showsockname)}]
}

##+##########################################################################
# 
# saveOutput -- Saves the content of the output window. 
# 
# It uses the playback stream as its data source.
# 
proc saveOutput {} {
    global state
    variable NS
    set dlg [ttk_toplevel .what -class Dialog]
    variable $dlg ""
    variable but both
    wm withdraw $dlg
    wm title $dlg "SockSpy Save"
    wm transient $dlg .
    
    set f [${NS}::labelframe $dlg.f -text "Select window"]
    foreach name {server client both} {
        set b [${NS}::radiobutton $f.$name -text $name \
                   -variable ::but -value $name]
        if {$NS ne "::ttk"} {$b configure -anchor w}
        grid $b -sticky ew
    }
    grid columnconfigure $f 0 -weight 1
    
    ${NS}::button $dlg.ok -text OK -default active \
        -command [list set [namespace which -variable $dlg] ok]
    ${NS}::button $dlg.cancel -text Cancel \
        -command [list set [namespace which -variable $dlg] cancel]
    if {$NS ne "::ttk"} {
        foreach b {ok cancel} {$dlg.$b configure -width -10}
    }

    grid $f - -sticky news -padx 2 -pady 2
    grid $dlg.ok $dlg.cancel -sticky se
    grid columnconfigure $dlg 0 -weight 1
    grid rowconfigure $dlg 0 -weight 1

    bind $dlg <Return> [list $dlg.ok invoke]
    bind $dlg <Escape> [list $dlg.cancel invoke]

    tk::PlaceWindow $dlg widget .
    wm deiconify $dlg
    tkwait variable [namespace which -variable $dlg]
    if {[set $dlg] eq "ok"} {
        set state(msg) "Saving ..."
        busy hold $dlg
        update idletasks
        performSaveOutput $dlg $but
        busy forget $dlg
        set state(msg) "Save completed."
    }
    destroy $dlg
    unset $dlg
}
proc busy {state w} {
    if {[info commands tk::busy] ne {}} {
        tk::busy $state .
    } else {
        set c [expr {$state eq "hold" ? "watch" : ""}]
        . configure -cursor $c
        $w configure -cursor $c
    }
}
proc performSaveOutput {dlg which} {
    global state
    set file [tk_getSaveFile -parent $dlg -initialfile $state(fname)]
    if {$file == ""} return

    set state(fname) $file
    if {[catch {open $file w} fd]} {
	tk_messageBox  -icon error -type ok -title "SockSpy error" \
            -message "Cannot open file '$file'"
	return
    }
    fconfigure $fd -translation binary
    foreach {who data time} $state(playback) {
	if {$who == "meta" || $who == "meta2"} continue
	if {$which eq "both" || $which == $who} {
	    if {$state(time)} {
		puts $fd [timestamp $time]
	    }
	    puts $fd $data
	}
    }
    close $fd
}

##+##########################################################################
# 
# printable -- Replaces all unprintable characters into dots.
# 
proc printable {s {spaces 0}} {
    variable printable
    if {![info exists printable]} {
        for {set n 0} {$n < 256} {incr n} {
            if {($n < 32 || $n >= 0x7e) && $n != 9} {
                lappend printable [format %c $n] "."
            }
        }
    }
    set s [string map $printable $s]
    if {$spaces} {
        set s [string map {" " "_"} $s]
    }
    return $s
}
##+##########################################################################
# 
# insertData -- Inserts data into the output window. WHO tells us if it is
# from the client, server or meta.
# 
proc insertData {who data {time {}} {force 0}} {
    global state
    foreach {who sockname} $who break
    array set prefix {meta = meta2 = client > server <}

    if {$time == ""} {				;# If not set, then set to now
	set time [clock seconds]
    }
    set timestamp [timestamp $time]

    DoExtract $who $data $timestamp		;# Display any extracted data
    if {! $force && ! $state(capture)} return	;# No display w/o capture on
    lappend state(playback) $who $data $time	;# Save for redraw and saving
    
    if {$state(ascii) || [regexp {^meta2?$} $who] } {
	regsub -all \r $data "" data
	foreach line [split $data \n] {
	    set line [printable $line]
	    set tag $who
	    if {$tag == "client" && [regexp -nocase {^get |^post } $line]} {
		lappend tag client2
	    }
	    if {$state(gui)} {
		.out insert end "$timestamp" time_$tag \
                    "$sockname " [concat $tag sockname] \
                    "$line\n" $tag
	    } else {
		puts "$timestamp$prefix($who)$line"
	    }
	}
    } else {					;# Hex output
	while {[string length $data]} {
	    set line [string range $data 0 15]
	    set data [string range $data [string length $line] end]
	    binary scan $line H* hex
	    regsub -all {([0-9a-f][0-9a-f])} $hex {\1 } hex
	    set line [format "%-48.48s	%-16.16s\n" $hex [printable $line 1]] 
	    if {$state(gui)} {
		.out insert end "$timestamp" time_$who \
                    "$sockname " [list $who sockname] \
                    "$line" $who
	    } else {
		puts "$timestamp$prefix(who)$line"
	    }
	}
    }
    if {$state(autoscroll) && $state(gui)} {
	.out see end
    }
}
##+##########################################################################
#
# timestampInit -- Initialize timestamp support
#
proc timestampInit {} {
    global state

    set state(timeFormat) $state(timeFormatDefault)
}
##+##########################################################################
#
# timestamp -- Produce printable timestamps
#
# Note that it is the user's responsibility to make sure the
# user-supplied format ends with a delimiter or separator such as a
# space or colon. The timestamp code itself checks whether or not it
# should do anything to simplify the many different places in the code
# from which can be called.

proc timestamp {time} {
    global state
    
    if {! $state(time)} { return "" }
    return [clock format $time -format $state(timeFormat)]
}
##+###########################################################################
#
# timestampWindow -- Dialog for the user to configure the timestamp format.
#
proc timestampWindow {} {
    global state
    variable NS

    set state(oldTimeFormat) $state(timeFormat)

    set w .tf2
    destroy .tf
    ttk_toplevel .tf
    wm title .tf "SockSpy Time Format"
    wm transient .tf .
    wm withdraw .tf

    set txt "Edit the format used for timestamps. See the Tcl clock command\n"
    append txt "documentation for a complete description of acceptable formats."
    
    ${NS}::labelframe .tf.top ;#-bd 2 -relief raised -padx 5
    
    ${NS}::label .tf.t -text $txt
    ${NS}::label .tf.l -text "Format: "
    ${NS}::entry .tf.e -textvariable state(timeFormat)
    ${NS}::button .tf.ok -text OK -default active -command {tfButton ok}
    ${NS}::button .tf.default -text Default -underline 0 \
        -command {tfButton default}
    ${NS}::button .tf.cancel -text Cancel -command {tfButton cancel}
    if {$NS ne "::ttk"} {
        foreach b {ok cancel default} {.tf.$b configure -width -10}
    }

    grid .tf.top -row 0 -column 0 -columnspan 4 -sticky ew -padx 10 -pady 10
    grid columnconfigure .tf 0 -weight 1
    grid x .tf.ok .tf.default .tf.cancel -padx 2 -sticky ew
    grid rowconfigure .tf 2 -minsize 8

    grid .tf.t - -in .tf.top -row 0
    grid .tf.l .tf.e -in .tf.top -row 1 -pady 10 -sticky ew
    grid columnconfigure .tf.top 1 -weight 1
    grid columnconfigure .tf.top 2 -minsize 10

    bind .tf <Escape> [list .tf.cancel invoke]
    bind .tf <Return> [list .tf.ok invoke]
    bind .tf <Alt-Key-d> [list .tf.default invoke]

    focus .tf.e
    .tf.e icursor end
    .tf.e select range 0 end
    tk::PlaceWindow .tf widget .
    wm deiconify .tf
}
##+##########################################################################
# 
# tfButton -- handles button clicks on the timestamp dialog
# 
proc tfButton {who} {
    if {$who == "default"} {
	set ::state(timeFormat) $::state(timeFormatDefault)
    } elseif {$who == "ok"} {
	destroy .tf
	redraw
    } elseif {$who == "cancel"} {
	set ::state(timeFormat) $::state(oldTimeFormat)
	destroy .tf
    }
}
##+##########################################################################
# 
# INFO
# 
# Puts up an informational message both in the output window and
# in the status window.
# 
proc INFO {msg {who meta} {time {}} {display 0}} {
    global state
    set state(msg) $msg
    insertData $who $msg $time $display
}
proc ERROR {emsg} {
    if {$::state(gui)} {
	tk_messageBox -title "SockSpy Error" -message $emsg -icon error
    } else {
	puts $emsg
    }
}
##+##########################################################################
# 
# sockReadable -- Called when there is data available on the fromSocket
# 
proc sockReadable {fromSock toSock who} {
    global state
    set died [catch {set data [read $fromSock]} err]
    if {$died || [eof $fromSock]} {
	close $fromSock
	catch { close $toSock }
	if {$died} { INFO $err }
	INFO "----- closed connection $fromSock \[eof\] -----"
	INFO "waiting for new connection..." 
	return
    }
    if {$toSock == ""} { ;# Make socks or http proxy connection
        if {[catch {ProxyConnect $fromSock $data} err]} {
            INFO $err
            close $fromSock
            INFO "----- closed connection $fromSock -----"
            INFO "waiting for new connection..." 
            return 0
        }
    } else {
	catch { puts -nonewline $toSock $data } ;# Forward if we have a socket
    }
    insertData [list $who $fromSock] $data
    update idletasks
}
##+##########################################################################
# 
# ProxyConnect
# 
# Called from a new socket connection when we have to determing who
# to forward to.
# 
proc ProxyConnect {fromSock data} {
    global state
    if {$state(proxy) eq "socks"} {
        return [SocksConnect $fromSock $data]
    }
    set skip 0
    set line1 [string range $data 0 [string first "\n" $data]]
    set line1 [string trimright $line1 "\r\n"]
    INFO "proxy request \"$line1\"" meta2
    if {![regexp {^([^ ]+) +([^ ]+)} $line1 -> method uri]} {
	return -code error "failed to parse a uri from '$line1'"
    }
    
    set method [string trim [string toupper $method]]
    if {$method eq "CONNECT"} {
        foreach {host port} [split $uri :] break
        if {$port eq ""} {set port 443}
        set uri "https://$host:$port"
        # Find the end of headers - if we do not have that yet then
        # we will have to do some reading until we have that.
        set pos [string first \r\n\r\n $data]
        if { $pos == -1 } {
            INFO "waiting for additional headers for CONNECT proxying"
            set skip 1
        } else {
            incr pos 4
            set data [string range $data $pos end]
            INFO "[string length $data] bytes to send for CONNECT"
        }
    }

    set state(uri) $uri				;# For debugging
    array set URI [::uri::split $uri]
    if {[lsearch {http https} [string tolower $URI(scheme)]] == -1} {
        return -code error "cannot proxy the '$URI(scheme)' protocol"
    }
    if {$URI(port) == ""} { set URI(port) 80 }
    set bad [catch {set sockServ [socket $URI(host) $URI(port)]} reason]
    if {$bad} {
	return -code error "cannot connect to $URI(host):$URI(port) => $reason"
    }
    if {$method eq "CONNECT"} {
	# We must send an HTTP response header to the client
	set s "HTTP/1.0 200 OK\nServer: SockSpy/$::state(version)\n"
	insertData meta $s
	puts $fromSock $s
    }
    INFO "fowarding $method request to $URI(host):$URI(port)" meta2
    if {$skip} {
	fileevent $fromSock readable \
	    [list ProxySkip $fromSock $sockServ]
    } else {
	fileevent $fromSock readable \
	    [list sockReadable $fromSock $sockServ client]
    }
    fconfigure $sockServ -blocking 0 -buffering none -translation binary
    fileevent $sockServ readable \
	[list sockReadable $sockServ $fromSock server]
    
    puts -nonewline $sockServ $data
    return
}

proc SocksConnect {client data} {
    set params [parseSOCKS $data]
    if {[llength $params] == 0} {
        puts -nonewline $client [binary format ccc2c4 0 0x5b {0 0} {0 0 0 0}]
        return -code error "failed to parse SOCKS prefix"
    }
    foreach {_ user _ host _ port _ xdata} $params break
    if {[catch {set sock [socket $host $port]} err]} {
        puts -nonewline $client [binary format ccc2c4 0 0x5b {0 0} {0 0 0 0}]
        return -code error "cannot connect to $host:$port: $err"
    }
    puts "connected to $host:$port on $sock"
    INFO "forwarding socks connection to $host:$port" meta2

    foreach {ip name port} [fconfigure $sock -peername] break
    puts -nonewline $client [binary format ccSc4 0 0x5a $port [split $ip .]]
    flush $client

    fileevent $client readable \
        [list sockReadable $client $sock client]
    fconfigure $sock -blocking 0 -buffering none -translation binary
    fileevent $sock readable \
        [list sockReadable $sock $client server]
    if {[string length $xdata] > 0} {
        puts -nonewline $sock $xdata
    }
    return
}

##+##########################################################################
# 
# ProxySkip
# 
# Called from a new CONNECT proxy connection when we still need to skip the 
# http header.
# 
proc ProxySkip {fromSock toSock} {
    global state
    set data [read $fromSock]
    if {[string length $data] == 0} {
	close $fromSock
	catch { close $toSock }
	INFO "----- closed connection -----"
	INFO "waiting for new connection..." 
	return
    }
    set pos [string first \r\n\r\n $data]
    if { $pos == -1 } {
	# Just drop the data.
	return
    }
    incr pos 4
    set data [string range $data $pos end]
    if { [string length $data] > 0 } {
	# Forward the real payload
	catch { puts -nonewline $toSock $data } ;
        insertData client $data
    }
    # And let the normal data handler do the rest:
    fileevent $fromSock readable \
        [list sockReadable $fromSock $toSock client]

    update    
}

# Parse the SOCKS prefix data. Handles SOCKS4 and SOCKS4a
proc parseSOCKS {data} {
    if {[string length $data] < 8} { return }
    binary scan $data ccSc4 version command port soctets
    set version [expr {$version & 0xff}]
    set command [expr {$command & 0xff}]
    set port [expr {$port & 0xffff}]
    foreach octet $soctets { lappend octets [expr {$octet & 0xff}] }
    set addr [join $octets .]
    set p1 [string first \0 $data 8]
    if {$p1 == -1} { INFO "no user name data"; return }
    set user [string range $data 8 [expr {$p1 - 1}]]
    if {[string match "0.0.0.*" $addr]} {
        set p2 [string first \0 $data [incr p1]]
        if {$p2 == -1} { INFO "no hostname data"; return }
        set host [string range $data $p1 [expr {$p2 - 1}]]
    } else {
        set host $addr
        set p2 $p1
    }
    set data [string range $data [incr p2] end]

    INFO [format {%s %s request by '%s' to %s:%d (%d byte excess)} \
              [expr {[string match "0.0.0*" $addr] ? "socks4a" : "socks4"}]\
              [expr {$command? "connect" : "listen"}] \
              $user $host $port [string length $data]]
    return [list user $user host $host port $port data $data]
}

##+##########################################################################
# 
# clntConnect -- Called when we get a new client connection
# 
proc clntConnect {sockClnt ip port} {
    global state SP

    set state(sockClnt) $sockClnt
    set state(meta) ""
    
    INFO "connect from [fconfigure $sockClnt -sockname] $port" meta2
    if {$state(proxy) ne "none"
        || $SP(servHost) == {} 
        || $SP(servHost) == "none"} {
	set sockServ ""
    } else {
	set n [catch {set sockServ [socket $SP(servHost) $SP(servPort)]} reason]
	if {$n} {
	    INFO "cannot connect: $reason"
	    close $sockClnt
	    ERROR "cannot connect to $SP(servHost) $SP(servPort): $reason"
	    insertData meta "----- closed connection -----"
	    insertData meta "waiting for new connection..." 
	    
	}
	INFO "connecting to $SP(servHost):$SP(servPort)" meta2
    }

    ;# Configure connection to the client
    fconfigure $sockClnt -blocking 0 -buffering none -translation binary
    fileevent $sockClnt readable \
	    [list sockReadable $sockClnt $sockServ client]

    ;# Configure connection to the server
    if {[string length $sockServ]} {
	fconfigure $sockServ -blocking 0 -buffering none -translation binary
	fileevent $sockServ readable \
		[list sockReadable $sockServ $sockClnt server]
    }
}
##+##########################################################################
# 
# DoListen
# 
# Opens the socket server to listen for connections. It first closes it if
# it is already open.
# 
proc DoListen {} {
    global state SP

    set rval 1
    catch {close $state(sockClnt)} ;# Only the last open connection
    
    # Close old listener if it exists
    if {$state(listen) != ""} {
	set n [catch {close $state(listen)} emsg]
	if {$n} { INFO "socket close error: $emsg"}
	set state(listen) ""
	after idle [list DoListen]
        return
    }

    # Listen on clntPort or proxyPort for incoming connections
    set port $SP(clntPort)
    if {$state(proxy) ne "none"} {set port $SP(proxyPort)}
    set n [catch {
        set state(listen) \
            [socket -server clntConnect -myaddr $state(myaddr) $port]} emsg]
    
    if {$n} {
	INFO "socket open error: $emsg"
	set state(title) "not connected"
	set rval 0
    } else {
	switch -exact -- $state(proxy) {
            "http" {
                set state(title) "HTTP proxy localhost:$SP(proxyPort)"
            }
            "socks" {
                set state(title) "SOCKS proxy localhost:$SP(proxyPort)"
            }
            default {
                set state(title) "localhost:$SP(clntPort) <--> "
                append state(title) "$SP(servHost):$SP(servPort)"
            }
        }
	INFO $state(title)
	INFO "waiting for new connection..."
    }
    if {$state(gui)} {
        wm title . "SockSpy -- $state(title)"
    }
    return $rval
}
##+##########################################################################
# 
# GetSetup -- Prompts the user for client port, server host and server port
# 
proc GetSetup {} {
    global state SP ok
    variable NS
    array set save [array get SP]
    set ok 0					;# Assume cancelling

    ;# Put in some default values
    if {![string length $SP(proxyPort)]} {set SP(proxyPort) 8080}
    if {![string length $SP(clntPort)]}	 {set SP(clntPort) 8080}
    if {![string length $SP(servPort)]}	 {set SP(servPort) 80}
    
    if {! $state(gui)} {
	catch {close $state(listen)}

	set d "no" ; if {$state(proxy) eq "http"} { set d yes }
	set p [Prompt "HTTP proxy mode" $d]
	if {[regexp -nocase {^y$|^yes$} $p]} {
	    set state(proxy) http
	    set SP(proxyPort) [Prompt "proxy port" $SP(proxyPort)]
	} else {
            set d "no" ; if {$state(proxy) eq "socks"} { set d yes }
            set p [Prompt "SOCKS proxy mode" $d]
            if {[regexp -nocase {^y$|^yes$} $p]} {
                set state(proxy) socks
                set SP(proxyPort) [Prompt "proxy port" $SP(proxyPort)]
            } else {
                set state(proxy) none
                set SP(clntPort) [Prompt "Client port" $SP(clntPort)]
                set SP(servHost) [Prompt "Server host" $SP(servHost)]
                set SP(servPort) [Prompt "Server port" $SP(servPort)]
            }
	}
	DoListen
	return
    } 

    destroy .dlg
    ttk_toplevel .dlg
    wm withdraw .dlg
    wm title .dlg "SockSpy Setup"
    wm transient .dlg .
    
    ${NS}::label .dlg.top
    set msg    "You can configure SockSpy to either forward data\n"
    append msg "a fixed server and port or to use the HTTP Proxy\n"
    append msg "protocol to dynamically determine the server and\n"
    append msg "port to forward data to."

    ${NS}::frame .dlg.fforward
    ${NS}::frame .dlg.fproxy
    ${NS}::frame .dlg.fsocks
    ${NS}::frame .dlg.fcmdline

    ${NS}::label .dlg.msg -text $msg -justify left
    ${NS}::radiobutton .dlg.forward -text "Use fixed server forwarding" \
	-variable state(proxy)	-value none -command GetSetup2
    if {$NS ne "::ttk"} { .dlg.forward configure -anchor w }
    ${NS}::label .dlg.fl1 -text "Client Port:" -anchor e
    ${NS}::entry .dlg.fe1 -textvariable SP(clntPort)

    ${NS}::label .dlg.fl2 -text "Server Host:" -anchor e
    ${NS}::entry .dlg.fe2 -textvariable SP(servHost)
    ${NS}::label .dlg.fl3 -text "Server Port:" -anchor e
    ${NS}::entry .dlg.fe3 -textvariable SP(servPort)
    
    ${NS}::radiobutton .dlg.proxy -text "Use HTTP Proxying" \
	-variable state(proxy)	-value http -command GetSetup2
    if {$NS ne "::ttk"} {.dlg.proxy configure -anchor w}
    ${NS}::label .dlg.pl1 -text "Proxy Port:" -anchor e
    ${NS}::entry .dlg.pe1 -textvariable SP(proxyPort)

    ${NS}::radiobutton .dlg.socks -text "Use SOCKS proying" \
        -variable state(proxy) -value socks -command GetSetup2
    if {$NS ne "::ttk"} {.dlg.socks configure -anchor w}
    ${NS}::label .dlg.sl1 -text "Proxy Port:" -anchor e
    ${NS}::entry .dlg.se1 -textvariable SP(proxyPort)

    ${NS}::checkbutton .dlg.local -text "Listen on all interfaces" \
        -variable state(myaddr) -onvalue 0.0.0.0 -offvalue localhost
    if {$NS ne "::ttk"} {.dlg.local configure -anchor w}
        
    ${NS}::label .dlg.cllabel -text "Command Line Equivalent"
    ${NS}::entry .dlg.clvar -textvariable SP(cmdLine)
    # -state readonly doesn't seem to work, sigh
    
    ${NS}::button .dlg.ok -text OK -default active -command ValidForm
    ${NS}::button .dlg.cancel -text Cancel -command [list destroy .dlg]
    if {$NS ne "::ttk"} {
        foreach win {.dlg.ok .dlg.cancel} {$win configure -width -10}
    }
    
    grid .dlg.top -row 0 -column 0 -columnspan 3 -sticky ew -padx 2 -pady 2
    grid columnconfigure .dlg 0 -weight 1
    grid x .dlg.ok .dlg.cancel -padx 2
    grid configure .dlg.ok -padx 0
    grid rowconfigure .dlg 2 -minsize 8
    
    pack .dlg.msg -in .dlg.top -side top -fill x -padx 2 -pady 1
    pack .dlg.fforward .dlg.fproxy .dlg.fsocks .dlg.local .dlg.fcmdline \
        -in .dlg.top -side top -fill x -padx 2 -pady 2
    
    grid .dlg.cllabel -in .dlg.fcmdline -row 0 -column 0 -sticky w 
    grid .dlg.clvar -in .dlg.fcmdline -row 1 -column 0 -sticky ew
    grid columnconfigure .dlg.fcmdline 0 -weight 1
    # no need for row/col configure

    grid .dlg.proxy - - -in .dlg.fproxy -sticky w
    grid x .dlg.pl1 .dlg.pe1 -in .dlg.fproxy -sticky ew
    grid columnconfigure .dlg.fproxy 0 -minsize .2i
    grid columnconfigure .dlg.fproxy 2 -weight 1
    grid columnconfigure .dlg.fproxy 3 -minsize 10
    grid rowconfigure .dlg.fproxy 2 -minsize 10

    grid .dlg.socks - - -in .dlg.fsocks -sticky w
    grid x .dlg.sl1 .dlg.se1 -in .dlg.fsocks -sticky ew
    grid columnconfigure .dlg.fsocks 0 -minsize .2i
    grid columnconfigure .dlg.fsocks 2 -weight 1
    grid columnconfigure .dlg.fsocks 3 -minsize 10
    grid rowconfigure .dlg.socks 2 -minsize 10

    grid .dlg.forward - - -in .dlg.fforward -sticky w
    grid x .dlg.fl1 .dlg.fe1 -in .dlg.fforward -sticky ew
    grid x .dlg.fl2 .dlg.fe2 -in .dlg.fforward -sticky ew
    grid x .dlg.fl3 .dlg.fe3 -in .dlg.fforward -sticky ew
    grid columnconfigure .dlg.fforward 0 -minsize .2i
    grid columnconfigure .dlg.fforward 2 -weight 1
    grid columnconfigure .dlg.fforward 3 -minsize 10
    grid rowconfigure .dlg.fforward 4 -minsize 10

    bind .dlg <Return> [list .dlg.ok invoke]
    bind .dlg <Escape> [list .dlg.cancel invoke]
    
    GetSetup2
    foreach entry {.dlg.pe1 .dlg.fe2 .dlg.se1} {
        $entry icursor end
    }

    # trace all variables involved in the Setup window 
    trace variable state(proxy) w cmdlineUpdate
    trace variable SP w cmdlineUpdate
    cmdlineUpdate SP servHost w

    switch -exact -- $state(proxy) {
        "http" { set focus .dlg.pe1 }
        "socks" { set focus .dlg.se1 }
        default { set focus .dlg.fe2 }
    }
    focus -force $focus
    tk::PlaceWindow .dlg widget .
    wm deiconify .dlg
    tkwait window .dlg
    wm deiconify .

    if {$ok} {
	DoListen
    } else {
	array set SP [array get save]
    }
}
##+##########################################################################
# 
# GetSetup2 -- toggles between forwarding and proxying modes in the dialog
# 
proc GetSetup2 {} {
    global state
    switch -exact -- $state(proxy) {
        "none" {array set s {0 normal 1 disabled 2 disabled}}
        "http" {array set s {0 disabled 1 normal 2 disabled}}
        "socks" {array set s {0 disabled 1 disabled 2 normal}}
    }
    
    .dlg.pl1 config -state $s(1)
    .dlg.pe1 config -state $s(1)
    .dlg.sl1 config -state $s(2)
    .dlg.se1 config -state $s(2)
    foreach w {1 2 3} {
	.dlg.fl$w config -state $s(0)
	.dlg.fe$w config -state $s(0)
    }
}
##+##########################################################################
# 
# ValidForm -- if setup dialog has valid entries then kill the dialog
# 
proc ValidForm {} {
    global state SP ok
    set ok 0
    if {$state(proxy) eq "http"} {
	if {$SP(proxyPort) != ""} {set ok 1}
    } elseif {$SP(clntPort) !="" && $SP(servHost) !="" && $SP(servPort) !=""} {
	set ok 1
    }
    if {$ok} {destroy .dlg}
    return $ok
}
##+#########################################################################
#
# cmdlineUpdate
#
# cmdlineUpdate watches the connection variables and updates the command-line
# equivalent.
#
proc cmdlineUpdate {X elt X} {
    global SP

    # Check that port values are integers and that server host is not empty.
    switch -exact -- $::state(proxy) {
        "http" {
            set SP(cmdLine) "sockspy -proxy $SP(proxyPort)"
            if {! [string is integer -strict $SP(proxyPort)]} {
                set SP(cmdLine) "none (invalid proxy port above)"
            }
            return
        }
        "socks" {
            set SP(cmdLine) "sockspy -socks $SP(proxyPort)"
            if {! [string is integer -strict $SP(proxyPort)]} {
                set SP(cmdLine) "none (invalid socks port above)"
            }
            return
        }
    }
    
    if {$SP(servHost) == ""} {
	set SP(cmdLine) "none (invalid server host above)"
	return
    }
    foreach elt {clntPort servPort} lbl {"client port" "server port"} {
	if {! [string is integer -strict $SP($elt)]} {
	    set SP(cmdLine) "none (invalid $lbl above)"
	    return
	}
    }
    set SP(cmdLine) "sockspy $SP(clntPort) $SP(servHost) $SP(servPort)"
}
##+##########################################################################
# 
# Prompt -- Non-gui way to get input from the user.
# 
proc Prompt {prompt {default ""}} {
    if {$default != ""} {
	puts -nonewline "$prompt ($default): "
    } else {
	puts -nonewline "$prompt: "
    }
    flush stdout
    set n [gets stdin line]

    if {$n == 0 && $default != ""} {
	set line $default
    }
    return $line
}
##+##########################################################################
# 
# Shutdown -- Closes the listen port before exiting
# 
proc Shutdown {} {
    global state

    catch {close $state(listen)}
    stateSaveReal				;# save all state info NOW!
    exit
}
##+##########################################################################
# 
# ButtonBar -- Toggles the visibility of the button bar
# 
proc ButtonBar {} {
    global state

    if {$state(bbar)} {				;# Need to add button bar
	pack .cmd -side top -fill x -pady 5 -in .bbar
    } else {
	pack forget .cmd
	.bbar config -height 1			;# Need this to give remove gap
    }
}
##+##########################################################################
# 
# ToggleExtract -- Toggles the visibility of the extract window
# 
proc ToggleExtract {{how 0}} {
    global state

    if {$how == -1} {				;# Hard kill
	destroy .extract
	set state(extract) 0
	return
    }
    if {$state(extract)} {
	createExtract
    } else {
	catch {wm withdraw .extract}
    }
}
##+##########################################################################
# 
# ToggleWrap -- turns on or off wrap in the text window
# 
proc ToggleWrap {} {
    global state
    array set x {0 none 1 char}
    .out configure -wrap $x($state(autowrap))
}
##+##########################################################################
# 
# ToggleCapture -- puts up a help message
# 
proc ToggleCapture {} {
    global state
    if {$state(capture)} {
	INFO "Data capture display enabled" meta
	.out config -bg white
    } else {
	INFO "Data capture display disabled" meta 1
	.out config -bg grey88
    }
}
##+##########################################################################
# 
# Help -- a simple help system
# 
proc Help {} {
    variable NS
    set dlg .help
    destroy $dlg
    ttk_toplevel $dlg -class Dialog
    wm withdraw $dlg
    wm title $dlg "SockSpy Help"
    wm transient $dlg .
    tk::PlaceWindow $dlg widget .

    set txt [text $dlg.t -relief raised -wrap word -width 70 -height 25 \
                 -padx 10 -pady 10 -cursor {} -yscrollcommand [list $dlg.sb set]]
    ${NS}::scrollbar $dlg.sb -orient vertical -command [list $dlg.t yview]
    ${NS}::button $dlg.dismiss -text Dismiss -command [list destroy $dlg]
    pack $dlg.dismiss -side bottom -pady 10
    pack $dlg.sb -side right -fill y
    pack $dlg.t -side top -expand 1 -fill both

    set bold "[font actual [$txt cget -font]] -weight bold"
    set fixed "[font actual [$txt cget -font]] -family courier"
    $txt tag config title -justify center -foregr red -font "Times 20 bold"
    $txt tag configure title2 -justify center -font "Times 12 bold"
    $txt tag configure header -font $bold
    $txt tag configure n -lmargin1 15 -lmargin2 15
    $txt tag configure fixed -font $fixed -lmargin1 25 -lmargin2 55

    $txt insert end "SockSpy\n" title
    $txt insert end "Authors: Tom Poindexter and Keith Vetter\n\n" title2

    set m "SockSpy lets you watch the conversation of a tcp client and server. "
    append m "SockSpy acts much like a gateway: it waits for a tcp connection, "
    append m "then connects to the real server. Data from the client is passed "
    append m "on to the server, and data from the server is passed onto the "
    append m "client.\n\n"

    append m "Along the way, the data streams are also displayed in text "
    append m "widget with data sent from the client displayed in green, data "
    append m "from the server in blue and connection metadata in red. The data "
    append m "can be displayed as printable ASCII or both hex and "
    append m "printables.\n\n"
    $txt insert end "What is SockSpy?\n" header $m n

    set m "Why might you want to use SockSpy? Debugging tcp client/server "
    append m "programs, examining protocols and diagnosing network problems "
    append m "are top candidates. Perhaps you just want to figure out how "
    append m "something works. I've used it to bypass firewalls, to rediscover "
    append m "my lost smtp password, to access a news server on a remote "
    append m "network, etc.\n\nIt's not a replacement for heavy-duty tools "
    append m "such as 'tcpdump' and other passive packet sniffers. On the "
    append m "other hand, SockSpy doesn't require any special privileges to "
    append m "run (unless of course, you try to listen on a Unix reserved tcp "
    append m "port less than 1024.)\n\n"
    $txt insert end "Why Use SockSpy?\n" header $m n

    set m "Just double click on SockSpy to start it. You will be prompted for "
    append m "various connection parameters described below.\n\n"
    append m "Alternatively, you can specify the connection parameters on the "
    append m "command line. This is also how you can run SockSpy in text mode "
    append m "without a GUI.\n\n"
    append m "To start SockSpy from the command line:\n"
    $txt insert end "How to Use SockSpy\n" header $m n
    
    set m "$ sockspy <listen-port> <server-host> <server-port>\n  or\n"
    append m "$ sockspy -proxy <proxy-port>\n\n"
    $txt insert end $m fixed

    set m "To start SockSpy in text mode without a GUI:\n"
    $txt insert end $m n
    set m "$ tclsh sockspy <listen-port> <server-host> <server-port>\n	or\n"
    append m "$ tclsh sockspy -proxy <proxy-port>\n\n"
    $txt insert end $m fixed

    set m    "<listen-port>: the tcp port on which to listen. Clients should "
    append m "connect to this port.\n"
    append m "<server-host>:  the host where the real server runs.\n"
    append m "<server-port>:  the tcp port on which the real server listens.\n"
    append m "<proxy-port>:  the tcp port on which to listen in proxy-mode.\n\n"
    $txt insert end $m n

    set m "In proxy mode SockSpy works like a simple HTTP proxy server. "
    append m "Instead of forwarding to a fixed server and port, it follows the "
    append m "HTTP proxy protocol and reads the server information from the "
    append m "first line of HTTP request.\n\n"
    append m "You can turn on proxy mode by selecting it in the SockSpy Setup "
    append m "dialog, or by specifying -proxy on the command line.\n\n"
    $txt insert end "Proxy Mode\n" header $m n

    set m "The extract window lets you extract specific parts of the "
    append m "data stream. As data arrives from the client, server, or as "
    append m "metadata, it gets matched against the appropriate regular "
    append m "expression filter. If it matches, the data gets displayed "
    append m "in the extract window. (Malformed regular expression are "
    append m "silently ignored.)\n\n"
    $txt insert end "Extract Window\n" header $m n

    set m "To spy on HTTP connections to a server, type:\n"
    $txt insert end "Example\n" header $m n
    $txt insert end "  sockspy 8080 www.some.com 80\n" fixed
    $txt insert end "and point your browser to\n" n
    $txt insert end "  http://localhost:8080/index.html\n\n" fixed
    $txt insert end "Alternatively, you could configure your browser to " n
    $txt insert end "use localhost and port 8000 as its proxy, and then " n
    $txt insert end "type:\n" n
    $txt insert end "  sockspy -proxy 8000\n" fixed
    $txt insert end "and user your browser normally.\n" n
    $txt config -state disabled
    wm deiconify $dlg
}
##+##########################################################################
# 
# About -- simple about box
# 
proc About {} {
    set m "SockSpy version $::state(version)\n"
    append m "by Tom Poindexter and Keith Vetter\n"
    append m "Copyright 1998-[clock format [clock seconds] -format %Y]\n\n"
    append m "A program to eavesdrop on a tcp client server conversation."
    tk_messageBox -icon info -title "About SockSpy" -message $m -parent .
}
##+##########################################################################
# 
# DoExtract -- Displays any data matching the RE in the extract window
# 
proc DoExtract {who data timestamp} {
    global state extract

    if {! $state(gui)} return
    if {! [info exists extract($who)]} return
    if {! [winfo exists .extract]} return
    
    regsub -all \r $data "" data
    foreach line [split $data \n] {
	if {$extract($who) == ""} continue
	catch {
	    if {[regexp -nocase $extract($who) $line]} {
		.extract.out insert end "$timestamp" time_$who
		.extract.out insert end "$line\n" $who
	    }
	}
    }
    if {$state(autoscroll)} {
	.extract.out see end
    }
}
##+##########################################################################
# 
# stateRestore - Initialize save/restore package and do restore.
# 
proc stateRestore {} {
    global env state SP extract

    if {[useRegistry]} {
        if {[stateRestoreRegistry]} { return }
    }

    switch $::tcl_platform(platform) "macintosh" {
	set stateFile [file join $env(PREF_FOLDER) "SockSpy Preferences"]
    } "windows" {
	set stateFile [file join $env(HOME) "sockspy.cfg"]
    } "unix" {
	if {[info exists env(DOTDIR)]} {
	    set stateFile [file join $env(DOTDIR) .sockspy]
	} else {
	    set stateFile [file join $env(HOME) .sockspy]
	}
    }
    
    # complain only if it exists and we fail to read it successsfully
    if {[file exists $stateFile]} {
	uplevel #0 [list source $stateFile]
    }
    
    set state(stateFile) $stateFile
    if {$state(proxy) eq "0"} {set state(proxy) "none"}
    if {$state(proxy) eq "1"} {set state(proxy) "http"}
    
    foreach v $::saveList {
	trace variable $v w stateSave
    }
}

set regkey {HKEY_CURRENT_USER\SOFTWARE\sockspy.sourceforge.net}
proc stateRestoreRegistry {} {
    global env state SP extract regkey
    set r 0
    foreach name $::saveList {
        catch {
            uplevel #0 [list set $name [registry get $regkey $name]]
            trace variable $name w stateSave
            set r 1
        }
    }
    return $r
}

##+#########################################################################
#
# stateSave and stateSaveReal - Save program state.
#
# Two procs are used to do this.  stateSave is called to schedule the save.
# stateSaveReal is called to actually do the save.
#
# stateSave schedules the save a short time in the future to avoid interfering
# with the UI.	This is especially a problem with the "extract" variables which
# aren't edited from a modal dialogue and thus have no associated "OK" button
# to tell us when to save them.	 (The alternative would be to save them after
# every keystroke - yuk.)
#
proc stateSave {a b c} {
    catch {after cancel $::state(saveId)}
    set ::state(saveId) [after 5000 stateSaveReal]
}

proc stateSaveReal {} {
    global state SP extract

    if {[useRegistry]} {
        return [stateSaveRegistry]
    }

    # silently ignore open failure
    if {[catch {open $state(stateFile) w} sf]} return

    set now [clock format [clock seconds] -format %c]
    puts $sf "# SockSpy Initialization File"
    puts $sf "# Written by SockSpy $state(version) on $now."
    puts $sf "#"
    puts $sf "# Warning: If you edit this file while SockSpy is running, "
    puts $sf "# edits will be lost! Also, only edit the lines already here. "
    puts $sf "# If you add procs or more variables, they will not be saved."
    
    puts $sf ""
    foreach v $::saveList {
	puts $sf [list set $v [set $v]]
    }
    close $sf
}

proc stateSaveRegistry {} {
    global state SP extract regkey
    foreach name $::saveList {
        registry set $regkey $name [set $name] sz
    }
}

proc useRegistry {} {
    global tcl_platform
    set r 0
    if {$tcl_platform(platform) eq "windows"} {
        if {![catch {package require registry}]} {
            set r 1
        }
    }
    return $r
}

proc Pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

################################################################
################################################################
################################################################

set state(gui) [info exists tk_version]
if {[catch {package present uri}]} {
    ERROR "ERROR: SockSpy requires the uri package from tcllib."
    exit 1
}
    
timestampInit
stateRestore

set showconfig 1
while {[string match -* [set option [lindex $argv 0]]]} {
    switch -exact -- $option {
        -local {
            set state(proxy) none
            set clntPort 8080
            set servHost localhost
            set servPort 80
            set showconfig 0
        }
        -proxy {
            set state(proxy) http
            if {[llength $argv] > 1 && ![string match -* [lindex $argv 1]]} {
                set SP(proxyPort) [Pop argv 1]
                set showconfig 0
            }
        }
        -socks {
            set state(proxy) socks
            if {[llength $argv] > 1 && ![string match -* [lindex $argv 1]]} {
                set SP(proxyPort) [Pop argv 1]
                set showconfig 0
            }
        }
        -myaddr {
            set state(myaddr) [Pop argv 1]
        }
        -timeformat {
            set state(timeFormat) [Pop argv 1]
        }
        -hex { set state(ascii) 0 }
        -ascii { set state(ascii) 1 }
        default {
            return -code error "invalid option \"$option\": must be\
                -local, -proxy, -socks or -myaddr"
        }
    }
    Pop argv
}

# If there are more args, it's for forwarding
if {[llength $argv] > 0} {
    foreach {SP(clntPort) sh sp} $argv break
    set state(proxy) none
    if {$sh ne ""} {set SP(servHost) $sh}
    if {$sp ne ""} {set SP(servPort) $sp ; set showconfig 0}
}

if {$state(gui)} { createMain }

if {$showconfig} {
    GetSetup
} else {
    DoListen
}

if {$state(extract)} createExtract

if {! $state(gui)} {
    vwait forever				;# tclsh needs this
} else {
    wm deiconify .
}
