#==============================================================================
# Contains miscellaneous scaling-related utility procedures.
#
# Structure of the module:
#   - Namespace initialization
#   - Public utility procedures
#   - Private helper procedures
#
# Copyright (c) 2020-2022  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require scaleutil 1.6

#
# Namespace initialization
# ========================
#

namespace eval scaleutilmisc {
    #
    # Public variables:
    #
    variable version	1.3
    variable library
    if {$::tcl_version >= 8.4} {
	set library	[file dirname [file normalize [info script]]]
    } else {
	set library	[file dirname [info script]] ;# no "file normalize" yet
    }

    #
    # Public procedures:
    #
    namespace export	scaleBWidgetSpinBox scaleBWidgetComboBox \
			scaleIncrDateentry scaleIncrTimeentry \
			scaleIncrCombobox scaleOakleyComboboxArrow

    variable onX11
    if {[catch {tk windowingsystem} winSys] == 0} {
	set onX11 [expr {[string compare $winSys "x11"] == 0}]
    } else {
	set onX11 \
	    [expr {[string compare $::tcl_platform(platform) "unix"] == 0}]
    }
}

package provide scaleutilmisc $scaleutilmisc::version

#
# Public utility procedures
# =========================
#

#------------------------------------------------------------------------------
# scaleutilmisc::scaleBWidgetSpinBox
#
# Scales a BWidget SpinBox widget of the given path name.
#------------------------------------------------------------------------------
proc scaleutilmisc::scaleBWidgetSpinBox {w pct} {
    #
    # Scale the width of the two arrows, which is set to 11
    #
    set arrWidth [::scaleutil::scale 11 $pct]
    $w.arrup configure -width $arrWidth
    $w.arrdn configure -width $arrWidth
}

#------------------------------------------------------------------------------
# scaleutilmisc::scaleBWidgetComboBox
#
# Scales a BWidget ComboBox widget of the given path name.
#------------------------------------------------------------------------------
proc scaleutilmisc::scaleBWidgetComboBox {w pct} {
    #
    # Scale the width of the arrow, which is set to 11 or 15
    #
    variable onX11
    set defaultWidth [expr {$onX11 ? 11 : 15}]
    set width [::scaleutil::scale $defaultWidth $pct]
    $w.a configure -width $width

    #
    # Scale the width of the two scrollbars, which is set to 11 or 15
    #
    ComboBox::_create_popup $w
    if {![Widget::theme]} {
	bind $w.shell <Map> [format {
	    if {[string compare [winfo class %%W] "Toplevel"] == 0} {
		%%W.sw.vscroll configure -width %d
		%%W.sw.hscroll configure -width %d
	    }
	} $width $width]
    }
}

#------------------------------------------------------------------------------
# scaleutilmisc::scaleIncrDateentry
#
# Scales an [incr Widgets] dateentry of the given path name.
#------------------------------------------------------------------------------
proc scaleutilmisc::scaleIncrDateentry {w pct} {
    #
    # Scale the values of a few options
    #
    set btnFg [$w cget -buttonforeground]
    $w configure -icon [calendarImg $pct] -selectthickness 2p \
	-backwardimage [backwardImg $pct $btnFg] \
	-forwardimage  [forwardImg  $pct $btnFg]
    variable onX11
    if {$onX11 && $::tk_version >= 8.5} {
	set captionFontSize [font actual TkCaptionFont -size]
	set defaultFontSize [font actual TkDefaultFont -size]
	$w configure -titlefont [list Helvetica $captionFontSize bold] \
	    -dayfont [list Helvetica $defaultFontSize] \
	    -datefont [list Helvetica $defaultFontSize]\
	    -currentdatefont [list Helvetica $defaultFontSize bold]
    } else {
	$w configure -titlefont {Helvetica 11 bold} -dayfont {Helvetica 9} \
	    -datefont {Helvetica 9} -currentdatefont {Helvetica 9 bold}
    }
    set default [lindex [$w configure -height] 3]
    $w configure -height [::scaleutil::scale $default $pct]
    set default [lindex [$w configure -width] 3]
    $w configure -width [::scaleutil::scale $default $pct]
}

#------------------------------------------------------------------------------
# scaleutilmisc::scaleIncrTimeentry
#
# Scales an [incr Widgets] timeentry of the given path name.
#------------------------------------------------------------------------------
proc scaleutilmisc::scaleIncrTimeentry {w pct} {
    #
    # Scale the values of a few options
    #
    $w configure -icon [watchImg $pct]
    set default [lindex [$w configure -watchheight] 3]
    $w configure -watchheight [::scaleutil::scale $default $pct]
    set default [lindex [$w configure -watchwidth] 3]
    $w configure -watchwidth [::scaleutil::scale $default $pct]
}

#------------------------------------------------------------------------------
# scaleutilmisc::scaleIncrCombobox
#
# Scales an [incr Widgets] combobox of the given path name.
#------------------------------------------------------------------------------
proc scaleutilmisc::scaleIncrCombobox {w pct} {
    #
    # Scale the two arrows, as well as the value of the -listheight
    # option and that of the -sbwidth option of the list component
    #
    scaleIncrComboboxArrows $pct
    set default [lindex [$w configure -listheight] 3]
    $w configure -listheight [::scaleutil::scale $default $pct]
    set listComp [$w component list]
    set default [lindex [$listComp configure -sbwidth] 3]
    $listComp configure -sbwidth [::scaleutil::scale $default $pct]
}

#------------------------------------------------------------------------------
# scaleutilmisc::scaleOakleyComboboxArrow
#
# Scales the default arrow of the Oakley combobox widget.
#------------------------------------------------------------------------------
proc scaleutilmisc::scaleOakleyComboboxArrow pct {
    switch $pct {
	100 {
	    set data "
#define down_width 9
#define down_height 5
static unsigned char down_bits[] = {
   0xff, 0x01, 0xfe, 0x00, 0x7c, 0x00, 0x38, 0x00, 0x10, 0x00};
"
	}
	125 {
	    set data "
#define down_width 11
#define down_height 6
static unsigned char down_bits[] = {
   0xff, 0x07, 0xfe, 0x03, 0xfc, 0x01, 0xf8, 0x00, 0x70, 0x00, 0x20, 0x00};
"
	}
	150 {
	    set data "
#define down_width 13
#define down_height 7
static unsigned char down_bits[] = {
   0xff, 0x1f, 0xfe, 0x0f, 0xfc, 0x07, 0xf8, 0x03, 0xf0, 0x01, 0xe0, 0x00,
   0x40, 0x00};
"
	}
	175 {
	    set data "
#define down_width 15
#define down_height 8
static unsigned char down_bits[] = {
   0xff, 0x7f, 0xfe, 0x3f, 0xfc, 0x1f, 0xf8, 0x0f, 0xf0, 0x07, 0xe0, 0x03,
   0xc0, 0x01, 0x80, 0x00};
"
	}
	200 {
	    set data "
#define down_width 17
#define down_height 9
static unsigned char down_bits[] = {
   0xff, 0xff, 0x01, 0xfe, 0xff, 0x00, 0xfc, 0x7f, 0x00, 0xf8, 0x3f, 0x00,
   0xf0, 0x1f, 0x00, 0xe0, 0x0f, 0x00, 0xc0, 0x07, 0x00, 0x80, 0x03, 0x00,
   0x00, 0x01, 0x00};
"
	}
    }

    ::combobox::bimage configure -data $data
}

#
# Private helper procedures
# =========================
#

#------------------------------------------------------------------------------
# scaleutilmisc::calendarImg
#------------------------------------------------------------------------------
proc scaleutilmisc::calendarImg pct {
    variable calendarImg
    if {![info exists calendarImg]} {
	set calendarImg [image create photo scaleutilmisc_calendarImg]

	switch $pct {
	    100 {
		set data "
R0lGODlhFAAUAKUjAAAAAPVLPvVMP9p4cfFSRvVaT/VdUeR1bet3bra2ttGYlNOloeeinNfBv8PD
w8bGxszMzM3Nzc/Pz9HR0dPT09XV1dfX19jY2NnZ2dvb29zc3N3d3d/f3+Xe3eDg4OHh4eLi4uPj
4+Tk5P//////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAUABQAAAagwJ9w
SCwaj8iiIcBsOp+F4XM6lVKvASu2KlR4v+CwdyjKOBwVyflzhlzOFxHZkkhIHnVP3UGpU+RCInR2
eAl6CXx+gD8iIR4eIB+PIiIdIiCPIIuCdXd5CAIMfQl/c52FHgQBB6OlgRoPDxYTsR8LAw0YsRib
HBISGRa/IBIRFRu/G5uDnoZ7rcunec+KQ5IWFhwa2CHYGR7YHiFJ5OXmQQA7
"
	    }
	    125 {
		set data "
R0lGODlhGQAZAKUtAAAAAPVLPvRLP/VMP9tfVvFTR/FgVel4b/drYfdrYvdsYfBzaba2tri4uLm5
uby8vL+/v9iYk8Kwr8O7uuerp+jAvcPDw8bGxsfHx8rKys3Nzc/Pz9jCwdDQ0NHR0dLS0tPT09TU
1NjY2NnZ2dvb29zc3N7e3uTb2uDg4OHh4eLi4uPj4+Tk5P//////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAZABkAAAbowJ9w
SCwaj8ikcrlMKJ7QqDSKIA4C2Kx2qx0QueDwN0zOjstkImHNbrvfxE+nQfdg6JAPhI7x0BsdH0Qs
KAyGKh6GFiwWhh4qhgwoLIOFh4kMi40Mj5GTgyoaoiskoiEsIaIkK6IaKpRDLLKztLW2lQ65KyC5
FywVBgsnK7kOn7GWDIiKLAdYFJCGx0KEkcuZLBECBRzRkrDUpCQkhOMmLCMSEyks46vgPywrIvSE
9CUsJfST9CIr8NUuMdvUSRrAZNc0OfI2LR6KBxBXhICIgQUGiCFWQHzQMMOGjyBDigyZgYnJkyaD
AAA7
"
	    }
	    150 {
		set data "
R0lGODlhHgAeAKUsAAAAAPVLPvVMP9l7dOxcUfROQfRYTPZjWPVpXuuBeba2tre3t8iIhNGHgtyN
h8Wvre2YkcHBwcXFxcfHx8nJyc3Nzc7OztHOztDQ0NPT09TU1NXV1dbW1tfX19jY2Nra2tvb29zc
3N3d3d/f3+fGw+Xb2+Dg4OHh4eLi4uPj4+Xh4eTk5P//////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAeAB4AAAb+wJ9w
SCwaj8ikcslsOp9CxGFKrVqvVASxEOh6v+Cwt0AUm8/dMnr9VbPZ7jeayKjb7/g8ntjpVBaAFB0R
gAsbG4URHRSFFX1EKyscCpQYKxKUCicnmRIrGJkckZCSmZaYlJudn6GjQ5GTlZeZqpSeoJSiK6SR
vb6/wL6kKCPFJysmxSO9JSqRJ8oorkKwprOpKxACBiSsudM/1bKomipcAQneCrqksQqntCkEXQ7q
7K8rIBP7HZ/7E9IeDGhwYUWHfyDABQtmwkKGhbvwiahA8cMKDRQroECRUcOKDxlFKCw1jhYnW/ZG
uoOX6qSCW60iUiP57pomlzC/yfwRApkZh5/LQvz0kCLF0J4jhppYIQKK06dQowoJAgA7
"
	    }
	    175 {
		set data "
R0lGODlhIwAjAKUuAAAAAPVIPuFXS/JORPBURPVQQPVaT/dbUPBsX+VwaO55cOx+d/ltY+GIfrW3
tLi6t7q8uby+u7/CvsmXl8iyr8i8vNKmpNS+u+ecksXHxMfJxsrMycvOys3QzNHT0NPV0tTW09XX
1NbZ1dfa1tjb19vd2tze293f3N7g3eTe3enT0ODj3+Hk4OLl4f//////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAjACMAAAb+wJ9w
SCwaj8ikcslsOp9QJGNKrVqv16OhwO16v2DwwRgom8/otDpAXrvf7CJ8nm7T7/b73Cjo+/+AgYIC
Rh6Gh4iJioseRi2PHhCSES0bkhAZLRmXGy0Rlx6PLY6PHQ6nDy0apw4SLRKsGi0PrB2ipC2mqKqs
rrCnsrSnto+4ug6pq6e+sbO1t0WiJBzUtiHUHKEe2CG52CTQRKIsK+UrLeTm46LmKyzhQ6LHyb0t
KggBCinOw/BC8qzoLWuxwAwGfg6IjYpWKiCvgQnMNECo0JhDZa1aWBgQgMAFiv5+iDrxoSSIFiRK
fhDRAgWFCRXOgVB5IqQoFCRygsOZ00RZCxMkRpBAgVIn0WIMc12s98tBsGdIxTXchZEZMJBR401F
9jBj06f9sv7bKtBrM2EJQ55rWaKtTxRtS9Q8EZeoibqPVhzJoKGv37+AA//NEKWw4cOIEysmEgQA
Ow==
"
	    }
	    200 {
		set data "
R0lGODlhKAAoAKUsAAAAAOZGOuZIO/VLPvVMP911be9aT/VMQPROQfNXS/BcUORoX+hoXvdoXet2
bvdrYNODfba2tr6+vseFgMeMiMuWkdaVkOufmem6tsbGxsvEw8vLy83Nzc/Pz9XV1dfX19vb29zc
3N3d3d7e3t/f3+fIxefOzOLR0OXa2eXd3OHh4eTk5P//////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAoACgAAAb+wJ9w
SCwaj8ikcslsOp/QqHTqfDSu2Kx2y70+jgbCYEwum8/oMUFhFKTfcLPAGIjb3wH6fW/OF+t8gX5E
gIF7g0OFhnaIQhQTkJGSk5SVkhRGIJqbnJ2en55GK6MrHBGnERwrEqgRISGtEqWtqqSipKaoqqyo
r7GzuqQrt6O5p7utvqiyxqnCxMDHq8mwy9HOtkXCzci91afMtM/awuXm5+jZRMIiHu4eIisf7x4q
oyYYKKPt7/HqQ9vE8ToVYsWFAwMSlLhWaxQ0btN6pUBAxgHDcetwCUx2ogyDi/+EBAw20JWKBWQs
gHRIbpSHDDAzeFixIWYGEis0QChQ4cNgipcxZ4b8ka7ohw4Fiw5r+dPmzJoxSZCwuaFpUIwANZKk
9gvi0JHSSioDt3JpxmIbvXUV91VrWK7WvLIkYm8fvXjz3qlQQc8nP3f+Vqg4ElipYWEjqChezLix
48eQoQQBADs=
"
	    }
	}
	scaleutilmisc_calendarImg put $data
    }

    return $calendarImg
}

#------------------------------------------------------------------------------
# scaleutilmisc::backwardImg
#------------------------------------------------------------------------------
proc scaleutilmisc::backwardImg {pct fg} {
    variable backwardImg
    if {![info exists backwardImg]} {
	set backwardImg [image create bitmap scaleutilmisc_backwardImg]

	switch $pct {
	    100 {
		set data "
#define backward_width 16
#define backward_height 16
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x30, 0xe0, 0x38, 0xf0, 0x3c,
   0xf8, 0x3e, 0xfc, 0x3f, 0xfc, 0x3f, 0xf8, 0x3e, 0xf0, 0x3c, 0xe0, 0x38,
   0xc0, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    125 {
		set data "
#define backward_width 20
#define backward_height 20
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x03,
   0x80, 0x83, 0x03, 0xc0, 0xc3, 0x03, 0xe0, 0xe3, 0x03, 0xf0, 0xf3, 0x03,
   0xf8, 0xfb, 0x03, 0xfc, 0xff, 0x03, 0xfc, 0xff, 0x03, 0xf8, 0xfb, 0x03,
   0xf0, 0xf3, 0x03, 0xe0, 0xe3, 0x03, 0xc0, 0xc3, 0x03, 0x80, 0x83, 0x03,
   0x00, 0x03, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    150 {
		set data "
#define backward_width 24
#define backward_height 24
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x0c, 0x18, 0x00, 0x0e, 0x1c, 0x00, 0x0f, 0x1e, 0x80, 0x0f, 0x1f,
   0xc0, 0x8f, 0x1f, 0xe0, 0xcf, 0x1f, 0xf0, 0xef, 0x1f, 0xf8, 0xff, 0x1f,
   0xf8, 0xff, 0x1f, 0xf0, 0xef, 0x1f, 0xe0, 0xcf, 0x1f, 0xc0, 0x8f, 0x1f,
   0x80, 0x0f, 0x1f, 0x00, 0x0f, 0x1e, 0x00, 0x0e, 0x1c, 0x00, 0x0c, 0x18,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    175 {
		set data "
#define backward_width 28
#define backward_height 28
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x80, 0x01, 0x00, 0x38, 0xc0, 0x01,
   0x00, 0x3c, 0xe0, 0x01, 0x00, 0x3e, 0xf0, 0x01, 0x00, 0x3f, 0xf8, 0x01,
   0x80, 0x3f, 0xfc, 0x01, 0xc0, 0x3f, 0xfe, 0x01, 0xe0, 0x3f, 0xff, 0x01,
   0xf0, 0xbf, 0xff, 0x01, 0xf8, 0xff, 0xff, 0x01, 0xf8, 0xff, 0xff, 0x01,
   0xf0, 0xbf, 0xff, 0x01, 0xe0, 0x3f, 0xff, 0x01, 0xc0, 0x3f, 0xfe, 0x01,
   0x80, 0x3f, 0xfc, 0x01, 0x00, 0x3f, 0xf8, 0x01, 0x00, 0x3e, 0xf0, 0x01,
   0x00, 0x3c, 0xe0, 0x01, 0x00, 0x38, 0xc0, 0x01, 0x00, 0x30, 0x80, 0x01,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    }
	    200 {
		set data "
#define backward_width 32
#define backward_height 32
static unsigned char backward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0x00, 0x0e,
   0x00, 0xf0, 0x00, 0x0f, 0x00, 0xf8, 0x80, 0x0f, 0x00, 0xfc, 0xc0, 0x0f,
   0x00, 0xfe, 0xe0, 0x0f, 0x00, 0xff, 0xf0, 0x0f, 0x80, 0xff, 0xf8, 0x0f,
   0xc0, 0xff, 0xfc, 0x0f, 0xe0, 0xff, 0xfe, 0x0f, 0xf0, 0xff, 0xff, 0x0f,
   0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f,
   0xe0, 0xff, 0xfe, 0x0f, 0xc0, 0xff, 0xfc, 0x0f, 0x80, 0xff, 0xf8, 0x0f,
   0x00, 0xff, 0xf0, 0x0f, 0x00, 0xfe, 0xe0, 0x0f, 0x00, 0xfc, 0xc0, 0x0f,
   0x00, 0xf8, 0x80, 0x0f, 0x00, 0xf0, 0x00, 0x0f, 0x00, 0xe0, 0x00, 0x0e,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	}
	scaleutilmisc_backwardImg configure -data $data -foreground $fg
    }

    return $backwardImg
}

#------------------------------------------------------------------------------
# scaleutilmisc::forwardImg
#------------------------------------------------------------------------------
proc scaleutilmisc::forwardImg {pct fg} {
    variable forwardImg
    if {![info exists forwardImg]} {
	set forwardImg [image create bitmap scaleutilmisc_forwardImg]

	switch $pct {
	    100 {
		set data "
#define forward_width 16
#define forward_height 16
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x03, 0x1c, 0x07, 0x3c, 0x0f,
   0x7c, 0x1f, 0xfc, 0x3f, 0xfc, 0x3f, 0x7c, 0x1f, 0x3c, 0x0f, 0x1c, 0x07,
   0x0c, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    125 {
		set data "
#define forward_width 20
#define forward_height 20
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x0c, 0x00,
   0x1c, 0x1c, 0x00, 0x3c, 0x3c, 0x00, 0x7c, 0x7c, 0x00, 0xfc, 0xfc, 0x00,
   0xfc, 0xfd, 0x01, 0xfc, 0xff, 0x03, 0xfc, 0xff, 0x03, 0xfc, 0xfd, 0x01,
   0xfc, 0xfc, 0x00, 0x7c, 0x7c, 0x00, 0x3c, 0x3c, 0x00, 0x1c, 0x1c, 0x00,
   0x0c, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    150 {
		set data "
#define forward_width 24
#define forward_height 24
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x18, 0x30, 0x00, 0x38, 0x70, 0x00, 0x78, 0xf0, 0x00, 0xf8, 0xf0, 0x01,
   0xf8, 0xf1, 0x03, 0xf8, 0xf3, 0x07, 0xf8, 0xf7, 0x0f, 0xf8, 0xff, 0x1f,
   0xf8, 0xff, 0x1f, 0xf8, 0xf7, 0x0f, 0xf8, 0xf3, 0x07, 0xf8, 0xf1, 0x03,
   0xf8, 0xf0, 0x01, 0x78, 0xf0, 0x00, 0x38, 0x70, 0x00, 0x18, 0x30, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	    175 {
		set data "
#define forward_width 28
#define forward_height 28
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x18, 0xc0, 0x00, 0x00, 0x38, 0xc0, 0x01, 0x00,
   0x78, 0xc0, 0x03, 0x00, 0xf8, 0xc0, 0x07, 0x00, 0xf8, 0xc1, 0x0f, 0x00,
   0xf8, 0xc3, 0x1f, 0x00, 0xf8, 0xc7, 0x3f, 0x00, 0xf8, 0xcf, 0x7f, 0x00,
   0xf8, 0xdf, 0xff, 0x00, 0xf8, 0xff, 0xff, 0x01, 0xf8, 0xff, 0xff, 0x01,
   0xf8, 0xdf, 0xff, 0x00, 0xf8, 0xcf, 0x7f, 0x00, 0xf8, 0xc7, 0x3f, 0x00,
   0xf8, 0xc3, 0x1f, 0x00, 0xf8, 0xc1, 0x0f, 0x00, 0xf8, 0xc0, 0x07, 0x00,
   0x78, 0xc0, 0x03, 0x00, 0x38, 0xc0, 0x01, 0x00, 0x18, 0xc0, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    }
	    200 {
		set data "
#define forward_width 32
#define forward_height 32
static unsigned char forward_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x07, 0x00,
   0xf0, 0x00, 0x0f, 0x00, 0xf0, 0x01, 0x1f, 0x00, 0xf0, 0x03, 0x3f, 0x00,
   0xf0, 0x07, 0x7f, 0x00, 0xf0, 0x0f, 0xff, 0x00, 0xf0, 0x1f, 0xff, 0x01,
   0xf0, 0x3f, 0xff, 0x03, 0xf0, 0x7f, 0xff, 0x07, 0xf0, 0xff, 0xff, 0x0f,
   0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f, 0xf0, 0xff, 0xff, 0x0f,
   0xf0, 0x7f, 0xff, 0x07, 0xf0, 0x3f, 0xff, 0x03, 0xf0, 0x1f, 0xff, 0x01,
   0xf0, 0x0f, 0xff, 0x00, 0xf0, 0x07, 0x7f, 0x00, 0xf0, 0x03, 0x3f, 0x00,
   0xf0, 0x01, 0x1f, 0x00, 0xf0, 0x00, 0x0f, 0x00, 0x70, 0x00, 0x07, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	}
	scaleutilmisc_forwardImg configure -data $data -foreground $fg
    }

    return $forwardImg
}

#------------------------------------------------------------------------------
# scaleutilmisc::watchImg
#------------------------------------------------------------------------------
proc scaleutilmisc::watchImg pct {
    variable watchImg
    if {![info exists watchImg]} {
	set watchImg [image create photo scaleutilmisc_watchImg]

	switch $pct {
	    100 {
		set data "
R0lGODlhFAAUAMZAADU2NDc7PTs9OkA9QTs/QT9BPkBERkVDRkRISkdJRklNT05MUExOS1BOUVBU
VlVZW1lbWFpeYF5hXmBkZmNlYmlmamNoamtpbWhsbmptampucG1xc29xbnN1cnZ6fHh8f4KEgYKG
icR2dYmLiIuPko6QjZSQjpeZlt6cm/yVlrS2s7q8ufmvsL7BvsPFwsfKxsvNys7QzdHT0NPV0trc
2fbZ1+Hj4OTn4+fq5urs6e7w7fHz8PP28vb59fn7+Pv9+v//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAUABQAAAf+gECCg4SFhocSGRkSh4YOGhsaGBiQGg6NQBIbGCAqLi4qIRgbEYcQ
Gh4uNDYtNjY0Lh4aEIUNFx4xNjc4Mji+Ni8fGAyEEhovuzg5y8sjMy8apYMTIzbKKjrZOiUyOTYj
E4MKFis42S8nOzvcOzU4LRULggoYMObqMCcmKCkpLDoyMigQhKBeixk7ePA4IaJGjx6wAiYQZGBC
ixwJH/rY6OPhDhcUDgx6QOJGxh4+fqjsiKPEA0IJOMTQwUNjyo07ZmxAQGjAAxA0aPaYsbHHDhog
HhQoNEACiBjmVqjjBWICgUMCHnQo4ULGDBclOjwIgAmAgQcWOHCg8MAAAEwLhAIIEEAWrl1DgQAA
Ow==
"
	    }
	    125 {
		set data "
R0lGODlhGQAZAMZAADI0Mjk2OjY4NjU5Ozw+PDxAQkRHSkdJRktITGdDQUlNT0tNS1BOUVBUVlZT
V1xZXVlbWFhdX1xgYl5gXWRhZWFlZ2NmY29tcWtvcW1vbG9zdnp4fHd6d3Z6fIB+gn2AfXyAguFn
aIOFiIaJhY2QjY6SlZOVkvp+faGcm/iKiKeppq2vrLS2s/mko7q8ub/Cv8THw8jKx8zOy9HU0PfJ
x9rd2d/h3uTm4+jq5/bp6ezu6+/y7vL08fb49fn7+Pv++///////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAZABkAAAf+gECCg4SFhoeIiYqDCxAZHR8dGRALi4wVIh4YFRIVGCAiEpWKCxsd
DiIqLqsqIg8bG6OHCB0VHS4xNTW5uy61HbKEBxoVJDA1Nzg3LjjKNTAlngeGEBccMTbNzTPaOCQx
HxoNhQeTLtk4OurrOtc2LhAY04wWI9w6NiY7+/vXOzgzRsgj1IDCChvqdrAgwc/fvhsrKowb1ADC
ixs6+LkgwWNEDBopTrTAESPCREEVY8hYEWMHDx4uEoQQmWMGCxkxJpwEogACjBv7ePTocQPFDh8+
hvbQEQOCAkIGJqwA+nIo0qtIibKQME9QgQj2XFpF+qMs0h01RkQoQIhAxYtxO8b6MJtUBwwIDggU
KjDhgwwccYfOuNpjx4wPE9gWGqBAgom/LnesSPpvhgkJCgYcCsCAwocXM5LJ0HFjxgvEDQQkEhB1
wogVMGLAWDFiggQEmhUBGMAggoUJwC2YHADAkiAAAQgYWE5AQHHj0KNHDwQAOw==
"
	    }
	    150 {
		set data "
R0lGODlhHgAeAMZAADM1MzI2ODY4NTk7OTs8Pz5APT9DRUNFQ0VISklLSElNT05MUE1PTFBST09T
VVRSVrA6PFNXWVVXVFhcX1pcWV5cX15iZGRiZmNlYmhrbmttanF2eHV2c3t5fXd8foGEh/xpaYmN
j4uNipSSlvp2c5GWmJeZlsSSkpqeoZyem/iEhaCin6mrqK6wrfqeoLO1srm7uL2/vPazscTHxMjK
x87QzdPV0tzf2+Dj3/ji4uXo5Onr6O3w7fL18fb49fn8+P//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAeAB4AAAf+gECCg4SFhoeIiYqLhQyOEREMCgyMiAwYHSMlISElIx4WCZWDCRYh
HRkIDxYWDwoZHx8ToowJG7IWJS8wMTEwLyYXFh8ZtIm2GwomMDQ2NzQ3NzY0MCkOHRvGhgkZHBEs
0Dg6Oi3jOjjPLREdF9qEEhwLLTU35jstO/k7OjcxLQ8eIhxK4A0FDXH6EubTgYEZigkbDhiKkAFD
jHoKeWjksUMDjB04YmDI0KDQgQsVTNTQkS+GiI0bPWrUYSMFK4mDDmRYAOPGjo0mRPQY2kPDC6I8
bsBYkAGnoJMSZuDYODToUKM9crgAIUPHDIpOgRxgRUOHRqI9gnY4oQIECRn3O3rsoIHhggFCYzHQ
qMGChY6hPnwwgOAiR+AeLVjUoFshbIEJEWaYJRrYx7gfmH8cnjthQgFCBSI0gDEVcODMqDX30BGj
QYXPgwgooJDCRtwep1Nn9tHDxgoKCmAPMkABg2TTujPLpTvhbqEBDiakWIn7dI/UPnj4nuBgwKEC
FSS8sF3dRwrUPbS/kDCBAKIBCCZQmDc57eHVNl5QmIDAOyIBC1QQAQoz2CBODfngMM0KEUywgACL
CIBABcUtQ8OF1KSAAQUVIAAhIwIM8AAFFkhQ3IYmckfAh6OEqEoFME7wAAIrjmIIAAIIEECOAgBg
449ABllIIAA7
"
	    }
	    175 {
		set data "
R0lGODlhIwAjAMZAADM1MjM1Nzc7PTk7OD0/Qj9BPlRAPkRGQ0RGSUhMTk5MUExOS09SVFFTUFJW
WFlWWldZVlZaXF9cYFpeYV1fXF5iZGFjYMxERmViZmJmaWlraGlsb3FzdvpOTnV3dHl+gH99gf1e
YIKFh42QjZaZlfp9fZebnqGjoairqc6joK2wrfigoLW3tPimpLy/u8TGw8jKx/bBwc3PzNPV0vLO
z9ja19zf2+Di3+Tn5PXl5ujq5+zu6+/y7vL08fX49Pn8+P//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAjACMAAAf+gECCg4SFhoeIiYqLjIYLjwyPC42MCxAcICKamiAbEZOUhQsRHyAc
ExASERIQE5gfE6ChCx4fFhGkJCcoJyQfuBmmDaENH54VJy4vMjPNMi8uJ6obHw6NxRkOJC4yNTY2
Mi433zXhJg8ZHwyLCRwZECgw3jc4OjMuOvk3NzUwKBAVOMgydGADBgcoZNi4kS9fDXwNdeAAhwLd
hgOIGHCAYALGwoggI3qwAYNEBA7DCGKokOFFjXoNd8icOdPCCR02XlSogAGjqA0TUMxgqIOmUZkW
SMjEMQPFhA0DBUHAMOGFjXwyR4yQyaMrjx0aSHzdgfNFhGyFDlSY8AHGDaP+HkZ47Rp27g4cMj5Q
kOBTkNoJJmbgmOk1bmG5PHrEKEFDRw0SEyr0BVIAgwQUNYrOTRy3R9wcK0J0KBGjxw4bKCxgKEDo
gIQKLGawYOHCa48ePjwYuNAhRIscPnrAcKGiBosKEhAQKjDhcrkaNxLf9uFDhYEU1LP7sFEDeuoJ
rAcVcDDhRGbbuLP/WL9eu2kbJyg8CC+oAIMJImTo6DpdPfv/1Jk2gwgUMECfIAhIYIFbO0jn338A
8qCDDBRUoFwhBChY3H7pUQchhD7wYIMKFURAgCEDJFCBBgwm9uCHIU6oQQUGHlJABMgItkOHPnz4
Q4wznGCBBAcSkmIFFKiSoKOL27nQ448xGldhAgMkMgADSMb2lnQzqJDdV/awYEEFClSpyAAO7NTR
S0U1NRZOMpywkwMCNCIAlhZooAIMMyzk5wwyqKDBmArUSckACKxigQUinKACCyqcIMKiyCFgZigA
pPgaBRRkYEEGFZZYaAChFAJAAAQo4EAED0TggAIEAABAqYnIeqqttOaq666KBAIAOw==
"
	    }
	    200 {
		set data "
R0lGODlhKAAoAMZAAC4wLTQ2Mzg6ODg7PageGz5APj1AQkVHREVJS0xKTkpOUUxOS09TVlFTUFZU
WFpXW1dZVlZaXFxeXFtfYv4xMWJfY2FjYWFlZ2hman5kZGhsbf1CQG5scG1xdHByb3Z4df5SUHV5
e316fnt/gn1/fICEh4KEgfxhYIqLio+SkPp2c5udmvmVlLG0svijorq9usHEwfe4uMfKx9DTz9ja
197g3fPd2fvd3OPm4ufp5vHs6uvu6u/x7vH08PX39Pn7+P//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////yH5
BAEKAEAALAAAAAAoACgAAAf+gECCg4SFhoeIiYqLjI2ICwuOkoQLDRYdISIiIR4XDQmTigsYIygj
IhwaGhwhpSMXkaGECRclIhoREQwKvAoMERIaIiawskALrRcPChopLS/QLy0pGgoRF6exkg0kHBEJ
JS0wMjPl5jIwLSUJEB0jDdsiF9fiMzQ0NTUr+TX3M+kVHmggAY+Rgg8YHoR4YS8fDhw5VuTI8RBH
vxkvQkTAEEIbIgSrIixsCHFixJImLWLUuOqAoggdJlhgWAOlSRomc+Ig9+LChA4REh3ocIFBixk1
Te5YyrTpjhwQ9s1oweBCB5eHGGiAUEIGDYhOwzKVgGKHRRklImhgcOjAhaL+NHMwrSGWqQUSTHHQ
eMGgQgWshA5gkNDBK46mElIs5cGY8Y67jp/WkNEhGOBBCuatQCq3KYQUPUKLviu6Bw+zM1ZIKFao
L4QWX5ky7rHjc2kPJErbcKEjx95rbFtXYAAD5+LSPGz38PDBh44YKjZsYKFjx2QIwwsdcDAPRg25
PEqL/vwhg4sTFE7E0OEjtHUZEYYbCEyL+AwUKVLgEO2jfw8ABIDAwg399ZcDfinQAF8FHgmCQAUR
eJdDePwVuIMJJPygoYYFtvdefAgY8qAEsMlVYYEbprihf9a9IMEElwliQAQTbHZYaB36oOKOP3hI
wwoTRDBfIQU8MIEHMtD6hSOKPKrYHg4zeBBkAYYYoECQL+C0ZH9NOmkdDPEpQGWVwKCQ5A49dNjl
ij3kcJ8EQiJSQFURZGmimmvSVsMLNDIw5iEzTqCBhGiqWcOOHk6mgQVxJiJAAhVMYEKSdxaY4YqJ
ymDCBBMgIMAiAvQlwaSxUegDCQW655sMJEgw3KeMDNBXBRrQBNaFTan0ggYTvCpJqJGSNQ5S/ORD
wz8oSGDBBAwMEMqjNE4gwQcrvCDDtTK8sMIHygaZAKyhBCArjRaUK8G5yi4LYbMBGDOIuAg8EF+k
vQb5AAIDtOtuIQEEIIABCCSQAAIF5KvvvooAAADCDDfscCGBAAA7
"
	    }
	}
	scaleutilmisc_watchImg put $data
    }

    return $watchImg
}

#------------------------------------------------------------------------------
# scaleutilmisc::scaleIncrComboboxArrows
#------------------------------------------------------------------------------
proc scaleutilmisc::scaleIncrComboboxArrows pct {
    switch $pct {
	100 {
	    downarrow configure -data "
#define down_width 16
#define down_height 16
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0xfc, 0x7f, 0xf8, 0x3f, 0xf0, 0x1f, 0xe0, 0x0f, 0xc0, 0x07, 0x80, 0x03,
   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 16
#define up_height 16
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xc0, 0x01, 0xe0, 0x03,
   0xf0, 0x07, 0xf8, 0x0f, 0xfc, 0x1f, 0xfe, 0x3f, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}

	125 {
	    downarrow configure -data "
#define down_width 20
#define down_height 20
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xff, 0x07,
   0xf8, 0xff, 0x03, 0xf0, 0xff, 0x01, 0xe0, 0xff, 0x00, 0xc0, 0x7f, 0x00,
   0x80, 0x3f, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x04, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 20
#define up_height 20
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x02, 0x00, 0x00, 0x07, 0x00, 0x80, 0x0f, 0x00, 0xc0, 0x1f, 0x00,
   0xe0, 0x3f, 0x00, 0xf0, 0x7f, 0x00, 0xf8, 0xff, 0x00, 0xfc, 0xff, 0x01,
   0xfe, 0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}

	150 {
	    downarrow configure -data "
#define down_width 24
#define down_height 24
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0xf8, 0xff, 0x3f, 0xf0, 0xff, 0x1f, 0xe0, 0xff, 0x0f,
   0xc0, 0xff, 0x07, 0x80, 0xff, 0x03, 0x00, 0xff, 0x01, 0x00, 0xfe, 0x00,
   0x00, 0x7c, 0x00, 0x00, 0x38, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 24
#define up_height 24
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x3e, 0x00,
   0x00, 0x7f, 0x00, 0x80, 0xff, 0x00, 0xc0, 0xff, 0x01, 0xe0, 0xff, 0x03,
   0xf0, 0xff, 0x07, 0xf8, 0xff, 0x0f, 0xfc, 0xff, 0x1f, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}

	175 {
	    downarrow configure -data "
#define down_width 28
#define down_height 28
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff, 0xff, 0x03,
   0xf0, 0xff, 0xff, 0x01, 0xe0, 0xff, 0xff, 0x00, 0xc0, 0xff, 0x7f, 0x00,
   0x80, 0xff, 0x3f, 0x00, 0x00, 0xff, 0x1f, 0x00, 0x00, 0xfe, 0x0f, 0x00,
   0x00, 0xfc, 0x07, 0x00, 0x00, 0xf8, 0x03, 0x00, 0x00, 0xf0, 0x01, 0x00,
   0x00, 0xe0, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 28
#define up_height 28
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
   0x00, 0x70, 0x00, 0x00, 0x00, 0xf8, 0x00, 0x00, 0x00, 0xfc, 0x01, 0x00,
   0x00, 0xfe, 0x03, 0x00, 0x00, 0xff, 0x07, 0x00, 0x80, 0xff, 0x0f, 0x00,
   0xc0, 0xff, 0x1f, 0x00, 0xe0, 0xff, 0x3f, 0x00, 0xf0, 0xff, 0x7f, 0x00,
   0xf8, 0xff, 0xff, 0x00, 0xfc, 0xff, 0xff, 0x01, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	}

	200 {
	    downarrow configure -data "
#define down_width 32
#define down_height 32
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0xf8, 0xff, 0xff, 0x3f, 0xf0, 0xff, 0xff, 0x1f, 0xe0, 0xff, 0xff, 0x0f,
   0xc0, 0xff, 0xff, 0x07, 0x80, 0xff, 0xff, 0x03, 0x00, 0xff, 0xff, 0x01,
   0x00, 0xfe, 0xff, 0x00, 0x00, 0xfc, 0x7f, 0x00, 0x00, 0xf8, 0x3f, 0x00,
   0x00, 0xf0, 0x1f, 0x00, 0x00, 0xe0, 0x0f, 0x00, 0x00, 0xc0, 0x07, 0x00,
   0x00, 0x80, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    uparrow configure -data "
#define up_width 32
#define up_height 32
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x80, 0x00, 0x00, 0x00, 0xc0, 0x01, 0x00, 0x00, 0xe0, 0x03, 0x00,
   0x00, 0xf0, 0x07, 0x00, 0x00, 0xf8, 0x0f, 0x00, 0x00, 0xfc, 0x1f, 0x00,
   0x00, 0xfe, 0x3f, 0x00, 0x00, 0xff, 0x7f, 0x00, 0x80, 0xff, 0xff, 0x00,
   0xc0, 0xff, 0xff, 0x01, 0xe0, 0xff, 0xff, 0x03, 0xf0, 0xff, 0xff, 0x07,
   0xf8, 0xff, 0xff, 0x0f, 0xfc, 0xff, 0xff, 0x1f, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}
    }
}
