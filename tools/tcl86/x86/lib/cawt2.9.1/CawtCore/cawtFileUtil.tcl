# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Cawt {

    namespace ensemble create

    namespace export IsUnicodeFile
    namespace export SplitFile ConcatFiles
    namespace export GetTmpDir

    proc IsUnicodeFile { fileName } {
        # Check, if a file is encoded in Unicode.
        #
        # fileName - File to check encoding.
        #
        # Unicode encoding is detected by checking the BOM.
        # If the first two bytes are `FF FE`, the file seems to be
        # a Unicode file.
        #
        # Returns true, if file is encoded in Unicode, otherwise false.
        #
        # See also: SplitFile ConcatFiles

        set catchVal [catch {open $fileName r} fp]
        if { $catchVal != 0 } {
            error "Could not open file \"$fileName\" for reading."
        }
        fconfigure $fp -translation binary
        set bom [read $fp 2]
        close $fp
        binary scan $bom "cc" bom1 bom2
        set bom1 [expr {$bom1 & 0xFF}]
        set bom2 [expr {$bom2 & 0xFF}]
        if { [format "%02X%02X" $bom1 $bom2] eq "FFFE" } {
            return true
        }
        return false
    }

    proc SplitFile { inFile { maxFileSize 2048 } { outFilePrefix "" } } {
        # Split a file into several output files.
        #
        # inFile        - Input file name.
        # maxFileSize   - Maximum size of output files in bytes.
        # outFilePrefix - Prefix for output file names.
        #
        # Split the content of the file specified in $inFile into several
        # output files. The output files have a maximum size of $maxFileSize and
        # are named as follows: $outFilePrefix.00001, $outFilePrefix.00002, ...
        #
        # Returns the generated file names as a list.
        # If the input file could not be opened for reading
        # or any of the output files could not be openend for 
        # writing, an error is thrown.
        #
        # See also: IsUnicodeFile ConcatFiles

        set catchVal [catch {open $inFile r} inFp]
        if { $catchVal != 0 } {
            error "Could not open file \"$inFile\" for reading."
        }
        fconfigure $inFp -translation binary

        if { $outFilePrefix ne "" } {
            set outFileName $outFilePrefix
        } else {
            set outFileName $inFile
        }
        set count 1
        set fileList [list]
        while { 1 } {
            set str [read $inFp $maxFileSize]
            if { $str ne "" } {
                set fileName [format "%s-%05d" $outFileName $count]
                set catchVal [catch {open $fileName w} outFp]
                if { $catchVal != 0 } {
                    close $inFp
                    error "Could not open file \"$fileName\" for writing."
                }
                fconfigure $outFp -translation binary
                puts -nonewline $outFp $str
                close $outFp
                lappend fileList $fileName
                incr count
            }
            if { [eof $inFp] } {
                break
            }
        }
        close $inFp
        return $fileList
    }

    proc ConcatFiles { outFile args } {
        # Concatenates files into one file.
        #
        # outFile - Output file name.
        # args    - List of input files.
        #
        # Concatenate the contents of the files specified in $args into one
        # file $outFile.
        #
        # Returns no value. 
        # If the output file could not be opened for writing
        # or any of the input files could not be openend for reading, an error
        # is thrown.
        #
        # See also: IsUnicodeFile SplitFile

        set catchVal [catch {open $outFile w} outFp]
        if { $catchVal != 0 } {
            close $inFp
            error "Could not open file \"$outFile\" for writing."
        }
        fconfigure $outFp -translation binary

        foreach fileName $args {
            set catchVal [catch {open $fileName r} fp]
            if { $catchVal != 0 } {
                close $outFp
                error "Could not open file \"$fileName\" for reading."
            }
            fconfigure $fp -translation binary
            fcopy $fp $outFp
            close $fp
        }
        close $outFp
    }

    proc GetTmpDir {} {
        global tcl_platform env

        set tmpDir ""
        # Try different environment variables.
        if { [info exists env(TMP)] && [file isdirectory $env(TMP)] } {
            set tmpDir $env(TMP)
        } elseif { [info exists env(TEMP)] && [file isdirectory $env(TEMP)] } {
            set tmpDir $env(TEMP)
        } elseif { [info exists env(TMPDIR)] && [file isdirectory $env(TMPDIR)] } {
            set tmpDir $env(TMPDIR)
        } else {
            # Last resort. These directories should be available at least.
            switch $tcl_platform(platform) {
                unix {
                    if { [file isdirectory "/tmp"] } {
                        set tmpDir "/tmp"
                    }
                }
            }
        }
        return [file nativename $tmpDir]
    }
}
