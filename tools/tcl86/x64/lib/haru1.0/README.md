haru - PDF library
================
`haru` Tcl bindings for [libharu](http://libharu.org/) PDF library.
My motivation was to be able to integrate a 3D file in a pdf, unfortunately for me this pure `Tcl library` [pdf4tcl](https://sourceforge.net/projects/pdf4tcl/) can not do it. That’s why this library was born...
Another similar project had already written this in Tcl, without _dependencies_. You can find [here](http://reddog.s35.xrea.com/wiki/tclhpdf.html), functions are the same, but it does not include the latest `libharu` updates.


Dependencies :
-------------------------
- [libharu](http://libharu.org/) v2.3.0
- [Tcl cffi](https://cffi.magicsplat.com) package >= 1.0b3


Examples :
-------------------------
```tcl
package require haru

set page_title "haru Tcl bindings for libharu..."

# init haru pdf...
set pdf [HPDF_New]

# add a new page object.
set page [HPDF_AddPage $pdf]

# page format
HPDF_Page_SetSize $page HPDF_PAGE_SIZE_A4 HPDF_PAGE_PORTRAIT

# page size
set height [HPDF_Page_GetHeight $page]
set width  [HPDF_Page_GetWidth $page]

# set font and size
set def_font [HPDF_GetFont $pdf "Helvetica" ""]
HPDF_Page_SetFontAndSize $page $def_font 24

# get text size
set tw [HPDF_Page_TextWidth $page [haru::hpdf_encode $page_title]]

# write text
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page [expr {($width - $tw) / 2}] [expr {$height - 50}] [haru::hpdf_encode $page_title]
HPDF_Page_EndText $page

# save the document to a file
HPDF_SaveToFile $pdf haru.pdf

# free...
HPDF_Free $pdf
```
Some characters may not display correctly when you want to add text for certain functions `HPDF_Page_TextOut`, `HPDF_Page_ShowText`...
For this, use this pure `Tcl` function `haru::hpdf_encode arg1 ?arg2` :
- `arg1` - text
- `arg2` (optional argument) - type encoding (see list [here](http://libharu.sourceforge.net/fonts.html#The_type_of_encodings_)) by default is set to `StandardEncoding (cp1252)`

See **[demo folder](/demo)** for more examples...

Documentation :
-------------------------
Not really... But for `libharu` there is this [one](http://libharu.sourceforge.net/documentation.html).

Special Thanks :
-------------------------
To [Ashok P. Nadkarni](https://github.com/apnadkarni) for helping me understand `Tcl cffi` package and `libharu`.

License :
-------------------------
**haru** is covered under the terms of the [MIT](LICENSE) license.

Release :
-------------------------
*  **10-02-2022** : 1.0
    - Initial release.