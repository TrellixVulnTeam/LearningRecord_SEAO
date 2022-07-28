# Test event handling functionality of Internet Explorer.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require Tk
package require cawt

set twapiVersion [Cawt GetPkgVersion "twapi"]

set appId [Explorer Open]
set appVersion "Explorer"

proc ToggleLogging { appId } {
    global gLog

    if { $gLog } {
        Cawt SetEventCallback $appId PrintEvent
    } else {
        Cawt SetEventCallback $appId ""
    }
}

proc Quit { appId } {
    Explorer Quit $appId
    Cawt Destroy
    exit 0
}

proc PrintEvent { args } {
    .bot.log insert end "$args\n"
    .bot.log see end
}

set gLog 1
ToggleLogging $appId

ttk::frame .top
ttk::frame .bot
grid .top -row 0 -column 0 -sticky ew
grid .bot -row 1 -column 0 -sticky news

ttk::checkbutton .top.tog -text "Enable logging" -variable gLog \
                 -command "ToggleLogging $appId"
ttk::label .top.inf -text "Logging events of $appVersion using Twapi $twapiVersion"
pack .top.tog .top.inf -side left -padx 10

text .bot.log -height 20 -width 70
pack .bot.log -fill both

bind . <Escape> "Quit $appId"
wm protocol . WM_DELETE_WINDOW "Quit $appId"

if { [lindex $argv 0] eq "auto" } {
    Explorer Quit $appId
    Cawt Destroy
    exit 0
}


