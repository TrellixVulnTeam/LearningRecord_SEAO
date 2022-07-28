## timeline-demo
##  demo for zoom-canvas using just -zoommode x

 # Preamble:
 # these two lines are required for running this script
 # even if the required packages (zoom-canvas ...) are not installed 
 # under a directory listed in auto_path
set thisDir [file normalize [file dirname [info script]]]
set auto_path [linsert $auto_path 0 [file dirname $thisDir]]

 # Press <F1> for the developer's backdoor (Windows-only) ..
bind . <F1> { catch { console show } }

package require zoom-canvas

set WR_FIELDS {	Mark Competitor DOB Country Date}
set WR_DATE_LIMIT "2021-08-30" ;# time of these tables.

set WRDATA(200m,men) {
	{20.6h "Andy STANFIELD"   1927-12-29 USA 1951-05-26}
	{20.5h "Peter RADFORD"    1939-09-20 GBR 1960-05-28}
	{20.3h "Henry CARR"       1942-11-27 USA 1963-03-23}
	{20.2h "Henry CARR"       1942-11-27 USA 1964-04-04}
	{19.8h "Tommie SMITH"     1944-06-06 USA 1968-10-16}
	{19.72 "Pietro MENNEA"    1952-06-28 ITA 1979-09-12}
	{19.66 "Michael JOHNSON"  1967-09-13 USA 1996-06-23}
	{19.32 "Michael JOHNSON"  1967-09-13 USA 1996-08-01}
	{19.30 "Usain BOLT"       1986-08-21 JAM 2008-08-20}
	{19.19 "Usain BOLT"       1986-08-21 JAM 2009-08-20}
}

set WRDATA(100m,men) {
	{10.6h "Donald LIPPINCOTT" 1893-11-16 USA 1912-07-06}
	{10.4h "Charley PADDOCK"   1900-08-11 USA 1921-04-23}
	{10.3h "Percy WILLIAMS"    1908-05-19 CAN 1930-08-09}
	{10.2h "Jesse OWENS"       1913-09-12 USA 1936-06-20}
	{10.1h "Willie WILLIAMS"   1931-09-12 USA 1956-08-03}
	{10.0h "Armin HARY"        1937-03-22 FRG 1960-06-21}
	{9.9h  "Charlie GREENE"    1945-03-21 USA 1968-06-20}
	{9.95  "Jim HINES"         1946-09-10 USA 1968-10-14}
	{9.93  "Calvin SMITH"      1961-01-08 USA 1983-07-03}
	{9.92  "Carl LEWIS"        1961-07-01 USA 1988-09-24}
	{9.90  "Leroy BURRELL"     1967-02-21 USA 1991-06-14}
	{9.86  "Carl LEWIS"        1961-07-01 USA 1991-08-25}
	{9.85  "Leroy BURRELL"     1967-02-21 USA 1994-07-06}
	{9.84  "Donovan BAILEY"    1967-12-16 CAN 1996-07-27}
	{9.79  "Maurice GREENE"    1974-07-23 USA 1999-06-16}
	{9.77  "Asafa POWELL"      1982-11-23 JAM 2005-06-14}
	{9.74  "Asafa POWELL"      1982-11-23 JAM 2007-09-09}
	{9.72  "Usain BOLT"        1986-08-21 JAM 2008-05-31}
	{9.69  "Usain BOLT"        1986-08-21 JAM 2008-08-16}
	{9.58  "Usain BOLT"        1986-08-21 JAM 2009-08-16}
}

proc date {dateStr} {
	clock scan $dateStr -gmt 1
}

 # draw the year axis
proc yearAxis {zc year0 year1 y0 y1} {
	set color gray50
	$zc create line [date "${year0}-01-01"] $y0 [date "${year1}-01-01"] 0 \
		-fill $color
	for {set year $year0} {$year < $year1} {incr year 10} {
		set t [date "${year}-01-01"]
		$zc create line $t [expr {$y0-10}] $t $y1 -fill $color
		$zc create text $t [expr {$y0-40}] -text "$year" -anchor center -fill $color
	}
}

proc makeDict {Keys Values} {
	set D [dict create]
	foreach k $Keys v $Values {
		dict set D $k $v
	}
	return $D
}

proc WR_timeline {zc title Fields Data y} {
	set boxHeight 30
	set boxColor red
	set boxBorderThickness 5
	set boxBorderColor [$zc cget -background]

	 # rec and rec0 are dictionaries
	  
	set rec0 {} 
	foreach row $Data {
		set rec [makeDict $Fields $row]			

		set mark [dict get $rec Mark]
		set date [dict get $rec Date]
		$zc create point [date $date] $y -tag MARK
		$zc create text [date $date] [expr {$y-$boxHeight/2.0-5}] -text "$mark" \
			-anchor e -angle 90 -tag MARK
		
		if { $rec0 eq "" } {
			 # this is the 1st row ... save data and continue with the next row
			set rec0 $rec	

			$zc create text [date [dict get $rec0 Date]] $y -text "$title  " -anchor e
			continue
		}

	
		if { [dict get $rec Competitor] ne [dict get $rec0 Competitor] } {
			set date0 [dict get $rec0 Date]
			set date  [dict get $rec  Date]
			$zc create rectangle [date $date0] [expr {$y-$boxHeight/2.0}] [date $date] [expr {$y+$boxHeight/2.0}] \
				-width $boxBorderThickness \
				-fill $boxColor -outline $boxBorderColor
	        $zc create text [date $date0] [expr {$y+$boxHeight/2.0+5}] \
				-text "[dict get $rec0 Competitor]" -anchor w -angle 60
	
			set rec0 $rec
		}

	}
	 # last record .. draw a box from date0 to WR_DATE_LIMIT
	set date0 [dict get $rec0 Date]
	global WR_DATE_LIMIT
	$zc create rectangle [date $date0] [expr {$y-$boxHeight/2.0}] [date $WR_DATE_LIMIT] [expr {$y+$boxHeight/2.0}] \
		-width $boxBorderThickness \
		-fill $boxColor -outline $boxBorderColor
    $zc create text [date $date0] [expr {$y+$boxHeight/2.0+5}] \
		-text "[dict get $rec Competitor]" -anchor w -angle 60
	
	$zc create text [date $WR_DATE_LIMIT] $y -text "  ..." -anchor w
	
	$zc raise MARK
}

# ---------------------------------

set ZC [zoom-canvas .zc -zoommode x -yaxis up -background gray90]
	# bind ZoomCanvas <Button-1> { %W scan mark %x %y }
	# bind ZoomCanvas <B1-Motion> { %W scan dragto %x %y 1 }
	 # these bindings are best in this case; they don't scroll vertically
	bind ZoomCanvas <Button-1> { %W scan mark %x 0 }
	bind ZoomCanvas <B1-Motion> { %W scan dragto %x 0 1 }

	bind ZoomCanvas <MouseWheel> { %W rzoom %D [%W canvasx %x] [%W canvasy %y] }
	bind ZoomCanvas <Key-z> { %W zoomfit }
	 # NOTE: <Key> bindings requires focus
	focus $ZC

label .title -text {World Records in Athletics} -font {-weight bold -size 12}
label .info -justify left -text {
 * Press Mouse-Button-1 and drag the canvas
 * Use MouseWheel for zooming
 * Press key Z for Zoom Best Fit
}
pack .title -side top
pack .info -side bottom
pack $ZC -expand 1 -fill both

yearAxis $ZC 1900 2021 0 400
set Y 50
foreach name [array names WRDATA] {
	WR_timeline $ZC $name $WR_FIELDS $WRDATA($name) $Y
	incr Y 200
}

wm geometry . 1300x700

 # this is for keeping the scroll confined within that scrollregion 
$ZC configure -scrollregion [$ZC bbox all]

 # before doing zoomfit , be sure the zoom-canvas is displayed
tkwait visibility $ZC
$ZC zoomfit
$ZC zoomfit

