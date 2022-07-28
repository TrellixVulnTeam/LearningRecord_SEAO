###
### DEMO for ALL Paved widgets ###
###

 set thisDir [file normalize [file dirname [info script]]]
 lappend auto_path [file dirname $thisDir]



package require Paved

proc aboutPaved {} {
   global thisDir

   set aboutMsg {

Paved Widgets:
a pure-tcl widget extension

by A.Buratti  
aldo.buratti@tiscali.it

}

   option add *Label.Font {{Monotype Corsiva} 16}
   option add *Button.Font {{Monotype Corsiva} 16}

   
   set f1 [file join $thisDir backgrounds cheese.gif]
   set f2 [file join $thisDir backgrounds pasta.gif]
   set f3 [file join $thisDir backgrounds woodfloor.gif]

   set top .about
   
   if [ catch { Paved::toplevel $top -tile $f3 } ] {
      raise $top
      return
   }

   wm title $top "Paved Widgets Demo"
   Paved::label $top.msg -bd 2 -relief sunken -tile $f1 \
          -compound center -text $aboutMsg

   Paved::button $top.ok -text Close -compound center -tile $f2 \
      -command "destroy $top" 

   pack $top.ok -side bottom -pady 20 -padx 50 -fill x
   pack $top.msg -expand 1 -fill both -padx 20 -pady 20

   wm geometry $top 310x290+40+40 
}


  if {$argv0 == [info script]} {
    # we are running in stand-alone mode
    wm iconify .
    aboutPaved
  }



