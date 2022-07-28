##  scrodget.tcl
##
##  scrodget.tcl - a generic scrolled widget
##
##    Scrodget enables user to create easily a widget with its scrollbar.
##    Scrollbars are created by Scrodget and scroll commands are automatically
##    associated to a scrollable widget with Scrodget::associate.
##
##    scrodget was inspired by ScrolledWidget (BWidget)
##
##  Copyright (c) 2012 <Irrational Numbers> : <aldo.w.buratti@gmail.com> 

scrodget is a pure-tcl implementation of a generic scrolled widget.
scrodget is built using the "snit" package; this package can be downloaded from
   http://www.wjduquette.com/snit
and should be properly installed before using scrodget.

VERSION:
  scrodget.tcl - 2.1.1
 REQUIRED PACKAGES:
  snit - 0.97 or higher
 TCL-Tk 8.4.x or higher recommended

== DEMOS ==

* demo-*.tcl *
These are full demo allowing you to interactively experiment all the "scrodget" features.

CHANGES
 1.0 - initial version
 1.0.1 - BUG-fix [typo] in typoscrodget.tcl - line 133
         old :  set isHidden(verticalal) 0
         new :  set isHidden(vertical) 0
         Surprisingly I discoverd this typo after many months of usage !
       - Enhanced 'associate' method; you can GET the associated widget, too!
         (see scrodget.txt)
       - BUG-fix : now you can safely use -autohide option within the constructor. 
       - Corrected typo in scrodget.txt (*EXAMPLE* section)
 1.1 - extended the -autohide option:
       Now you can specify none,both,only-vertical,only-horizontal.
 2.0 - scrodget now allows 4 scrollbars together (if you need them) !
       (*2.0 syntax is not compatible with 1.x*)
        options -vscrollside and -hscrollside have been replaced with -scrollsides
       Scrodget has been rewritten conformant to Snit 0.97 recommandations 
        (removing deprecated syntax)
 2.0.1 - BUG-fix : east/west scrollbars were exchanged !
         Fix : removed all internal pad-space (1 pixel) around scrollbars
         and associated widget.     
 2.0.2 - BUG-fix : 
            $w associate
          raises an error "can't read internalW"
           if no widget has been associated.
          Now fixed.
 2.1   - Now scrodget also supports 'themed' look&feel (tile)
 2.1.1 - Released with a less restrictive license

          
For comments and suggestions, please write to
 <aldo.w.buratti@gmail.com>

