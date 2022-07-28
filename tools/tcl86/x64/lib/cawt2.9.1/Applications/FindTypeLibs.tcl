# Utility script to find type libraries in the registry.
#
# Copyright: 2020-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

package require registry

proc Recurse { key level } {
    puts -nonewline "Key: $key"
    set values [registry values $key]
    foreach v $values {
        set type [registry type $key $v]
        set val  [registry get  $key $v]
        puts -nonewline " $val"
    }
    puts ""
    set keys [registry keys $key]
    foreach k $keys {
        set subKey [format "%s\\%s" $key $k]
        Recurse $subKey [expr $level + 1]
    }
}

Recurse "HKEY_CLASSES_ROOT\\TypeLib" 0
