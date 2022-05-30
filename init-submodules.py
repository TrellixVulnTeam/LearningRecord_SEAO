# -*- coding: UTF-8 -*-

import os

if __name__ == '__main__':
    submodules = [
        'C-C++/ThirdPartyLibrarys/compression/zlib',
        'C-C++/ThirdPartyLibrarys/compression/libzip',
        'C-C++/ThirdPartyLibrarys/xml/tinyxml2',
        'C-C++/ThirdPartyLibrarys/json/cJSON',
        'C-C++/ThirdPartyLibrarys/json/rapidjson',
        'C-C++/ThirdPartyLibrarys/character-encoding/libiconv',
        'C-C++/ThirdPartyLibrarys/database/sqlite',
        'C-C++/ThirdPartyLibrarys/database/sqlcipher',
        'C-C++/ThirdPartyLibrarys/crypto/openssl',
        'C-C++/ThirdPartyLibrarys/network/curl',
        'C-C++/ThirdPartyLibrarys/serialization/protobuf',
        'C-C++/ThirdPartyLibrarys/apple/libusbmuxd',
        'C-C++/ThirdPartyLibrarys/apple/libplist',
        'C-C++/ThirdPartyLibrarys/apple/libimobiledevice',
        'C-C++/ThirdPartyLibrarys/apple/libimobiledevice-glue',
        'C-C++/ThirdPartyLibrarys/apple/ideviceinstaller'
    ]

    cmd = "git submodule update --init --recursive"
    for submodule in submodules:
        cmd += " " + submodule

    os.system(cmd)
