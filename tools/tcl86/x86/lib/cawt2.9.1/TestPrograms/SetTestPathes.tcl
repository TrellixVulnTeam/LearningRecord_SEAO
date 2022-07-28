set cawtDir [file join [pwd] ".."]

set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals"]]

if {$::tcl_platform(pointerSize) == 8} {
    set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals" "Img"  "Img-win64"]]
    set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals" "tDOM" "tDOM-win64"]]
} else {
    set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals" "Img"  "Img-win32"]]
    set auto_path [linsert $auto_path 0 $cawtDir [file join $cawtDir "Externals" "tDOM" "tDOM-win32"]]
}
