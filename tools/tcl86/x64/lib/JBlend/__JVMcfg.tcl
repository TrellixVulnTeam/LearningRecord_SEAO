# __JVMcfg.tcl : template for linking the JVM dll at runt-time
#
# -- configuration compatible with JBlend version 2.1

# SAVE a copy of this file as "JVMcfg.tcl" 
#  and MODIFY it accordling to your installation.

 # WRITE here the path name for jvm.dll (or libjvm.so, or libjvm.dylib)
 # Path may be an absolute or a relative pathname.
 #  Relative-pathnames must be relative to the directory of this file.
 # -- path names should be in Unix notation
 # example: set ::JBlend_JVM  "Z:/......./jvm.dll"
 set ::JBlend_JVM @JBLEND_JVM@
