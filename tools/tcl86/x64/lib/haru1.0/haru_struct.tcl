# Copyright (c) 2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl binding for libharu (http://libharu.org/) PDF library.

cffi::Struct create error_handler {
    error_no  ulong
    detail_no ulong
    user_data {pointer unsafe}
}

cffi::Struct create hpdfpoint {
    x float
    y float
}

cffi::Struct create hpdf3Dpoint {
    x float
    y float
    z float
}

cffi::Struct create hpdfbox {
    left   float
    bottom float
    right  float
    top    float
}

cffi::Struct create hpdfrect {
    left   float
    bottom float
    right  float
    top    float
}

cffi::Struct create hpdftextwidth {
    numchars uint
    numwords uint
    width    uint
    numspace uint

}

cffi::Struct create hpdfdate {
    year        int
    month       int
    day         int
    hour        int
    minutes     int
    seconds     int
    ind         {pointer unsafe}
    off_hour    int
    off_minutes int
}

cffi::Struct create hpdftransmatrix {
    a float
    b float
    c float
    d float
    x float
    y float
}

cffi::Struct create hpdfdashmode {
    ptn0    ushort
    num_ptn int
    phase   int
}

cffi::Struct create hpdfrgbcolor {
    r float
    g float
    b float
}

cffi::Struct create hpdfcmykcolor {
    c float
    y float
    m float
    k float
}

cffi::Struct create rectlen {
    len int
}