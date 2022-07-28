#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" -- ${1+"$@"}

# Utility script to send and receive large attachments via mail
# by splitting the file into several files.
#
# Example usages:
# Send:    tclsh MailAttachment.tcl --send --sendfile Word2Pdf.tcl --to info@poSoft.de --subject "Attachment Mail"
# Receive: tclsh MailAttachment.tcl --receive --receivefile "ReceivedFile" --subject "Attachment Mail*" 
#
# Copyright: 2017-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

set cawtDir [file join [pwd] ".."]
set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals"]]

package require cawt

proc PrintUsage { appName } {
    global gOpt

    puts ""
    puts "Usage: $appName \[Options\]"
    puts ""
    puts "Utility program to send and receive large attachments via mail"
    puts "by splitting the file into several files."
    puts ""
    puts "Actions:"
    puts "  --help   : Print help message and exit."
    puts "  --send   : Send a file via separate mails."
    puts "  --receive: Extract file pieces from mails with specified subject prefixes."
    puts ""
    puts "Options:"
    puts "  --size <int>        : Number of bytes for each file piece. Default: 2048"
    puts "  --sendfile <file>   : Send specified file."
    puts "  --receivefile <file>: Store received file in specified file."
    puts "  --to <string>       : Send mails to specified mail address."
    puts "  --subject <string>  : Subject of sent or received mails."
    puts "  --cleanup           : Delete intermediate splitted files."
    puts "  --test              : Build Outlook mails, but do not send. Use for testing."
    puts ""
}

# Default values for command line options.
set gOpt(FileSize)    2048
set gOpt(Action)      ""
set gOpt(SendFile)    ""
set gOpt(ReceiveFile) ""
set gOpt(Addresses)   [list]
set gOpt(Subject)     ""
set gOpt(Cleanup)     false
set gOpt(Test)        false

set curArg 0
while { $curArg < $argc } {
    set curParam [lindex $argv $curArg]
    if { [string compare -length 1 $curParam "-"]  == 0 || \
         [string compare -length 2 $curParam "--"] == 0 } {
        set curOpt [string tolower [string trimleft $curParam "-"]]
        if { $curOpt eq "help" } {
            PrintUsage $argv0
            exit 0
        } elseif { $curOpt eq "send" } {
            set gOpt(Action) "send"
        } elseif { $curOpt eq "receive" } {
            set gOpt(Action) "receive"
        } elseif { $curOpt eq "sendfile" } {
            incr curArg
            set gOpt(SendFile) [lindex $argv $curArg]
        } elseif { $curOpt eq "receivefile" } {
            incr curArg
            set gOpt(ReceiveFile) [lindex $argv $curArg]
        } elseif { $curOpt eq "to" } {
            incr curArg
            lappend gOpt(Addresses) [lindex $argv $curArg]
        } elseif { $curOpt eq "subject" } {
            incr curArg
            set gOpt(Subject) [lindex $argv $curArg]
        } elseif { $curOpt eq "cleanup" } {
            set gOpt(Cleanup) true
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

if { $gOpt(Action) eq "" } {
    puts "Error: No action specified.\n"
    PrintUsage $argv0
    exit 0
}

set outlookId [Outlook Open]

if { $gOpt(Action) eq "send" } {
    if { $gOpt(SendFile) eq "" || [file exists $gOpt(SendFile)] == false } {
        puts "Error: No file or invalid file specified for sending.\n"
        PrintUsage $argv0
        exit 0
    }
    if { [llength $gOpt(Addresses)] == 0 } {
        puts "Error: No mail address(es) specified for sending.\n"
        PrintUsage $argv0
        exit 0
    }

    set fileList [Cawt SplitFile $gOpt(SendFile) $gOpt(FileSize)]
    foreach fileName $fileList {
        if { $gOpt(Subject) eq "" } {
            set subject [file tail $fileName]
        } else {
            set subject "$gOpt(Subject) ([file tail $fileName])"
        }
        puts "Creating mail \"$subject\" (Attachment: $fileName)"
        set mailId [Outlook CreateMail $outlookId $gOpt(Addresses) $subject "" $fileName]
        if { ! $gOpt(Test) } {
            puts "Sending mail"
            $mailId -with { Recipients } ResolveAll
            Outlook SendMail $mailId
        }
        puts ""
    }
    if { $gOpt(Cleanup) } {
        foreach f $fileList {
            file delete -force $f
        }
    }
}

if { $gOpt(Action) eq "receive" } {
    if { $gOpt(ReceiveFile) eq "" } {
        puts "Error: No file or invalid file specified for receiving.\n"
        PrintUsage $argv0
        exit 0
    }
    foreach mailId [Outlook GetMailIds $outlookId] {
        if { [string match $gOpt(Subject) [$mailId Subject]] } {
            set attachmentId [$mailId -with {Attachments} Item 1]
            set fileName [$attachmentId FileName]
            set numInd [string last "-" $fileName]
            set fileNum [string range $fileName [expr $numInd+1] end]
            set outFile [format "%s-%s" $gOpt(ReceiveFile) $fileNum]
            set outFile [file nativename [file normalize $outFile]]
            $attachmentId SaveAsFile $outFile
            lappend outFileList $outFile
        }
    }
    if { [llength $outFileList] > 0 } {
        puts "Concatenating files to $gOpt(ReceiveFile)"
        Cawt ConcatFiles $gOpt(ReceiveFile) {*}[lsort $outFileList]
        if { $gOpt(Cleanup) } {
            puts "Cleaning intermediate files"
            foreach f $outFileList {
                file delete -force $f
            }
        }
    }
}

Cawt Destroy
exit 0
