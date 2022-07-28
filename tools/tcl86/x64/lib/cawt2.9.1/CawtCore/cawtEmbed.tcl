# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Cawt {

    namespace ensemble create

    namespace export EmbedApp
    namespace export SetEmbedTimeout

    proc _ResizeEmbeddedWindow { appId embedFrame windowId width height } {
      if { $appId eq "" || [Cawt IsAppIdValid $appId] } {
            twapi::resize_window $windowId $width $height
            twapi::move_window $windowId 0 0
        } else {
            bind $embedFrame <Configure> [list]
        }
    }

    proc SetEmbedTimeout { timeout } {
        # Set the timeout to wait for the embedded application to start.
        #
        # timeout - Timeout in seconds.
        #
        # Returns no value.
        #
        # See also: EmbedApp

        variable sTimeout

        set sTimeout $timeout
        if { $sTimeout <= 0.0 } {
            set sTimeout 1.0
        }
    }

    proc EmbedApp { embedFrame args } {
        # Embed an application into a Tk frame.
        #
        # embedFrame - Tk frame.
        # args       - Options described below.
        #
        # -filename <string> - Embed the application based on specified opened file.
        # -window <string>   - Embed the application based on a window identifier.
        #                      The window identifier must be a list as returned by
        #                      twapi::find_windows: { $windowHandle HWND }
        # -appid             - Identifier of the application instance.
        #                      Must be specified, if the application has been started
        #                      via the COM interface.
        # -timeout <float>   - Timeout in seconds to wait for the application to start.
        #                      Applicable only when using `-filename`. 
        #                      Default: 1 second.
        #
        # Returns no value.
        #
        # See also: SetEmbedTimeout ::Ppt::OpenPres ::Word::OpenDocument ::Excel::OpenWorkbook

        variable sTimeout

        set opts [dict create \
            -appid    ""  \
            -filename ""  \
            -window   ""  \
            -timeout  -1.0 \
        ]


        set catchVal [catch {info level -1}]
        if { $catchVal } {
            set callerName "Main"
        } else {
            set callerProc [lindex [info level -1] 0]
            set callerName [lindex [split $callerProc "::"] end]
        }

        foreach { key value } $args {
            if { [dict exists $opts $key] } {
                if { $value eq "" } {
                    error "$callerName: No value specified for key \"$key\"."
                }
                dict set opts $key $value
            } else {
                error "$callerName: Unknown option \"$key\" specified."
            }
        }

        set appId    [dict get $opts "-appid"]
        set fileName [dict get $opts "-filename"]
        set windowId [dict get $opts "-window"]
        set timeout  [dict get $opts "-timeout"]

        if { $timeout < 0.0 && [info exists sTimeout] } {
            # Global timeout has been set via SetEmbedTimeout.
            set timeout $sTimeout
        }
        if { $timeout < 0.0 } {
            # Neither SetEmbedTimeout nor -timeout has been specified.
            # Use default value.
            set timeout 1.0
        }
        set numTrys [expr { int ($timeout * 10.0) }]
        if { $numTrys < 1 } {
            set numTrys 1
        }

        if { $fileName eq "" && $windowId eq "" } {
            error "$callerName: Neither \"-filename\" nor \"-window\" option specified."
        }

        if { ! [winfo exists $embedFrame] } {
            error "$callerName: Frame \"$embedFrame\" does not exists."
        }
        if { [winfo class $embedFrame] ne "Frame" } {
            error "$callerName: \"$embedFrame\" is not a frame."
        }
        if { ! [$embedFrame cget -container] } {
            error "$callerName: Frame \"$embedFrame\" is not a container frame."
        }

        if { $fileName ne "" } {
            set shortName [file tail $fileName]
            for { set curTry 0 } { $curTry < $numTrys } { incr curTry } {
                set hndlList [twapi::find_windows -text "*${shortName}*" -match glob]
                if { [llength $hndlList] > 0 } {
                    break
                }
                after 100
            }
            if { [llength $hndlList] == 0 } {
                error "$callerName: Cannot embed application with file \"$shortName\"."
            }
            set windowId [lindex $hndlList 0]
        }
        set frameHndl [twapi::tkpath_to_hwnd $embedFrame]
        twapi::SetParent $windowId $frameHndl
        bind $embedFrame <Configure> \
             [list Cawt::_ResizeEmbeddedWindow $appId $embedFrame $windowId %w %h]
    }
}
