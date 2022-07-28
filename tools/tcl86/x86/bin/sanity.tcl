set packages {
    tcllibc 0.3.15
    tablelist 6.19
    wcb 3.7
    mentry 3.14
    scrollutil 1.15
    BWidget 1.9.15
    DiffUtil 0.4.1
    awthemes 10.4.0
    Img 1.4.13
    Itcl 4.2.2
    Mpexpr 1.2
    Tcl 8.6.12
    TclCurl 7.83.1
    Thread 2.8.7
    Tk 8.6.12
    Tktable 2.11
    WS::Utils 3.1.0
    WS::Server 3.4.0
    WS::Client 3.0.1
    cawt 2.9.1
    cmark 1.0
    csp  0.1.0
    dde 1.4.4
    gridplus 2.11
    parser 1.8
    pdf4tcl 0.9.2
    rbc 0.1.1
    registry 1.3.5
    ruff 2.3.0
    sqlite3 3.38.0
    struct::list 1.8.5
    tclcsv 2.3
    tdbc 1.1.3
    tdbc::odbc 1.1.3
    tdbc::sqlite3 1.1.3
    tdom 0.9.2
    tdomhtml 0.1.0
    tkdnd 2.9
    tnc 0.3.0
    treectrl 2.4.3
    twapi 4.7.1
    udp 1.0.10
    vfs 1.4.2
    tksvg 0.10
    pdf4tcl 0.9.2
    gc_class 1.0
    rl_http 1.9
    rl_json 0.11.0
    crimp 0.2
    critcl 3.1.18
    tarray 1.0.0
    tarray_ui 1.0.0
    xtal 1.0.0
    tls 1.7.22
    iocp 1.1.0
    dgtools::argvparse 0.2
    dgtools::dgtutils 0.1
    dgtools::recover 0.1
    dgtools::repo 0.1
    dgtools::shistory 0.2
    dgw::basegui 0.2
    tmdoc 0.4
    Bezier 1.1
    BContour 1.1
    duktape 0.9.0
    autoopts 0.6
    shtmlview::shtmlview 0.9.1
    chesschart 0.2
    scrolldata 2.12
    Ffidl 0.9b0
    Ffidlrt 0.4
    type 0.1
    nacl 1.1
    ooxml 1.6
    kettle 1
    ankh 1.0
    mustache 1.1
    tclyaml 0.5
    apave 3.4.12
    baltip 1.3.7
    bartabs 1.5.5
    hl_tcl 0.9.40
    cffi 1.0.7
    loon 1.2.3
    ImageScale 0.1
    mqtt 3.1
    broker 2.1
    zoom-canvas 2.0
    www 2.0
    www::proxypac 1.0
    www::http2 1.0
    www::websocket 1.0
    www::digest 2.0
    www::socks 1.0
    tsvg 0.1
    xjson 1.5
    tomato 1.2.2
    lg2 0.1
    tdot 0.3.1
}

set packages_x64 {
    haru 1.0
}
proc check_package_version {p v} {
    puts "Loading $p"
    if {[catch {
        uplevel #0 [list package require $p]
    } res]} {
        puts stderr "Failed to load package $p: $res"
        return 1
    }
    if {$res != $v} {
        puts stderr "Package $p version $res does not match expected $v"
        return 1
    }
    return 0
}

set error_count 0
foreach {p v} $packages {
    incr error_count [check_package_version $p $v]
    # Special case x64-only
}
if {$::tcl_platform(pointerSize) == 8} {
    foreach {p v} $packages_x64 {
        incr error_count [check_package_version $p $v]
    }
}

puts "$error_count package[expr {$error_count == 1 ? {} : {s}}] not present or incorrect version."


