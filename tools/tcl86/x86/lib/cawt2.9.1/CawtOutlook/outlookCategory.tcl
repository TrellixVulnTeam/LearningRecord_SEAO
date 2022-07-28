# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export AddCategory
    namespace export DeleteCategory
    namespace export GetCategoryId
    namespace export GetCategoryNames
    namespace export GetNumCategories
    namespace export HaveCategory

    proc GetNumCategories { appId } {
        # Get the number of Outlook categories.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns the number of Outlook categories.
        #
        # See also: HaveCategory GetCategoryNames GetCategoryId
        # AddCategory DeleteCategory

        set nsObj [$appId GetNamespace "MAPI"]
        set count [$nsObj -with { Categories } Count]
        Cawt Destroy $nsObj
        return $count
    }

    proc HaveCategory { appId categoryName } {
        # Check, if a category already exists.
        #
        # appId        - Identifier of the Outlook instance.
        # categoryName - Name of the category to check.
        #
        # Returns true, if the category exists, otherwise false.
        #
        # See also: HaveCategory GetCategoryNames GetCategoryId
        # AddCategory DeleteCategory GetCategoryColor

        if { [lsearch -exact [Outlook::GetCategoryNames $appId] $categoryName] >= 0 } {
            return true
        } else {
            return false
        }
    }

    proc GetCategoryId { appId indexOrName } {
        # Get a category by its index or name.
        #
        # appId       - Identifier of the Outlook instance.
        # indexOrName - Index or name of the category.
        #
        # Returns the identifier of the found category.
        #
        # The first category has index 1.
        #
        # If the index is out of bounds or the category name does not
        # exist, an error is thrown.
        #
        # See also: HaveCategory GetNumCategories GetCategoryNames 
        # AddCategory DeleteCategory

        set nsObj [$appId GetNamespace "MAPI"]
        set count [$nsObj -with { Categories } Count]
        if { [string is integer -strict $indexOrName] } {
            set index [expr int($indexOrName)] 
            if { $index < 1 || $index > $count } {
                error "GetCategoryId: Invalid index $index given."
            }
        } else {
            set index 1
            set found false
            foreach name [Outlook GetCategoryNames $appId] {
                if { $indexOrName eq $name } {
                    set found true
                    break
                }
                incr index
            }
            if { ! $found } {
                error "GetCategoryId: No category with name $indexOrName"
            }
        }
        set categoryId [$nsObj -with { Categories } Item $index]
        Cawt Destroy $nsObj
        return $categoryId
    }

    proc GetCategoryNames { appId } {
        # Get a list of category names.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of category names.
        #
        # See also: HaveCategory GetNumCategories GetCategoryId
        # AddCategory DeleteCategory

        set nsObj [$appId GetNamespace "MAPI"]
        set categories [$nsObj Categories]
        set count [$categories Count]

        set nameList [list]
        for { set i 1 } { $i <= $count } { incr i } {
            set categoryId [$categories Item [expr {$i}]]
            lappend nameList [$categoryId Name]
            Cawt Destroy $categoryId
        }
        Cawt Destroy $categories
        Cawt Destroy $nsObj
        return $nameList
    }

    proc AddCategory { appId name { color "" } } {
        # Add a new category to the Outlook categories.
        #
        # appId - Identifier of the Outlook instance.
        # name  - Name of the new category.
        # color - Value of enumeration type [Enum::OlCategoryColor]
        #         or category color name.
        #         If set to the empty string, a color is choosen automatically by Outlook.
        #
        # Returns the identifier of the new category.
        # If a category with given name is already existing, the identifier of that
        # category is returned.
        #
        # See also: HaveCategory GetNumCategories GetCategoryNames 
        # GetCategoryId DeleteCategory GetCategoryColor

        if { [Outlook HaveCategory $appId $name] } {
            return [Outlook::GetCategoryId $appId $name]
        }

        set nsObj [$appId GetNamespace "MAPI"]
        set categories [$nsObj Categories]
        if { $color eq "" } {
            set categoryId [$categories Add $name]
        } else {
            set colorEnum [Outlook::GetCategoryColorEnum $color]
            set categoryId [$categories Add $name $colorEnum]
        }
        Cawt Destroy $categories
        Cawt Destroy $nsObj
        return $categoryId
    }

    proc DeleteCategory { appId indexOrName } {
        # Delete an Outlook category.
        #
        # indexOrName - Index or name of the Outlook category.
        #
        # Returns no value.
        #
        # See also: AddCategory HaveCategory GetNumCategories GetCategoryNames 
        # GetCategoryId DeleteCategory

        set nsObj [$appId GetNamespace "MAPI"]
        set categories [$nsObj Categories]
        set count [$categories Count]

        if { [string is integer -strict $indexOrName] } {
            set index [expr int($indexOrName)] 
            if { $index < 1 || $index > $count } {
                error "DeleteCategory: Invalid index $index given."
            }
        } else {
            set index 1
            set found false
            foreach name [Outlook::GetCategoryNames $appId] {
                if { $indexOrName eq $name } {
                    set found true
                    break
                }
                incr index
            }
            if { ! $found } {
                error "DeleteCategory: No category with name $indexOrName"
            }
        }
        $categories Remove $index

        Cawt Destroy $categories
        Cawt Destroy $nsObj
    }
}
