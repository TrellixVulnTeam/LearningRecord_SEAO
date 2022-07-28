# Cross platform init script for Tcl JBlend. 
# Known to work on unix and windows.
#    Windows (32/64), Linux (32/64), MacOsX (64)
# Based on works of Christopher Hylands, Mo Dejong


package ifneeded JBlend 2.1  [list apply { dir  {
	set thisDir [file normalize ${dir}]
	 # valid Tcl version: 8.5.x plus 8.6.0, then 8.6.6 and later
	 # Tcl 8.6.1..8.6.5 have a small change whose side effect is to crash
	 # special extension like tclblend 
	package require Tcl 8.5.0-8.6.1  8.6.6

	 # try to guess the tcl-interpreter architecture (32/64 bit) ...
	set arch $::tcl_platform(pointerSize)
	switch -- $arch {
		4 { set arch x32  }
		8 { set arch x64 }
		default { error "JBlend: Unsupported architecture: Unexpected pointer-size $arch!!! "}
	}
	
	 # set os and tail_libFile for the current platform
	set tail_libFile unknow
	set os $::tcl_platform(platform)
	switch -- $os {
		windows { set os win ; set tail_libFile tclJBlend.dll }
		unix    {
		set os $::tcl_platform(os)
			switch -- $os {
				Darwin { set os darwin ; set tail_libFile libtclJBlend.dylib }
				Linux  { set os linux ;  set tail_libFile libtclJBlend.so }
			}
		}
	}
		
	set dir_libFile [file join $thisDir ${os}-${arch}]
	if { ! [file isdirectory $dir_libFile ] } {
		error "JBlend: Unsupported platform ${os}-${arch}"
	}
	set full_libFile [file join $dir_libFile $tail_libFile]			 
	if { ! [file exists $full_libFile] } {
		error "JBlend: Missing DLL \"$tail_libFile\" in directory \"$dir_libFile\".\nTry reinstalling the JBlend package."
	}
	
	# BUG: some old tclkits don't have tcl_platform(pathSeparator)	
	# set pathSep $::tcl_platform(pathSeparator)
	# FIX: .. do it yoursel
	switch -- $::tcl_platform(platform) {
	 windows { set pathSep ";" }
	 unix    { set pathSep ":" }
	 default { set pathSep "X" }  ;#  !!	 
	}
	

    set JVMinitFromCfg  false
	set JVMcfgFile  "$thisDir/JVMcfg.tcl"
	if { ! [info exists ::JBlend_JVM] } {
		# try to get ::JBlend_JVM from the custom configuration
		catch {source $JVMcfgFile; set JVMinitFromCfg true }
	}

	if { ! [info exists ::JBlend_JVM] } {
		error "JBlend: undefined variable \"::JBlend_JVM\" (point to JavaVM runtime)
		It must be set before trying to load this package, 
		or 
		it must be defined in the configuration file \"$JVMcfgFile\". "
	}
		
	 # if filename is relative, transform it in absolute filename.
	 #  N.B. we should assume that it's relative to $thisDir (not to current-dir)
	set savedPwd [pwd]; cd $thisDir;
	set ::JBlend_JVM [file normalize $::JBlend_JVM]
	cd $savedPwd ; unset savedPwd

	if { ! [file exists $::JBlend_JVM] } {
		if { $JVMinitFromCfg } {
			error "JBlend: variable ::JBlend_JVM  refers to a non existing file \"$::JBlend_JVM\".
			Check the settings in \"$JVMcfgFile\". "
		} else {
			error "JBlend: variable ::JBlend_JVM  refers to a non existing file \"$::JBlend_JVM\".
			You should
			* redefine it properly before trying to load this package
			or 
			* unset ::JBlend_JVM
			  so that settings in the configuration file \"$JVMcfgFile\". will take place. "
		}
	}

    # ::JBlend_JVM will be used by the Init method of the loaded extension
	 
	# Prepare other parameters that will be used by the loaded extension ...
	 	
	#  this is required in order Java could recall the tclJBlend native libraries
	lappend ::tclblend_init "-Djava.library.path=${dir_libFile}"	
	append ::env(CLASSPATH) "${pathSep}[file join $thisDir tclJBlend.jar]"	
	                           
	load $full_libFile tcljblend
	
	source [file join $thisDir javalock.tcl]
	source [file join $thisDir javaUtils.tcl]
	
	package provide JBlend 2.1

}} $dir] ;# end of lambda apply
