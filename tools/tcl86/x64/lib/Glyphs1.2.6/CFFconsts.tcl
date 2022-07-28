# set some constants for CFF fonts

set CFF(TopDictMap) [ apply { {} {
		 # note: order is critical..
		 # map is just a list: the value for the key 'k' is the element at position k.
		 # the only exception is the element 12 (0x0C) ...   
		set map {}
		 # simple operators from 0 to 5
		lappend map   version notice fullName familyName weight fontBBox
	     # Codes from 6 to 11 are reserved ...
	    foreach code {6 7 8 9 10 11} {
			lappend map "---"
		}	
			 # prepare subcodes for codes 12 XX
			 # from 12 00 to 12 08
			set codes12XX {}
			lappend codes12XX \
				copyright isFixedPitch italicAngle underlinePosition \
				underlineThickness paintType charstringType	fontMatrix strokeWidth
			 # codes from 12 09 to 12 29 are not defined
			for {set code 9} {$code <=29} {incr code} {
				lappend codes12XX "---"
			}
			 # from12 30 to 12 38 (only if CIDFonts)
			lappend codes12XX \
				ros	cidFontVersion cidFontRevision cidFontType cidCount \
				uidBase fdArray fdSelect fontName
	
		lappend map $codes12XX
		lappend map \
			uniqueId xuid Charset Encoding CharStrings Private
		return $map
}}]	
		
		
	# skip - useless for CFF in OpenTypeFonts 		
if {0} {	
set CFF(StandardEncoding) {
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" "" "" "" 
	space exclam quotedbl numbersign dollar percent ampersand quoteright
	parenleft parenright asterisk plus comma hyphen period slash 
	zero one two three four five six seven eight nine
	colon semicolon less equal greater question at 
	A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
	bracketleft backslash bracketright asciicircum underscore quoteleft 
	a b c d e f g h i j k l m n o p q r s t u v w x y z 
	braceleft bar braceright asciitilde 
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" "" "" "" "" ""
	exclamdown cent sterling fraction yen florin section currency quotesingle
	quotedblleft guillemotleft guilsinglleft guilsinglright fi fl "" endash dagger
	daggerdbl periodcentered "" paragraph bullet quotesinglbase quotedblbase quotedblright
	guillemotright ellipsis perthousand "" questiondown "" grave acute circumflex tilde
	macron breve dotaccent dieresis "" ring cedilla "" hungarumlaut ogonek caron
	emdash 
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" 
	AE "" ordfeminine "" "" "" "" Lslash Oslash OE ordmasculine 
	"" "" "" "" "" ae "" "" "" dotlessi "" ""
	lslash oslash oe germandbls
}


set _ExpertEncoding {
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" "" "" "" 
	space exclamsmall Hungarumlautsmall "" dollaroldstyle dollarsuperior
	ampersandsmall Acutesmall parenleftsuperior parenrightsuperior twodotenleader onedotenleader
	comma hyphen period fraction zerooldstyle oneoldstyle twooldstyle threeoldstyle
	fouroldstyle fiveoldstyle sixoldstyle sevenoldstyle eightoldstyle nineoldstyle colon
	semicolon commasuperior threequartersemdash periodsuperior questionsmall "" asuperior
	bsuperior centsuperior dsuperior esuperior "" "" "" isuperior "" "" lsuperior msuperior
	nsuperior osuperior "" "" rsuperior ssuperior tsuperior "" ff fi fl ffi ffl
	parenleftinferior "" parenrightinferior Circumflexsmall hyphensuperior Gravesmall
	Asmall Bsmall Csmall Dsmall Esmall Fsmall Gsmall Hsmall Ismall Jsmall Ksmall
	Lsmall Msmall Nsmall Osmall Psmall Qsmall Rsmall Ssmall Tsmall Usmall Vsmall
	Wsmall Xsmall Ysmall Zsmall 
	colonmonetary onefitted rupiah Tildesmall 
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" ""
	"" "" "" "" "" "" "" "" "" "" "" "" "" ""
	exclamdownsmall centoldstyle Lslashsmall "" "" Scaronsmall Zcaronsmall Dieresissmall
	Brevesmall Caronsmall "" Dotaccentsmall "" "" Macronsmall "" "" figuredash hypheninferior
	"" "" Ogoneksmall Ringsmall Cedillasmall "" "" "" onequarter onehalf threequarters
	questiondownsmall oneeighth threeeighths fiveeighths seveneighths onethird twothirds ""
	"" zerosuperior onesuperior twosuperior threesuperior foursuperior fivesuperior
	sixsuperior sevensuperior eightsuperior ninesuperior zeroinferior oneinferior twoinferior
	threeinferior fourinferior fiveinferior sixinferior seveninferior eightinferior
	nineinferior centinferior dollarinferior periodinferior commainferior Agravesmall
	Aacutesmall Acircumflexsmall Atildesmall Adieresissmall Aringsmall AEsmall Ccedillasmall
	Egravesmall Eacutesmall Ecircumflexsmall Edieresissmall Igravesmall Iacutesmall
	Icircumflexsmall Idieresissmall Ethsmall Ntildesmall Ogravesmall Oacutesmall
	Ocircumflexsmall Otildesmall Odieresissmall OEsmall Oslashsmall Ugravesmall Uacutesmall
	Ucircumflexsmall Udieresissmall Yacutesmall Thornsmall Ydieresissmall
} 

}

  set CFF(StandardStrings) {
	    .notdef space exclam quotedbl numbersign dollar percent ampersand quoteright
	    parenleft parenright asterisk plus comma hyphen period slash zero one two
	    three four five six seven eight nine colon semicolon less equal greater
	    question at
		A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
		bracketleft backslash bracketright asciicircum underscore quoteleft 
		a b c d e f g h i j k l m n o p q r s t u v w x y z
		braceleft bar braceright asciitilde exclamdown cent sterling
	    fraction yen florin section currency quotesingle quotedblleft guillemotleft
	    guilsinglleft guilsinglright fi fl endash dagger daggerdbl periodcentered paragraph
	    bullet quotesinglbase quotedblbase quotedblright guillemotright ellipsis perthousand
	    questiondown grave acute circumflex tilde macron breve dotaccent dieresis ring
	    cedilla hungarumlaut ogonek caron emdash AE ordfeminine Lslash Oslash OE
	    ordmasculine ae dotlessi lslash oslash oe germandbls onesuperior logicalnot mu
	    trademark Eth onehalf plusminus Thorn onequarter divide brokenbar degree thorn
	    threequarters twosuperior registered minus eth multiply threesuperior copyright
	    Aacute Acircumflex Adieresis Agrave Aring Atilde Ccedilla Eacute Ecircumflex
	    Edieresis Egrave Iacute Icircumflex Idieresis Igrave Ntilde Oacute Ocircumflex
	    Odieresis Ograve Otilde Scaron Uacute Ucircumflex Udieresis Ugrave Yacute
	    Ydieresis Zcaron aacute acircumflex adieresis agrave aring atilde ccedilla eacute
	    ecircumflex edieresis egrave iacute icircumflex idieresis igrave ntilde oacute
	    ocircumflex odieresis ograve otilde scaron uacute ucircumflex udieresis ugrave
	    yacute ydieresis zcaron exclamsmall Hungarumlautsmall dollaroldstyle dollarsuperior
	    ampersandsmall Acutesmall parenleftsuperior parenrightsuperior twodotenleader onedotenleader
	    zerooldstyle oneoldstyle twooldstyle threeoldstyle fouroldstyle fiveoldstyle sixoldstyle
	    sevenoldstyle eightoldstyle nineoldstyle commasuperior threequartersemdash periodsuperior
	    questionsmall asuperior bsuperior centsuperior dsuperior esuperior isuperior lsuperior
	    msuperior nsuperior osuperior rsuperior ssuperior tsuperior ff ffi ffl
	    parenleftinferior parenrightinferior Circumflexsmall hyphensuperior Gravesmall Asmall
	    Bsmall Csmall Dsmall Esmall Fsmall Gsmall Hsmall Ismall Jsmall Ksmall Lsmall
	    Msmall Nsmall Osmall Psmall Qsmall Rsmall Ssmall Tsmall Usmall Vsmall Wsmall
	    Xsmall Ysmall Zsmall colonmonetary onefitted rupiah Tildesmall exclamdownsmall
	    centoldstyle Lslashsmall Scaronsmall Zcaronsmall Dieresissmall Brevesmall Caronsmall
	    Dotaccentsmall Macronsmall figuredash hypheninferior Ogoneksmall Ringsmall Cedillasmall
	    questiondownsmall oneeighth threeeighths fiveeighths seveneighths onethird twothirds
	    zerosuperior foursuperior fivesuperior sixsuperior sevensuperior eightsuperior ninesuperior
	    zeroinferior oneinferior twoinferior threeinferior fourinferior fiveinferior sixinferior
	    seveninferior eightinferior nineinferior centinferior dollarinferior periodinferior
	    commainferior Agravesmall Aacutesmall Acircumflexsmall Atildesmall Adieresissmall
	    Aringsmall AEsmall Ccedillasmall Egravesmall Eacutesmall Ecircumflexsmall Edieresissmall
	    Igravesmall Iacutesmall Icircumflexsmall Idieresissmall Ethsmall Ntildesmall Ogravesmall
	    Oacutesmall Ocircumflexsmall Otildesmall Odieresissmall OEsmall Oslashsmall Ugravesmall
	    Uacutesmall Ucircumflexsmall Udieresissmall Yacutesmall Thornsmall Ydieresissmall 
		"001.000" "001.001" "001.002" "001.003" 
		Black Bold Book Light Medium Regular Roman Semibold
	}


