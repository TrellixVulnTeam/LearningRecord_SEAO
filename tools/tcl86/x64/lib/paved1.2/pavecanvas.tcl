package provide Paved::canvas 1.2

##  Pavecanvas.tcl
##
##	Paved::canvas : an extension of the canvas widget.
##                     handling huge scrollregions
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
# How to use Paved::canvas:
#   Read "pavecanvas.txt" for detailed info.
#   Sample code in provided in "demo*.tcl".
#


::snit::widgetadaptor Paved::canvas {

   variable bg
   variable isInternalTile false
   variable srcImage ""

    # tile's size
   variable tdx
   variable tdy
    # tiled-background's anchor point
   variable t_wx0
   variable t_wy0
    # number of tiles
   variable Nx
   variable Ny

    # origin (anchor) of the background image
   variable X0 0
   variable Y0 0


    # canvas margins ( borderwidth + highlightthickness ).
    # (It could be computed each time, but it is cheaper to save it)
    # Note that every changes to the above standard options generates a
    #  <Configure> event. For this reason it is not necessary to intercept
    #  changes to such options
   variable margin 0

    # this is not a new option; it is for trapping changes to -scrollregion
   option -scrollregion -configuremethod Set_scrollregion
   option -tile         -configuremethod Set_tile
   option -bgzoom       -configuremethod Set_bgzoom     -default 1
   option -tileorigin   -configuremethod Set_tileorigin -default {0 0}

   delegate method * to hull except {delete lower xview yview}
   delegate option * to hull except {-scrollregion}

    #define a 'pseudo' Class binding
   typeconstructor {
      bind PavedCanvas <Configure> { %W _RedrawBg %w %h }
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
         installhull using ::canvas 
      }    
      set bg [image create photo ${win}_bg]
      $hull create image 0 0 -image $bg -anchor nw -tags bgimage
       # background image must be the first on the display-list
      $hull lower bgimage
      $win configurelist $args

      bindtags $win [linsert [bindtags $win] 1 PavedCanvas]
   }

   destructor {
      image delete $bg
      $win _RemoveInternalTile
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


   method Set_scrollregion {option value} {
       # note that we should call the $hull object;
       #  if we call the $win object, it causes a never ending recursion!
      $hull configure -scrollregion $value
      set options(-scrollregion) $value
      $win _RedrawBg [winfo width $win] [winfo height $win]
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
      
      } else {

         $win _RemoveInternalTile         
         set srcImage {}
         image create photo $bg
      }
      
      if { $errMsg == "" } {
          set options(-tile) $value
          if { $srcImage != "" } {
            set tdx [image width $srcImage]
            set tdy [image height $srcImage]
             # force to recompute X0,Y0 (where to put the 'first' tile)
            $win configure -tileorigin $options(-tileorigin)
          }
          return
      } else {
          return -code error $errMsg
      }
   }


   method Set_tileorigin {option value} {
      if { [llength $value] != 2 } {
          return -code error "#Bad tileorigin $value"
      }
      set options(-tileorigin) $value
       # the 'real' tile-origin is computed only if a tile is present.
       # the real tile-origin is computed as follows:
       #  a) X0,Y0 are converted in pixels
       #  b) X0,Y0 are 'normalized' respect to the size of the tile.
       # I.e. if tile's size is 100x100 pixels,
       #      then a proposed tileorigin equal to { 734, 112 } is equivalent
       #      to its 'modulo tile', resulting { 34,12 }
       # (similarly, tileorigin { -5,-7} is equivalent to {95,93})
       #
       # Be careful that when tile changes, tile-origin should be
       #  recomputed.
      if { $srcImage != "" } {
         set X0 [expr [lindex $value 0] % $tdx]
         set Y0 [expr [lindex $value 1] % $tdy]

         set X0 [winfo pixels $win $X0]
         set Y0 [winfo pixels $win $Y0]
         $win _RedrawBg [winfo width $win] [winfo height $win]
      }
   }


   method Set_bgzoom {option value} {
      if { ! [string is integer $value] } {
          return -code error "#wrong value: expected an integer"
      }
      if { $value <= 0 } {
          return -code error "#wrong value: must be positive"
      }
      set options(-bgzoom) $value
      $win _RedrawBg [winfo width $win] [winfo height $win]
   }
   

   method lower {args} {
      eval $hull lower $args
       # be sure bgimage is always the lowest 
      $hull lower bgimage
   }

    # delete all items on canvas (leaving the background-image intact)
   method clean {} {
	$win delete !bgimage
   }

     # poi prova a intercettare meglio
     # override the "delete" command:
     #  'current' , 'all', 'bgimage' tags are converted to safe tags.
     # In this way is (quite) impossible to delete the background...
   method delete {args} {
       set new_args {}
       foreach tag $args {
           switch -- $tag {
              all     { set tag "!bgimage" }
              current { set tag "current&&!bgimage" }
              bgimage { set tag 0 ; # tag "0" does not exist }
           }
           lappend new_args $tag
       }
       eval $hull delete $new_args
   }


   method xview {args} {      
      set res [eval $hull xview $args]
      if { $srcImage != {} } {
          # adjust effective width subtracting margins
         set w [winfo width $win]
         incr w [expr -2*$margin]
          # adjust effective tile's size with zoom factor
         set etdx [expr $tdx * $options(-bgzoom)] 
         set x [$hull canvasx $margin]
         if { $x < $t_wx0  ||  $x > ($t_wx0+$Nx*$etdx-$w) } {
             # scroll bgimage
            set DX [expr floor(($x-$X0)/$etdx)*$etdx + $X0 - $t_wx0]
            set t_wx0 [expr $t_wx0 + $DX]
            $hull move bgimage $DX 0
         }
      }
      return $res
   }

   method yview {args} {      
      set res [eval $hull yview $args]
      if { $srcImage != {} } {
          # adjust effective height subtracting margins
         set h [winfo height $win]
         incr h [expr -2*$margin]
          # adjust effective tile's size with zoom factor
         set etdy [expr $tdy * $options(-bgzoom)] 
         set y [$hull canvasy $margin]
         if { $y < $t_wy0  ||  $y > ($t_wy0+$Ny*$etdy-$h) } {
             # scroll bgimage
            set DY [expr floor(($y-$Y0)/$etdy)*$etdy + $Y0 - $t_wy0]
            set t_wy0 [expr $t_wy0 + $DY]
            $hull move bgimage 0 $DY
         }
      }
      return $res
   }


    # Private
   method _RedrawBg { w h } {
      if { $srcImage != {} } {
          # re-create (reset) an empty image
         image create photo $bg
          # note that distances may be in different formats 
          #  (inches,mm,points,pixels)
	  # convert them in pixels

         set w  [winfo pixels $win $w]
         set h  [winfo pixels $win $h]

         set bd [winfo pixels $win [$hull cget -borderwidth]]
         set ht [winfo pixels $win [$hull cget -highlightthickness]]
         set margin [expr $bd + $ht]

          # subtract margins from the window area
         incr w [expr -2*$margin]
         incr h [expr -2*$margin]

         set wx0 [$hull canvasx $margin]
         set wy0 [$hull canvasy $margin]

          # adjust effective tile's size with zoom factor
         set zoom $options(-bgzoom)
         set etdx [expr $tdx * $zoom] 
         set etdy [expr $tdy * $zoom] 

         set t_wx0 [expr floor(($wx0-$X0)/$etdx)*$etdx+$X0]
         set Nx [expr int(ceil(double($w)/$etdx)) +1]
         set t_wy0 [expr floor(($wy0-$Y0)/$etdy)*$etdy+$Y0]
         set Ny [expr int(ceil(double($h)/$etdy)) +1]
               
	 $bg copy $srcImage -zoom $zoom $zoom \
                  -to 0 0 [expr $Nx * $etdx] [expr $Ny * $etdy]
	 $win coords bgimage $t_wx0 $t_wy0
      }
   }

}

namespace eval Paved { ; }

  # for backward compatibility : DEPRECATED
proc Paved::canvasAdaptor {path args} {
   Paved::canvas adapt $path {*}$args
   return $path
}

