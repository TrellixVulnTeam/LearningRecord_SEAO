package provide Paved::label 1.2

##  pavelabel.tcl
##
##	Paved-Label : an extension of the label widget.
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

package require  snit

#
# How to use Paved::label:
#   Read "pavelabel.txt" for detailed info.
#   Sample code in provided in "demo*.tcl".
#


::snit::widgetadaptor Paved::label {
   
   variable bg
   variable isInternalTile false
   variable srcImage ""
   
   delegate method * to hull
   
   option -tile      -configuremethod Set_tile  
   option -compound  -configuremethod Set_compound  -default none
   delegate option * to hull except { -image -compound } 

    #define a Class binding
   typeconstructor {
      bind PavedLabel <Configure> { %W _RedrawBg %w %h }
   }

   typemethod adapt {w args} {
        $type create $w "*REUSE*" {*}$args
   }
   
   constructor {args} {
      if { [lindex $args 0] == "*REUSE*" } {
          # remove *REUSE* element
         set args [lreplace $args 0 0]
         installhull $win
      } else {
         installhull using ::label 
      }    
      set bg [image create photo ${win}_bg]
      $win configurelist $args
      
      bindtags $win [linsert [bindtags $win] 1 PavedLabel]
   }


   destructor {
      image delete $bg
      $win _RemoveInternalTile
   }
   

    # intercept option -compound.
    # Only  "none" and "center" are valid.
    # Other 'valid' options are forced to "center" 
    #  (just for preserving old clients) 
   method Set_compound {option value} {
       switch -- $value {
           none -
           center  { set value $value }
           top -
           left -
           right -
           bottom  { set value center }

           default { return -code error \
                     "bad compound \"$value\": must be  none, center"
                   }
       }
       $hull configure -compound $value
       set options(-compound) $value
   }


    # Private
   method _RemoveInternalTile {} {
      # INVARIANT  ::  isInternalTile == true  ==>  srcImage != {}
      #                srcImage == {}  ==>  isInternalTile == false
      if { $isInternalTile } { 
           image delete $srcImage
           set isInternalTile false
           set srcImage {}
      }
   }


   method Set_tile {option value} {      
      set errMsg ""
      if { $value != {} } {

           # is it an 'image' or not ?
          if { [catch {image type $value}] } {
               # $value is not an 'image' ; assume it is a filename
              if { [catch {image create photo -file $value} newImage] } {
                  set errMsg $newImage
                   # leave existing srcImage
              } else {                   
                  $win _RemoveInternalTile
                  set isInternalTile true
                  set srcImage $newImage
              }              
          } else {
               # $value is an 'image'
              $win _RemoveInternalTile
              set srcImage $value
          }
          if { $errMsg == "" } { $hull configure -image $bg }
      
      } else {

         $win _RemoveInternalTile         
         set srcImage {}
         $hull configure -image {}
      }
      
      if { $errMsg == "" } {
          set options(-tile) $value
          $win _RedrawBg [winfo width $win] [winfo height $win]
          return
      } else {
          return -code error $errMsg
      }
   }
   
    
    # Private
   method _RedrawBg { w h } {
      if { $srcImage != {} } {
          # re-create an empty image
         image create photo $bg
          # note that distances may be in different formats 
          #  (inches,mm,points,pixels)
	  # convert them in pixels
         set bd   [winfo pixels $win [$hull cget -bd]]
	 set ht   [winfo pixels $win [$hull cget -highlightthickness]]
         set padx [winfo pixels $win [$hull cget -padx]]
         set pady [winfo pixels $win [$hull cget -pady]]

         set w [winfo pixels $win $w]
         set h [winfo pixels $win $h]

         set D  [expr $bd + $ht]
	    
         set w [expr $w -2*($D + $padx)]
	 set h [expr $h -2*($D + $pady)]

         if { $w > 0  && $h > 0 } { 
            $bg copy $srcImage  -to 0 0 $w $h
         }
      }
   }

}


namespace eval Paved { ; }

  # for backward compatibility : DEPRECATED
proc Paved::labelAdaptor {path args} {
   Paved::label adapt $path {*}$args
   return $path
}

