# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Cawt {

    namespace ensemble create

    namespace export CheckComObjects
    namespace export CheckList
    namespace export CheckMatrix
    namespace export CheckBoolean
    namespace export CheckNumber
    namespace export CheckString
    namespace export CheckFile

    proc CheckComObjects { expected msg { printCheck true } } {
        # Check, if the number of COM objects fits expected value.
        #
        # expected   - Expected number of COM objects.
        # msg        - Message for test case.
        # printCheck - Print message for successful test case.
        #
        # Returns true, if the number of COM objects fits expected value.
        # If $printCheck is set to true, a line prepended with `"Check:"` and the
        # message supplied in $msg is printed to standard output.
        # If the check fails, return false and print message prepended with `"Error:"`.
        #
        # See also: CheckList CheckMatrix CheckBoolean CheckNumber CheckString GetNumComObjects

        set value [Cawt::GetNumComObjects]
        if { $expected != $value } {
            puts "Error: $msg (Expected: $expected Have: $value)"
            return false
        }
        if { $printCheck } {
            puts "Check: $msg (Expected: $expected Have: $value)"
        }
        return true
    }

    proc CheckString { expected value msg { printCheck true } } {
        # Check, if two string values are identical.
        #
        # expected   - Expected string value.
        # value      - Test string value.
        # msg        - Message for test case.
        # printCheck - Print message for successful test case.
        #
        # Returns true, if both string values are identical.
        # If "printCheck" is set to true, a line prepended with `"Check:"` and the
        # message supplied in "msg" is printed to standard output.
        # If the check fails, return false and print message prepended with `"Error:"`.
        #
        # See also: CheckComObjects CheckList CheckMatrix CheckBoolean CheckNumber

        if { $expected ne $value } {
            puts "Error: $msg (Expected: \"$expected\" Have: \"$value\")"
            return false
        }
        if { $printCheck } {
            puts "Check: $msg (Expected: \"$expected\" Have: \"$value\")"
        }
        return true
    }

    proc CheckBoolean { expected value msg { printCheck true } } {
        # Check, if two boolean values are identical.
        #
        # expected   - Expected boolean value.
        # value      - Test boolean value.
        # msg        - Message for test case.
        # printCheck - Print message for successful test case.
        #
        # Returns true, if both boolean values are identical.
        # If $printCheck is set to true, a line prepended with `"Check:`" and the
        # message supplied in $msg is printed to standard output.
        # If the check fails, return false and print message prepended with `"Error:`".
        #
        # See also: CheckComObjects CheckNumber CheckList CheckMatrix CheckString

        if { [expr bool($expected)] != [expr bool($value)] } {
            puts "Error: $msg (Expected: $expected Have: $value)"
            return false
        }
        if { $printCheck } {
            puts "Check: $msg (Expected: $expected Have: $value)"
        }
        return true
    }

    proc CheckNumber { expected value msg { printCheck true } } {
        # Check, if two numerical values are identical.
        #
        # expected   - Expected numeric value.
        # value      - Test numeric value.
        # msg        - Message for test case.
        # printCheck - Print message for successful test case.
        #
        # Returns true, if both numeric values are identical.
        # If $printCheck is set to true, a line prepended with `"Check:"` and the
        # message supplied in $msg is printed to standard output.
        # If the check fails, return false and print message prepended with `"Error:"`.
        #
        # See also: CheckComObjects CheckBoolean CheckList CheckMatrix CheckString

        if { $expected != $value } {
            puts "Error: $msg (Expected: $expected Have: $value)"
            return false
        }
        if { $printCheck } {
            puts "Check: $msg (Expected: $expected Have: $value)"
        }
        return true
    }

    proc CheckList { expected value msg { printCheck true } } {
        # Check, if two lists are identical.
        #
        # expected   - Expected list.
        # value      - Test list.
        # msg        - Message for test case.
        # printCheck - Print message for successful test case.
        #
        # Returns true, if both lists are identical.
        # If $printCheck is set to true, a line prepended with `"Check:"` and the
        # message supplied in $msg is printed to standard output.
        # If the check fails, return false and print message prepended with `"Error:"`.
        #
        # See also: CheckComObjects CheckMatrix CheckBoolean CheckNumber CheckString

        if { [llength $expected] != [llength $value] } {
            puts "Error: $msg (List length differ. Expected: [llength $expected] Have: [llength $value])"
            return false
        }
        set index 0
        foreach exp $expected val $value {
            if { $exp != $val } {
                puts "Error: $msg (Values differ at index $index. Expected: $exp Have: $val)"
                return false
            }
            incr index
        }
        if { $printCheck } {
            if { [llength $value] <= 4 } {
                puts "Check: $msg (Expected: $expected Have: $value)"
            } else {
                puts "Check: $msg (Lists are identical. List length: [llength $value])"
            }
        }
        return true
    }

    proc CheckMatrix { expected value msg { printCheck true } } {
        # Check, if two matrices are identical.
        #
        # expected   - Expected matrix.
        # value      - Test matrix.
        # msg        - Message for test case.
        # printCheck - Print message for successful test case.
        #
        # Returns true, if both matrices are identical.
        # If $printCheck is set to true, a line prepended with `"Check:"` and the
        # message supplied in $msg is printed to standard output.
        # If the check fails, return false and print message prepended with `"Error:"`. 
        #
        # See also: CheckComObjects CheckList CheckBoolean CheckNumber CheckString

        if { [llength $expected] != [llength $value] } {
            puts "Error: $msg (Matrix rows differ. Expected: [llength $expected] Have: [llength $value])"
            return false
        }
        set row 0
        foreach expRow $expected valRow $value {
            set col 0
            foreach exp $expRow val $valRow {
                if { $exp != $val } {
                    puts "Error: $msg (Values differ at row/col $row/$col. Expected: $exp Have: $val)"
                    return false
                }
                incr col
            }
            incr row
        }
        if { $printCheck } {
            puts "Check: $msg (Matrices are identical. Matrix rows: [llength $value])"
        }
        return true
    }

    proc CheckFile { fileName1 fileName2 msg { printCheck true } } {
        # Check, if two files are identical.
        #
        # fileName1  - First file name.
        # fileName2  - Second file name.
        # msg        - Message for test case.
        # printCheck - Print message for successful test case.
        #
        # Returns true, if both files are identical.
        # If "printCheck" is set to true, a line prepended with `"Check:"` and the
        # message supplied in "msg" is printed to standard output.
        # If the check fails, return false and print message prepended with `"Error:"`.
        #
        # See also: CheckComObjects CheckList CheckMatrix CheckBoolean CheckNumber

        if { ! [file isfile $fileName1] } {
            puts "Error: $msg (File not existent: \"$fileName1\")"
            return false
        }
        if { ! [file isfile $fileName2] } {
            puts "Error: $msg (File not existent: \"$fileName2\")"
            return false
        }

        if { [file size $fileName1] != [file size $fileName2] } {
            puts "Error: $msg (Expected size: [file size $fileName1] Have: [file size $fileName2])"
            return false
        } 

        set fp1 [open $fileName1 "r"]
        set fp2 [open $fileName2 "r"]

        fconfigure $fp1 -translation binary
        fconfigure $fp2 -translation binary

        set retVal  0
        set bufSize 2048

        set str1 [read $fp1 $bufSize]
        while { 1 } {
            set str2 [read $fp2 $bufSize]
            if { $str1 ne $str2 } {
                # Files differ
                set retVal 0
                break
            }
            set str1 [read $fp1 $bufSize]
            if { $str1 eq "" } {
                # Files are identical
                set retVal 1
                break
            }
        }
        close $fp1
        close $fp2

        if { $retVal == 0 } {
            puts "Error: $msg (Files differ: \"[file tail $fileName1]\" \"[file tail $fileName2]\")"
            return false
        } else {
            if { $printCheck } {
                puts "Check: $msg (Files are identical: \"[file tail $fileName1]\" \"[file tail $fileName2]\")"
            }
        }
        return true
    }
}
