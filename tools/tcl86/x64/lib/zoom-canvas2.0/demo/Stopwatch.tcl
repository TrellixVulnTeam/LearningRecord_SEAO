# Stopwatch

if 0 {
==========================================================================
 Stopwatch is a chronometer-like clock that 
   may be reset/suspended/resumed.
 Stopwatch returns a time (in millliseconds) from the last reset.
 By default the returned time is equal to the real elapsed time,
 but if you change the clock's "-speed"  to some value,
 then you can see an apparent-time growing with that speed (even negative!).
 
 In order to get the apparent-time you should simply  call [$myclock get],
 but if you want to repeatedly call a given proc, then you should
 simply activate the Stopwatch's periodic schedule.
 example:.
	 proc myfun {msg t} { puts "$t : $msg" }
 	 set myclock [Stopwatch new]
	 $myclock configure -periodiccmd [list myfun "Hi!"]  ;# param t will be appended
     $myclock configure	-period 100  ;# in msec, i.e. every 0.1 secs 

When the stopwatch is suspended (i.e. [$myclock suspend] ) the returned apparent-time
does not change, and the periodic scheduler is suspended, too.

Here the basic and only methods:

* CREATE a new swObj
  set swObj [Stopwatch new ?_options_?]
	_options_ are:
	 -speed _s_   :: speed of the clock, default is 1.0
     -period _n_: :: interval (in millisecs) between two beats of the internal
	                 scheduler, if set.
	 -periodiccmd _cmdPrefix_ ::
	 				 if _cmdPrefix is {}, then the scheduler is deactivated, else
	 				 every _n_ millisecs (see _period above) _cmdPrefix_ will be
	 				 called followed by the internal apparent-time (in milliseconds).
* DESTROY the stopwatch
  $swObj destroy
* CGET/CONFIGURE
  $swObj cget _option_                :: get the value of option _option_
  $swObj configure                    :: get the list of all the options and their current value
  $swObj configure _option_           :: same as 'cget'
  $swObj configure _option_ _value    :: set _option_ to _value_ 
* RESET/SUSPEND/RESUME
  $swObj reset ?_n_?    :: restart the apparent-time to _n_  (default is 0)
  $swObj suspend   :: suspend the advancement of the apparent-time (and also suspend the periodic scheduler if set).
  $swObj resume    :: resume the advancement of the apparent-time (and also resume the periodic scheduler, if set)
  $swObj state     :: return "active" or "suspended"
* GET
* $swObj get       :: return the apparent-time (in millisecs) 
==========================================================================
}

## Copyright (c) 2021 <Irrational Numbers> : <aldo.w.buratti@gmail.com> 
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

snit::type Stopwatch {

	 # Alternative to "_Class_ create %AUTO% ..."
    typemethod new {args} {
        uplevel 1  [list $type create %AUTO% {*}$args]
    }

	proc NOW {} { clock milliseconds }

	option -period -default 1000  -type snit::integer ;# in milliseconds
	option -periodiccmd -default {} -configuremethod _periodiccmdCfg 
	option -speed -default 1.0 -type snit::double -configuremethod _speedCfg  ;

	variable my ; # array of internal vars
	
	constructor {args} {
		set my(afterID) 0   ;# 0 means "not scheduled"
		set my(suspended) false
		
		# my(APP_T)  ::  apparent-time (msec) returned by [$self get]

		# the internal apparent-time my(APP_T) is updated only when queried (i.e. $self get).
		# Since my(APP_T) depends on the -speed factor, when -spedd changes
		# (or when clock is suspended),
		#  then it is mandatory to update my(APP_T) with the previous -speed 
		#  and fix the my(T) (true-time of the last sync)
		
		# my(T) :: my(T) is the instant (as returned by [clock milliseconds])
		#          in which the last apparent-time my(APP_T) was determined

		$self reset 0						
		$self configurelist $args
	}

	destructor {
		 # before closing, stop any pending refresh 
		$self _CancelSchedule		
	}

	method _CancelSchedule {} {
		if { $my(afterID) > 0 } { 
			after cancel $my(afterID)
			set my(afterID) 0
		}
		return
	}
	
	method reset { {t 0} } {
		set my(APP_T) $t
		set my(T)   [NOW]
		return
	}
	
	method suspend {} {
		 # before suspending, we need to update the apparent-time,
		 # because the -speed factor may be changed later
		$self get ;# done!
		
		set my(suspended) true
		$self _CancelSchedule
	}

	method state {} {
		expr {$my(suspended) ? "suspended" : "active"}
	}	
	
	method resume {} {
		if { ! $my(suspended) } return

		 # since the apparent-time was suspended till now,
		 # then resync my(T) now.
		set my(T) [NOW]
		set my(suspended) false
		$self _ScheduleNextTick
	}

	method _periodiccmdCfg {opt value} {
		set options($opt) $value
		if { $value != {} } {
			$self _ScheduleNextTick
		}
	}
	
	 # speed can also be negative or 0.0 !!
	method _speedCfg {opt value} {
		 # before changing the speed,
		 # we nee to update the current my(APP_T)
		$self get ;# done!
		 
		set options($opt) $value	
	}
	

	 # return apparent-time in msec.
	 # If clock is suspended, apparent-time does not change.
	 # 
	 # INTERNAL: 
	 # Apparent-time depends
	 #  on the elapsed time between the last sync
	 #   and also on the -speed factor.
	 #  Therefore, when the speed factor changes or when the clock
	 #   is suspended (.. this is like a temporary speed equal to 0)
	 #  , it is mandatory to call this method, so to determine and fix
	 #    the apparent-time in that istant.
	method get {} {
		if { $my(suspended) } { return $my(APP_T) }
		set NOW [NOW]
		set deltaT [expr {$NOW-$my(T)}]
		set my(T) $NOW
		incr my(APP_T) [expr {round($deltaT*$options(-speed))}]
		return $my(APP_T)	
	}
	
	
	method _ScheduleNextTick {} {
		if { $my(afterID) > 0 } return ;# already scheduled
		
		if { $my(suspended) } return
		if { $options(-periodiccmd) == {} } return
		
		set my(afterID) [\
			after $options(-period) \
				[list apply { 
					{self} { $self _CancelSchedule; $self _RunAndReschedule } 
					} $self \
				]]
		return
	}

	method _RunAndReschedule {} {
		set t [$self get]
		if { $options(-periodiccmd) != {} } {
			uplevel #0 $options(-periodiccmd) $t
			$self _ScheduleNextTick
		}			
	}

}
