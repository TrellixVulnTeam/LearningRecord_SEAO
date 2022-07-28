package provide Paved::frame 1.2

##  paveframe.tcl
##
##	Paved::frame : an extension of the frame widget.
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

package require snit

#
# How to use Paved::frame:
#   Read "paveframe.txt" for detailed info.
#   Sample code in provided in "demo*.tcl".
#


::snit::widgetadaptor Paved::frame {
   variable bg
   variable bgLabel
   variable isInternalTile false
   variable srcImage ""

   option -tile -configuremethod Set_tile
    # this is not a new option; it is for trapping changes to -padX/padY
   option { -padx padX Pad } -configuremethod Set_padxy -default 0
   option { -pady padY Pad } -configuremethod Set_padxy -default 0    

   delegate method * to hull 
   delegate option * to hull except {-padx -pady}

     #define a 'pseudo' Class binding
   typeconstructor {
      bind PavedFrame <Configure> { %W _RedrawBg %w %h }
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
         installhull using ::frame 
      }    
      set bg [image create photo ${win}_bg]
      set bgLabel [::label ${win}.bg -image $bg -bd 0 -relief flat -padx 0 -pady 0]
      lower $bgLabel
      place $bgLabel -in $win

      $win configurelist $args
      bindtags $win [linsert [bindtags $win] 1 PavedFrame]
   }


   destructor {
      image delete $bg
      if { $isInternalTile } {
         image delete $srcImage
      }
   }

   method Set_padxy {option value} {
      set options($option) $value
      $hull configure $option $value
      if { $option == "-padx" } {
         place $bgLabel -in $win -x -$value
      } else {
         place $bgLabel -in $win -y -$value
      }
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


   method Set_tile {optin value} {      
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
              win _RemoveInternalTile
              set srcImage $value
          }
      
      } else {

         $win _RemoveInternalTile         
         set srcImage {}
         image create photo $bg
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
         set bd [winfo pixels $win [$hull cget -bd]]
         set w  [winfo pixels $win $w]
         set h  [winfo pixels $win $h]
         set ht [winfo pixels $win [$hull cget -highlightthickness]]

	 set D  [expr $bd + $ht]   
         set w [expr $w -2*$D]
	 set h [expr $h -2*$D]

         if { $w > 0  && $h > 0 } { 
            $bg copy $srcImage  -to 0 0 $w $h
         }
      }
   }

}

namespace eval Paved { ; }

  # for backward compatibility : DEPRECATED
proc Paved::frameAdaptor {path args} {
   Paved::frame adapt $path {*}$args
   return $path
}

