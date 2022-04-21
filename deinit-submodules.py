# -*- coding: UTF-8 -*-

import os

if __name__ == '__main__':
    submodules = [
        'C-C++/ThirdPartyLibrarys/compression/bit7z',
        'C-C++/ThirdPartyLibrarys/compression/zlib',
        'C-C++/ThirdPartyLibrarys/compression/libzip',
        'C-C++/ThirdPartyLibrarys/apple/libimobiledevice-glue',
        'C-C++/ThirdPartyLibrarys/apple/libusbmuxd',
        'C-C++/ThirdPartyLibrarys/apple/libplist',
        'C-C++/ThirdPartyLibrarys/apple/libimobiledevice',
        'C-C++/ThirdPartyLibrarys/apple/ideviceinstaller',
        'C-C++/ThirdPartyLibrarys/xml/pugixml',
        'C-C++/ThirdPartyLibrarys/xml/tinyxml2',
        'C-C++/ThirdPartyLibrarys/json/cJSON',
        'C-C++/ThirdPartyLibrarys/json/rapidjson',
        'C-C++/ThirdPartyLibrarys/json/json',
        'C-C++/ThirdPartyLibrarys/serialization/MMKV',
        'C-C++/ThirdPartyLibrarys/serialization/protobuf',
        'C-C++/ThirdPartyLibrarys/character-encoding/icu',
        'C-C++/ThirdPartyLibrarys/character-encoding/libiconv',
        'C-C++/ThirdPartyLibrarys/multimedia/FFmpeg',
        'C-C++/ThirdPartyLibrarys/multimedia/ImageMagick',
        'C-C++/ThirdPartyLibrarys/database/sqlite',
        'C-C++/ThirdPartyLibrarys/database/sqlcipher',
        'C-C++/ThirdPartyLibrarys/network/cpp-httplib',
        'C-C++/ThirdPartyLibrarys/network/curl',
        'C-C++/ThirdPartyLibrarys/network/grpc',
        'C-C++/ThirdPartyLibrarys/network/libwebsockets',
        'C-C++/ThirdPartyLibrarys/network/websocketpp',
        'C-C++/ThirdPartyLibrarys/network/uWebSockets',
        'C-C++/ThirdPartyLibrarys/network/libhv',
        'C-C++/ThirdPartyLibrarys/network/libuv',
        'C-C++/ThirdPartyLibrarys/network/libev',
        'C-C++/ThirdPartyLibrarys/network/libevent',
        'C-C++/ThirdPartyLibrarys/network/nginx',
        'C-C++/ThirdPartyLibrarys/network/memcached',
        'C-C++/ThirdPartyLibrarys/network/redis',
        'C-C++/ThirdPartyLibrarys/network/mu_event',
        'C-C++/ThirdPartyLibrarys/network/muduo',
        'C-C++/ThirdPartyLibrarys/network/poco',
        'C-C++/ThirdPartyLibrarys/network/seastar',
        'C-C++/ThirdPartyLibrarys/network/wolfssl',
        'C-C++/ThirdPartyLibrarys/network/boringssl',
        'C-C++/ThirdPartyLibrarys/network/mbedtls',
        'C-C++/ThirdPartyLibrarys/network/libressl',
        'C-C++/ThirdPartyLibrarys/network/openssl',
        'C-C++/ThirdPartyLibrarys/network/libssh2',
        'C-C++/ThirdPartyLibrarys/network/openssh',
        'C-C++/ThirdPartyLibrarys/network/dropbear-ssh',
        'C-C++/ThirdPartyLibrarys/network/rsync',
        'C-C++/ThirdPartyLibrarys/network/putty',
        'C-C++/ThirdPartyLibrarys/network/asio',
        'C-C++/ThirdPartyLibrarys/network/samba',
        'C-C++/ThirdPartyLibrarys/linux/glibc',
        'C-C++/ThirdPartyLibrarys/windows/pthread-win32',
        'C-C++/ThirdPartyLibrarys/windows/openssh-win32',
        'C-C++/ThirdPartyLibrarys/windows/ImageMagick-Windows',
        'C-C++/ThirdPartyLibrarys/windows/grepWin',
        'C-C++/ThirdPartyLibrarys/windows/tortoisesvn',
        'C-C++/ThirdPartyLibrarys/windows/TortoiseGit',
        'C-C++/ThirdPartyLibrarys/windows/winscp',
        'C-C++/ThirdPartyLibrarys/windows/Windows-classic-samples',
        'C-C++/ThirdPartyLibrarys/windows/Windows-driver-samples',
        'C-C++/ThirdPartyLibrarys/crypto/openssl',
        'C-C++/ThirdPartyLibrarys/crypto/cryptopp',
        'C-C++/ThirdPartyLibrarys/crypto/botan',
        'C-C++/ThirdPartyLibrarys/crypto/libtomcrypt',
        'C-C++/ThirdPartyLibrarys/tools/spdlog',
        'C-C++/ThirdPartyLibrarys/tools/glog',
        'C-C++/ThirdPartyLibrarys/tools/log4cplus',
        'C-C++/ThirdPartyLibrarys/tools/googletest',
        'C-C++/ThirdPartyLibrarys/tools/uthash',
        'C-C++/ThirdPartyLibrarys/tools/cppjieba'
    ]

    for submodule in submodules:
        os.system("git submodule deinit -f " + submodule)
        os.system("git rm --cached " + submodule)

        convertedSubmodule = submodule.replace('/', '\\')
        os.system("rmdir /s /q " + convertedSubmodule)
        os.system("rmdir /s /q .git\\modules\\" + convertedSubmodule)

    os.system("rmdir /s /q C-C++\\ThirdPartyLibrarys")
    os.system("rmdir /s /q .gitmodules")
    os.system("rmdir /s /q .git\\modules\\C-C++")
