#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" -- ${1+"$@"}

# Utility script to retrieve information from OneNote.
#
# Copyright: 2013-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

set cawtDir [file join [pwd] ".."]
set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals"]]
if {$::tcl_platform(pointerSize) == 8} {
    set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals" "tDOM" "tDOM-win64"]]
} else {
    set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals" "tDOM" "tDOM-win32"]]
}

package require cawt

proc PrintUsage { appName } {
    global gOpt

    puts ""
    puts "Usage: $appName \[Options\]"
    puts ""
    puts "Utility program to retrieve information from OneNote."
    puts ""
    puts "Actions:"
    puts "  --help             : Print help message and exit."
    puts "  --print            : Print information about notebooks, sections or pages to stdout."
    puts "                       If no other option is given, print a list of all notebook names."
    puts "                       If --notebook is given, print all section names of that notebook."
    puts "                       If --section and --notebook are given, print all page names of that section."
    puts "  --check            : Find recently changed pages."
    puts "                       Use options --days and --mail to change default behaviour."
    puts "                       Default is: Look back $gOpt(Days) days. Print found page names to stdout."
    puts "Options:"
    puts "  --notebook <string>: Check or print specified notebook."
    puts "  --section <string> : Check or print specified section."
    puts "  --page <string>    : Check or print specified page."
    puts "  --xml              : Print information in OneNote XML format."
    puts "  --days <int>       : Specify number of days for recently changed pages."
    puts "  --mail <string>    : Send list of recently changed pages via Outlook mail."
    puts "                       If given string is a valid file name, scan that file for mail addresses."
    puts "                       Each line must contain key \"always\" or \"option\" followed by a mail address."
    puts "                       Otherwise the string is expected to be a mail address."
    puts "  --test             : Build Outlook mail, but do not send. Use for testing."
    puts ""
}

proc always { addr } {
    global gOpt

    lappend gOpt(AlwaysList) $addr
}

proc option { addr } {
    global gOpt

    lappend gOpt(OptionList) $addr
}

# Default values for command line action options.
set gOpt(Print) false
set gOpt(Check) false

# Default values for command line options.
set gOpt(Notebook)  ""
set gOpt(Section)   ""
set gOpt(Page)      ""
set gOpt(PrintXml)  false
set gOpt(Days)      1
set gOpt(Mail)      ""
set gOpt(Test)      false

set gOpt(AlwaysList) [list]
set gOpt(OptionList) [list]

set curArg 0
while { $curArg < $argc } {
    set curParam [lindex $argv $curArg]
    if { [string compare -length 1 $curParam "-"]  == 0 || \
         [string compare -length 2 $curParam "--"] == 0 } {
        set curOpt [string tolower [string trimleft $curParam "-"]]
        if { $curOpt eq "help" } {
            PrintUsage $argv0
            exit 0
        } elseif { $curOpt eq "print" } {
            set gOpt(Print) true
        } elseif { $curOpt eq "check" } {
            set gOpt(Check) true
        } elseif { $curOpt eq "notebook" } {
            incr curArg
            set gOpt(Notebook) [lindex $argv $curArg]
        } elseif { $curOpt eq "section" } {
            incr curArg
            set gOpt(Section) [lindex $argv $curArg]
        } elseif { $curOpt eq "page" } {
            incr curArg
            set gOpt(Page) [lindex $argv $curArg]
        } elseif { $curOpt eq "xml" } {
            set gOpt(PrintXml) true
        } elseif { $curOpt eq "days" } {
            incr curArg
            set gOpt(Days) [lindex $argv $curArg]
        } elseif { $curOpt eq "mail" } {
            incr curArg
            set gOpt(Mail) [lindex $argv $curArg]
        } elseif { $curOpt eq "test" } {
            set gOpt(Test) true
        } else {
            puts "Error: Unknown option \"$curParam\"."
            PrintUsage $argv0
            exit 0
        }
    }
    incr curArg
}

if { $gOpt(Print) == false && $gOpt(Check) == false } {
    PrintUsage $argv0
    exit 0
}

set oneNoteId [OneNote Open]
set domRoot   [OneNote GetDomRoot $oneNoteId]

if { $gOpt(Print) } {
    if { $gOpt(Notebook) eq "" } {
        # No notebook specified: Print all available notebooks.
        if { $gOpt(PrintXml) } {
            puts [$domRoot asXML]
        } else {
            set notebookDomList [OneNote GetNotebooks $domRoot]
            foreach notebookDom $notebookDomList {
                puts [OneNote GetNodeName $notebookDom]
            }
        }
    } else {
        # Check if specified notebook exists.
        set domNotebook [OneNote FindNotebook $domRoot $gOpt(Notebook)]
        if { $domNotebook eq "" } {
            puts "Error: Notebook \"$gOpt(Notebook)\" not found."
            exit 1
        }
        if { $gOpt(Section) eq "" } {
            # No section specified: Print all available sections.
            if { $gOpt(PrintXml) } {
                puts [$domNotebook asXML]
            } else {
                set sectionDomList [OneNote GetSections $domNotebook]
                foreach sectionDom $sectionDomList {
                    puts [OneNote GetNodeName $sectionDom]
                }
            }
        } else {
            # Check if specified section exists.
            set domSection [OneNote FindSection $domNotebook $gOpt(Section)]
            if { $domSection eq "" } {
                puts "Error: Section \"$gOpt(Section)\" not found in notebook \"$gOpt(Notebook)\"."
                exit 1
            }
            if { $gOpt(Page) eq "" } {
                # No page specified: Print all available pages.
                if { $gOpt(PrintXml) } {
                    puts [$domSection asXML]
                } else {
                    set pageDomList [OneNote GetPages $domSection]
                    foreach pageDom $pageDomList {
                        puts [OneNote GetNodeName $pageDom]
                    }
                }
            } else {
                # Check if specified page exists.
                set domPage [OneNote FindPage $domSection $gOpt(Page)]
                if { $domPage eq "" } {
                    puts "Error: Page \"$gOpt(Page)\" not found in notebook \"$gOpt(Notebook)::$gOpt(Section)\"."
                    exit 1
                }
                OneNote PrintPage $oneNoteId $domPage
            }
        }
    }
    exit 0
}

if { $gOpt(Check) } {
    if { $gOpt(Notebook) eq "" } {
        set msg "all notebooks"
    } else {
        set msg "notebook $gOpt(Notebook)"
    }
    set modifiedList [OneNote GetLastModified $domRoot \
                              [clock add [clock seconds] [expr -$gOpt(Days)] days] \
                              "Page" $gOpt(Notebook)]

    if { [llength $modifiedList] == 0 } {
        set mailTitle "No changed pages of $msg in the last $gOpt(Days) days"
        set bodyText  $mailTitle
        set checkText ""
    } else {
        set mailTitle "Changed pages of $msg in the last $gOpt(Days) days"
        set bodyText "<html><body>\n"
        append bodyText "<h2>$mailTitle</h2>\n"
        append bodyText "<table border=\"1\">\n"
        append bodyText "  <tr><th>Date</th><th>Notebook</th><th>Section</th><th>Page</th></tr>\n"
        foreach pageNode $modifiedList {
            set pageName [OneNote GetNodeName $pageNode]
            set pageDate [Cawt XmlDateToIsoDate [OneNote GetNodeAttribute $pageNode "lastModifiedTime"]]
            set pageLink [OneNote GetNodeHyperLink $oneNoteId $pageNode]
            set sectionNode [$pageNode parentNode]
            set sectionName [OneNote GetNodeName $sectionNode]
            set sectionLink [OneNote GetNodeHyperLink $oneNoteId $sectionNode]
            set notebookNode [$sectionNode parentNode]
            set notebookName [OneNote GetNodeName $notebookNode]
            set notebookLink [OneNote GetNodeHyperLink $oneNoteId $notebookNode]

            append checkText "$pageDate ${notebookName}::${sectionName}::${pageName}\n"

            append bodyText "  <tr>\n"
            append bodyText "    <td><code>$pageDate</code></td>\n"
            append bodyText "    <td><a href=$notebookLink>$notebookName</a></td>\n"
            append bodyText "    <td><a href=$sectionLink>$sectionName</a></td>\n"
            append bodyText "    <td><a href=$pageLink>$pageName</a></td>\n"
            append bodyText "  </tr>\n"
        }
        append bodyText "</table>\n"
        append bodyText "</body></html>\n"
    }

    if { $gOpt(Mail) ne "" } {
        set outlookId [Outlook Open]
        if { [file exists $gOpt(Mail)] } {
            source $gOpt(Mail)
            set toList $gOpt(AlwaysList)
            if { [llength $modifiedList] > 0 } {
                lappend toList {*}$gOpt(OptionList)
            }
        } else {
            set toList [list $gOpt(Mail)]
        }
        set mailId [Outlook CreateHtmlMail $outlookId $toList $mailTitle $bodyText]
        if { ! $gOpt(Test) } {
            $mailId -with { Recipients } ResolveAll
            Outlook SendMail $mailId
            Outlook Quit $outlookId
        }
    } else {
        puts "${mailTitle}"
        puts $checkText
    }
}

OneNote Quit $oneNoteId
Cawt Destroy
exit 0
