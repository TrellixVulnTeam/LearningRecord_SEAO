# Test event handling functionality of Excel.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}

package require Tk
package require cawt

set twapiVersion [Cawt GetPkgVersion "twapi"]

set appId      [Excel OpenNew]
set appVersion [Excel GetVersion $appId true]

proc ToggleLogging { appId } {
    global gLog

    if { $gLog } {
        Cawt SetEventCallback $appId PrintEvent
    } else {
        Cawt SetEventCallback $appId ""
    }
}

proc Quit { appId } {
    # Excel application may have been closed. 
    # Check, if appId refers to a valid COM object.
    if { [Cawt IsAppIdValid $appId] } {
        Excel Quit $appId
        Cawt Destroy
    }
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
    Excel Quit $appId
    Cawt Destroy
    exit 0
}
