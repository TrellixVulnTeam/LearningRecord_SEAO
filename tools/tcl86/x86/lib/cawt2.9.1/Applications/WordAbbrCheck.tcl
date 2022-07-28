#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" -- ${1+"$@"}

# Utility script to list and count the words in a Word document.
# The output can be used to check for used abbreviations in a
# document, which are not contained in an abbreviation table.
#
# Copyright: 2017-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

set cawtDir [file join [pwd] ".."]
set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals"]]

package require cawt

proc PrintUsage { appName } {
    puts ""
    puts "Usage: $appName \[Options\] WordFile"
    puts "  Open a Word document and perform several checks and statistics."
    puts "  If no options are specified, the number of words in the document"
    puts "  are counted."
    puts ""
    puts "Options:"
    puts "  --help             : Print this help message."
    puts "  --showfiles        : Open log and result files after generation."
    puts "  --outfile <string> : Store results in given file."
    puts "                       Use \"stdout\" to print to standard output."
    puts "                       Default: Results are stored in a file with"
    puts "                       same root name as input file, but extension \".txt\"."
    puts "  --minlength <int>  : Only count words having more than minlength"
    puts "                       characters. Default: 2 characters."
    puts "  --maxlength <int>  : Only count words having less than maxlength"
    puts "                       characters. Default: Unlimited."
    puts "  --nonumbers        : Only count words which are no numbers."
    puts "  --sortmode <string>: Sorting mode of word output."
    puts "                       Default: length."
    puts "                       Possible values: dictionary, length, increasing, decreasing."
    puts "  --csv              : Write result data in CSV format."
    puts "                       Default: Space seperated."
    puts "  --printtables      : Print table names of the Word file and exit."
    puts "  --abbr <string>    : Title of a table in the Word file containing"
    puts "                       abbreviations. It is assumed, that the abbreviations"
    puts "                       start in row 2 and are listed in column 1."
    puts "  --links            : Check validity of internal and external links."
    puts ""
}

proc Log { msg { exitProg false } } {
    global gLogFp gLogFile

    puts $msg

    if { ! [info exists gLogFp] } {
        set gLogFp [open $gLogFile "w"]
    }
    puts $gLogFp $msg
    flush $gLogFp

    if { $exitProg } {
        close $gLogFp
        exit 0
    }
}

set optPrintHelp   false
set optWordFile    ""
set optOutFile     ""
set optMinLength   2
set optMaxLength   -1
set optShowFiles   false
set optShowNumbers true
set optCsvFormat   false
set optSortMode    "length"
set optCheckLinks  false
set optPrintTables false
set optAbbrTable   ""
set optAbbrRow     2
set optAbbrCol     1

set curArg 0
while { $curArg < $argc } {
    set curParam [lindex $argv $curArg]
    if { [string compare -length 1 $curParam "-"]  == 0 || \
         [string compare -length 2 $curParam "--"] == 0 } {
        set curOpt [string tolower [string trimleft $curParam "-"]]
        if { $curOpt eq "help" } {
            set optPrintHelp true
        } elseif { $curOpt eq "showfiles" } {
            set optShowFiles true
        } elseif { $curOpt eq "outfile" } {
            incr curArg
            set optOutFile [lindex $argv $curArg]
        } elseif { $curOpt eq "minlength" } {
            incr curArg
            set optMinLength [lindex $argv $curArg]
        } elseif { $curOpt eq "maxlength" } {
            incr curArg
            set optMaxLength [lindex $argv $curArg]
        } elseif { $curOpt eq "nonumbers" } {
            set optShowNumbers false
        } elseif { $curOpt eq "csv" } {
            set optCsvFormat true
        } elseif { $curOpt eq "sortmode" } {
            incr curArg
            set optSortMode [lindex $argv $curArg]
        } elseif { $curOpt eq "printtables" } {
            set optPrintTables true
        } elseif { $curOpt eq "abbr" } {
            incr curArg
            set optAbbrTable [lindex $argv $curArg]
        } elseif { $curOpt eq "links" } {
            set optCheckLinks true
        }
    } else {
        if { $optWordFile eq "" } {
            set optWordFile $curParam
        }
    }
    incr curArg
}

if { $optPrintHelp } {
    PrintUsage $argv0
    exit 0
}

# Check, if all necessary parameters have been supplied.
if { $optWordFile eq "" } {
    puts "No Word input file specified."
    PrintUsage $argv0
    exit 1
}
set wordFile [file nativename [file normalize $optWordFile]]

# Open new Word instance and show the application window.
set appId [Word Open true]

# Open the Word document in read-only mode.
set docId [Word OpenDocument $appId $wordFile -readonly true]

if { $optPrintTables } {
    set numTables [Word GetNumTables $docId]
    for { set i 1 } { $i <= $numTables } { incr i } {
        set tableId [Word GetTableIdByIndex $docId $i]
        puts [format "%03d: %s" $i [$tableId Title]]
    }
    # Quit Word application without showing possible alerts.
    Word Close $docId
    Word Quit $appId false
    Cawt Destroy
    exit 0
}

# Create the abbreviations and log files.
set gLogFile "[file rootname $wordFile]_Log.txt"
Log "Counting words of file $wordFile ..."

if { $optOutFile eq "" } {
    set fileName "[file rootname $wordFile]_Abbr.txt"
    set fp [open $fileName "w"]
} elseif { $optOutFile eq "stdout" } {
    set fileName "stdout"
    set fp stdout
} else {
    set fileName $optOutFile
    set fp [open $fileName "w"]
}
Log "Writing results to file $fileName ..."
Log "Writing logs    to file $gLogFile ..."

if { $optCheckLinks } {
    Log "Checking for invalid links ..."
    set invalidLinkDict [Word GetHyperlinksAsDict $docId -check true -valid false]
    dict for { id info } $invalidLinkDict {
        dict with info {
            Log "    $address $text $start $end"
        }
    }
}

set abbrList [list]
if { $optAbbrTable ne "" } {
    set numTables [Word GetNumTables $docId]
    for { set i 1 } { $i <= $numTables } { incr i } {
        set tableId [Word GetTableIdByIndex $docId $i]
        if { [$tableId Title] eq $optAbbrTable } {
            set abbrList [Word GetColumnValues $tableId $optAbbrCol $optAbbrRow]
            Log "Found abbreviation table $optAbbrTable."
            break
        }
    }
    if { [llength $abbrList] == 0 } {
        Log "Abbreviation table $optAbbrTable not found."
    }
}

set wordCountList [Word CountWords $docId \
                   -sortmode $optSortMode \
                   -minlength $optMinLength \
                   -maxlength $optMaxLength \
                   -shownumbers $optShowNumbers]
foreach { word count } $wordCountList {
    set abbrFound ""
    if { [lsearch -exact $abbrList $word] >= 0 } {
        set abbrFound "ABBR"
    }
    if { $optCsvFormat } {
        puts $fp [format "%s,%d,%s" $word $count $abbrFound]
    } else {
        puts $fp [format "%-20s %5d %s" $word $count $abbrFound]
    }
}

if { $optAbbrTable ne "" } {
    if { [llength $abbrList] > 0 } {
        Log "Checking for unused abbreviations ..."
        foreach abbr $abbrList {
            set abbrHash($abbr) 0
        }
        foreach { word count } $wordCountList {
            if { [info exists abbrHash($word)] } {
                incr abbrHash($word)
            }
        }
        foreach abbr [array names abbrHash] {
            if { $abbrHash($abbr) == 0  || [dict get $wordCountList $abbr] == 1 } {
                Log "    $abbr"
            }
        }
    }
}

# Quit Word application without showing possible alerts.
Word Close $docId
Word Quit $appId false
Cawt Destroy

if { $optShowFiles } {
    puts "\nStarting log file [file nativename $gLogFile]"
    eval exec cmd /c start [list [file nativename $gLogFile]] &
    puts "\nStarting result file [file nativename $fileName]"
    eval exec cmd /c start [list [file nativename $fileName]] &
}
Log "Done" true
close $fp
