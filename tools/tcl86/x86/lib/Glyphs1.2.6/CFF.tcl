# CFF.tcl
#
# This module is part of the Glyphs package, providing methods for accessing
# the 'CFF 'table, and then decoding (PostScript format) glyph outlines.
#
# Reference Specification:
#     Opentype 1.6 - http://www.microsoft.com/typography/otspec/
#   https://www.microsoft.com/typography/OTSPEC/cff.htm
#   http://download.microsoft.com/download/8/0/1/801a191c-029d-4af3-9642-555f6fe514ee/cff.pdf
#   http://download.microsoft.com/download/8/0/1/801a191c-029d-4af3-9642-555f6fe514ee/type2.pdf
#
# CREDITS
#  Part of this code is a rework of 
#   * sfntutil.tcl - by Lars Hellstrom
#   * opentype.js - by Frederik De Bleser.


package require Itcl

namespace eval CFF {

	itcl::class Stack {
		private variable stack {}
	
	    method destroy {} { itcl::delete object $this }
		method reset {} { set stack {} }
	
		method size {} { llength $stack }
		
		method push {value} { lappend stack $value ; return }
	
		method pop {} {
			set val [lindex $stack end]
			set stack [lreplace $stack end end]
			return $val
		}
	
		method shift {} {
			set stack [lassign $stack val]
			return $val
		}
	}

	variable thisDir
	set thisDir [file normalize [file dirname [info script]]]
    variable CFF ;#  const tables
	source [file join $thisDir CFFconsts.tcl]
	unset thisDir
}

	# === Basic CFF Data Types ================================================
	#
	# NOTE: multi.byte numerical values and offsets are ... BigEndian byte order

	proc CFF::_getCard8 {fd} {
		binary scan [read $fd 1] "cu" val
		return $val
	}

	 # same as getCard8
	proc CFF::_getByte {fd} {
		_getCard8 $fd
	}

	proc CFF::_getBytes { fd n } {
		read $fd $n
	}

	proc CFF::_getCard16 {fd} {
		binary scan [read $fd 2] Su val
		return $val
	}

	 # read a BigEndian integer made of size bytes (1..4 bytes)
	proc CFF::_getOffset {fd size} {
		set val 0
		while {$size > 0} {
			set byte [_getByte $fd]
		    set val [expr {$val<<8 | $byte}]
			incr size -1
		}
		return $val
	}
		
	proc CFF::_getSID {fd} {
		binary scan [read $fd 2] Su val
		return $val
	}

	# =========================================================================
	# === Basic CFF structures ================================================
	
	 # Parse a `CFF` INDEX array.
	 #  a raw index consists of an array of offsets, then a list of objects at those offsets.
	 #  It is converted in a list of properly decoded objects.
	 #  'decoder' is a proc taking two args: fd and size, returning the decoded value.
	proc CFF::_getINDEX {fd decoder} {
		set count [_getCard16 $fd]
		if { $count == 0 } { return {} }
		
		set offsetSize [_getByte $fd]
		set sizes {}
		 # note that there are count+1 elems
		 # 1st elements is always "1"
		set prevOffset [_getOffset $fd $offsetSize]
		for { set i 1 } { $i <= $count } { incr i } {
			set offset [_getOffset $fd $offsetSize]
	 		 # I don't care about the offsets; I care about the length of each elem ..
			lappend sizes [expr {$offset - $prevOffset}]
			set prevOffset $offset
		}
		# now we are at the beginning of the first elem
		set elem0Pos [tell $fd]
		set nextElemPos $elem0Pos
		set L {}
		foreach size $sizes {
			lappend L [uplevel 1 $decoder $fd $size]
			incr nextElemPos $size
			seek $fd $nextElemPos
		}
		 # file access position is set just after the end of the INDEXstructure
		return $L
	}


	# A (CFF) DICT contains key-value pairs in a compact tokenized format.

	# Internally a CFF-Dict is a sequence of entries (of variables size);
	# you don't know how many entries are there, but you know their totalSize (in bytes).
	# Stop scanning the entries when you reach this limit.
	# CFF-Dict entries:
	# Each entry is made of 1 or more operand then one operator.
	# The operator is the key, and the operands are the value
	#  (Note that the key/values order is inverted)	
	# Note that some values are of SID type; usually they will be converted later (in strings)
	proc CFF::_getDICT {fd totalSize operatorDecoder} {
		set scanLimit [expr {[tell $fd]+$totalSize}]
		set D [dict create]
		set operands {}
		while { [tell $fd] < $scanLimit } {
			set b0 [_getByte $fd]  ;# b0 is the lookahed byte
			 # The first byte for each dict item distinguishes between operator (key)
			 # and operand (value).
	         # Values > 21 are operands.
			if { $b0 > 21 } {
				lappend operands [_getOperand $fd $b0]  ;# the value(s)
			} else {
				 # it's an operator(the key)
				set operator [_getOperator $fd $b0]
				set operator [uplevel 1 $operatorDecoder [list $operator]]

				  # If a value is a list of one, it is unpacked.
				if { [llength $operands] > 1 } {
					set value $operands
				} else {
					set value [lindex $operands 0]
				}
				set operands {} 		
	
				dict set D $operator $value
			}
		}
		return $D
	}


	 # --- support utilities for parsing DICT : operators and operands --------

	 # an operator is a number or a list of two number
	proc CFF::_getOperator {fd b0} {
		if { $b0 == 12 } {
			# Two-byte operators have an initial escape byte of 12 (0x0C)
			set val [list $b0 [_getByte $fd]]		
		} else {
			set val $b0
		}
		return $val
	}

	
	 # Parse a `CFF` DICT real value.
	proc CFF::_getFloatOperand {fd} {
		set floatStr ""
		set eoF 0x0F ; # end of float
		set lookup { 0 1 2 3 4 5 6 7 8 9 0 "." "E" "E-" "reserved" "-"}
	
	    while {true} {
	        set b [_getByte $fd]
	        set n1 [expr {$b>> 4}]
	        set n2 [expr {$b & 0x0F}]
	
	        if { $n1 == $eoF } break;
	
			append floatStr [lindex $lookup $n1]
	
	        if { $n2 == $eoF } break;
			append floatStr [lindex $lookup $n2]
	    }
	
         # remove leading zeros , or it will be parsed as an octal number
        if { [string range $floatStr 0 0] eq "0" } { 
            set floatStr [string trimleft $floatStr "0"]
        } elseif { [string range $floatStr 0 1] eq "-0" } {
            set floatStr "-[string trimleft [string range 1 end $floatStr] "0"]
        }

		if { ! [string is double $floatStr] } {
			error "bad float number \"$floatStr\""
		}
		return [expr {$floatStr + 0.0}]
	}
	

	proc CFF::_getOperand {fd b0} {
		if { $b0 == 28 } {
			set b1 [_getByte $fd]
			set b2 [_getByte $fd]
			return [expr {($b1<<8) | $b2}]
		}
		if { $b0 == 29 } {
			set b1 [_getByte $fd]
			set b2 [_getByte $fd]
			set b3 [_getByte $fd]
			set b4 [_getByte $fd]
			return [expr {($b1<<24) | ($b2<<16) | ($b3<<8) | $b4 }]
		}
		if { $b0 == 30 } {
			return [_getFloatOperand $fd]
		}	
		if { $b0 >= 32 && $b0 <= 246 } {
			return [expr {$b0 - 139}]
		}	
		if { $b0 >= 247 && $b0 <= 250 } {
			set b1 [_getByte $fd]
			return [expr {($b0 - 247) * 256 + $b1 + 108}]
		}
		if { $b0 >= 251 && $b0 <= 254 } {
			set b1 [_getByte $fd]
			return [expr {-($b0 - 251) * 256 - $b1 - 108}]
		}
		error "Invalid b0 $b0"
	}
	 

	# === CharStrings (glyph) parsing =========================================
	
	# Decode a charstring code and return a list of paths.
	#  A path is a list made of chained 'points'
	#	A chained point is made of (x y flag)
	#     flag : 1 - the point is on the curve
	#     flag : 0 - the point is a control-point (of a cubic Bezier)
	# The encoding is described in the Type 2 Charstring Format
	# https://www.microsoft.com/typography/OTSPEC/charstr2.htm
	proc CFF::getGlyphPoints  {fd topDict glyphIdx} {
		lassign [lindex [dict get $topDict "CharStrings"] $glyphIdx]  offset size
		seek $fd $offset

		set STATE(path) {}		 
		set STATE(paths) {}		 
	    set STATE(stack) [Stack #auto]
	    set STATE(relWidth) 0
	    set STATE(nStems) 0
	    set STATE(gotWidth) false
	    set STATE(x) 0
	    set STATE(y) 0
	    set STATE(c1x) 0
	    set STATE(c1y) 0
	    set STATE(c2x) 0
	    set STATE(c2y) 0
	
		set gsubrs [dict get $topDict _gsubrs]
		set gsubrsBias [dict get $topDict _gsubrsBias]
		    
	    if { [dict get $topDict "_isCIDFont" ] } {
	        set fdIndex [lindex [dict get $topDict "fdSelect"] $glyphIdx]
	        set fdDict [lindex [dict get $topDict "fdArray"] $fdIndex]
	        set subrs [dict get $fDict _subrs]
	        set subrsBias [dict get $fDict _subrsBias]
	    } else {
	        set subrs [dict get $topDict _subrs]
	        set subrsBias [dict get $topDict _subrsBias]
	    }
	
	    _decodeCharstring $fd $size $gsubrs $gsubrsBias $subrs $subrsBias STATE

		$STATE(stack) destroy
		
		if { $STATE(path) != {} } {
			lappend STATE(paths) $STATE(path)
		}
# ?? ignore STATE(relWidth)  ??
	    return $STATE(paths)  
	}


	# side effects:
	#  update STATE(nStems)
	#  reset  STATE(stack)
	#  (eventually) set STATE(relWidth)
	#  (eventually) set STATE(gotWidth)
	proc CFF::_sub_parseStems {STATEname} {
		upvar 1 $STATEname STATE
		
		set hasWidthArg [expr {[$STATE(stack) size] % 2 != 0 ? true : false}]	
		if { $hasWidthArg && ! $STATE(gotWidth) } {
			set STATE(relWidth) [$STATE(stack) shift]
		}
		incr STATE(nStems) [expr {[$STATE(stack) size]>>1}]
		$STATE(stack) reset
		set STATE(gotWidth) true
	}



	# add current path (if non empty) to paths
	# then set a new path
	proc CFF::_sub_newPath {STATEname x y} {
		upvar 1 $STATEname STATE
		
		if { $STATE(path) != {} } {
			lappend STATE(paths) $STATE(path)
			set STATE(path) {}
		}
		lappend STATE(path) $x $y 1 ;# MOVETO
	}

     # decode a CharString
	 # A lot of side effetcs:
	 # the main side effects is the uodate of STATE(path) and STATE(paths)
	 #  also works on STATE(stack), STATE(relWidth) ...)
	 #
	 # note that arithmetic and logic operators are not implemented
	 #  ( .. I din't find a font using them ... yet )
	proc CFF::_decodeCharstring {fd totalSize gsubrs gsubrsBias subrs subrsBias STATEname} {
		upvar 1 $STATEname STATE

		 # Note: totalSize is a safety limit, since each CharString MUST end with 'endchar'		
		set scanLimit [expr {[tell $fd]+$totalSize}]
		while { [tell $fd] < $scanLimit } {	
			set v [_getCard8 $fd]
			switch -- $v {
				1 -
				3 -
				18 -
				23 { ;# hstem, vstem, hstemhm, vstemhm				
					_sub_parseStems	STATE
				}
				19 -
				20 { ;# hintmask, cntmask
					_sub_parseStems	STATE
					 # skip bytes required for the mask made of nStems bits
					seek $fd [expr {($STATE(nStems)+7)>>3}] current			
				}
	
				4 { 
					 # vmoveto  
					if { [$STATE(stack) size] > 1 && ! $STATE(gotWidth) } {
						set STATE(relWidth) [$STATE(stack) shift]
						set STATE(gotWidth) true
					}
				    set STATE(y) [expr {$STATE(y)+[$STATE(stack) pop]}]
					_sub_newPath STATE $STATE(x) $STATE(y)		    
				}
				21 { 
					 # rmoveto  
					if { [$STATE(stack) size] > 2 && ! $STATE(gotWidth) } {
						set STATE(relWidth) [$STATE(stack) shift]
						set STATE(gotWidth) true
					}
				    set STATE(y) [expr {$STATE(y)+[$STATE(stack) pop]}]
				    set STATE(x) [expr {$STATE(x)+[$STATE(stack) pop]}]
					_sub_newPath STATE $STATE(x) $STATE(y)		    
				}
				22 { 
					 # hmoveto  
					if { [$STATE(stack) size] > 1 && ! $STATE(gotWidth) } {
						set STATE(relWidth) [$STATE(stack) shift]
						set STATE(gotWidth) true
					}
				    set STATE(x) [expr {$STATE(x)+[$STATE(stack) pop]}]
					_sub_newPath STATE $STATE(x) $STATE(y)		    
				}		
				
				
				5 {
					 # rlineto
					while { [$STATE(stack) size]  > 0} {
					    set STATE(x) [expr {$STATE(x)+[$STATE(stack) shift]}]
					    set STATE(y) [expr {$STATE(y)+[$STATE(stack) shift]}]
						lappend STATE(path) $STATE(x) $STATE(y) 1  ;# LINETO
					}
				}
				6 {
					 #hlineto
					while { [$STATE(stack) size]  > 0} {
						set STATE(x) [expr {$STATE(x)+[$STATE(stack) shift]}]
						lappend STATE(path) $STATE(x) $STATE(y) 1  ;# LINETO
						if { [$STATE(stack) size] == 0 } break
						set STATE(y) [expr {$STATE(y)+[$STATE(stack) shift]}]
						lappend STATE(path) $STATE(x) $STATE(y) 1  ;# LINETO
					}
				}
				7 {
					 #vlineto
					while { [$STATE(stack) size]  > 0} {
						set STATE(y) [expr {$STATE(y)+[$STATE(stack) shift]}]
						lappend STATE(path) $STATE(x) $STATE(y) 1  ;# LINETO
						if { [$STATE(stack) size] == 0 } break
						set STATE(x) [expr {$STATE(x)+[$STATE(stack) shift]}]
						lappend STATE(path) $STATE(x) $STATE(y) 1  ;# LINETO
					}
				}
				8 {
					 # rrcurveto
					while { [$STATE(stack) size]  > 0} {
						set STATE(c1x) [expr {$STATE(x) + [$STATE(stack) shift]}]
						set STATE(c1y) [expr {$STATE(y) + [$STATE(stack) shift]}]
						set STATE(c2x) [expr {$STATE(c1x) + [$STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [$STATE(stack) shift]}]
						set STATE(x)   [expr {$STATE(c2x) + [$STATE(stack) shift]}]
						set STATE(y)   [expr {$STATE(c2y) + [$STATE(stack) shift]}]
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1  ;# CUBIC
					}
				}
				24 {
					 # rcurveline
					while { [$STATE(stack) size]  > 2} {
						set STATE(c1x) [expr {$STATE(x) + [$STATE(stack) shift]}]
						set STATE(c1y) [expr {$STATE(y) + [$STATE(stack) shift]}]
						set STATE(c2x) [expr {$STATE(c1x) + [$STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [$STATE(stack) shift]}]
						set STATE(x)   [expr {$STATE(c2x) + [$STATE(stack) shift]}]
						set STATE(y)   [expr {$STATE(c2y) + [$STATE(stack) shift]}]
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1  ;# CUBIC
					}
					set STATE(x) [expr {$STATE(x)+[$STATE(stack) shift]}]
					set STATE(y) [expr {$STATE(y)+[$STATE(stack) shift]}]
					lappend STATE(path) $STATE(x) $STATE(y) 1 ;# LINE
				}
				25 {
					 # rlinecurve
					while { [$STATE(stack) size]  > 6} {
						set STATE(x) [expr {$STATE(x)+[$STATE(stack) shift]}]
						set STATE(y) [expr {$STATE(y)+[$STATE(stack) shift]}]
						lappend STATE(path) $STATE(x) $STATE(y) 1 ;# LINE
					}
					set STATE(c1x) [expr {$STATE(x) + [$STATE(stack) shift]}]
					set STATE(c1y) [expr {$STATE(y) + [$STATE(stack) shift]}]
					set STATE(c2x) [expr {$STATE(c1x) + [$STATE(stack) shift]}]
					set STATE(c2y) [expr {$STATE(c1y) + [$STATE(stack) shift]}]
					set STATE(x)   [expr {$STATE(c2x) + [$STATE(stack) shift]}]
					set STATE(y)   [expr {$STATE(c2y) + [$STATE(stack) shift]}]
					lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1 ;# CUBIC
					}
				26 {
					 # vvcurveto
					if { [$STATE(stack) size] % 2 } {
						set STATE(x) [expr {$STATE(x)+[$STATE(stack) shift]}]
					}
					while { [$STATE(stack) size]  > 0} {
						set STATE(c1x) $STATE(x)
						set STATE(c1y) [expr {$STATE(y) + [ $STATE(stack) shift]}]
						set STATE(c2x) [expr {$STATE(c1x) + [ $STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [ $STATE(stack) shift]}]
						set STATE(x)   $STATE(c2x)
						set STATE(y)   [expr {$STATE(c2y) + [ $STATE(stack) shift]}]
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1 ;# CUBIC
						}
				}
				27 {
					 # hhcurveto
					if { [$STATE(stack) size] % 2 } {
						set STATE(y) [expr {$STATE(y)+[$STATE(stack) shift]}]
					}
					while { [$STATE(stack) size]  > 0} {
						set STATE(c1x) [expr {$STATE(x) + [ $STATE(stack) shift]}]
						set STATE(c1y) $STATE(y)
						set STATE(c2x) [expr {$STATE(c1x) + [ $STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [ $STATE(stack) shift]}]
						set STATE(x)   [expr {$STATE(c2x) + [ $STATE(stack) shift]}]
						set STATE(y)   $STATE(c2y)
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1 ;# CUBIC
						}
				}
				30 {
					 # vhcurveto
					while { [$STATE(stack) size]  > 0} {
						set STATE(c1x) $STATE(x)
						set STATE(c1y) [expr {$STATE(y) + [ $STATE(stack) shift]}]
						set STATE(c2x) [expr {$STATE(c1x) + [ $STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [ $STATE(stack) shift]}]
						set STATE(x)   [expr {$STATE(c2x) + [ $STATE(stack) shift]}]
						set STATE(y)   [expr {$STATE(c2y) + ([$STATE(stack) size]== 1 ? [ $STATE(stack) shift] : 0)}]
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1 ;# CUBIC
		
						if { [$STATE(stack) size] == 0 } break
	
						set STATE(c1x) [expr {$STATE(x) + [ $STATE(stack) shift]}]
						set STATE(c1y) $STATE(y)
						set STATE(c2x) [expr {$STATE(c1x) + [ $STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [ $STATE(stack) shift]}]
						set STATE(y)   [expr {$STATE(c2y) + [ $STATE(stack) shift]}]
						set STATE(x)   [expr {$STATE(c2x) + ([$STATE(stack) size]== 1 ? [ $STATE(stack) shift] : 0)}]
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1 ;# CUBIC
						}
				}
				31 {
					 # hvcurveto
					while { [$STATE(stack) size]  > 0} {
						set STATE(c1x) [expr {$STATE(x) + [ $STATE(stack) shift]}]
						set STATE(c1y) $STATE(y)
						set STATE(c2x) [expr {$STATE(c1x) + [ $STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [ $STATE(stack) shift]}]
						set STATE(y)   [expr {$STATE(c2y) + [ $STATE(stack) shift]}]
						set STATE(x)   [expr {$STATE(c2x) + ([$STATE(stack) size]== 1 ? [ $STATE(stack) shift] : 0)}]
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1 ;# CUBIC
		
						if { [$STATE(stack) size] == 0 } break
	
						set STATE(c1x) $STATE(x)
						set STATE(c1y) [expr {$STATE(y) + [ $STATE(stack) shift]}]
						set STATE(c2x) [expr {$STATE(c1x) + [ $STATE(stack) shift]}]
						set STATE(c2y) [expr {$STATE(c1y) + [ $STATE(stack) shift]}]
						set STATE(x)   [expr {$STATE(c2x) + [ $STATE(stack) shift]}]
						set STATE(y)   [expr {$STATE(c2y) + ([$STATE(stack) size]== 1 ? [ $STATE(stack) shift] : 0)}]
						lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $STATE(x) $STATE(y) 1 ;# CUBIC
						}
				}
	
	
				29 { ;# callgsubr
					set currPos [tell $fd]
					set codeIndex  [$STATE(stack) pop]
					incr codeIndex $gsubrsBias
					lassign [lindex $gsubrs $codeIndex] offset size
					seek $fd $offset				 
					_decodeCharstring $fd $size  $gsubrs $gsubrsBias $subrs $subrsBias STATE
					seek $fd $currPos
				}
				10 { ;# callsubr
					set currPos [tell $fd]
					set codeIndex  [$STATE(stack) pop]
					incr codeIndex $subrsBias
					lassign [lindex $subrs $codeIndex] offset size
					seek $fd $offset				 
					_decodeCharstring $fd $size $gsubrs $gsubrsBias $subrs $subrsBias STATE
					seek $fd $currPos
				}			
				11 { ;# return
					return
				}
				14 { ;# endchar
					if { [$STATE(stack) size] > 0 && ! $STATE(gotWidth) } {
						set STATE(relWidth) [ $STATE(stack) shift]
						set STATE(gotWidth) true
					}
					if { [llength $STATE(path)] > 0 } {
						lappend STATE(paths) $STATE(path)
						set STATE(path) {}
					}
					return
				}
					
									
				12 {  ;#  flex operators
					set v [_getCard8 $fd]
					switch -- $v {
						35 { ;# flex
							 # |- dx1 dy1 dx2 dy2 dx3 dy3 dx4 dy4 dx5 dy5 dx6 dy6 fd flex (12 35) |-
							set STATE(c1x) [expr {$STATE(x)+[ $STATE(stack) shift]}] ;# dx1
							set STATE(c1y) [expr {$STATE(y)+[ $STATE(stack) shift]}] ;# dy1
							set STATE(c2x) [expr {$STATE(c1x)+[ $STATE(stack) shift]}] ;# dx2
							set STATE(c2y) [expr {$STATE(c1y)+[ $STATE(stack) shift]}] ;# dy2
							set jpx [expr {$STATE(c2x)+[ $STATE(stack) shift]}] ;# dx3
							set jpy [expr {$STATE(c2y)+[ $STATE(stack) shift]}] ;# dy3
							set c3x [expr {$jpx+[ $STATE(stack) shift]}] ;# dx4
							set c3y [expr {$jpy+[ $STATE(stack) shift]}] ;# dy4
							set c4x [expr {$c3x+[ $STATE(stack) shift]}] ;# dx5
							set c4y [expr {$c3y+[ $STATE(stack) shift]}] ;# dy5
							set STATE(x)   [expr {$c4x+[ $STATE(stack) shift]}] ;# dx6
							set STATE(y)   [expr {$c4y+[ $STATE(stack) shift]}] ;# dy6
	
							StackShift                ;# flex depth
							lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $jpx $jpy 1 ;# CUBIC
							lappend STATE(path) $c3x $c3y 0 $c4x $c4y 0 $STATE(x) $STATE(y) 1  ;# CUBIC
							}
						34 { ;# hflex
							 # |- dx1 dx2 dy2 dx3 dx4 dx5 dx6 hflex (12 34) |-
							set STATE(c1x) [expr {$STATE(x)+[ $STATE(stack) shift]}] ;# dx1
							set STATE(c1y) $STATE(y)
							set STATE(c2x) [expr {$STATE(c1x)+[ $STATE(stack) shift]}] ;# dx2
							set STATE(c2y) [expr {$STATE(c1y)+[ $STATE(stack) shift]}] ;# dy2
							set jpx [expr {$STATE(c2x)+[ $STATE(stack) shift]}] ;# dx3
							set jpy $STATE(c2y)
							set c3x [expr {$jpx+[ $STATE(stack) shift]}] ;# dx4
							set c3y $STATE(c2y)
							set c4x [expr {$c3x+[ $STATE(stack) shift]}] ;# dx5
							set c4y $STATE(y)
							set STATE(x)   [expr {$c4x+[ $STATE(stack) shift]}] ;# dx6
	
							lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $jpx $jpy 1 ;# CUBIC
							lappend STATE(path) $c3x $c3y 0 $c4x $c4y 0 $STATE(x) $STATE(y) 1 ;# CUBIC
						}
						36 { ;# hflex1
	                            # |- dx1 dy1 dx2 dy2 dx3 dx4 dx5 dy5 dx6 hflex1 (12 36) |-
							set STATE(c1x) [expr {$STATE(x)+[ $STATE(stack) shift]}] ;# dx1
							set STATE(c1y) [expr {$STATE(y)+[ $STATE(stack) shift]}] ;# dy1
							set STATE(c2x) [expr {$STATE(c1x)+[ $STATE(stack) shift]}] ;# dx2
							set STATE(c2y) [expr {$STATE(c1y)+[ $STATE(stack) shift]}] ;# dy2
							set jpx [expr {$STATE(c2x)+[ $STATE(stack) shift]}] ;# dx3
							set jpy $STATE(c2y)
							set c3x [expr {$jpx+[ $STATE(stack) shift]}] ;# dx4
							set c3y $STATE(c2y)
							set c4x [expr {$c3x+[ $STATE(stack) shift]}] ;# dx5
							set c4y [expr {$c3y+[ $STATE(stack) shift]}] ;# dy5
							set STATE(x)   [expr {$c4x+[ $STATE(stack) shift]}] ;# dx6
	
							lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $jpx $jpy 1 ;# CUBIC
							lappend STATE(path) $c3x $c3y 0 $c4x $c4y 0 $STATE(x) $STATE(y) 1 ;# CUBIC
						}
						37 { ;# flex1
	                            # |- dx1 dy1 dx2 dy2 dx3 dy3 dx4 dy4 dx5 dy5 d6 flex1 (12 37) |-
							set STATE(c1x) [expr {$STATE(x)+[ $STATE(stack) shift]}] ;# dx1
							set STATE(c1y) [expr {$STATE(y)+[ $STATE(stack) shift]}] ;# dy1
							set STATE(c2x) [expr {$STATE(c1x)+[ $STATE(stack) shift]}] ;# dx2
							set STATE(c2y) [expr {$STATE(c1y)+[ $STATE(stack) shift]}] ;# dy2
							set jpx [expr {$STATE(c2x)+[ $STATE(stack) shift]}] ;# dx3
							set jpy [expr {$STATE(c2y)+[ $STATE(stack) shift]}] ;# dy3
							set c3x [expr {$jpx+[ $STATE(stack) shift]}] ;# dx4
							set c3y [expr {$jpy+[ $STATE(stack) shift]}] ;# dy4
							set c4x [expr {$c3x+[ $STATE(stack) shift]}] ;# dx5
							set c4y [expr {$c3y+[ $STATE(stack) shift]}] ;# dy5
							if { abs($c3x-$STATE(x)) > abs($c4y-$STATE(y)) } {
								set STATE(x)   [expr {$c4x+[ $STATE(stack) shift]}]
							} else {
								set STATE(y)   [expr {$c4y+[ $STATE(stack) shift]}]
							}
							lappend STATE(path) $STATE(c1x) $STATE(c1y) 0 $STATE(c2x) $STATE(c2y) 0 $jpx $jpy 1 ;# CUBIC
							lappend STATE(path) $c3x $c3y 0 $c4x $c4y 0 $STATE(x) $STATE(y) 1 ;# CUBIC
						}
						default {
							# WARNING !! Unknown operator
							set stack {}
						}				
					}
				}
	
				28 { ;# shortint
					set b1 [_getCard8 $fd]
					set b2 [_getCard8 $fd]
					$STATE(stack) push\
						[expr {(($b1<<24) | ($b2<<16)) >> 16}]
				}				
				default {
					if { $v < 32 } {
						# !!! Warning Unknown operator
					} elseif { $v < 247 } {
						$STATE(stack) push [expr {$v-139}]
					} elseif { $v < 251 } {
						set b1 [_getCard8 $fd]
						$STATE(stack) push [expr {($v-247)*256+$b1+108}]
					} elseif { $v < 255 } {
						set b1 [_getCard8 $fd]
						$STATE(stack) push [expr {-($v-251)*256-$b1-108}]
					} else {
						set b1 [_getCard8 $fd]
						set b2 [_getCard8 $fd]
						set b3 [_getCard8 $fd]
						set b4 [_getCard8 $fd]
						$STATE(stack) push [expr {(($b1<<24) | ($b2<<16) | ($b3<<8) | $b4) / 65536.0} ]
						 #  WARNING !!! this number should be interpreted as a 
						 # 16-bit signed integer with 16 bits of fraction 
					}
				}
			}
		}
	}

	# ========================================================================= 

 
	 # Subroutines are encoded using the negative half of the number space.
	 # See type 2 chapter 4.7 "Subroutine operators".
	 # Return a bias (displacement) to be added to subr-number
	proc CFF::_calcCFFSubroutineBias {subrs} {
		set len [llength $subrs]
	    if { $len < 1240 } {
	        set bias 107
	    } elseif { $len < 33900 } {
	        set bias 1131
	    } else {
	        set bias 32768
	    }
	    return $bias
	} 
    
	# Given a String Index (SID), return the value of the string.
	# Strings below index 392 are standard CFF strings and are not encoded in the font.
	proc CFF::_decodeString { strings index } {
		variable CFF
		if { $index <= 390 } {
			return [lindex $CFF(StandardStrings) $index]
		}
		incr index -391
		return [lindex $strings $index]
	}

 

	 # Parse the CFF charset table, which contains internal names for all the glyphs.
	 # This function will return a list of glyph names.
	 # See Adobe TN #5176 chapter 13, "Charsets".
	proc  CFF::_scanCFFCharset {fd nGlyphs strings} {
		set charset { ".notdef" }
		incr nGlyphs -1
	
		set fmt [_getCard8 $fd]
		switch -- $fmt {
			0 {
				for {set i 0} {$i < $nGlyphs} {incr i} {
					set sid [_getSID $fd]
					lappend charset [_decodeString $strings $sid]
				}
			}
			1 {
				while { [llength $charset] <= $nGlyphs} {
					set sid [_getSID $fd]
					set count [_getCard8 $fd]
					for {set i 0} {$i <= $count} {incr i} {
						lappend charset [_decodeString $strings $sid]
						incr sid			
					}
				}
			}
			2 {
				while { [llength $charset] <= $nGlyphs} {
					set sid [_getSID $fd]
					set count [_getCard16 $fd]
					for {set i 0} {$i <= $count} {incr i} {
						lappend charset [_decodeString $strings $sid]
						incr sid			
					}
				}
			
			}
			default {
				error "Unknown charset format $fmt"		
			}
		}
		return $charset
	}

        
		# a code is one integer or a list of two integers
		proc CFF::_decodeDictOperator {Map code} {
			lindex $Map $code
		}
	
		 # a code is an integer or a list of two integers
		 # we are only interested with 3 operators ...
		proc CFF::_decodePrivateDictOperator {code} {
			if { $code == 19 } { return "subrs" }
			if { $code == 20 } { return "defaultWidthX" }
			if { $code == 21 } { return "nominalWidthX" }
			return "_dummy"			
		}


	 # a decoder for the _getINDEX proc	          
	proc CFF::_savePositionAndSize {fd size} {
		set offset [tell $fd]
		seek $fd $size current
		return [list $offset $size]
	}


	# Get a topDICT and:
	#  replace the SIDs with string
	#  expand the "Private" section (if exists)
	#   and if this section contains "subrs", then place "subrs" and "subrsBias"
	#   as key elements of topDICT
	proc CFF::_gatherCFFTopDict { fd topDict startOfCFF strings } {
		set topDictSIDS { ;# CONST
			version notice copyright fullName familyName weight fontName
		}
		 # note that also the the "ros" key is made of a list of SIDS (*special care*)	
			
		 # retouch all the keys with a SID value (but the key "ros")
		dict for {key val} $topDict {
			if { $key in $topDictSIDS } {
				dict set topDict $key [_decodeString $strings $val]
			}
		}
		 # special care for the key "ros"
		if { [dict exists $topDict "ros"] } {
			set val [dict get $topDict "ros"]
			lassign $val SID1 SID2 num
			set str1 [_decodeString $strings $SID1]
			set str2 [_decodeString $strings $SID1]
			set value [list $str1 $str2 $num]
	
			dict set topDict "ros" $val
		}
	
		 # expand Private entry
		if { [dict exists $topDict "Private"] } {
			lassign [dict get $topDict "Private"] privateSize privateOffset
			if { $privateSize != 0  &&  $privateOffset != 0 } {
				seek $fd [expr {$startOfCFF + $privateOffset}]
				dict set topDict "Private" \
					[_getDICT $fd $privateSize [list _decodePrivateDictOperator]]
			}
		}
	
		 # expand Private/subrs entry
		dict set topDict "_subrs" {}
		dict set topDict "_subrsBias" 0
		if { [dict exists $topDict "Private" "subrs"] } {
			set subrsOffset [dict get $topDict "Private" "subrs"]
			if { $subrsOffset == 0 } {
				set subrs {}
			} else {
				seek $fd [expr {$startOfCFF + $privateOffset+ $subrsOffset}]
			 	set subrs [_getINDEX $fd _savePositionAndSize]
			}
			dict set topDict "_subrs" $subrs
			dict set topDict "_subrsBias"  [_calcCFFSubroutineBias $subrs]
		}
		
		return $topDict
	}



	 # .. returna a dict (major minor offsetSize)
	 # cursor is placed at the beginning of the next block
	proc CFF::_scanHeader {fd} {
		set header [dict create]
		dict set header "major" [_getCard8 $fd]
		dict set header "minor" [_getCard8 $fd]
		set size  [_getCard8 $fd]  ;# no need to store it
		dict set header "offsetSize" [_getCard8 $fd]
		set skip [expr {$size - 4}]
		if { $skip > 0 } { seek $fd $skip current }
		return $header
	}


		# return a (decoded) TopDict
		# note that some entries' values are SID (String ID) and should be decoded later
	proc CFF::_scanTopDict {fd size} {
		set defaultTopDict [dict create  \
		    fontBBox			{0 0 0 0} \
			isFixedPitch 		0 \
			italicAngle 		0 \
			underlinePosition 	-100 \
			underlineThickness 	50 \
			paintType 			0 \
			charstringType		2 \
			fontMatrix			{0.001 0 0 0.001 0 0} \
			strokeWidth			0 \
			cidFontVersion		0 \
			cidFontRevision		0 \
			cidFontType			0 \
			cidCount			8720 \
			Encoding			0 \
		]
	
		variable CFF
		set D [_getDICT $fd $size [list _decodeDictOperator $CFF(TopDictMap)]]
		return [dict merge $defaultTopDict $D]
	}



	# ??ma chi lo chiama ??
	 # ?? dove setti lo start dello scan ??
	proc CFF::_scanCFFFDSelect {fd nGlyphs fdArrayCount} {
	    set fdSelect {}
	    set fmt [_getCard8 $fd]
	    if {$fmt == 0} {
	         # Simple list of nGlyphs elements
			for {set iGid 0} {$iGid < $nGlyphs} {incr iGid} {
	            set fdIndex [_getCard8 $fd]
	            if {$fdIndex >= $fdArrayCount} {
	                error "CFF table CID Font FDSelect has bad FD index value $fdIndex"
	            }
	            lappend fdSelect $fdIndex
	        }
	    } elseif {$fmt == 3} {
	         # Ranges
	        set nRanges [_getCard16 $fd]
	        set first   [_getCard16 $fd]
	        if {$first != 0} {
	            error "CFF Table CID Font FDSelect format 3 range has bad initial GID: $first"
	        }
	        for {set iRange 0} {$iRange < $nRanges} {incr iRange} {
	            set fdIndex [_getCard8 $fd]
				set next    [_getCard16 $fd]
	            if {$fdIndex >= $fdArrayCount} {
	                error "CFF table CID Font FDSelect has bad FD index value $fdIndex"
	            }
	            if {$next > $nGlyphs} {
	                error "CFF Table CID Font FDSelect format 3 range has bad GID: $next"
	            }
	            for {} {$first < $next} {incr first} {
	                lappend fdSelect $fdIndex
	            }
	            set first $next
	        }
	        if {$next != $nGlyphs} {
	            error "CFF Table CID Font FDSelect format 3 range has bad final GID: $next"
	        }
	    } else {
	        error "CFF Table CID Font FDSelect table has unsupported format $fmt"
	    }
	    return $fdSelect;
	}

 
    proc CFF::load {fd start size} {
		seek $fd $start
		set _Header [_scanHeader $fd]
		set _FontNames [_getINDEX $fd _getBytes]
	    if { [llength $_FontNames] > 1 } {
	        error "CFF table has too many fonts ([llength $_FontNames]"
	    }
	
		set _TopDicts [_getINDEX $fd _scanTopDict]
		 # note that dicts are still partially RAW (they contains number, but some of them
		 #  are SID  (string-id reference that we will expand later) 
	    if { [llength $_TopDicts] > 1 } {
	        error "CFF table has too many fonts top-dict ([llength $_TopDicts]"
	    }	

		set topDict [lindex $_TopDicts 0]
		dict set topDict "start" $start
	 	 # scan stringINDEX
		dict set topDict "ExtraStrings" [_getINDEX $fd _getBytes]

         # scan subrINDEX
		dict set topDict "_gsubrs" [_getINDEX $fd _savePositionAndSize]
		dict set topDict "_gsubrsBias" [_calcCFFSubroutineBias [dict get $topDict "_gsubrs"]]

         # Adjust SIDs and expand Private and _subrs
		set topDict [_gatherCFFTopDict $fd $topDict $start [dict get $topDict "ExtraStrings"]]

         # now decode other tables ...........................................

	       #  CharStrings INDEX is the glyphs list
		seek $fd [expr {$start + [dict get $topDict "CharStrings"]}] 
		 # don't decode each glyphs, just save offset and size for a next access 
		dict set topDict "CharStrings" [_getINDEX $fd _savePositionAndSize]
			
		set nGlyphs [llength [dict get $topDict "CharStrings"]]
	
		 # Charset INDEX is the list of the names of the glyphs
		seek $fd [expr {$start + [dict get $topDict "Charset"]}] 	 
		dict set topDict "Charset" [_scanCFFCharset $fd $nGlyphs [dict get $topDict "ExtraStrings"]]
	
	    dict set topDict "_isCIDFont" [expr {[dict exists $topDict "ros"] ? true : false}]

if 0 {  ;# useless code
		if { [dict exists $topDict "Private"] } {
			set defaultWidthX [dict get $topDict "Private" "defaultWidthX"]
			set nominalWidthX [dict get $topDict "Private" "nominalWidthX"]
		}
	
}

		 #	?? maybe this is useless for the current purpose ...
		if { [dict get $topDict "_isCIDFont" ] } {
			if { ! [dict exists $topDict fdArray] || ! [dict exists $topDict fdSelect] } {
	            error "Font is marked as a CID font, but FDArray and/or FDSelect information is missing"		
			} 
			
			seek $fd [expr {$start + [dict get $topDict "fdArray"]}]
			set _rawfds [_getIndex $fd _scanTopDict]
			set fds {}
			foreach fdElem _rawfds {
				lappend fds  [_gatherCFFTopDict $fdElem $start [dict get $topDict "ExtraStrings"]]		
			}
			dict set topDict "fdArray" $fds  ; # list of dictionaries
			
			seek $fd [expr {$start + [dict get $topDict "fdSelect"]}]
	        dict set topDict "fdSelect" \
				[_scanCFFFDSelect $fd $nGlyphs [llength [dict get $topDict "fdArray"]]]
			}

		# CFF Encoding skipped ...		
		return $topDict
	}


# =============================================================================
# == unused code ==============================================================
# =============================================================================

if {0} {

	 # Parse the CFF encoding data. Only one encoding can be specified per font.
	 # See Adobe TN #5176 chapter 12, "Encodings".
	proc CFF::_scanCFFEncoding {fd} {
	    set enc [dict create]
	    set fmt [_getCard8 $fd]
	    switch -- $fmt {
			0 {
		        set nCodes [_getCard8 $fd]
		        for {set i 0} {$i < $nCodes} {incr i} {
	            	set code [_getCard8 $fd]
	            	dict set enc $code $i
	            }
	        }
			1 {
				set nRanges [_getCard8 $fd]
				set code 1
		        for {set i 0} {$i < $nRanges} {incr i} {
		        	set first [_getCard8 $fd]
		        	set nLeft [_getCard8 $fd]
		        	set last  [expr {$first+$nLeft}]
			        for {set j $first} {$j <= $last} {incr j} {
			        	dict set enc $j $code
			        	incr code
			        }
			    }
			}
			default {
				error "Unknown encoding format $fmt"
			}
	    }	
	    return $enc
	}

}