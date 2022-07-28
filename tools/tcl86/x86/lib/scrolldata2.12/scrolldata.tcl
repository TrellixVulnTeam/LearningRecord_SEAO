#!/usr/bin/tclsh
#
# Copyright 2015-2017 Brad Lanam Walnut Creek CA USA
# Copyright 2020 Brad Lanam Pleasant Hill CA
#
# LICENSE
#
# This library is free software; you can use, modify, and redistribute it
# for any purpose, provided that existing copyright notices are retained
# in all copies and that this notice is included verbatim in any
# distributions.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#

package require Tk 8.6-

package provide scrolldata 2.12

::oo::class create ::scrolldata {
  constructor { win sb confcallback popcallback displaymax {rowmult 1} } {
    # sdvars:
    #   conf.callback   row configuration callback procedure
    #   dispmax         current number of rows displayed
    #   display.afterid display after id
    #   disp.reserved   how many lines are reserved at the top.
    #   first           boolean.  true for first time displayed.
    #   indisplay       lock for display routine
    #   inresize        lock for resize routine
    #   listoffset      current position in data
    #   mapped          how many windows are currently mapped (0-2)
    #   max             the user's display maximum
    #   mousewheel.bound mousewheel bound to 'all'
    #   os.macosx       boolean
    #   os.windows      boolean
    #   page.adjust     normally 0.  Can be set to adjust the size
    #                   of the page scroll-down.  Useful if some overlap
    #                   on page up/down is wanted.
    #   pop.callback    row populate callback procedure
    #   resize.afterid  after id for the resizing procedure
    #   rowmult         number of rows for each scroll unit.
    #                   the height of each row is assume to be the same.
    #   scroll.afterid  after id for scroll moveto call
    #   window          the scrollable window
    #   window.sb       the scrollbar
    #   row.heights:    dictionary
    #                   height: integer: height of the row
    #                   first: boolean: first time calculated?
    #   recalc          a flag to recalculate the row heights once
    #                   the main window has a height.
    # sdslaves: array
    #   list of slave widgets indexed by row
    #
    my variable sdvars
    my variable sdslaves

    set genplat $::tcl_platform(platform)
    set sdvars(os.windows) false
    set sdvars(os.macosx) false
    if { $genplat eq "windows" } {
      set sdvars(os.windows) true
    }
    if { $::tcl_platform(os) eq "Darwin" } {
      set sdvars(os.macosx) true
    }

    set sdvars(window) $win
    set sdvars(window.sb) $sb
    set sdvars(conf.callback) $confcallback
    set sdvars(pop.callback) $popcallback
    set sdvars(dispmax) $displaymax
    set sdvars(display.afterid) {}
    set sdvars(disp.reserved) 0
    set sdvars(listoffset) 0
    set sdvars(mousewheel.bound) false
    set sdvars(resize.afterid) {}
    set sdvars(first) 1
    set sdvars(indisplay) 0
    set sdvars(inresize) 0
    set sdvars(scroll.afterid) {}
    set sdvars(mapped) 0
    set sdvars(page.adjust) 0
    set sdvars(rowmult) $rowmult ; # how many rows of data per line
    set sdvars(row.heights) [dict create]
    set sdvars(recalc) 0

    # This is the default.
    # Done here as it makes the construction
    # of the scrolldata object easier for the user.
    # This can of course be overridden by the user.
    $sdvars(window.sb) configure -command [list [self] scroll]

    set w $sdvars(window)
    set bt [my sd_addBindTag $w sd_mapped]
    bind $bt <Map> [list [self] sd_domap %W]
    set w $sdvars(window.sb)
    set bt [my sd_addBindTag $w sd_mapped]
    bind $bt <Map> [list [self] sd_domap %W]

    # No telling where the focus is in relation to the pointer,
    # so must bind to all.

    bind all <Prior> +[list [self] pageHandler -1]
    bind all <Next> +[list [self] pageHandler 1]
    # prevline and nextline are bound to control-p and control-n
    # for some themes, so bind up and down also.
    bind all <<PrevLine>> +[list [self] arrowHandler -1]
    bind all <<NextLine>> +[list [self] arrowHandler 1]
    bind all <Up> +[list [self] arrowHandler -1]
    bind all <Down> +[list [self] arrowHandler 1]
  }

  method setPageAdjust { pa } {
    my variable sdvars

    set sdvars(page.adjust) $pa
  }

  method setReserved { r } {
    my variable sdvars

    set sdvars(disp.reserved) $r
  }

  # Sets the scrollbar low/high ratios.
  method setScrollbar { } {
    my variable sdvars

    if { $sdvars(max) > 0 } {
      set l [expr {
          double($sdvars(listoffset)) /
          double($sdvars(max))}]
      set h [expr {
          double($sdvars(listoffset)+$sdvars(dispmax)) /
          double($sdvars(max))}]
    } else {
      set l 0.0
      set h 1.0
    }
    $sdvars(window.sb) set $l $h
    $sdvars(window.sb) set $l $h
  }

  # Internal
  # Redisplays the data using the current offset.
  # Even though the widget doesn't actually change, the leave and enter
  # events for the widget are generated, as there may be different data
  # in the widget.
  method sd_scroll { } {
    my variable sdvars

    if { ! [winfo exists $sdvars(window)] } {
      return
    }
    set sdvars(scroll.afterid) {}
    # generate the leave and enter events for whatever's under the mouse pointer
    lassign [winfo pointerxy $sdvars(window)] x y
    set tw [winfo containing $x $y]
    if { $tw ne $sdvars(window) && $tw ne $sdvars(window.sb) } {
      event generate $tw <Leave>
    }
    my display $sdvars(max) $sdvars(listoffset)
    if { $tw ne $sdvars(window) && $tw ne $sdvars(window.sb) } {
      event generate $tw <Enter>
    }
  }

  # Scrolls the window.
  # Standard method used by a scrollbar.
  method scroll { args } {
    my variable sdvars

    if { [llength $args] == 0 } {
      return
    }
    if { ! [info exists sdvars(max)] } {
      return
    }

    lassign $args cmd val type
    set rm $sdvars(rowmult)
    if { $cmd eq "scroll" && $type eq "pages" } {
      set offset [expr {
          (($sdvars(listoffset)+
            ($val*
             ($sdvars(dispmax)+$sdvars(page.adjust)-$sdvars(disp.reserved))
            )
           ) /
          $rm)*$rm}]
    }
    if { $cmd eq "scroll" && $type eq "units" } {
      set offset [expr {$sdvars(listoffset)+($val*$rm)}]
    }
    if { $cmd eq "moveto" } {
      set offset [expr {int(floor(double($sdvars(max))*double($val)))/$rm*$rm}]
      set offset [expr {$offset-$sdvars(disp.reserved)}]
    }
    set tmax [expr {$sdvars(max)-$sdvars(dispmax)}]
    if { $offset > $tmax } {
      set offset $tmax
    }
    if { $offset < 0 } {
      set offset 0
    }

    set sdvars(listoffset) $offset
    my setScrollbar
    # This delay is useful in all cases.
    # A scrollwheel doesn't use moveto, and can send a lot of events.
    if { $sdvars(scroll.afterid) ne {} } {
      after cancel $sdvars(scroll.afterid)
    }
    set sdvars(scroll.afterid) [after 1 [list [self] sd_scroll]]
  }

  method scrollUnit { dir } {
    my setScrollbar
    my scroll scroll $dir units
  }

  # Check to see if the data index is currently displayed.
  # if not, scroll the window so that the data index is displayed.
  method chkScroll { didx } {
    my variable sdvars

    set rc 0
    if { ! [info exists sdvars(max)] } {
      return $rc
    }
    my setScrollbar
    if { $sdvars(max) == 0 } {
      return $rc
    }
    set didx [expr {$didx*$sdvars(rowmult)}]
    set max [expr {double($sdvars(max))}]
    set val $didx
    set low [expr {$sdvars(listoffset)+$sdvars(disp.reserved)}]
    set high [expr {$sdvars(listoffset)+$sdvars(dispmax)-1}]
    if { $val < $low || $val > $high } {
      set sval [expr {double($val)/$max}]
      my scroll moveto $sval
      set rc 1
    }
    return $rc
  }

  method fieldRow { didx } {
    my variable sdvars

    set rc -1
    if { ! [info exists sdvars(max)] } {
      return $rc
    }
    if { $sdvars(max) == 0 } {
      return $rc
    }
    set didx [expr {$didx*$sdvars(rowmult)}]
    set low $sdvars(listoffset)
    set high [expr {$sdvars(listoffset)+$sdvars(dispmax)-1}]
    if { $didx >= $low && $didx <= $high } {
      set rc [expr {$didx-$sdvars(listoffset)+1}]
    }
    return $rc
  }

  # Get the current number of rows displayed on screen.
  method getdispmax { } {
    my variable sdvars

    return $sdvars(dispmax)
  }

  # Internal
  # Called when the window and window.sb are mapped.
  method sd_domap { w } {
    my variable sdvars

    incr sdvars(mapped)
    my sd_removeBindTag $w sd_mapped
  }

  # Bind this routine to <Configure>.
  # Calls the internal resize after 50 milliseconds.
  method resize { {nw 0} {nh 0} } {
    my variable sdvars

    if { $sdvars(first) } {
      return
    }
    if { $sdvars(mapped) != 2 } {
      return
    }
    if { $sdvars(inresize) } {
      return
    }
    if { $sdvars(indisplay) } {
      return
    }
    if { $sdvars(resize.afterid) ne {} } {
      after cancel $sdvars(resize.afterid)
    }
    set sdvars(resize.afterid) \
        [after 50 [list [self] sd_resize]]
  }

  method _setRowHeight { r h } {
    variable sdvars

    if { [dict exists $sdvars(row.heights) $r first] } {
      dict set sdvars(row.heights) $r first false
    } else {
      dict set sdvars(row.heights) $r first true
    }
    dict set sdvars(row.heights) $r height $h
  }

  # Internal
  # The first time through, the widget height is an estimate by the
  # packing manager.  So always calculate the row height a second time.
  method _getRowHeight { r } {
    variable sdvars

    set calc false
    if { ! [dict exists $sdvars(row.heights) $r] } {
      set calc true
    } else {
      if { [dict get $sdvars(row.heights) $r first] } {
        set calc true
      }
      if { $sdvars(recalc) == 1 } {
        set calc true
      }
    }

    if { $calc } {
      set rh [my _calcRowHeight $r]
      my _setRowHeight $r $rh
    }

    set rh [list [dict get $sdvars(row.heights) $r height] \
        [dict get $sdvars(row.heights) $r first]]
    return $rh
  }

  # Internal
  # Does the work to resize the window.
  # Calculates the number of rows that can be displayed.
  # If the first time, the max height of the slave windows in each row
  # needs to be calculated, as the slave heights are not set initially.
  # If the resize forces the list offset off screen, the list offset
  # is adjusted so that it stays on screen.
  method sd_resize { } {
    my variable sdvars
    my variable sdslaves

    if { ! [winfo exists $sdvars(window)] } {
      return
    }
    if { ! [winfo exists $sdvars(window.sb)] } {
      return
    }
    if { $sdvars(inresize) } {
      return
    }
    set sdvars(inresize) 1

    set odm $sdvars(dispmax)
    set h1 [winfo reqheight $sdvars(window)]
    set h2 [winfo height $sdvars(window)]
    set h $h2
    if { $h1 > $h2 } {
      set h [expr {min($h1,$h2)}]
    }
    if { $h1 < $h2 } {
      set h [expr {max($h1,$h2)}]
    }

    set c 0
    lassign [grid bbox $sdvars(window) 0 0 4 0] x y hw hh
    set currh 0
    for { set r 1 } { $r <= $sdvars(dispmax) } { incr r } {
      lassign [my _getRowHeight $r] rh first
      incr c
      incr currh $rh
      if { ($currh + $hh) > $h } {
        # this will handle the situation where the window size is smaller...
        incr c -1
        break
      }
    }
    set r $c
    if { $c > 0 } {
      set er [expr {int(($h - $hh) / ($currh / $c))}]
      if { $er > $r && ($currh+$hh+($currh/$c)) <= $h } {
        set r $er
      }
    }

    set sdvars(dispmax) $r

    if { $r != $odm || $r == 0 } {
      if { ($sdvars(max)-$sdvars(dispmax)) < $sdvars(listoffset) } {
        set sdvars(listoffset) \
            [expr {$sdvars(max)-$sdvars(dispmax)}]
        if { $sdvars(listoffset) < 0 } {
          set sdvars(listoffset) 0
        }
      }
      my display $sdvars(max) $sdvars(listoffset)
    }
    set sdvars(resize.afterid) {}
    set sdvars(inresize) 0
  }

  # Reconfigures a single row.
  # 'grid forget' all the current slaves for that row
  # and calls the row configuration callback.
  method reconfigure { r dataidx } {
    my variable sdslaves

    grid forget {*}$sdslaves($r)
    dict unset sdvars(row.heights) $r
    my _confRow $r $dataidx
    return $sdslaves($r)
  }

  # Force a reconfigure for all rows.
  # The list offset can be changed.
  method reconfigureAll { {dataidx {}} } {
    my variable sdvars
    my variable sdslaves

    if { $dataidx eq {} } {
      set dataidx $sdvars(listoffset)
    }

    for { set r 1 } { $r <= $sdvars(dispmax) } { incr r } {
      if { ! [info exists sdslaves($r)] } {
        break
      }
      grid forget {*}$sdslaves($r)
      dict unset sdvars(row.heights) $r
      my _confRow $r $dataidx
      incr dataidx
    }
  }

  method sd_addBindTag { w tag } {
    if { [lsearch -exact [bindtags $w] $tag$w] == -1 } {
      bindtags $w [concat [bindtags $w] $tag$w]
    }
    return $tag$w
  }

  method sd_removeBindTag { w tag } {
    set b [bindtags $w]
    set idx [lsearch -exact $b $tag$w]
    set b [lreplace $b $idx $idx]
    bindtags $w $b
  }

  # Internal
  # Let the first display of the window adjust the width and height,
  # but thereafter, stop all propogation of width and height changes.
  # This procedure runs after the window is displayed, so it is bound
  # to the <Configure> event.
  method sd_stopPropagation { type } {
    my variable sdvars

    if { ! $sdvars(first) } {
      return
    }
    if { $sdvars(mapped) != 2 } {
      return
    }

    # remove the binding
    my sd_removeBindTag $sdvars(window) sd_initconf

    set sdvars(indisplay) 0
    if { $sdvars(first) && [winfo exists $sdvars(window)] } {
      grid propagate $sdvars(window) off
      set sdvars(first) 0
    }
    my sd_resize
  }

  # Internal
  # Reset the bindings on comboboxes so that the 'all' bindings
  # come first.
  method _resetBinding { s } {
    set bt [bindtags $s]
    set idx [lsearch -exact $bt all]
    set bt [lreplace $bt $idx $idx]
    set bt [linsert $bt 0 all]
    bindtags $s $bt
  }

  # Configure the slaves for a row.
  # Call the row configuration callback to configure the slaves.
  # For any combo box in the slave list, reset the bindings.
  method _confRow { r dataidx } {
    my variable sdslaves
    my variable sdvars

    set sdslaves($r) [$sdvars(conf.callback) $sdvars(window) $r $dataidx]
    foreach {s} $sdslaves($r) {
      set class [winfo class $s]
      if { $class eq "Listbox" || $class eq "TCombobox" } {
        # the bindings must be reset, otherwise the arrow keys will
        # not work properly.
        my _resetBinding $s
      }
    }
  }

  # Internal
  # Get the height of row by calculating the max height of all
  # of the slave widgets.
  method _calcRowHeight { r } {
    variable sdslaves

    set rh 0
    foreach {sw} $sdslaves($r) {
      set rh [expr {max($rh,[my _calcWidgetHeight $sw $r])}]
    }
    return $rh
  }

  # Internal
  # Get the height of a slave widget.
  # If the widget is a container, look through its children to get
  # the height.
  method _calcWidgetHeight { s r } {
    my variable sdvars

    set rh [winfo reqheight $s]
    if { $rh == 1 } {
      # some sort of container...get an estimate
      foreach {sc} [winfo children $s] {
        set rh [expr {max($rh,[winfo reqheight $sc])}]
      }
      # the assumption here is that the second row will be the
      # same height as the first.
      set rh [expr {$rh*$sdvars(rowmult)}]
    }
    return $rh
  }

  # Internal
  # Make sure the offset is in the range of the display maximum.
  # If not, adjust.
  method _chkOffset { dmax offset dispmax } {
    if { $dmax - $offset + 1 < $dispmax } {
      set offset [expr {$dmax - $dispmax}]
      if { $offset < 0 } {
        set offset 0
      }
    }
    return $offset
  }

  # Main display routine.  Specify the maximum display wanted.
  # This routine calls the populate row callback for each row passing
  # the proper display index.
  method display { dmax {offset {}} {fromafter {}} } {
    my variable sdvars
    my variable sdslaves

    if { ! [winfo exists $sdvars(window)] } {
      return
    }
    set sdvars(indisplay) 1
    after cancel $sdvars(display.afterid)

    if { $offset eq {} } {
      set offset $sdvars(listoffset)
    }

    # removal of an item should not shrink the screen...
    if { $offset > 0 &&
        [info exists sdvars(max)] &&
        $dmax + 1 == $sdvars(max) &&
        $offset + $sdvars(dispmax) == $sdvars(max) } {
      incr offset -1
    }
    set offset [my _chkOffset $dmax $offset $sdvars(dispmax)]

    set r 1
    set sdvars(max) $dmax

    set dataidx $offset
    set maxh [winfo height $sdvars(window)]
    lassign [grid bbox $sdvars(window) 0 0 4 0] x y hw hh
    set currh $hh
    # if maxh is not 1, the window has a size,
    #   use the actual height of the window.
    # if maxh is 1, the window hasn't been sized yet,
    #   use the number of rows requested.
    set rh 0
    set firstflag false
    while { $dataidx < $sdvars(max) } {
      # check height based on height of previous row, so we don't
      # configure and remove a row.
      if { $maxh != 1 && ($currh+$rh) > $maxh } {
        break
      }
      if { ! [info exists sdslaves($r)] } {
        my _confRow $r $dataidx
      }

      lassign [my _getRowHeight $r] rh first
      if { $first } {
        set firstflag true
      }
      incr currh $rh
      $sdvars(pop.callback) $sdvars(window) $r $dataidx $sdslaves($r)

      if { $maxh == 1 && $r >= $sdvars(dispmax) } {
        break
      }

      incr r 1
      incr dataidx
    }

    if { $maxh != 1 || $dataidx >= $sdvars(max) } {
      incr r -1
    }
    set r [expr {$r/$sdvars(rowmult)*$sdvars(rowmult)}]
    set sdvars(dispmax) $r
    set offset [my _chkOffset $dmax $offset $sdvars(dispmax)]
    set sdvars(listoffset) $offset

    # remove the grid items larger than the display
    set r [expr {$sdvars(dispmax)+1}]
    while { [info exists sdslaves($r)] } {
      # don't use remove here, as windows does really weird resizing thingies.
      grid forget {*}$sdslaves($r)
      unset sdslaves($r)
      incr r
    }

    my setScrollbar
    # After the first display, don't propagate changes any more.
    # need time for window to display, otherwise resize will mangle it.
    # the sd_stopPropagation call also turns off the indisplay flag.
    if { $sdvars(first) } {
      set w $sdvars(window)
      set bt [my sd_addBindTag $w sd_initconf]
      bind $bt <Configure> [list [self] sd_stopPropagation c]
      bind $bt <Visibility> [list [self] sd_stopPropagation v]
    } else {
      set sdvars(indisplay) 0
    }
    # The row height calculation may not return the correct height
    # the first time (as frames only reflect their true height once
    # they have been fully displayed).
    # If any row heights are calculated for the first time
    # call display again to recalculate the row heights.
    # Also recalculate everything again once the outer frame has a height.

    if { $fromafter eq "-after" && $sdvars(recalc) == 2 } {
      # if a after-idle display was executed, make sure
      # it is not re-scheduled.
      set sdvars(display.afterid) {}
    }

    # if a prior after-idle display was cancelled, re-schedule it.
    if { $sdvars(display.afterid) ne {} && $fromafter ne "-after" } {
      set firstflag true
      set sdvars(recalc) 0 ; # make sure recalc flag stays intact
    }

    set sdvars(display.afterid) {}
    if { $firstflag || ($maxh != 1 && $sdvars(recalc) == 0)  } {
      incr sdvars(recalc)
      set sdvars(display.afterid) [after idle \
          [list [self] display $sdvars(max) $sdvars(listoffset) -after]]
    }
  }

  # Return the current offset within the display.
  method curroffset { } {
    my variable sdvars

    return $sdvars(listoffset)
  }

  # Configures a widget and appends it to the slave list.
  # If the widget with that name exists already, it is
  # simply appended to the slave list.
  # If the widget does not yet exist, $cmd is called and
  # the widget is appended to the slave list.
  method reconfWidget { slv s cmd } {
    upvar $slv sl

    if { [winfo exists $s] } {
      lappend sl $s
    } else {
      lappend sl [{*}$cmd]
    }
  }

  # Scroll by pages.
  method pageHandler { d } {
    variable sdvars

    if { ! [winfo exists $sdvars(window)] } {
      return -code ok
    }
    set cont [winfo containing {*}[winfo pointerxy $sdvars(window)]]
    if { ! [winfo exists $cont] } {
      return -code ok
    }
    if { ! [string match $sdvars(window)* $cont] } {
      return -code ok
    }
    set class [winfo class $cont]
    if { $class eq "Listbox" || $class eq "TCombobox" || $class eq "Text" } {
      return -code ok
    }
    my scroll scroll $d pages
    return -code break
  }

  # Scroll by single units.
  method arrowHandler { d } {
    variable sdvars

    if { ! [winfo exists $sdvars(window)] } {
      return -code ok
    }
    set cont [winfo containing {*}[winfo pointerxy $sdvars(window)]]
    if { ! [winfo exists $cont] } {
      return -code ok
    }
    if { ! [string match $sdvars(window)* $cont] } {
      return -code ok
    }
    set class [winfo class $cont]
    if { $class eq "TSpinbox" || $class eq "Spinbox" ||
        $class eq "Listbox" || $class eq "TCombobox" || $class eq "Text" } {
      return -code ok
    }
    my scroll scroll $d units
    return -code ok
  }

  # Adjusts the wheel scroll values for windows and mac os x.
  method wheelHandler { wz d } {
    my variable sdvars

    if { ! [winfo exists $sdvars(window)] } {
      return -code ok
    }
    if { [winfo class $wz] eq "TCombobox" } {
      return -code ok
    }
    set cont [winfo containing {*}[winfo pointerxy $sdvars(window)]]
    if { ! [winfo exists $cont] } {
      return -code ok
    }
    if { ! [string match $sdvars(window)* $cont] &&
        ! [string match $sdvars(window.sb)* $cont] } {
      return -code ok
    }
    set class [winfo class $cont]
    if { $class eq "TSpinbox" || $class eq "Spinbox" ||
        $class eq "Listbox" || $class eq "TCombobox" || $class eq "Text" } {
      return -code ok
    }
    if { $sdvars(os.windows) } {
      set d [expr {int(-$d / 120)}]
    }
    if { $sdvars(os.macosx) } {
      set d [expr {int(-$d)}]
    }
    # These two tests check for excess events.
    # a non-braking scrollwheel can send a lot of extra scroll events.
    if { $d < 0 && $sdvars(listoffset) <= 0 } {
      return
    }
    if { $d > 0 && $sdvars(listoffset) >= ($sdvars(max)-$sdvars(dispmax)) } {
      return
    }

    my scroll scroll $d units
    return
  }

  # Not automatically bound as some scrolling areas have specific areas
  # where the wheel use is allowed.
  method bindWheel { p } {
    my variable sdvars

    if { ! $sdvars(mousewheel.bound) } {
      bind all <MouseWheel> +[list {*}$p %W %D]
      bind $sdvars(window.sb) <MouseWheel> +[list {*}$p %W %D]
      if { ! $sdvars(os.windows) } {
        bind all <Button-4> +[list {*}$p %W -1]
        bind all <Button-5> +[list {*}$p %W 1]
        bind $sdvars(window.sb) <Button-4> +[list {*}$p %W -1]
        bind $sdvars(window.sb) <Button-5> +[list {*}$p %W 1]
      }
      set sdvars(mousewheel.bound) true
    }
  }
}

