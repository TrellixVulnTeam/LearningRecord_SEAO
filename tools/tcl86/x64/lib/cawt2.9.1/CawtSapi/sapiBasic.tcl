# Copyright: 2020-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Sapi {

    namespace ensemble create
    
    namespace export GetSpeakOptions
    namespace export GetVoiceByName
    namespace export GetVoiceNames
    namespace export Open
    namespace export SetSpeakOptions
    namespace export SetVoice
    namespace export Speak

    variable sapiAppName "sapi.SpVoice"

    variable _ruff_preamble {
        The `Sapi` namespace provides commands to control the Microsoft Speech API (SAPI).

        [Microsoft SAPI documentation]
        (https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ms723602(v=vs.85))
    }

    proc Open {} {
        # Open a SAPI object instance.
        #
        # Returns the SAPI object identifier.
        #
        # See also: Speak SetSpeakOptions GetVoiceNames

	variable sapiAppName

        set appId [Cawt GetOrCreateApp $sapiAppName true]
        return $appId
    }

    proc GetSpeakOptions { appId args } {
        # Get speak options.
        #
        # appId - Identifier of the SAPI instance.
        # args  - Options described below.
        #
        # -rate   - Get the speaking rate of the voice.
        #           Values range from -10 (slowest) to 10 (fastest).
        # -volume - Set the volume (loudiness) of the voice.
        #           Values range from 0 to 100.
        #
        # Example:
        #     lassign [GetSpeakOptions $appId -rate -volume] rate volume
        #
        # Returns the specified options as a list.
        #
        # See also: Open Speak SetSpeakOptions

        set valList [list]
        foreach key $args {
            switch -exact -nocase -- $key {
                "-rate"   { lappend valList [$appId Rate] }
                "-volume" { lappend valList [$appId Volume] }
                default   { error "GetSpeakOptions: Unknown key \"$key\" specified" }
            }
        }
        return $valList
    }

    proc SetSpeakOptions { appId args } {
        # Set speak options.
        #
        # appId - Identifier of the SAPI instance.
        # args  - Options described below.
        #
        # -rate <int>   - Set the speaking rate of the voice.
        #                 Values range from -10 (slowest) to 10 (fastest).
        # -volume <int> - Set the volume (loudiness) of the voice.
        #                 Values range from 0 to 100.
        #
        # Returns no value.
        #
        # See also: Open Speak GetSpeakOptions

        foreach { key value } $args {
            if { $value eq "" } {
                error "SetSpeakOptions: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-rate"   { $appId Rate   [expr int( $value)] }
                "-volume" { $appId Volume [expr int( $value)] }
                default   { error "SetSpeakOptions: Unknown key \"$key\" specified" }
            }
        }
    }

    proc Speak { appId str args } {
        # Speak a sentence.
        #
        # appId - Identifier of the SAPI instance.
        # str   - String to be spoken.
        # args  - Options described below.
        #
        # -flags <int> - Bitflag of enumerations of type [Enum::SpeechVoiceSpeakFlags]
        #
        # Returns no value.
        #
        # See also: Open SetSpeakOptions GetVoiceNames

        set flags $Sapi::SVSFDefault
        foreach { key value } $args {
            if { $value eq "" } {
                error "Speak: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-flags" { set flags $value }
                default  { error "Speak: Unknown key \"$key\" specified" }
            }
        }
        $appId Speak $str [expr int($flags)]
    }

    proc SetVoice { appId voiceId } {
        # Set the voice for speaking.
        #
        # appId   - Identifier of the SAPI instance.
        # voiceId - Identifier of the voice.
        #
        # Returns no value.
        #
        # See also: Open SetSpeakOptions GetVoiceByName

        # Workaround from Ashok to directly invoke the Voice 
        # property method as a propertyputref (type 8).
        $appId -invoke Voice [list 8] [list $voiceId]
    }

    proc GetVoiceNames { appId } {
        # Get a list of voice names.
        #
        # appId - Identifier of the SAPI instance.
        #
        # Returns the list of voice names.
        #
        # See also: Open Speak GetVoiceByName SetVoice

        set voicesList [list]
        set voices [$appId GetVoices]
        set numVoices [$voices Count]
        for { set v 0 } { $v < $numVoices } { incr v } {
            set voice [$voices Item $v]
            lappend voicesList [$voice GetDescription]
            Cawt Destroy $voice
        }
        Cawt Destroy $voices
        return $voicesList
    }

    proc GetVoiceByName { appId voiceName } {
        # Get a voice identifier by specifying its name.
        #
        # appId     - Identifier of the SAPI instance.
        # voiceName - Name of the voice.
        #
        # Returns the voice identifier.
        #
        # See also: Open Speak GetVoiceNames SetVoice

        set voices [$appId GetVoices]
        set numVoices [$voices Count]
        for { set v 0 } { $v < $numVoices } { incr v } {
            set voice [$voices Item $v]
            if { [$voice GetDescription] eq $voiceName } {
                Cawt Destroy $voices
                return $voice
            }
            Cawt Destroy $voice
        }
        error "Voice \"$voiceName\" not available."
    }
}
