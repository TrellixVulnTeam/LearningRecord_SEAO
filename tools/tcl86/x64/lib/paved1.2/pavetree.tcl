package provide Paved::Tree 1.2

##  pavetree.tcl
##
##	Paved-Tree : an extension of the BWidget-Tree widget.
##
##  Copyright (c) 2004-2012 <Irrational Numbers> : <aldo.w.buratti@gmail.com> 
##
##  NOTE: package "snit" is required. (Snit is part of tcllib)
##
## This library is free software; you can use, modify, and redistribute it
## for any purpose, provided that existing copyright notices are retained
## in all copies and that this notice is included verbatim in any
## distributions.
##
## This software is distributed WITHOUT ANY WARRANTY; without even the
## implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
##


#
# How to use Paved::Tree:
#   Read "pavetree.txt" for detailed info.
#   Sample code in provided in "demo*.tcl".
#


package require snit
package require BWidget
package require Paved::canvas


snit::widgetadaptor Paved::Tree {
    
    # pseudo-component (see the constructor)
   component internalCanvas
   
   delegate option -tile to internalCanvas
   delegate option -tileorigin to internalCanvas
   delegate option -bgzoom to internalCanvas
          
   delegate option *     to hull
   delegate method *     to hull

   typemethod adapt {w args} {
        $type create $w "*REUSE*" {*}$args
   }
   
   constructor {args} {
      if { [lindex $args 0] == "*REUSE*" } {
          # remove *REUSE* element
         set args [lreplace $args 0 0]
         installhull $win
      } else {
         installhull using ::Tree 
      }    
       # a BWidget-Tree uses a canvas sub-widget for drawing the tree.
       # This internal canvas is named ".c".
       # BWidget-Tree provides an undocumented (and steady) method
       #  for accessing this feature 
    
       # internalCanvas is 'pseudo' Snit component. 
       # Being already within $win, you shouldn't install it;
       #  just provide a reference          
      set internalCanvas [Tree::getcanvas $win]
      Paved::canvas adapt $internalCanvas
      $win configurelist $args
   }

}


namespace eval Paved { ; }

  # for backward compatibility : DEPRECATED
proc Paved::TreeAdaptor {path args} {
   Paved::Tree adapt $path {*}$args
   return $path
}



