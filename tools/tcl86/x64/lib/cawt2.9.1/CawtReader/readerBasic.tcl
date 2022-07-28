# Copyright: 2017-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Reader {

    namespace ensemble create

    namespace export Open
    namespace export OpenNew
    namespace export Quit
    namespace export SetReaderProg

    variable readerProgName ""

    variable _ruff_preamble {
        The `Reader` namespace provides commands to control Acrobat Reader.
    }

    proc _Init {} {
        variable readerProgName

        if { $readerProgName ne "" } {
            return
        }

        set readerProg ""

        # First, try to get path to Acrobat Reader from Windows registry.
        set readerProg [Cawt GetProgramByExtension ".pdf"]

        if { $readerProg eq "" } {
            set retVal [catch { package require registry } version]
            if { $retVal == 0 } {
                set keys [list \
                    {HKEY_LOCAL_MACHINE\\SOFTWARE\\Classes\\SOFTWARE\\Abobe\\Acrobat} \
                    {HKEY_CLASSES_ROOT\\Software\\Abobe\\Acrobat}]

                foreach key $keys {
                    if { ! [catch "registry get \"$key\" Exe" result] } {
                        if { [file executable $result] } {
                            set readerProg [file normalize $result]
                            break
                        }
                    }
                }
            }
        }

        # If reading from registry did not work, try some standard installation pathes.
        if { $readerProg eq "" } {
            set acroProgs [list \
                    "C:/Program Files/Adobe/Acrobat Reader DC/Reader/AcroRd32.exe" \
                    "C:/Program Files (x86)/Adobe/Acrobat Reader DC/Reader/AcroRd32.exe" \
                    "C:/Program Files/Adobe/Reader 11.0/Reader/AcroRd32.exe" \
                    "C:/Program Files/Adobe/Reader 10.0/Reader/AcroRd32.exe"]
            foreach acroProg $acroProgs {
                if { [file executable $acroProg] } {
                    set readerProg $acroProg
                    break
                }
            }
        }

        if { $readerProg eq "" } {
            error "CawtReader: Cannot find Acrobat Reader"
        }
        set readerProgName $readerProg
    }

    proc _Start { fileName useNewInstance args } {
        variable readerProgName

        set embedFrame ""
        set readerOpts ""
        if { $useNewInstance } {
            append readerOpts "/n "
        }
        if { [llength $args] > 0 } {
            append readerOpts "/A \""

            foreach { key value } $args {
                if { $value eq "" } {
                    error "CawtReader: No value specified for key \"$key\""
                }
                switch -exact -nocase -- $key {
                    "-nameddest" { append readerOpts "namedest=$value"  }
                    "-page"      { append readerOpts "page=$value" }
                    "-zoom"      { append readerOpts "zoom=$value" }
                    "-pagemode"  { append readerOpts "pagemode=$value"}
                    "-search"    { append readerOpts "search=$value"}
                    "-scrollbar" { append readerOpts "scrollbar=[Cawt TclInt $value]" }
                    "-toolbar"   { append readerOpts "toolbar=[Cawt TclInt $value]" }
                    "-statusbar" { append readerOpts "statusbar=[Cawt TclInt $value]" }
                    "-messages"  { append readerOpts "messages=[Cawt TclInt $value]" }
                    "-navpanes"  { append readerOpts "navpanes=[Cawt TclInt $value]" }
                    "-embed"     { set embedFrame $value }
                    default      { error "CawtReader: Unknown key \"$key\" specified" }
                }
                append readerOpts "&" 
            }
            append readerOpts "\""
        }
        # puts "opts=$readerOpts"

        eval exec [list $readerProgName] $readerOpts $fileName &
        if { $embedFrame ne "" } {
            Cawt EmbedApp $embedFrame -filename $fileName
        }
    }

    proc SetReaderProg { fileName } {
        # Set the path to Acrobat Reader program.
        #
        # fileName - Full path name to Acrobat Reader program `AcroRd32.exe`
        #
        # Use this procedure, if the automatic detection of the path to 
        # Acrobat Reader does not work.
        #
        # Note, that this procedure must be called before calling [Open] or [OpenNew].
        #
        # Returns no value.
        #
        # See also: Open OpenNew

        variable readerProgName

        set readerProgName $fileName
    }

    proc OpenNew { fileName args } {
        # Open a new Acrobat Reader instance.
        #
        # fileName - File name of PDF file to open.
        # args     - List of startup options and its values.
        #
        # For a detailled description of supported options see [Open].
        #
        # Returns no value.
        #
        # See also: Open Quit

        Reader::_Init
        Reader::_Start $fileName true {*}$args
    }

    proc Open { fileName args } {
        # Open an Acrobat Reader instance.
        #
        # fileName - File name of PDF file to open.
        # args     - Options described below.
        #
        # -nameddest <string> - Specify a named destination in the PDF document.
        # -page <int>         - Specify a numbered page in the document, using an integer value. 
        #                       The document’s first page has a value of 1.
        # -zoom <int>         - Specify a zoom factor in percent.
        # -pagemode <string>  - Specify page display mode.
        #                       Valid values: bookmarks thumbs none
        # -search <string>    - Open the Search panel and perform a search for the 
        #                       words in the specified string. You can search only for single words.
        #                       The first matching word is highlighted in the document.
        # -scrollbar <bool>   - Turn scrollbars on or off.
        # -toolbar <bool>     - Turn the toolbar on or off.
        # -statusbar <bool>   - Turn the status bar on or off.
        # -messages <bool>    - Turn document message bar on or off.
        # -navpanes <bool>    - Turn the navigation panes and tabs on or off.
        # -embed <frame>      - Embed the Reader instance into a Tk frame. This frame must
        #                       exist and must be created with option `-container true`.
        #
        # Use an already running instance, if available.
        #
        # Note, that above described options are only a subset of all available
        # command line parameters. For a full list, see:
        # <http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_open_parameters.pdf>
        #
        # Returns no value.
        #
        # See also: OpenNew Quit

        Reader::_Init
        Reader::_Start $fileName false {*}$args
    }

    proc Quit {} {
        # Quit all Acrobat Reader instances.
        #
        # Returns no value.
        #
        # See also: Open OpenNew

        variable readerProgName

        if { $readerProgName ne "" } {
            Cawt KillApp [file tail $readerProgName]
        }
    }
}
