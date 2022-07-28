# Copyright: 2011-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Matlab {

    namespace ensemble create

    namespace export ExecCmd
    namespace export Open
    namespace export OpenNew
    namespace export Quit
    namespace export Visible

    variable matlabAppName "Matlab.Application"

    variable _ruff_preamble {
        The `Matlab` namespace provides commands to control MathWorks Matlab.
    }

    proc OpenNew { { visible true } } {
        # Open a new Matlab instance.
        #
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        #
        # Returns the identifier of the new Matlab application instance.
        #
        # See also: Open Visible Quit

        variable matlabAppName

        set appId [Cawt GetOrCreateApp $matlabAppName false]
        Matlab Visible $appId $visible
        return $appId
    }

    proc Open { { visible true } } {
        # Open a Matlab instance. 
        #
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        #
        # Use an already running instance, if available.
        #
        # Returns the identifier of the Matlab application instance.
        #
        # See also: OpenNew Visible Quit

        variable matlabAppName

        set appId [Cawt GetOrCreateApp $matlabAppName true]
        Matlab Visible $appId $visible
        return $appId
    }

    proc Visible { appId visible } {
        # Toggle the visibility of a Matlab application window.
        #
        # appId   - Identifier of the Matlab instance.
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        #
        # Returns no value.
        #
        # See also: Open OpenNew

        $appId Visible [Cawt TclInt $visible]
    }

    proc Quit { appId } {
        # Quit a Matlab instance.
        #
        # appId - Identifier of the Matlab instance.
        #
        # Returns no value.
        #
        # See also: Open

        $appId Quit
    }

    proc ExecCmd { appId cmd } {
        # Execute a Matlab command.
        #
        # appId - Identifier of the Matlab instance.
        # cmd   - String containing the Matlab command being executed.
        #
        # Returns the Matlab answer as a string.

        set retVal [$appId Execute $cmd]
        return $retVal
    }
}
