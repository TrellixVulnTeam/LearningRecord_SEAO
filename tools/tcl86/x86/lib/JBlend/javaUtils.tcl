# javaUtils.tcl --
#
# Collections of utilities


# java::jvmProperties --
#
# 	Make a java::call to java.lang.System getProperties method
#   and store info about the JVM
#
# Results:
# 	A tcl dictionary of about 50 key-values ..

proc java::jvmProperties {} {
    set KV [dict create]
    set props [java::call System getProperties]
    set names [$props propertyNames]
	while { [$names hasMoreElements] } {
	  set key [[$names nextElement] toString]
	  set value [$props getProperty $key]
	  dict set KV $key $value
    }
    return $KV
}

 # alternative, fastest .. ??
proc java::alt_jvmProperties {} {
    set KV [dict create]
	set props [java::call System getProperties]
    foreach entry [java::listify {java.util.Map.Entry} [$props entrySet]] {
    	set key [[$entry getKey] toString]
    	set value [[$entry getValue] toString]
		dict set KV $key $value
	}
	return $KV
}

array set ::java::jvm [java::jvmProperties]

 # set the global *array* ::tcljava
 #  NOTE: it's an alias (alternative name) for java::jvm
 # *DEPRECATED* use the java::jvm *array* instead.
 
upvar 0 ::java::jvm  ::tcljava

