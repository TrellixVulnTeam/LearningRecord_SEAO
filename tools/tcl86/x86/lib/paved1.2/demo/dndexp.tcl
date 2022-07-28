# quick and dirty tool for changing tile of demoAll
#  Just an experiment:
#  Open an Explorer window and drag some gif-files 
#   over the paved-widgets ...

 # only for Windows ; binary package tkdnd should be installed
package require tkdnd

source demoAll.tcl


set pwList { \
   .main.statusBar \
   .main.pane.f1 \
   .main.pane.f1.b1 \
   .main.pane.f1.b2 \
   .main.pane.f1.b3 \
   .main.pane.f1.b4 \
   .main.pane.cvs
}

foreach w $pwList {
   dnd bindtarget $w Files <Drop> { %W configure -tile [lindex %D 0] }
}

# strange behaviour;
#  sometimes the target widget are not enabled;
#  if you restart dragging a gif-file, the set of
#  enabled widgets changes 
#  (i.e. some not-enabled targets become enabled and viceversa)      
