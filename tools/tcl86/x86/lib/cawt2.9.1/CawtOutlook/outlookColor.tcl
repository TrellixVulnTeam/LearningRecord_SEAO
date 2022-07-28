# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export GetCategoryColor
    namespace export GetCategoryColorEnum
    namespace export GetCategoryColorName
    namespace export GetCategoryColorNames

    variable sCategoryColorList

    array set sCategoryColorList [list \
        $Outlook::olCategoryColorRed        { "Red"         231 161 162 } \
        $Outlook::olCategoryColorOrange     { "Orange"      249 186 137 } \
        $Outlook::olCategoryColorPeach      { "Peach"       247 221 143 } \
        $Outlook::olCategoryColorYellow     { "Yellow"      252 250 144 } \
        $Outlook::olCategoryColorGreen      { "Green"       120 209 104 } \
        $Outlook::olCategoryColorTeal       { "Teal"        159 220 201 } \
        $Outlook::olCategoryColorOlive      { "Olive"       198 210 176 } \
        $Outlook::olCategoryColorBlue       { "Blue"        157 183 232 } \
        $Outlook::olCategoryColorPurple     { "Purple"      181 161 226 } \
        $Outlook::olCategoryColorMaroon     { "Maroon"      218 174 194 } \
        $Outlook::olCategoryColorSteel      { "Steel"       218 217 220 } \
        $Outlook::olCategoryColorDarkSteel  { "DarkSteel"   107 121 148 } \
        $Outlook::olCategoryColorGray       { "Gray"        191 191 191 } \
        $Outlook::olCategoryColorDarkGray   { "DarkGray"    111 111 111 } \
        $Outlook::olCategoryColorBlack      { "Black"        79  79  79 } \
        $Outlook::olCategoryColorDarkRed    { "DarkRed"     193  26  37 } \
        $Outlook::olCategoryColorDarkOrange { "DarkOrange"  226  98  13 } \
        $Outlook::olCategoryColorDarkPeach  { "DarkPeach"   199 153  48 } \
        $Outlook::olCategoryColorDarkYellow { "DarkYellow"  185 179   0 } \
        $Outlook::olCategoryColorDarkGreen  { "DarkGreen"    54 143  43 } \
        $Outlook::olCategoryColorDarkTeal   { "DarkTeal"     50 155 122 } \
        $Outlook::olCategoryColorDarkOlive  { "DarkOlive"   119 139  69 } \
        $Outlook::olCategoryColorDarkBlue   { "DarkBlue"     40  88 165 } \
        $Outlook::olCategoryColorDarkPurple { "DarkPurple"   92  63 163 } \
        $Outlook::olCategoryColorDarkMaroon { "DarkMaroon"  147  68 107 } \
    ]

    proc GetCategoryColorEnum { colorEnumOrName } {
        # Convert a category color enumeration or name into a color enumeration.
        #
        # colorEnumOrName - A category color enumeration or name.
        #
        # See [GetCategoryColor] for a description of color enumerations and names.
        #
        # Returns the category color enumeration.
        #
        # See also: ::Cawt::GetColor GetCategoryColor GetCategoryColorName GetCategoryColorNames

        variable sCategoryColorList

        if { [string is integer $colorEnumOrName] } {
            if { [info exists sCategoryColorList($colorEnumOrName)] } {
                return $colorEnumOrName
            }
        } else {
            foreach { key val } [array get sCategoryColorList] {
                if { [lindex $val 0] eq $colorEnumOrName } {
                    return $key
                }
            }
        }
        error "GetCategoryColorEnum: Invalid color representation \"$colorEnumOrName\" specified."
    }

    proc GetCategoryColorName { colorEnum } {
        # Convert a category color enumeration into a category color name.
        #
        # colorEnum - A category color enumeration.
        #
        # See [GetCategoryColor] for a description of color enumerations and names.
        #
        # Returns the category color name.
        #
        # See also: ::Cawt::GetColor GetCategoryColor GetCategoryColorEnum GetCategoryColorNames

        variable sCategoryColorList

        if { [info exists sCategoryColorList($colorEnum)] } {
            return [lindex $sCategoryColorList($colorEnum) 0]
        }
        error "GetCategoryColorName: Invalid color enumeration \"$colorEnum\" specified."
    }

    proc GetCategoryColorNames {} {
        # Get all category color names.
        #
        # See [GetCategoryColor] for a description of color enumerations and names.
        #
        # Returns a list of all category color names.
        #
        # See also: ::Cawt::GetColor GetCategoryColor GetCategoryColorEnum GetCategoryColorName

        variable sCategoryColorList

        set colorNameList [list]
        foreach { key val } [array get sCategoryColorList] {
            lappend colorNameList [lindex $val 0]
        }
        return $colorNameList
    }

    proc GetCategoryColor { colorEnumOrName } {
        # Convert a category color enumeration or name
        # into a hexadecimal Tcl color string representation.
        #
        # colorEnumOrName - A category color enumeration or name.
        #
        # Outlook category colors can be specified in one of the following representations:
        #   Enum - A value of enumeration [Enum::OlCategoryColor].
        #   Name - Enumeration name without prefix `olCategoryColor`.
        #          Example: Name of `Outlook::olCategoryColorBlack` is `Black`.
        #
        # Returns the hexadecimal representation of the specified color, ex. `#00FFAA`.
        #
        # See also: ::Cawt::GetColor GetCategoryColorEnum GetCategoryColorName GetCategoryColorNames

        variable sCategoryColorList

        set enum [Outlook::GetCategoryColorEnum $colorEnumOrName]
        set rgb [lrange $sCategoryColorList($enum) 1 end]
        lassign $rgb r g b
        return [format "#%02X%02X%02X" $r $g $b]
    }
}
