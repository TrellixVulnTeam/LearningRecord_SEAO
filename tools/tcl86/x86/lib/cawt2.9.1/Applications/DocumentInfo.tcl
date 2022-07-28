#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" -- ${1+"$@"}

# Utility script to print information about Office document files.
#
# Copyright: 2013-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

set cawtDir [file join [pwd] ".."]
set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals"]]

package require cawt

proc PrintUsage { appName } {
    puts ""
    puts "Usage: $appName \[Options\] OfficeFile \[OfficeFile\]"
    puts ""
    puts "Print information about one or more Office documents."
    puts "Currently only PowerPoint files are implemented."
    puts ""
    puts "Options:"
    puts "  --help  : Print this help mesage and quit."
    puts "  --videos: Print a list of all videos in the document."
    puts "  --images: Print a list of all images in the document."
    puts ""
}

#
# Procedures to retrieve Excel information.
#
proc PrintExcelInfos { fileName } {
    global gOpts

    puts "PrintExcelInfos $fileName not yet implemented"
}

#
# Procedures to retrieve PowerPoint information.
#
proc PrintPptImages { presId } {
    foreach { name slideIndex } [Ppt GetPresImages $presId] {
        puts [format "Image at slide %03d: %s" $slideIndex $name]
    }
}

proc PrintPptVideos { presId } {
    foreach { name slideIndex } [Ppt GetPresVideos $presId] {
        puts [format "Video at slide %03d: %s" $slideIndex $name]
    }
}

proc PrintPptInfos { fileName } {
    global gOpts

    set appId [Ppt Open]
    set presId [Ppt OpenPres $appId $fileName -readonly true]

    set slideCount [Ppt GetNumSlides $presId]
    puts "PowerPoint file: $fileName has $slideCount slides."

    if { $gOpts(PrintImages) } {
        PrintPptImages $presId
    }
    if { $gOpts(PrintVideos) } {
        PrintPptVideos $presId
    }
    Ppt Close $presId
    Ppt Quit $appId false
}

#
# Procedures to retrieve Word information.
#
proc PrintWordInfos { fileName } {
    global gOpts

    puts "PrintWordInfos $fileName not yet implemented"
}

# Default values for command line options.
set gOpts(PrintHelp)   false
set gOpts(PrintImages) false
set gOpts(PrintVideos) false

# The list of office files supplied on the command line.
set officeFiles [list]

set curArg 0
while { $curArg < $argc } {
    set curParam [lindex $argv $curArg]
    if { [string compare -length 1 $curParam "-"]  == 0 || \
         [string compare -length 2 $curParam "--"] == 0 } {
        set curOpt [string tolower [string trimleft $curParam "-"]]
        if { $curOpt eq "help" } {
            set gOpts(PrintHelp) true
        } elseif { $curOpt eq "images" } {
            set gOpts(PrintImages) true
        } elseif { $curOpt eq "videos" } {
            set gOpts(PrintVideos) true
        }
    } else {
        # A DOS shell does no file expansion, as is done with a Unix style shell.
        # So we do this here. Only "?" and "*" are recognized.
        if { $::tcl_platform(platform) eq "windows" } {
            if { [string match "*\\**" $curParam] || [string match "*\\?*" $curParam] } {
                foreach f [lsort -dictionary [glob -nocomplain -types f -- [file normalize $curParam]]] {
                    lappend officeFiles $f
                }
            } else {
                if { [file isfile $curParam] } {
                    lappend officeFiles $curParam
                }
            }
        } else {
            if { [file isfile $curParam] } {
                lappend officeFiles $curParam
            }
        }
    }
    incr curArg
}

if { $gOpts(PrintHelp) || [llength $officeFiles] == 0 } {
    PrintUsage $argv0
    exit 0
}

foreach officeFile $officeFiles {
    set fileName [file nativename [file normalize $officeFile]]
    if { ! [file exists $fileName] } {
        puts "File $fileName not existent."
        continue
    }

    switch -exact -nocase -- [Office GetOfficeType $fileName] {
        "Excel" { PrintExcelInfos $fileName }
        "Ppt"   { PrintPptInfos   $fileName }
        "Word"  { PrintWordInfos  $fileName }
        default { puts "File $fileName is not an Office file." }
    }
}

Cawt Destroy
exit 0
