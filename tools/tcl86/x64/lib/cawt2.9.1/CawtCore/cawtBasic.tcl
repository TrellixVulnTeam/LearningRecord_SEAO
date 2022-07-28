# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Cawt {

    namespace ensemble create

    namespace export CentiMetersToPoints
    namespace export Destroy
    namespace export GetComObjects
    namespace export GetDotsPerInch
    namespace export GetNumComObjects
    namespace export GetOrCreateApp
    namespace export GetPkgVersion
    namespace export HavePkg
    namespace export InchesToPoints
    namespace export IsComObject
    namespace export IsAppIdValid
    namespace export IsValidUrlAddress
    namespace export IsValidId
    namespace export KillApp
    namespace export PointsToCentiMeters
    namespace export PointsToInches
    namespace export PopComObjects
    namespace export PrintNumComObjects
    namespace export PushComObjects
    namespace export SetDotsPerInch
    namespace export SetEventCallback
    namespace export TclBool
    namespace export TclInt
    namespace export TclString
    namespace export ValueToPoints
    namespace export GetProgramByExtension

    variable pkgInfo
    variable dotsPerInch
    variable httpInitialized

    variable _CawtIntro {
        # CAWT - COM Automation With Tcl

        `CAWT` is a high-level Tcl interface for scripting Microsoft Windows®
        applications having a COM interface. It uses [Twapi](https://twapi.magicsplat.com/)
        for automation via the COM interface.

        Currently packages for Microsoft Excel, Word, PowerPoint, OneNote,
        Outlook, Speech API, Internet Explorer, MathWorks Matlab, Adobe Acrobat Reader
        and Google Earth are available.

        **Note:** Only Microsoft Office packages Excel, Word and PowerPoint are
        in active development. The other packages are proof-of-concept
        examples only.

        Important links:
        * [CAWT homepage](http://www.cawt.tcl3d.org/)
        * [CAWT sources](https://sourceforge.net/projects/cawt/)
        * [CAWT manual (PDF)](http://www.cawt.tcl3d.org/download/CawtManual.pdf)
    }
    
    variable _ruff_preamble {
        The `Cawt` namespace provides commands for basic automation
        functionality.
    }

    proc _Init {} {
        variable pkgInfo
        variable dotsPerInch
        variable httpInitialized

        set dotsPerInch 72
        set httpInitialized false

        set retVal [catch {package require twapi 4} version]
        set pkgInfo(twapi,avail)   [expr !$retVal]
        set pkgInfo(twapi,version) $version

        set retVal [catch {package require tdom} version]
        set pkgInfo(tdom,avail)   [expr !$retVal]
        set pkgInfo(tdom,version) $version

        set retVal [catch {package require cawtcore} version]
        set pkgInfo(cawtcore,avail)   [expr !$retVal]
        set pkgInfo(cawtcore,version) $version

        set retVal [catch {package require cawtoffice} version]
        set pkgInfo(cawtoffice,avail)   [expr !$retVal]
        set pkgInfo(cawtoffice,version) $version

        set retVal [catch {package require cawtearth} version]
        set pkgInfo(cawtearth,avail)   [expr !$retVal]
        set pkgInfo(cawtearth,version) $version

        set retVal [catch {package require cawtexcel} version]
        set pkgInfo(cawtexcel,avail)   [expr !$retVal]
        set pkgInfo(cawtexcel,version) $version

        set retVal [catch {package require cawtexplorer} version]
        set pkgInfo(cawtexplorer,avail)   [expr !$retVal]
        set pkgInfo(cawtexplorer,version) $version

        set retVal [catch {package require cawtmatlab} version]
        set pkgInfo(cawtmatlab,avail)   [expr !$retVal]
        set pkgInfo(cawtmatlab,version) $version

        set retVal [catch {package require cawtocr} version]
        set pkgInfo(cawtocr,avail)   [expr !$retVal]
        set pkgInfo(cawtocr,version) $version

        set retVal [catch {package require cawtonenote} version]
        set pkgInfo(cawtonenote,avail)   [expr !$retVal]
        set pkgInfo(cawtonenote,version) $version

        set retVal [catch {package require cawtoutlook} version]
        set pkgInfo(cawtoutlook,avail)   [expr !$retVal]
        set pkgInfo(cawtoutlook,version) $version

        set retVal [catch {package require cawtppt} version]
        set pkgInfo(cawtppt,avail)   [expr !$retVal]
        set pkgInfo(cawtppt,version) $version

        set retVal [catch {package require cawtreader} version]
        set pkgInfo(cawtreader,avail)   [expr !$retVal]
        set pkgInfo(cawtreader,version) $version

        set retVal [catch {package require cawtword} version]
        set pkgInfo(cawtword,avail)   [expr !$retVal]
        set pkgInfo(cawtword,version) $version

        set retVal [catch {twapi::tclcast bstr "0.0"} val]
        set pkgInfo(haveStringCast) [expr !$retVal]
    }

    proc HavePkg { pkgName } {
        # Check, if a CAWT sub-package is available.
        #
        # pkgName - The name of the sub-package.
        #
        # Returns true, if sub-package pkgName was loaded successfully.
        # Otherwise returns false.
        #
        # See also: GetPkgVersion

        variable pkgInfo

        if { [info exists pkgInfo($pkgName,avail)] } {
            return $pkgInfo($pkgName,avail)
        }
        return 0
    }

    proc GetPkgVersion { pkgName } {
        # Get the version of a CAWT sub-package.
        #
        # pkgName - The name of the sub-package
        #
        # Returns the version of the CAWT sub-package as a string.
        # If the package is not available, an empty string is returned.
        #
        # See also: HavePkg

        variable pkgInfo

        set retVal ""
        if { [HavePkg $pkgName] } {
            set retVal $pkgInfo($pkgName,version)
        }
        return $retVal
    }

    proc SetDotsPerInch { dpi } {
        # Set the dots-per-inch value used for conversions.
        #
        # dpi - Integer dpi value.
        #
        # If the dpi value is not explicitely set with this procedure,
        # it's default value is 72.
        #
        # Returns no value.
        #
        # See also: GetDotsPerInch

        variable dotsPerInch

        set dotsPerInch $dpi
    }

    proc GetDotsPerInch {} {
        # Get the dots-per-inch value used for conversions.
        #
        # Returns the dots-per-inch value used for conversions.
        #
        # See also: SetDotsPerInch

        variable dotsPerInch

        return $dotsPerInch
    }

    proc InchesToPoints { inches } {
        # Convert inch value into points.
        #
        # inches - Floating point inch value to be converted to points.
        #
        # Returns the corresponding value in points.
        #
        # See also: SetDotsPerInch CentiMetersToPoints PointsToInches

        variable dotsPerInch

        return [expr {$inches * double($dotsPerInch)}]
    }

    proc PointsToInches { points } {
        # Convert value in points into inches.
        #
        # points - Floating point value to be converted to inches.
        #
        # Returns the corresponding value in inches.
        #
        # See also: SetDotsPerInch CentiMetersToPoints InchesToPoints

        variable dotsPerInch

        return [expr {$points / double($dotsPerInch)}]
    }

    proc CentiMetersToPoints { cm } {
        # Convert centimeter value into points.
        #
        # cm - Floating point centimeter value to be converted to points.
        #
        # Returns the corresponding value in points.
        #
        # See also: SetDotsPerInch InchesToPoints PointsToCentiMeters

        variable dotsPerInch

        return [expr {$cm / 2.54 * double($dotsPerInch)}]
    }

    proc PointsToCentiMeters { points } {
        # Convert value in points into centimeters.
        #
        # points - Floating point value to be converted to centimeters.
        #
        # Returns the corresponding value in centimeters.
        #
        # See also: SetDotsPerInch InchesToPoints CentiMetersToPoints

        variable dotsPerInch

        return [expr {$points * 2.54 / double($dotsPerInch)}]
    }

    proc ValueToPoints { value } {
        # Convert a value into points.
        #
        # value - Floating point value to be converted to points.
        #
        # * If the value is followed by `i`, it is interpreted as inches.
        # * If the value is followed by `c`, it is interpreted as centimeters.
        # * If the value is a simple floating point number or followed by `p`,
        #   it is interpreted as points, i.e. the pure value is returned.
        #
        # Example:
        #      ValueToPoints 2c
        #      ValueToPoints 1.5i
        #
        # Returns the corresponding value in points.
        #
        # See also: CentiMetersToPoints InchesToPoints

        if { [string index $value end] eq "c" } {
            return [Cawt::CentiMetersToPoints [string range $value 0 end-1]]
        } elseif { [string index $value end] eq "i" } {
            return [Cawt::InchesToPoints [string range $value 0 end-1]]
        } elseif { [string index $value end] eq "p" } {
            return [string range $value 0 end-1]
        } elseif { [string is double $value] } {
            return $value
        } else {
            error "Invalid value \"$value\" specified."
        }
    }

    proc TclInt { val } {
        # Cast a value to an integer with boolean range.
        #
        # val - The value to be casted.
        #
        # Returns 1, if $val is not equal to zero or true.
        # Otherwise returns 0.
        #
        # See also: TclBool TclString

        set tmp 0
        if { $val } {
            set tmp 1
        }
        return $tmp
    }

    proc TclBool { val } {
        # Cast a value to a boolean.
        #
        # val - The value to be casted.
        #
        # Returns true, if $val is not equal to zero or true.
        # Otherwise returns false.
        #
        # See also: TclInt TclString

        return [twapi::tclcast boolean $val]
    }

    proc TclString { val } {
        # Cast a value to a string.
        #
        # val - The value to be casted.
        #
        # Returns casted string in a format usable for the COM interface.
        #
        # See also: TclInt TclBool

        variable pkgInfo

        if { $pkgInfo(haveStringCast) } {
            return [twapi::tclcast bstr $val]
        } else {
            return [twapi::tclcast string $val]
        }
    }

    proc GetOrCreateApp { appName useExistingFirst } {
        # Use or create an instance of an application.
        #
        # appName          - The name of the application to be created or used.
        # useExistingFirst - Prefer an already running application.
        #
        # Application names supported and tested with CAWT are:
        #   * `Excel.Application`
        #   * `GoogleEarth.ApplicationGE`
        #   * `InternetExplorer.Application`
        #   * `Matlab.Application`
        #   * `MODI.Document`
        #   * `Outlook.Application`
        #   * `PowerPoint.Application`
        #   * `Word.Application`
        #
        # **Note:**
        #   * There are higher level functions `Open` and `OpenNew` for the
        #     CAWT sub-packages.
        #
        # If $useExistingFirst is set to true, it is checked, if an application
        # instance is already running. If true, this instance is used.
        # If no running application is available, a new instance is started.
        #
        # Returns the application identifier.
        #
        # See also: KillApp

        set foundApp false
        if { ! [HavePkg "twapi"] } {
            error "Cannot use $appName. No Twapi extension available."
        }
        if { $useExistingFirst } {
            set retVal [catch {twapi::comobj $appName -active} appId]
            if { $retVal == 0 } {
                set foundApp true
            }
        }
        if { $foundApp == false } {
            set retVal [catch {twapi::comobj $appName} appId]
        }
        if { $foundApp == true || $retVal == 0 } {
            return $appId
        }
        error "Cannot get or create $appName object."
    }

    proc KillApp { progName } {
        # Kill all running instances of an application.
        #
        # progName - The application's program name, as shown in the task manager.
        #
        # Returns no value.
        #
        # See also: GetOrCreateApp

        set pids [concat [twapi::get_process_ids -name $progName] \
                         [twapi::get_process_ids -path $progName]]
        foreach pid $pids {
            # Catch the error in case process does not exist any more
            catch {twapi::end_process $pid -force}
        }
    }

    proc IsValidId { comObj } {
        # Obsolete: Replaced with [IsComObject] in version 2.0.0

        return [IsComObject $comObj]
    }

    proc IsComObject { comObj } {
        # Check, if parameter is a COM object.
        #
        # comObj - The COM object.
        #
        # Returns true, if $comObj is a COM object.
        # Otherwise returns false.
        #
        # See also: IsAppIdValid GetComObjects GetNumComObjects

        return [expr { [twapi::comobj? $comObj] && ! [$comObj -isnull] } ]
    }

    proc IsAppIdValid { appId } {
        # Check, if an application identifier is valid.
        #
        # appId - The application identifier.
        #
        # Returns true, if $appId is valid.
        # Otherwise returns false.
        #
        # See also: IsComObject GetComObjects GetNumComObjects

        set catchVal [catch { $appId -default }]
        if { $catchVal != 0 } {
            return false
        }
        return true
    }

    proc GetComObjects {} {
        # Get the COM objects currently in use as a list.
        #
        # Returns the COM objects currently in use as a list.
        #
        # See also: IsComObject GetNumComObjects PrintNumComObjects Destroy

        return [twapi::comobj_instances]
    }

    proc GetNumComObjects {} {
        # Get the number of COM objects currently in use.
        #
        # Returns the number of COM objects currently in use.
        #
        # See also: IsComObject GetComObjects PrintNumComObjects Destroy

        return [llength [Cawt::GetComObjects]]
    }

    proc PrintNumComObjects {} {
        # Print the number of currently available COM objects to stdout.
        #
        # Returns no value.
        #
        # See also: IsComObject GetComObjects GetNumComObjects Destroy

        puts "Number of COM objects: [Cawt::GetNumComObjects]"
    }

    proc _PrintComObjStack { msg } {
        variable comObjStack

        puts "$msg :"
        set num 1
        foreach entry $comObjStack {
            puts "$num: $entry"
            incr num
        }
    }

    proc PushComObjects { { printStack false } } {
        # Push current list of COM objects onto a stack.
        #
        # printStack - Print stack content after pushing onto stdout.
        #
        # Returns no value.
        #
        # See also: PopComObjects

        variable comObjStack

        lappend comObjStack [lsort -dictionary [Cawt::GetComObjects]]

        if { $printStack } {
            Cawt::_PrintComObjStack "PushComObjects"
        }
    }

    proc PopComObjects { { printStack false } } {
        # Pop last entry from COM objects stack.
        #
        # printStack - Print stack content after popping onto stdout.
        #
        # Pop last entry from COM objects stack and
        # remove all COM objects currently in use which
        # are not contained in the popped entry.
        #
        # Returns no value.
        #
        # See also: PushComObjects

        variable comObjStack

        set lastEntry [lindex $comObjStack end]
        set comObjStack [lrange $comObjStack 0 end-1]
        foreach comObj [lsort -dictionary [Cawt::GetComObjects]] {
            if { [lsearch -exact $lastEntry $comObj] < 0 } {
                Cawt Destroy $comObj
            }
        }
        if { $printStack } {
            Cawt::_PrintComObjStack "PopComObjects"
        }
    }

    proc Destroy { { comObj "" } } {
        # Destroy one or all COM objects.
        #
        # comObj - The COM object to be destroyed.
        #
        # If $comObj is an empty string, all existing COM objects are destroyed.
        # Otherwise only the specified COM object is destroyed.
        #
        # **Note:** 
        #   * Twapi does not clean up generated COM object identifiers, so you
        #     have to put a call to Destroy at the end of your CAWT script.
        #     For further details about COM objects and their lifetime see the Twapi
        #     documentation.
        #
        # Returns no value.
        #
        # See also: PushComObjects PopComObjects

        if { $comObj ne "" } {
            $comObj -destroy
        } else {
            foreach obj [Cawt::GetComObjects] {
                $obj -destroy
            }
        }
    }

    proc GetProgramByExtension { extension } {
        # Get path to program for a given file extension.
        #
        # extension - The extension string (including a dot, ex. `.pdf`).
        #
        # Returns the path to the program which is associated in the Windows registry
        # with the file extension.

        set retVal [catch { package require registry } version]
        if { $retVal != 0 } {
            return ""
        }
        # Read the type name.
        set type [registry get HKEY_CLASSES_ROOT\\$extension {}]
        # Work out where to look for the program.
        set path "HKEY_CLASSES_ROOT\\$type\\Shell\\Open\\command"
        # Read the program name.
        set prog [registry get $path {}]

        set lastSpaceIndex [expr {[string last " " $prog] - 1}]
        set progName [string trim [string range $prog 0 $lastSpaceIndex] "\""]
        if { [file executable $progName] } {
            return $progName
        }
        return ""
    }

    proc SetEventCallback { appId callback } {
        # Set an event callback procedure.
        #
        # appId    - The application identifier.
        # callback - The event callback procedure.
        #
        # If $callback is the empty string, an existing event
        # callback is disabled.
        #
        # The $callback procedure must have an `args` argument
        # as shown in the following example:
        #     proc PrintEvent { args } {
        #         puts $args
        #     }
        #
        #     set appId [Excel Open]
        #     Cawt SetEventCallback $appId PrintEvent
        #
        # Returns no value.

        variable sBindId

        if { [info exists sBindId] } {
            $appId -unbind $sBindId
        }
        if { $callback ne "" } {
            set sBindId [$appId -bind $callback]
        }
    }

    proc IsValidUrlAddress { address } {
        # Check, if supplied address is a valid URL.
        #
        # address - The URL address.
        #
        # Returns true, if $address is a valid URL.
        # Otherwise returns false.
        #
        # See also: ::Word::GetHyperlinksAsDict

        variable httpInitialized

        # Internal note: The algorithm used in this procedure is
        # also used in a slightly modified way using caching in
        # CawtWord::GetHyperlinksAsDict.

        if { ! $httpInitialized } {
            package require http
            # Needed to check http and https links.
            http::register https 443 [list ::twapi::tls_socket]
            set httpInitialized true
        }

        lassign [split $address "#"] address subAddress
        if { $subAddress eq "" } {
            set catchVal [catch { \
                http::geturl $address -validate true -strict false } token]
        } else {
            set catchVal [catch { http::geturl $address } token]
            if { $catchVal == 0 } {
                set htmlData [http::data $token]
                # Search for <a name="subAddress"> occurences.
                set exp {<[\s]*a[\s]+name=([^\s>]+)[\s]*>}
                set matchList [regexp -all -inline -nocase -- $exp $htmlData]
                set catchVal 1
                foreach { overall match } $matchList {
                    set matchStr [string trim $match "\"\'"]
                    if { $matchStr eq $subAddress } {
                        set catchVal 0
                        break
                    }
                }
            }
        }
        set valid false
        if { $catchVal == 0 } {
            if { [http::ncode $token] < 400 } {
                set valid true
            }
        }
        http::cleanup $token
        return $valid
    }
}

Cawt::_Init
