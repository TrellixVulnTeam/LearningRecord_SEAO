# Glyphs
#
# This module offers a simplified interface for accessing the vectorial layouts
# of glyphs contained in OpenType files.
#
# Reference Specification:
#     Opentype 1.6 - http://www.microsoft.com/typography/otspec/
#
# LIMITATIONS
# * No checksum or full parsing implemented. Just the minumum for extracting glyphs.
# *
#
# CREDITS
#  Thanks to Ricard Marxer for the inspiration  - www.caligraft.com
#  Part of this code is a rework of 
#   * org.apache.batik.svggen project  (Apache License, 2.0)
#   * pdf4tcl project
#     Copyright (c) 2004 by Frank Richter <frichter@truckle.in-chemnitz.de> and
#                       Jens Ponisch <jens@ruessel.in-chemnitz.de>
#     Copyright (c) 2006-2012 by Peter Spjuth <peter.spjuth@gmail.com>
#     Copyright (c) 2009 by Yaroslav Schekin <ladayaroslav@yandex.ru>
#   * sfntutil.tcl - by Lars Hellstrom


 #  Example: see test suite

package require Itcl

 # the following non-standard packages should be installed in 'standard paths'
 # OR within this 'lib' subdir
set auto_path [linsert $auto_path 0 [file join [file dirname [file normalize [info script]]] lib]]    

package require Bezier
package require BContour

itcl::class Glyphs {	
    # --- standard new/destroy -------------------------------  
    proc new {args} {
        set class [namespace current]
         # object should be created in caller's namespace,
         # and fully qualified name should be returned
        uplevel 1 namespace which \[$class #auto $args\]                
    }

    method destroy {} {
        itcl::delete object $this
    }
    # --------------------------------------------------------
    
    private variable my ; # array used for collecting instance vars ..

    constructor {fontPath {subFontIdx 0}} {
        set my(fontPath) [file normalize $fontPath]
        
        set my(fd) [open $fontPath "r"]
        fconfigure $my(fd) -translation binary        

		# WARNING:
        # All multi-byte numerical data and offsets are stored in BigEndian byte order

		if { [catch {set my(tables) [$this _ReadOffsetTable $subFontIdx]} errMsg] } {
			$this destroy ;# invoke destructor
			error $errMsg
        }
         # preload the mandatory tables  (note: skip 'OS/2' and 'post' table)
		 #  'name' table already loaded
		 # Other tables are loaded on demand
        foreach tbl {head hhea maxp hmtx cmap} {
            $this _ReadTable.${tbl}
        }
		if { $my(isCFF) } {
			set my(CFF) [$this _ReadTable.CFF]
			 # savee CFF's glyphs positions in my(glyphPos)
			foreach az [dict get $my(CFF) "CharStrings"] {
				lassign $az  pos size
				lappend my(glyphPos) $pos
			}			
		} else {
			# font based on TrueType fonts
			set my(glyphPos) [$this _ReadTable.loca]
			# 'glyf' table is loaded on demand.
		}		

         # read some optional tables (if exist)
        foreach tbl {kern} {
            $this _ReadTable.${tbl}
        }         
         # .. glyf table, scanned on demand                   
    }
																		
	 # _ReadOffsetTable
	 # ---------------
	   # set my(isCFF)  -- based on CFF outlines
	   
	 # if ttcf , read the subFontIdx font 
	 #   else subFontIdx is ignored
	 # return a dict of tables  
     # Side effect:
	 # my(subFonts) contains the list of subFonts (if font-file is an OpenType collection)
	 #              or a list with THE fontname  (if font-file contains just one font)
	 # my(nameinfo))

	 # Each font-info is a dictionary
	 # An error is raised if fontPath cannot be properly parsed.
	method _ReadOffsetTable {subFontIdx} {
		set my(isCFF) false
		set magicTag [read $my(fd) 4]
		if { $magicTag == "ttcf" } {  ;# OpenTypeCollection
			set fontsOffset [_ReadTTC_Header $my(fd)] ;# one elem for each subfont
			set idx 0
			foreach fontOffset $fontsOffset {
				 # go to the start of the subfont and skip the initial 'magicTag' 
				seek $my(fd) [expr {$fontOffset+4}]
				set _tablesDict [_ReadTableRecord $my(fd)]
				 # extract names ...
				set nameinfo [_ReadTable.name $my(fd) [dict get $_tablesDict "name" "-start"]]
				 # family and subfamily
				lappend my(subFonts) [list \
					[_name.info $nameinfo fontFamily] \
					[_name.info $nameinfo fontSubfamily] \
					]
				if { $idx == $subFontIdx } {
					set tablesDict $_tablesDict
					set my(nameinfo) $nameinfo
				}				
				incr idx
			}
		} elseif { $magicTag in  { "OTTO" "\x00\x01\x00\x00"  "typ1" "true" } } {
			if { $magicTag == "OTTO" } {
				set my(isCFF) true ;# font based on CFF outline
			}
			set tablesDict [_ReadTableRecord $my(fd)]
			set my(nameinfo) [_ReadTable.name $my(fd) [dict get $tablesDict "name" "-start"]]
			set my(subFonts) [list [list [$this name.info fontFamily] [$this name.info fontSubfamily]]]
		} else {
			error "Unrecognized magic-number for OpenType font: 0x[binary encode hex $magicTag]"
		}
		return $tablesDict
	}

	 # _ReadTTCHeader $fd
	 # ------------------			
	 # scan the TTC header and 
	 # returns a list of fontsOffset ( i.e. where each sub-font starts )
	proc _ReadTTC_Header {fd} {
		binary scan [read $fd 8] SuSuIu  majorVersion minorVersion numFonts
		 #extract a list of 32bit integers 
		binary scan [read $fd [expr {4*$numFonts}]] "Iu*" fontsOffset 
		
		# NOTE: if majorVersion > 2 there can be a trailing digital-signature section ....
		#  ...  IGNORE IT			
		return $fontsOffset
	}


	 # _ReadTableDirectory
	 # -------------------
	 # returns a dictionary with 
	 #   keys = _tableName_ 
	 #   values = checksum, start, length (as a dictionary)
	proc _ReadTableRecord {fd} {
		 # Assert: we are at the beginng of the Table-Directory	
        binary scan [read $fd 8] SuSuSuSu numTables searchRange\
            entrySelector rangeShift       
		set tablesDict [dict create]
        for {set n 0} {$n<$numTables} {incr n} {
            binary scan [read $fd 16] a4H8IuIu tag checksum start length
            dict set tablesDict $tag [dict create -checksum $checksum -start $start -length $length]
        }
		return $tablesDict
	}

     # from the *numerical* code of a char to its glyph index
     # ( a numerical code is the decimal representation of its (hex) unicode
     #  eg.  946 is the numcode of \u03B2  ( 946=3*256+11*16+2)
    public method numcode2glyphIndex {numCode} {
        set idx 0
		set numCode [expr {0+$numCode}]  ;# force integer conversion
        if {  [info exists my(charToGlyph,$numCode)] } {
            set idx $my(charToGlyph,$numCode)
        }
        return $idx    
    }
    
     # from unicode to its glyph index
    public method unicode2glyphIndex {ch} {
        $this numcode2glyphIndex [scan $ch %c]    
    }
    
     # returns a glyph-object for character $ch
     # e.g.
     #     $obj  glyphByUnicode  "A"    ; # simple char
     #     $obj  glyphByUnicode   A     ; # same as above
     #     $obj  glyphByUnicode   ABC   ; # same as above; only the first char is considered !
     #     $obj  glyphByUnicode  \"     ; # the quote
     #     $obj  glyphByUnicode  "ß"    ; # unicode char \u03B2 (greek letter "Beta")
     #     $obj  glyphByUnicode  \u03B2 ; # same as above
    public method glyphByUnicode {ch} {
        $this glyph [$this unicode2glyphIndex $ch]
    }

     # similar to glyphByUnicode; argument is the *numerical* code of the character         
	 # DEPRECATED: use glyphByNumcode
    public method glyphByCharCode {charCode} {
        $this glyph [$this numcode2glyphIndex $charCode]
    }
    public method glyphByNumcode {numCode} {
        $this glyph [$this numcode2glyphIndex $numCode]
    }
    
    private variable glyphCache ; # array : cache of glyphs 
                               # key is glyph-index
                               # value is a glyph-object


     # This is a special method called by the destructor of a single glyph;
     # the glyphs object should release the cache
    private method _forget {glyph} {
          unset glyphCache([$glyph get index])
    }


     # returns the glyph-object stored at $idx position in the glyf-table
     # ( or in the CharStrings section for CFF fonts).
     # NOTE: the new glyph-obj will be created in glyphs namespace.
     # NOTE: you *can* destroy single glyph-objs but it's not necessary; 
     #  all the glyph-objs will be destroyed when the 'main' glyphs-obj is destroyed
    public method glyph {idx} {
		if { $idx < 0|| $idx >= $my(numGlyphs) } {
    		error "Glyph $idx - index out of range"
		}
        if { ! [info exists glyphCache($idx)] } {      
            set absPos [lindex $my(glyphPos) $idx]
			if { $absPos ==  [lindex  $my(glyphPos) $idx+1] } {
				 # notdef or space ...
				set hasGlyph false
			} else {
				set hasGlyph true
             	# warning: lindex accepts {} or blancs as index (!) returning the whole list !
             	# this should be considered an input error
            	if { $absPos == {} || ! [string is digit $absPos] } {
                	error "Glyph $idx - out of index"
            	}
            	seek $my(fd) $absPos    											
			}		
            set glyphCache($idx) [Glyph::new $this $idx $hasGlyph]
		}
        return $glyphCache($idx)
    }
    
    destructor {
        catch {close $my(fd)}
        foreach {idx obj} [array get glyphCache] {
            $obj destroy
        }       
    }



    # head - Font header table  (required)
    # NOTE: some fields skipped
    #  see http://www.microsoft.com/typography/otspec/head.htm
    private method _ReadTable.head {} {
        set tabInfo [dict get $my(tables) "head"]
        seek $my(fd) [dict get $tabInfo -start]        
        set nBytes [dict get $tabInfo -length]
        binary scan [read $my(fd) $nBytes] "SuSuSux6Iu x2 Su x16 S4 x6 SuSu" \
            ver_maj ver_min my(fontRevision) magic \
            my(unitsPerEm) my(bbox) \
            my(indexToLocFormat) my(glyphDataFormat)
        
        if {$ver_maj != 1} {error "Unknown head table version $ver_maj"}
        if {$magic != 0x5F0F3CF5} {error "Invalid head table magic $magic"}
    }

	 # DEPRECATED - just for compatibility; use the new names in _ID2Name
    private common _NameID2Str [dict create {*}{
      0  {Copyright notice}
      1  {Font Family name}
      2  {Font Subfamily name}
      3  {Unique font identifier}
      4  {Full font name}
      5  {Version string}
      6  {Postscript name}
      7  Trademark
      8  Manufacturer
      9  Designer
      10 Description
      11 {Vendor URL}
      12 {Designer URL}
      13 {License Description}
      14 {License Info URL}
      15 {}
      16 {Preferred Family}
      17 {Preferred Subfamily}
      18 {Compatible Full name}
      19 {Sample text}
      20 {PostScript CID findfont name}
      21 {WWS family name}
      22 {WWS subfamily name}
	  23 lightBackgroundPalette
	  24 darkBackgroundPalette
	  25 variationsPostScriptNamePrefix  
   }]
	private common _Str2NameID ; # reverse dict

	dict for { key val } $_NameID2Str {
		dict set _Str2NameID $val $key
	}

    	#  (NEW) NameIDs for the name table. (superseed the deprecated _NameID2Str)
	private common _ID2Name [dict create {*}{
		0  copyright
		1  fontFamily
		2  fontSubfamily
		3  uniqueID
		4  fullName
		5  version
		6  postScriptName
		7  trademark
		8  manufacturer
		9  designer
		10 description
		11 manufacturerURL
		12 designerURL
		13 license
		14 licenseURL
		15 reserved
		16 preferredFamily
		17 preferredSubfamily
		18 compatibleFullName
		19 sampleText
		20 postScriptFindFontName
		21 wwsFamily
		22 wwsSubfamily
		23 lightBackgroundPalette
		24 darkBackgroundPalette
		25 variationsPostScriptNamePrefix       
	}]
	private common _Name2ID ; # reverse dict

	dict for { key val } $_ID2Name {
		dict set _Name2ID $val $key
	}


	 # _convertfromUTF16BE $data
	 # -------------------------
	 # convert strings from UTF16BE to (tcl)Unicode strings.
	 # NOTE:
	 # When font-info is extracted from namerecords with platformID==3 (Windows)
	 # data (binary strings) are originally encoded in UTF16-BE.
	 # These data should be converted in (tcl)Unicode strings.
	 # Since the "tcl - unicode encoding" is BigEndian or LittleEndian, depending
	 # on the current platform, two variants of _convertfromUTF16BE areprovided;
	 # the right conversion will be choosen once at load-time.

	 # Note: the right procedure is selected at load-time
	if { $::tcl_platform(byteOrder) == "bigEndian" } {
		proc _convertfromUTF16BE {data} {
			encoding convertfrom unicode $data
		}
	} else {
		proc _convertfromUTF16BE {data} {
			 # swp bytes, then call encoding unicode ..
			binary scan $data "S*" z 
			encoding convertfrom unicode [binary format "s*" $z]
		}
	}

	 # extract all the names (id) andtheir values from $nameRecords matching $baseTriplet
	proc _ScanNameRecords { fd storageStart nameRecords baseTriplet } {
		set nameinfo [dict create]
		 # Assert: nameRecords are sorted by platformID,encodingID,languageID,nameID
		foreach { platformID encodingID languageID nameID length offset } $nameRecords {
			set currTriplet [binary format "SSS" $platformID $encodingID $languageID]
			set cmp [string compare -nocase $baseTriplet $currTriplet]
			if { $cmp == 0 } {
				seek $fd [expr {$storageStart+$offset}]
				binary scan [read $fd $length] "a*" value	
				if { $nameID > 25 } break ;# no reason to scan the rest of the table ..
		
				if { $platformID == 3 } { ;# windows
					# Windows only: extracted strings from records with platformID == "windows"
		 			#  are in UTF-16BE format. They should be converted.
					set value [_convertfromUTF16BE $value]
				}
				dict set nameinfo $nameID $value    
			}
			if { $cmp == -1 } break ;# no reason the scan the rest of the table ..
		}
		return $nameinfo
	}


	 #  _ReadTable.name $fd
	 # --------------------
	 # Scan the 'name' table and return a font-info dictionary.
	 # Reference Specification:
	 #    see http://www.microsoft.com/typography/otspec/name.htm
	 # NOTE:
	 # We don't care to extract all the (repeated) info for different platforms,
	 #  encodings, languages.
	 # Running on Windows  we extract details from records having
	 #    platform:  3 (windows)
	 #    encoding:  1 (Unicode BMP (UCS-2))
	 #    language: 0x0409  (English (US))
	 #   (NOTE: The encoding UCS-2  is a subset of UTF-18BE)
	 # Running on non-Windows, we extract details from records having
	 #   platform: 1 (macintosh)
	 #   encoding: 0 (macRoman)
	 #   language: 0 (American English)
 	 #
	 # info are saved in my(nameinfo) dictionary - see also name.info method
     proc _ReadTable.name {fd start} {
		seek $fd $start       
        binary scan [read $fd 6] "SuSuSu"  format count stringOffset
        set storageStart [expr {$start+$stringOffset}]
         #Each nameRecord is made of 6 UnsignedShort
		binary scan [read $fd [expr {2*6*$count}]] "Su*"  nameRecords  

		 # WARNING: some fonts (eg AmericanTypewriter.tcc) have incomplete
		 #  'Windows' sections. For these reason, always load the 'standard'
		 # 'mac' section and then, if you are on Windows, overwrite it with
		 # the values from the (sometimes incomplete) 'Windows' section.
		set nameinfo [dict create]
		 # Scan all the nameRecords. ( from the standard 'mac' section )
		set baseTriplet [binary format "SSS" 1 0 0]	 ;# mac triplet
		set nameinfo [_ScanNameRecords $fd $storageStart $nameRecords $baseTriplet]

		if { $::tcl_platform(platform) == "windows" } {
			set baseTriplet [binary format "SSS" 3 1 0x0409] ; # windows triplet	 
			set winnameinfo [_ScanNameRecords $fd $storageStart $nameRecords $baseTriplet]
		
			set nameinfo [dict merge $nameinfo $winnameinfo]
		}
		
		 # if $format == 1, there should be a 'languageTag section' 
		 #  ...  IGNORE IT 
	
		return $nameinfo            
    }    

	 # DEPRECATED - just for compatibility - see the new "name.info"
    
     # $fontOBJ nameinfo    ---> list of id, names pairs
     # $fontOBJ nameinfo 44 ---> 3ple  {id name value} about id
     # $fontOBJ nameinfo "Trademark" ---> 3ple  {id name value} about name
    public method nameinfo {{what *}} {
		_nameinfo $my(nameinfo) $what
	}
	     
	 # DEPRECATED - just for compatibility - see the new "_name.info"
    private proc _nameinfo { nameinfo {what *}} {
        if { $what == "*" } {
            set L {}
            foreach id [dict keys $nameinfo] {
                lappend L $id [dict get $_NameID2Str $id]
            }
            return $L
        }
        
        if { [string is digit $what] } {
        	set id $what
        	if { ! [dict exists $nameinfo $id] } { return {} }
        	set value [dict get $nameinfo $id]
			return [list $id [dict get $_NameID2Str $id] $value] 
        }
         # else assume what is a key
		set idStr $what
		if { ! [dict exists $_Str2NameID $idStr] } { return {} }
		set id [dict get $_Str2NameID $idStr]
		if { ! [dict exists $nameinfo $id] } { return {} }
      	set value [dict get $nameinfo $id]
    	return [list $id $idStr $value]         
    }

     # $fontOBJ name.info    ---> list of id, names pairs
     # $fontOBJ name.info 12 --->  value about id:12
     # $fontOBJ name.info "fontFamily" ---> value about name:fontFamily
    public method name.info {{what *}} {
		_name.info $my(nameinfo) $what
	}
	     
    private proc _name.info { nameinfo {what *}} {
        if { $what == "*" } {
            set L {}
            foreach id [dict keys $nameinfo] {
                lappend L $id [dict get $_ID2Name $id]
            }
            return $L
        }
        
        if { [string is digit $what] } {
        	set id $what
        	if { ! [dict exists $nameinfo $id] } { return {} }
        	return [dict get $nameinfo $id]
        }
         # else assume what is a key
		set idStr $what
		if { ! [dict exists $_Name2ID $idStr] } { return {} }
		set id [dict get $_Name2ID $idStr]
		if { ! [dict exists $nameinfo $id] } { return {} }
      	return [dict get $nameinfo $id]
    }

    
    # maxp - Maximum profile table  (required)
    # NOTE: partial parsing; only my(numGlyphs)
    private method _ReadTable.maxp {} {
        set tabInfo [dict get $my(tables) "maxp"]
        seek $my(fd) [dict get $tabInfo -start]        
        binary scan [read $my(fd) 6] "SuSuSu" \
            ver_maj ver_min my(numGlyphs)
    }

   
    # hhea - Horizontal Header  (required)
    # - This table contains information for horizontal layout
    # see http://www.microsoft.com/typography/otspec/hhea.htm
    private method _ReadTable.hhea { } {
        set tabInfo [dict get $my(tables) "hhea"]
        seek $my(fd) [dict get $tabInfo -start]
        set nBytes [dict get $tabInfo -length]
        binary scan [read $my(fd) $nBytes] "SuSu SSS SuSS SSSS x8 SuSu" \
                ver_maj ver_min \
                my(ascender) my(descender) my(lineGap) \
                my(advanceWidthMax) my(minLeftSideBearing) my(minRightSideBearing) \
                my(xMaxExtent) my(caretSlopeRise) my(caretSlopeRun) my(caretOffset) \
                my(metricDataFormat) my(numberOfHMetrics)
                
         # support pre 1.1.2 naming   (*DEPRECATED*)
        set my(Ascender)  $my(ascender)
        set my(Descender) $my(descender)
        set my(LineGap)   $my(lineGap)
		 
        if {$ver_maj != 1} {error "Unknown hhea table version"}
        if {$my(metricDataFormat) != 0} {error "Unknown horizontal metric data format"}
        if {$my(numberOfHMetrics) == 0} {error "Number of horizontal metrics is 0"}   
    }

	# hmtx - Horizontal Metrics  (required)
	# see http://www.microsoft.com/typography/otspec/hmtx.htm
	# NOTE: data from other tables required, 
	#   my(numberOfHMetrics) ...
    private method _ReadTable.hmtx {} {
        set tabInfo [dict get $my(tables) "hmtx"]
        seek $my(fd) [dict get $tabInfo -start]
        set nBytes [dict get $tabInfo -length]
        set my(hmetrics) {}       
        for {set glyph 0} {$glyph < $my(numberOfHMetrics)} {incr glyph} {
            # advance width and left side bearing. lsb is actually signed
            # short, but we don't need it anyway (except for subsetting)
            binary scan [read $my(fd) 4] "SuS" aw lsb
            lappend my(hmetrics) [list $aw $lsb]
            if {$glyph == 0} {set my(defaultWidth) $aw}
            if {[info exists my(glyphToChar,$glyph)]} {
                foreach char $my(glyphToChar,$glyph) {
                    set my(charWidths,$char) $aw
                }
            }            
        }
        
        # The rest of the table only lists advance left side bearings.
        # so we reuse aw set by the last iteration of the previous loop.
        # -- BUG (in reportlab) fixed here: aw used scaled in hmetrics,
        # -- i.e. float (must be int)
        for {set glyph $my(numberOfHMetrics)} {$glyph < $my(numGlyphs)} {incr glyph} {
            binary scan [read $my(fd) 2] "Su" lsb
            lappend my(hmetrics) [list $aw $lsb]
            if {[info exists my(glyphToChar,$glyph)]} {
                foreach char $my(glyphToChar,$glyph) {
                    set my(charWidths,$char) $aw
                }
            }
        }
    }       


    # loca - Index to location
    # NOTE: require my(indexToLocFormat)
    # see http://www.microsoft.com/typography/otspec/loca.htm
	# Returns the absolute starting position of each glyf    
    private method _ReadTable.loca {} {
        set tabInfo [dict get $my(tables) "loca"]
        seek $my(fd) [dict get $tabInfo -start]

        set offsetPositions {}
        if {$my(indexToLocFormat) == 0} {
            set nBytes [dict get $tabInfo -length]
            set numGlyphs [expr $nBytes / 2]
            binary scan [read $my(fd) $nBytes] "Su${numGlyphs}" glyphPositions
            foreach el $glyphPositions {
                lappend offsetPositions [expr {$el << 1}]
            }
        } elseif {$my(indexToLocFormat) == 1} {
            set nBytes [dict get $tabInfo -length]
            set numGlyphs [expr $nBytes / 4]
            binary scan [read $my(fd) $nBytes] "Iu${numGlyphs}" offsetPositions
        } else {
            error "Unknown location table format $my(indexToLocFormat)"
        }
       
        set absPositions {}
        set glyfBase [dict get $my(tables) "glyf" -start]                        
        foreach offset $offsetPositions {
			lappend absPositions [expr {$glyfBase+$offset}]
		}
		return $absPositions
    }

    # cmap - Character to glyph index mapping table
    # NOTE: require ....
    # see http://www.microsoft.com/typography/otspec/cmap.htm        
    private method _ReadTable.cmap {} {
        set tabInfo [dict get $my(tables) "cmap"]
        set cmap_offset [dict get $tabInfo -start]
        seek $my(fd) $cmap_offset        
        binary scan [read $my(fd) 4] "SuSu" version cmapTableCount
		set unicode_cmap_offset -1
        for {set f 0} {$f < $cmapTableCount} {incr f} {
            binary scan [read $my(fd) 8] "SuSuIu" platformID encodingID offset
            if {($platformID == 3 && $encodingID == 1) || ($platformID == 0)} {
                # Microsoft, Unicode OR just Unicode
                seek $my(fd) [expr {$cmap_offset+$offset}]
                binary scan [read $my(fd) 2] "Su" format
                if {$format == 4} {
                    set unicode_cmap_offset [expr {$cmap_offset + $offset}]
                    break
                }
            }
            # This SHOULD NOT exit loop:
            if {($platformID == 3 && $encodingID == 0)} {
                seek $my(fd) [expr {$cmap_offset+$offset}]
                binary scan [read $my(fd) 2] "Su" format
                if {$format == 4} {
                    set unicode_cmap_offset [expr {$cmap_offset + $offset}]
                    break
                }
            }
        }
         # we got Format 4
		if { $unicode_cmap_offset == -1 } {
            error "Font does not have cmap for Unicode"
        }
        incr unicode_cmap_offset 2 ; # skip first 2 bytes (format)
        seek $my(fd) ${unicode_cmap_offset}
        binary scan [read $my(fd) 6] "SuSuSu" length language segCount

        set segCount [expr {$segCount / 2}]
        set limit [expr {$unicode_cmap_offset + $length}]
        seek $my(fd) +6 current
        set nBytes [expr 2*${segCount}]        
        binary scan [read $my(fd) $nBytes] "Su${segCount}" endCount
        seek $my(fd) +2 current
        binary scan [read $my(fd) $nBytes] "Su${segCount}" startCount
        binary scan [read $my(fd) $nBytes] "S${segCount}" idDelta
        set idRangeOffset_start [tell $my(fd)]
        binary scan [read $my(fd) $nBytes] "Su${segCount}" idRangeOffset      
        for {set i 0} {$i < $segCount} {incr i} {
            set r_start  [lindex $startCount $i]
            set r_end    [lindex $endCount   $i]
            set r_offset [lindex $idRangeOffset $i]
            set r_delta  [lindex $idDelta $i]           
            for {set uniccode $r_start} {$uniccode <= $r_end} {incr uniccode} {
                if {$r_offset == 0} {
                    set glyph [expr {($uniccode + $r_delta) & 0xFFFF}]
                } else {
                    set offset [expr {($uniccode - $r_start) * 2 + $r_offset}]
                    set offset [expr {$idRangeOffset_start + 2 * $i + $offset}]
                    if {$offset > $limit} {
                        # workaround for broken fonts (like Thryomanes)
                        set glyph 0
                    } else {
                        seek $my(fd) $offset                    
                        binary scan [read $my(fd) 2] "Su" glyph
                        if {$glyph != 0} {
                            set glyph [expr {($glyph + $r_delta) & 0xFFFF}]
                        }
                    }
                }
                set my(charToGlyph,$uniccode) $glyph
                
                lappend my(glyphToChar,$glyph) $uniccode
            }
        }
    }

	# The `CFF` table contains the glyph outlines in PostScript format.
    # NOTE: only for fonts based on CFF outlines
    # see https://docs.microsoft.com/en-us/typography/opentype/spec/font-file#font-tables
	#  and for the CFF spec
	# http://wwwimages.adobe.com/www.adobe.com/content/dam/acom/en/devnet/font/pdfs/5176.CFF.pdf	       
    private method _ReadTable.CFF {} {
        set tabInfo [dict get $my(tables) "CFF "] ;# WARNING: CFF has a trailing space !!
		set my(CFF) [CFF::load $my(fd) [dict get $tabInfo -start] [dict get $tabInfo -length]]
	}

     # kern - Font kerning table  (OPTIONAL)
     #  see http://www.microsoft.com/typography/otspec/kern.htm
	 # LIMITATIONS:
	 #  * only kerning-tables "format 0" are supported.
	 #  * tables with "minimum" values (instead of kerning values) are skipped.
	 #  * tables with cross-stram (perpendicular) kerning are skipped. 
    private method _ReadTable.kern { } {
		set my(kerningSubTables) {}    
        if { ! [dict exists $my(tables) "kern"] } return
        set tabInfo [dict get $my(tables) "kern"]
        seek $my(fd) [dict get $tabInfo -start]
        set nBytes [dict get $tabInfo -length]
        binary scan [read $my(fd) 4] "SuSu" ver nTables
        for {set i 0} { $i < $nTables } {incr i} {
        	set startOfSubTable [tell $my(fd)]
        	        	
	        binary scan [read $my(fd) 6] "SuSuSu" \
                st_ver st_length st_coverage
             # parse st_coverage field ..
            set st_horizontal [expr {$st_coverage & 0x01}] 
            set st_minimum [expr {($st_coverage >> 1) & 0x01}] 
            set st_crossstream [expr {($st_coverage >> 2) & 0x01}] 
            set st_override [expr {($st_coverage >> 3) & 0x01}] 
			set st_format [expr {($st_coverage>>8) & 0xff}]


			switch -- $st_format {
			 0 { 
				set data [$this _KerningTable.Format_0]
			 }
			 default { 
				 # silently skip ..
			 }
			}

			lappend my(kerningSubTables) [dict create \
		    	-format $st_format \
				-orientation [expr {$st_horizontal ? "H" : "V"}] \
		    	-crossstream $st_crossstream \
		    	-hasminimum $st_minimum \
		    	-override $st_override \
		    	-data $data \
			]
			
			# goto to next table:
			seek $my(fd) [expr $startOfSubTable+$st_length]
		}
    } 

	 # returns a list of items.
	 # Each item is a list of 
	 #  ab (two 16bit index packed in a 32 bit value)
	 #  val (the kerning value for the ab pair.
	 # NOTE: we assume that the list is properly sorted by ab pairs.
	 #  See method "getKerning" used for extracting info from this data  
	private method _KerningTable.Format_0 {} {
		binary scan [read $my(fd) 8] "SuSuSuSu" \
        	nPairs searchRange entrySelector rangeShift
        for {set i 0} {$i<$nPairs} {incr i} {
            binary scan [read $my(fd) 6] "IuS" lrPair val
			# left and right glyphs (each 16 bit) stored as a packed 32 bit val
			lappend L [list $lrPair $val]	
		}
		return $L
	}
	
     # this is an unsupported method ...
     # Returns a list of subtables.
     #  Each subtable is a dictionary with 
	 #    "-format,-orientation,-hasminimum,-crossstream,-override,-data" keys.
	 #  The "-data" key holds the big data ...
	public method _getRawKerningTables {} {
		return $my(kerningSubTables)
	}   
	
	    
	 # Returns the kerning-value for the (a,b) pair (a,b are glyphIndex)
	 # Returns 0 if not found.
	 # By default, kerning is for horizontal ("H") data; use "V" for vertical kerning. 
	 # LIMITATIONS:
	 #  * only kerning-tables "format 0" are supported.
	 #  * tables with "minimum" values (instead of kerning values) are not suported.
	 #  * tables with cross-stram (perpendicular) kerning are not supported	   
	public method getKerning {a b {orientation "H"}} {
		set v 0
		foreach subtable $my(kerningSubTables) {
			dict with subtable {
				if { ${-orientation} ne $orientation }  continue
				 # if this table contains minimum values (instead of kerning values),
				 #  skip it
				if { ${-hasminimum} } continue
				 # currently crosstream (perpendicular kerning) is not supported
				 #  ? should I provide a 2d-vector instead of a single value ?
				if { ${-crossstream} } continue					
				if { ${-override} } { set v 0 }
				switch -- ${-format} {
				 0	{
				 	set ab [expr {($a<<16)|$b}]
					set res [lsearch -sorted -integer -index 0 -inline ${-data} $ab]
					set abVal [lindex $res 1]
					if {$abVal != {}} {
						set v [expr {$v+$abVal}]
					}					
				 }
				 default {
				 	# ignore ...
				 }
				}
			}			
		}	
		return $v
	}
  

    private common PublicProps {
        fontPath numGlyphs bbox unitsPerEm fontRevision
        ascender descender lineGap advanceWidthMax
        minLeftSideBearing minRightSideBearing xMaxExtent
        caretSlopeRise caretSlopeRun caretOffset
        metricDataFormat numberOfHMetrics    
    }  
    
     # [$obj get] returns all public properties
     # [$obj get $prop] returns the value of the $prop property 
     #   (even it is not public, unsupported)
     # If property does not exist, returns ""
    public method get { {prop {}} } {
        if { $prop == {} } {
             # remove blancs
            return [string trim [regsub -all {\s+} $PublicProps " "]]        
        }
        set res ""
        catch { set res $my($prop) }
        return $res
    }

	 # NOTE : pre 1.1.1 'lowercase' properties are DEPRECATED
	private common GPublicProps {
		advanceWidth chars leftSideBearing
	}

	 # returns properties related to a given glyph-index
	public method gget {gIdx {gprop {}} } {
        if { $gprop == {} } {
             # remove blancs
            return [string trim [regsub -all {\s+} $GPublicProps " "]]        
        }
         # still support lowercase gprop (DEPRECATED)
	    switch -- $gprop {
	      advancewidth -
	      advanceWidth -
		  leftsidebearing -
		  leftSideBearing {
	      	lassign [lindex $my(hmetrics) $gIdx] aw lsb
	      	return [expr {(($gprop eq "advancewidth") || ($gprop eq "advanceWidth")) ? $aw : $lsb}]
	      }      
	      chars {
	      	set L {}
		  	if { [info exists my(glyphToChar,$gIdx)] } {
				foreach unicode $my(glyphToChar,$gIdx) {
					lappend L [format %c $unicode]
				}			
			}
			return $L
		  } 	      
		}
	}
	
	
}


# =============================================================================
# =============================================================================
# =============================================================================


itcl::class Glyph {
    # --- standard new/destroy -------------------------------  

    proc new {args} {
        set class [namespace current]
         # object should be created in caller's namespace,
         # and fully qualified name should be returned
        uplevel 1 namespace which \[$class #auto $args\]                
    }

    method destroy {} {
        itcl::delete object $this
    }
    # --------------------------------------------------------
    
     # convert from 2.14 format (16 bits fixed-decimal format) to double
    private proc f2.14_to_double {x} {
        expr {$x / double(0x4000)}
    } 

     # CONSTANTS
     # ---------
      # Constants for Simple Glyphs
        private common REPEAT_BIT    0x08     
        private common ONCURVE_BIT   0x01        
        private common XSHORTVEC_BIT 0x02
        private common YSHORTVEC_BIT 0x04 
        private common XDUAL_BIT     0x10
        private common YDUAL_BIT     0x20
      # Constants for Composite Glyphs
        private common ARG_1_AND_2_ARE_WORDS  0x0001
        private common ARGS_ARE_XY_VALUES     0x0002
        private common WE_HAVE_A_SCALE        0x0008
        private common WE_HAVE_AN_X_AND_Y_SCALE  0x0040
        private common WE_HAVE_A_TWO_BY_TWO   0x0080
        private common MORE_COMPONENTS        0x0020
        private common WE_HAVE_INSTRUCTIONS   0x0100
                       
    private variable my ; # array used for collecting instance vars ..
    #                        index, bbox, instructions, points


     # NOTE: before creating a new glyph, the file-descriptor access postion 
     #   should be set at the beginning of the right 'index' of glyf-table
     # if idx is negative, then it's an empty glyph
    constructor { glyphs index hasGlyph } {
        set my(bcontours) {} ;# list of Bezier-contours
        set my(instructions) ""
        set my(bbox) {}
        set my(glyphs) $glyphs
        set fd [$glyphs get fd]
        set my(index) $index ; # just for introspection  
		if { [$glyphs get isCFF] } {
			set my(points) [CFF::getGlyphPoints $fd [$glyphs get CFF] $index]
# ? what about bbox ???
			return
		}
		if { ! $hasGlyph } {
			set nOfContours 0
			set my(bbox) {0 0 0 0}
		} else {      
        	binary scan [read $fd 10] "S S4" nOfContours my(bbox)
		}        
        if { $nOfContours >= 0 } {
            set my(points) [$this _SimpleGlyph $fd $nOfContours]
        } else {
            set my(points) [$this _CompositeGlyph $fd]       
        }
    }
    
    destructor {
        foreach bc $my(bcontours) {
            $bc destroy
        }
        catch { $my(glyphs) _forget $this }
    }
    
    
	 # return
     #   points       - a list of contours. A contour is a sequence
     #                      { x1 y1 isOn1  x2 y2 isOn2 ... }
     #side-effect: set 
     #   my(instructions) ...
    private method _SimpleGlyph {fd nOfContours} {
        set my(instructions) ""
        if { $nOfContours == 0 } { return {} }
        
        set nBytes [expr 2*$nOfContours]
        binary scan [read $fd $nBytes] "Su${nOfContours}" endPtsOfContours
        binary scan [read $fd 2] "Su" instructionLength
        set my(instructions) [read $fd $instructionLength]
         # The last end point index reveals the total number of points
        set count [lindex $endPtsOfContours end]
        incr count
        
         # Read the flags array : The flags are run-length encoded
        set flags {}
        for {set i 0} { $i < $count } { incr i } {
            binary scan [read $fd 1] "cu" c
            lappend flags $c
            if { $c &  $REPEAT_BIT } {
                binary scan [read $fd 1] "cu" repeats
                lappend flags {*}[lrepeat $repeats $c]
                incr i $repeats
            }
        }
         # ASSERT:  [llength $flags] == $count
        
        # -- read X coords
        #    The table is stored as relative values, but we'll store them as absolutes        
        # TODO : OPTIMIZE IT- read the whole vector, then parse it ..
        set x 0
        set X {}
        foreach flag $flags {
            if { $flag & $XDUAL_BIT } {
                set rx 0
                if { $flag & $XSHORTVEC_BIT } {
                    binary scan [read $fd 1] "cu" rx
                } 
            } else {
                if { $flag & $XSHORTVEC_BIT } {
                    binary scan [read $fd 1] "cu" rx
                    set rx [expr {-$rx}]                    
                } else {                
                    binary scan [read $fd 2] "S" rx                    
                }
            }
            incr x $rx
            lappend X $x
        }
        # -- read Y coords        
        set y 0
        set Y {}
        foreach flag $flags {
            if { $flag & $YDUAL_BIT } {
                set ry 0
                if { $flag & $YSHORTVEC_BIT } {
                    binary scan [read $fd 1] "cu" ry
                } 
            } else {
                if { $flag & $YSHORTVEC_BIT } {
                    binary scan [read $fd 1] "cu" ry
                    set ry [expr {-$ry}]                    
                } else {                
                    binary scan [read $fd 2] "S" ry                  
                }
            }
            incr y $ry
            lappend Y $y
        }

         # Finally, save X Y and flags in my(points)
         #  grouped by contours ...
        set i 0
        set contours {}
        foreach endPt $endPtsOfContours {
            set contour {}
            while { $i <= $endPt } {
                lappend contour [lindex $X $i] [lindex $Y $i] [expr [lindex $flags $i] & $ONCURVE_BIT]
                incr i
            }
            lappend contours $contour
        }
        return $contours
    }

	 # return
     #   points       - a list of contours. A contour is a sequence
     #                      { x1 y1 isOn1  x2 y2 isOn2 ... }
    private method _CompositeGlyph { fd } {           
         # first step: simply read and store the list of components (with flags, ...)
        set composite {}
        set flags $MORE_COMPONENTS ; # initial dummy value
        while { $flags & $MORE_COMPONENTS } {        
            binary scan [read $fd 4] "SuSu" flags glyphIndex            
            # Get the arguments as just their raw values
            if { $flags & $ARG_1_AND_2_ARE_WORDS } {
                binary scan [read $fd 4] "SS" argument1 argument2
            } else {
                binary scan [read $fd 2] "cucu" argument1 argument2
            }
            
            set xtranslate 0
            set ytranslate 0
            set point1 0
            set point2 0
            
            set xscale  1.0
            set yscale  1.0
            set scale01 0.0
            set scale10 0.0
                                                                                   
            # Assign the arguments according to the flags
            if { $flags & $ARGS_ARE_XY_VALUES } {
                set xtranslate $argument1
                set ytranslate $argument2
            } else {
                set point1 $argument1
                set pont2 $argument2
            }
            # Get the scale values (if any)
            if {$flags & $WE_HAVE_A_SCALE} {
                # WARNING: it's a 2.14 format ; convert it
                binary scan [read $fd 2] "Su" xscale
                set xscale [f2.14_to_double $xscale]
                set yscale $xscale
            } elseif { $flags & $WE_HAVE_AN_X_AND_Y_SCALE }  {
                binary scan [read $fd 2] "Su" xscale
                set xscale [f2.14_to_double $xscale]
                binary scan [read $fd 2] "Su" yscale
                set yscale [f2.14_to_double $yscale]
            } elseif { $flags & $WE_HAVE_A_TWO_BY_TWO } {
                binary scan [read $fd 2] "Su" xscale
                set xscale [f2.14_to_double $xscale]
                binary scan [read $fd 2] "Su" scale01
                set scale01 [f2.14_to_double $scale01]
                binary scan [read $fd 2] "Su" scale10
                set scale10 [f2.14_to_double $scale10]
                binary scan [read $fd 2] "Su" yscale
                set yscale [f2.14_to_double $yscale]
            }           
            lappend composite [list $glyphIndex $flags [expr $flags & $ARGS_ARE_XY_VALUES] \
               $xtranslate $ytranslate $point1 $point2 $xscale $yscale $scale01 $scale10]               
        }
         #Are there hinting intructions to read?     ( who cares ?)
        if { $flags  & $WE_HAVE_INSTRUCTIONS}  {
            binary scan [read $fd 2] "Su" nInstr
            set my(instructions) [read $fd $nInstr]
        }
        # --------------------------------------------
        # ... and now, ..... lets' glue all parts ...
        # --------------------------------------------
        set glyphsObj $my(glyphs)
        set newContours {}
        foreach comp $composite {
            lassign $comp glyphIdx flags isXYoffset xtranslate ytranslate point1 point2 xscale yscale scale01 scale10
            if { ! $isXYoffset } {
               error "Sorry, cannot handle weird composite-glyphs !"
            }            
            set contours [[$glyphsObj glyph $glyphIdx] get points]
            foreach contour $contours {
                set newContour {}
                foreach {x y isOnCurve} $contour {
                    set x1 [expr {round($x*$xscale + $y*$scale10) + $xtranslate}]
                    set y1 [expr {round($x*$scale01 + $y*$yscale) + $ytranslate}]
                    lappend newContour  $x1 $y1 $isOnCurve               
                }
                lappend newContours $newContour                
            }             
        }
        return $newContours
    }

 
    public method get { {what {}} }  {
        set validArgs {index bbox leftSideBearing advanceWidth chars points instructions pathLengths paths}    
        if { $what == {} } {
           return $validArgs
        }
        switch -- $what {
            paths {              
                if { ! [info exists my(paths)] } {
                    set my(paths) [$this _getSVGpaths]
                }
                return $my(paths)
            }            
            pathlengths -              
            pathLengths {              
                if { ! [info exists my(pathLengths)] } {
                    set my(pathLengths) [$this _getLengths]
                }
                return $my(pathLengths)
            }
			leftSideBearing -
			leftsidebearing -
			advanceWidth -
			advancewidth -
			chars
			{
				return [$my(glyphs) gget $my(index) $what]
			}          
            default {
                if { $what ni $validArgs } {
           			error "wrong arg \"$what\": must be [join $validArgs ", "]"
        		}
                 # get the cached value
                return $my($what)            
            }
        }
    }   



    # == auxiliary procs
    private proc midPoint { x0 y0 x1 y1 } {
        list [expr ($x0+$x1)/2.0] [expr ($y0+$y1)/2.0]
    }


     # returns a list of BContours ( a BContour is a sequence of Bezier Curves )   
    private proc _buildContoursTTF {gPoints} {
        set bcontours {}
        foreach contour $gPoints {
            set XYZ {}          
            foreach {x y isOnCurve} $contour {
                lappend XYZ [list $x $y $isOnCurve]
            }
 			lassign [lindex $XYZ 0] px0 py0 isOn0
			if { $isOn0 } {
            	set bcontour [BContour::new [list $px0 $py0]]			
			} else {
				lassign [lindex $XYZ end] pxN pyN isOnN
				if { $isOnN } {
					set bcontour [BContour::new [list $pxN $pyN]]
					 # rotate the points ..
					set XYZ [linsert $XYZ 0 [lindex $XYZ end]]
					 # this way, 0th point == last point (i.e. closed curve)
				} else {
					lassign [midPoint $pxN $pyN $px0 $py0] mpx mpy
    	        	set bcontour [BContour::new [list $mpx $mpy]]
				}						
			}			
             # close the XYZ contour by appending the first point
             # **ONLY** if contour is open !!
            lassign [lindex $XYZ 0] px0 py0 isOn0
            if { $x != $px0 || $y != $py0 } {
            	lappend XYZ [lindex $XYZ 0]
            }
        
            set i 0
            set nPoints [llength $XYZ]

            while { $i < $nPoints-1 } {
				lassign [lindex $XYZ $i] px0 py0 isOn0       
                incr i
				lassign [lindex $XYZ $i] px1 py1 isOn1

                if { $isOn0  &&  $isOn1 } {
                     # LINETO
                    $bcontour append [list $px1 $py1]
                    continue
                }
                if { !$isOn0 &&  !$isOn1 } { 
                    lassign [midPoint $px0 $py0 $px1 $py1] mpx mpy
                     # QUADTO
                    $bcontour append [list $px0 $py0] [list $mpx $mpy]
                    continue
                }
                if { !$isOn0 &&  $isOn1 } { 
                     #QUADTO
                    $bcontour append [list $px0 $py0] [list $px1 $py1]
                    continue
                }

                incr i        
				lassign [lindex $XYZ $i] px2 py2 isOn2
    
                if { $isOn0 &&  !$isOn1 && $isOn2 } { 
                     # QUADTO
                    $bcontour append [list $px1 $py1] [list $px2 $py2]
                    continue
                }
                if { $isOn0 &&  !$isOn1 && !$isOn2 } { 
                    lassign [midPoint $px1 $py1 $px2 $py2] mpx mpy
                     # QUADTO
                    $bcontour append [list $px1 $py1] [list $mpx $mpy]
                    continue
                }
                 # no other cases 
            }
            lappend bcontours $bcontour        
        }
        return $bcontours
    }

     # analogue to _buildContoursTTF, for CFF .
    private proc _buildContoursCFF {gPoints} {
        set bcontours {}
        foreach contour $gPoints {
            set XYZ {}          
            foreach {x y isOnCurve} $contour {
                lappend XYZ [list $x $y $isOnCurve]
            }
 
             # close the contour XYZ by appending the first point
             # **ONLY** if contour is open !!
            lassign [lindex $XYZ 0] px0 py0 isOn0
            if { $x != $px0 || $y != $py0 } {
            	lappend XYZ [lindex $XYZ 0]
            }
 
            set bcontour [BContour::new [list $px0 $py0]]			        
            set i 0
            set nPoints [llength $XYZ]

            while { $i < $nPoints-1 } {
				lassign [lindex $XYZ $i] px0 py0 isOn0       
                incr i
				lassign [lindex $XYZ $i] px1 py1 isOn1

                if { $isOn0  &&  $isOn1 } {
                     # LINETO
                    $bcontour append [list $px1 $py1]
                    continue
                } else {
					# its' a cubic
	                incr i        
					lassign [lindex $XYZ $i] px2 py2 isOn2
	                incr i        
					lassign [lindex $XYZ $i] px3 py3 isOn3
                     # CUBIC
                    $bcontour append [list $px1 $py1] [list $px2 $py2] [list $px3 $py3] 
                    continue
				}
                 # no other cases 
            }
            lappend bcontours $bcontour        
        }
        return $bcontours
    }


     # from { {x y} {x y} .... }
     #   to { x y x y ... }
    private proc _flatten { points } {
        set L {}
        foreach P $points {
            lappend L {*}$P
        }
        return $L
    }
	    
     # Returns a list of paths.
     # A path is a list of simple *abstract* commands for drawing lines and
     #  curves (likewise SVG notation).
     # commands are:
     #  MOVETO: M x y    - set the initial point)
     #  LINETO: L x y    - draw a line from current point to (x,y); 
     #                then (x,y) becomes the current point.
     #  QUADTO: Q x1 y1 x2 y2  
     #                - draw a quadratic Bezier curve 
     #                  from current point to (x1,y1) (x2,y2);
     #                  then (x2,y2) becomes the current point.
     #  CUBICTO: C x1 y1 x2 y2 x3 y3  
     #                - draw a cubic Bezier curve 
     #                  from current point to (x1,y1) (x2,y2) (x3,y3);
     #                  then (x3,y3) becomes the current point.
     #
    private method _getSVGpaths {} {
        set Paths {}
        foreach c [$this _getContours] {
        	set strokes [$c strokes]
        	 # warning; a contour may be empty !
        	if { [llength $strokes] == 0 }  continue
             # get first point of first stroke
            set startPoint [lindex [[$c stroke 0] points] 0]
            set Path {}
            lappend Path [list M {*}$startPoint] ; # MOVETO

            foreach stroke $strokes {
                 # remove the first point (it's equal to the lastof prev stroke)
                set points [lrange [$stroke points] 1 end]
                switch -- [$stroke degree] {
                    0 {
                       # .. ?? valid ??
                    }
                    1 {
                        lappend Path [list L {*}[_flatten $points]] ;# LINETO
                    }
                    2 {
                        lappend Path [list Q {*}[_flatten $points]] ;# QUADTO
                    }
                    3 {
                        lappend Path [list C {*}[_flatten $points]] ;# CUBICTO
                    }
                    default { error "only lines, quadratic and cubic bezier expected"}
                }            
            }
            lappend Paths $Path
        }
        return $Paths    
    }
    
	private method _getContours {} { 
        if { $my(bcontours) == {} } {
        	if { [$my(glyphs) get isCFF] } {
	            set my(bcontours) [_buildContoursCFF $my(points)]			
			} else {
	            set my(bcontours) [_buildContoursTTF $my(points)]			
			}
        }
        return $my(bcontours)    
    }


     # returns a list of N contours-lengths  - N is the number of contours -  
    private method _getLengths {} {
        set L {}
        foreach c [$this _getContours] {
            lappend L [$c length]
        }
        return $L
    }

     # return a list of N list-of-points  (N is the number of contours)
     #  where each point's value is at/tangent_at/normal_at
	 #  or vtangent_at/vnormal_at  (* in these latter 2 cases each returned
	 #  element is not a point; it's a segment (a list of two points))
    public method onUniformDistance { dL meth } {
        set L {}
        foreach c [$this _getContours] {
            lappend L [$c onUniformDistance $dL $meth]
        }
        return $L    
    }
}