# -*- tcl -*- Tcl package index file
# --- --- --- Handcrafted, final generation by configure.

package ifneeded tkimg 1.4.13 [list load [file join $dir tkimg1413t.dll]]

# Compatibility hack. When asking for the old name of the package
# then load all format handlers and base libraries provided by tkImg.
# Actually we ask only for the format handlers, the required base
# packages will be loaded automatically through the usual package
# mechanism.

# When reading images without specifying it's format (option -format),
# the available formats are tried in reversed order as listed here.
# Therefore file formats with some "magic" identifier, which can be
# recognized safely, should be added at the end of this list.

package ifneeded Img 1.4.13 {
    package require img::window
    package require img::tga
    package require img::ico
    package require img::pcx
    package require img::sgi
    package require img::sun
    package require img::xbm
    package require img::xpm
    package require img::ps
    package require img::jpeg
    package require img::png
    package require img::tiff
    package require img::bmp
    package require img::ppm
    package require img::gif
    package require img::pixmap
    package provide Img 1.4.13
}

if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::bmp 1.4.13 [list load [file join $dir tcl9tkimgbmp1413t.dll]] 
} else { 
package ifneeded img::bmp 1.4.13 [list load [file join $dir tkimgbmp1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::dted 1.4.13 [list load [file join $dir tcl9tkimgdted1413t.dll]] 
} else { 
package ifneeded img::dted 1.4.13 [list load [file join $dir tkimgdted1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::flir 1.4.13 [list load [file join $dir tcl9tkimgflir1413t.dll]] 
} else { 
package ifneeded img::flir 1.4.13 [list load [file join $dir tkimgflir1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::gif 1.4.13 [list load [file join $dir tcl9tkimggif1413t.dll]] 
} else { 
package ifneeded img::gif 1.4.13 [list load [file join $dir tkimggif1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::ico 1.4.13 [list load [file join $dir tcl9tkimgico1413t.dll]] 
} else { 
package ifneeded img::ico 1.4.13 [list load [file join $dir tkimgico1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded jpegtcl 9.4.0 [list load [file join $dir tcl9jpegtcl940t.dll]] 
} else { 
package ifneeded jpegtcl 9.4.0 [list load [file join $dir jpegtcl940t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::jpeg 1.4.13 [list load [file join $dir tcl9tkimgjpeg1413t.dll]] 
} else { 
package ifneeded img::jpeg 1.4.13 [list load [file join $dir tkimgjpeg1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded zlibtcl 1.2.11 [list load [file join $dir tcl9zlibtcl1211t.dll]] 
} else { 
package ifneeded zlibtcl 1.2.11 [list load [file join $dir zlibtcl1211t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded pngtcl 1.6.37 [list load [file join $dir tcl9pngtcl1637t.dll]] 
} else { 
package ifneeded pngtcl 1.6.37 [list load [file join $dir pngtcl1637t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded tifftcl 4.1.0 [list load [file join $dir tcl9tifftcl410t.dll]] 
} else { 
package ifneeded tifftcl 4.1.0 [list load [file join $dir tifftcl410t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::pcx 1.4.13 [list load [file join $dir tcl9tkimgpcx1413t.dll]] 
} else { 
package ifneeded img::pcx 1.4.13 [list load [file join $dir tkimgpcx1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::pixmap 1.4.13 [list load [file join $dir tcl9tkimgpixmap1413t.dll]] 
} else { 
package ifneeded img::pixmap 1.4.13 [list load [file join $dir tkimgpixmap1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::png 1.4.13 [list load [file join $dir tcl9tkimgpng1413t.dll]] 
} else { 
package ifneeded img::png 1.4.13 [list load [file join $dir tkimgpng1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::ppm 1.4.13 [list load [file join $dir tcl9tkimgppm1413t.dll]] 
} else { 
package ifneeded img::ppm 1.4.13 [list load [file join $dir tkimgppm1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::ps 1.4.13 [list load [file join $dir tcl9tkimgps1413t.dll]] 
} else { 
package ifneeded img::ps 1.4.13 [list load [file join $dir tkimgps1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::raw 1.4.13 [list load [file join $dir tcl9tkimgraw1413t.dll]] 
} else { 
package ifneeded img::raw 1.4.13 [list load [file join $dir tkimgraw1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::sgi 1.4.13 [list load [file join $dir tcl9tkimgsgi1413t.dll]] 
} else { 
package ifneeded img::sgi 1.4.13 [list load [file join $dir tkimgsgi1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::sun 1.4.13 [list load [file join $dir tcl9tkimgsun1413t.dll]] 
} else { 
package ifneeded img::sun 1.4.13 [list load [file join $dir tkimgsun1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::tga 1.4.13 [list load [file join $dir tcl9tkimgtga1413t.dll]] 
} else { 
package ifneeded img::tga 1.4.13 [list load [file join $dir tkimgtga1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::tiff 1.4.13 [list load [file join $dir tcl9tkimgtiff1413t.dll]] 
} else { 
package ifneeded img::tiff 1.4.13 [list load [file join $dir tkimgtiff1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::window 1.4.13 [list load [file join $dir tcl9tkimgwindow1413t.dll]] 
} else { 
package ifneeded img::window 1.4.13 [list load [file join $dir tkimgwindow1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::xbm 1.4.13 [list load [file join $dir tcl9tkimgxbm1413t.dll]] 
} else { 
package ifneeded img::xbm 1.4.13 [list load [file join $dir tkimgxbm1413t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0-]} { 
package ifneeded img::xpm 1.4.13 [list load [file join $dir tcl9tkimgxpm1413t.dll]] 
} else { 
package ifneeded img::xpm 1.4.13 [list load [file join $dir tkimgxpm1413t.dll]] 
} 
