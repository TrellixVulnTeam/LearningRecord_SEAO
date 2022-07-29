@echo off

SET PATH=%cd%\tools\strawberry\perl\bin;%cd%\tools\nasm;%cd%\tools\jom;%cd%\tools\cmake\bin;%cd%\tools\tcl86\x86\bin;%cd%\tools\groff\bin;%PATH%

::openssl
cd C-C++\ThirdPartyLibrarys\crypto\openssl
call git checkout OpenSSL_1_1_1k
call perl Configure VC-WIN32 --prefix=%cd%\Win32\Debug --debug no-asm no-zlib no-tests
call nmake
call nmake install
call mkdir ..\..\..\Includes\OpenSSL_1_1_1k
call xcopy %cd%\Win32\Debug\include ..\..\..\Includes\OpenSSL_1_1_1k /s /e /y
call xcopy %cd%\Win32\Debug\bin ..\..\..\Output\Win32\Debug /s /e /y
call xcopy %cd%\Win32\Debug\lib ..\..\..\Output\Win32\Debug /s /e /y
call nmake clean
call rmdir /s /q Win32\Debug
call perl Configure VC-WIN32 --prefix=%cd%\Win32\Release --release no-asm no-zlib no-tests
call nmake
call nmake install
call xcopy %cd%\Win32\Release\bin ..\..\..\Output\Win32\Release /s /e /y
call xcopy %cd%\Win32\Release\lib ..\..\..\Output\Win32\Release /s /e /y
call nmake clean
call rmdir /s /q Win32
call git checkout master

::zlib
cd ..\..\compression\zlib
call nmake -f win32/Makefile.msc clean
call nmake -f win32/Makefile.msc CFG=debug
call mkdir ..\..\..\Includes\zlib
call xcopy %cd%\zlib.h ..\..\..\Includes\zlib /y
call xcopy %cd%\zconf.h ..\..\..\Includes\zlib /y
call xcopy %cd%\zutil.h ..\..\..\Includes\zlib /y
call xcopy %cd%\zlib.lib ..\..\..\Output\Win32\Debug /y
call xcopy %cd%\zlib.pdb ..\..\..\Output\Win32\Debug /y
call xcopy %cd%\zdll.lib ..\..\..\Output\Win32\Debug /y
call xcopy %cd%\zlib1.dll ..\..\..\Output\Win32\Debug /y
call xcopy %cd%\zlib1.pdb ..\..\..\Output\Win32\Debug /y
call nmake -f win32/Makefile.msc clean
call nmake -f win32/Makefile.msc
call xcopy %cd%\zlib.lib ..\..\..\Output\Win32\Release /y
call xcopy %cd%\zlib.pdb ..\..\..\Output\Win32\Release /y
call xcopy %cd%\zdll.lib ..\..\..\Output\Win32\Release /y
call xcopy %cd%\zlib1.dll ..\..\..\Output\Win32\Release /y
call xcopy %cd%\zlib1.pdb ..\..\..\Output\Win32\Release /y
call nmake -f win32/Makefile.msc clean

::libzip
cd ..\libzip
call xcopy ..\zlib vstudio\zlib /e /y
call rmdir /s /q vstudio\zlib\build
call rmdir /s /q vstudio\zlib\installed
call del lib\config.h
call del lib\zipconf.h
call del lib\zip_err_str.c
call rmdir /s /q build
call cd vstudio
call vsbuild build "Visual Studio 16 2019" v142 Win32
call xcopy ..\build\config.h ..\lib /y
call xcopy ..\build\zipconf.h ..\lib /y
call xcopy ..\build\lib\zip_err_str.c ..\lib /y
call xcopy ..\build\lib\Debug\zip.lib ..\..\..\..\Output\Win32\Debug /y
call xcopy ..\build\lib\Debug\zip.dll ..\..\..\..\Output\Win32\Debug /y
call xcopy ..\build\lib\Debug\zip.pdb ..\..\..\..\Output\Win32\Debug /y
call xcopy ..\build\lib\RelWithDebInfo\zip.lib ..\..\..\..\Output\Win32\Release /y
call xcopy ..\build\lib\RelWithDebInfo\zip.dll ..\..\..\..\Output\Win32\Release /y
call xcopy ..\build\lib\RelWithDebInfo\zip.pdb ..\..\..\..\Output\Win32\Release /y
call rmdir /s /q ..\build
call rmdir /s /q zlib\build
call rmdir /s /q zlib\installed

::curl
cd ..\..\..\network\curl
call git checkout curl-7_79_1
call mkdir deps
call mkdir deps\Win32
call mkdir deps\Win32\Debug
call mkdir deps\Win32\Debug\bin
call mkdir deps\Win32\Debug\lib
call mkdir deps\Win32\Debug\include
call mkdir deps\Win32\Release\bin
call mkdir deps\Win32\Release\lib
call mkdir deps\Win32\Release\include

call xcopy ..\..\..\Output\Win32\Debug\libcrypto-1_1.dll %cd%\deps\Win32\Debug\bin /y
call xcopy ..\..\..\Output\Win32\Debug\libcrypto-1_1.pdb %cd%\deps\Win32\Debug\lib /y
call xcopy ..\..\..\Output\Win32\Debug\libssl-1_1.dll %cd%\deps\Win32\Debug\bin /y
call xcopy ..\..\..\Output\Win32\Debug\libssl-1_1.pdb %cd%\deps\Win32\Debug\lib /y
call xcopy ..\..\..\Output\Win32\Debug\zlib1.dll %cd%\deps\Win32\Debug\bin /y
call xcopy ..\..\..\Output\Win32\Debug\zlib1.pdb %cd%\deps\Win32\Debug\lib /y
call xcopy ..\..\..\Output\Win32\Debug\libcrypto.lib %cd%\deps\Win32\Debug\lib /y
call xcopy ..\..\..\Output\Win32\Debug\libssl.lib %cd%\deps\Win32\Debug\lib /y
call xcopy ..\..\..\Output\Win32\Debug\zdll.lib %cd%\deps\Win32\Debug\lib /y
call xcopy ..\..\..\Includes\OpenSSL_1_1_1k %cd%\deps\Win32\Debug\include /s /e /y
call xcopy ..\..\..\Includes\zlib\zconf.h %cd%\deps\Win32\Debug\include /y
call xcopy ..\..\..\Includes\zlib\zlib.h %cd%\deps\Win32\Debug\include /y
call xcopy ..\..\..\Includes\zlib\zutil.h %cd%\deps\Win32\Debug\include /y

call xcopy ..\..\..\Output\Win32\Release\libcrypto-1_1.dll %cd%\deps\Win32\Release\bin /y
call xcopy ..\..\..\Output\Win32\Release\libcrypto-1_1.pdb %cd%\deps\Win32\Release\lib /y
call xcopy ..\..\..\Output\Win32\Release\libssl-1_1.dll %cd%\deps\Win32\Release\bin /y
call xcopy ..\..\..\Output\Win32\Release\libssl-1_1.pdb %cd%\deps\Win32\Release\lib /y
call xcopy ..\..\..\Output\Win32\Release\zlib1.dll %cd%\deps\Win32\Release\bin /y
call xcopy ..\..\..\Output\Win32\Release\zlib1.pdb %cd%\deps\Win32\Release\lib /y
call xcopy ..\..\..\Output\Win32\Release\libcrypto.lib %cd%\deps\Win32\Release\lib /y
call xcopy ..\..\..\Output\Win32\Release\libssl.lib %cd%\deps\Win32\Release\lib /y
call xcopy ..\..\..\Output\Win32\Release\zdll.lib %cd%\deps\Win32\Release\lib /y
call xcopy ..\..\..\Includes\OpenSSL_1_1_1k %cd%\deps\Win32\Release\include /s /e /y
call xcopy ..\..\..\Includes\zlib\zconf.h %cd%\deps\Win32\Release\include /y
call xcopy ..\..\..\Includes\zlib\zlib.h %cd%\deps\Win32\Release\include /y
call xcopy ..\..\..\Includes\zlib\zutil.h %cd%\deps\Win32\Release\include /y

set OS=Windows_NT
call .\buildconf.bat
set OS=
cd .\winbuild
call nmake /f Makefile.vc mode=dll clean
call nmake /f Makefile.vc mode=dll VC=16 GEN_PDB=yes DEBUG=yes MACHINE=x86 WITH_DEVEL=../deps/Win32/Debug WITH_SSL=dll WITH_ZLIB=dll ENABLE_UNICODE=yes
call xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.exe ..\..\..\..\Output\Win32\Debug /y
call xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.pdb ..\..\..\..\Output\Win32\Debug /y
call xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\libcurl_debug.dll ..\..\..\..\Output\Win32\Debug /y
call xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.lib ..\..\..\..\Output\Win32\Debug /y
call xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.pdb ..\..\..\..\Output\Win32\Debug /y

call xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\include ..\..\..\..\Includes /s /e /y

call nmake /f Makefile.vc mode=dll clean
call nmake /f Makefile.vc mode=dll VC=16 GEN_PDB=yes DEBUG=no MACHINE=x86 WITH_DEVEL=../deps/Win32/Release WITH_SSL=dll WITH_ZLIB=dll ENABLE_UNICODE=yes
call xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.exe ..\..\..\..\Output\Win32\Release /y
call xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.pdb ..\..\..\..\Output\Win32\Release /y
call xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\libcurl.dll ..\..\..\..\Output\Win32\Release /y
call xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl.lib ..\..\..\..\Output\Win32\Release /y
call xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl.pdb ..\..\..\..\Output\Win32\Release /y

call nmake /f Makefile.vc mode=dll clean
call rmdir /s /q ..\deps
call git checkout master

::cJSON
cd ..\..\..\json\cJSON
call git checkout v1.7.15
call mkdir build-x86
call cmake -S . -B build-x86 -G "Visual Studio 16 2019" -A Win32 -T v142
call msbuild /P:Configuration=Debug build-x86\ALL_BUILD.vcxproj
call msbuild /P:Configuration=RelWithDebInfo build-x86\ALL_BUILD.vcxproj
call mkdir ..\..\..\Includes\cJSON
call xcopy cJSON.h ..\..\..\Includes\cJSON /y
call xcopy cJSON_Utils.h ..\..\..\Includes\cJSON /y
call xcopy build-x86\Debug\cjson.lib ..\..\..\Output\Win32\Debug /y
call xcopy build-x86\Debug\cjson.dll ..\..\..\Output\Win32\Debug /y
call xcopy build-x86\Debug\cjson.pdb ..\..\..\Output\Win32\Debug /y
call xcopy build-x86\RelWithDebInfo\cjson.lib ..\..\..\Output\Win32\Release /y
call xcopy build-x86\RelWithDebInfo\cjson.dll ..\..\..\Output\Win32\Release /y
call xcopy build-x86\RelWithDebInfo\cjson.pdb ..\..\..\Output\Win32\Release /y
call rmdir /s /q build-x86
call git checkout master

::TinyXML2
cd ..\..\xml\tinyxml2
call git checkout 9.0.0
call mkdir build-x86
call cmake -S . -B build-x86 -G "Visual Studio 16 2019" -A Win32 -T v142 -D tinyxml2_SHARED_LIBS=1
call msbuild /P:Configuration=Debug build-x86\ALL_BUILD.vcxproj
call msbuild /P:Configuration=RelWithDebInfo build-x86\ALL_BUILD.vcxproj
call mkdir ..\..\..\Includes\tinyxml2
call xcopy tinyxml2.h ..\..\..\Includes\tinyxml2 /y
call xcopy build-x86\Debug\tinyxml2.lib ..\..\..\Output\Win32\Debug /y
call xcopy build-x86\Debug\tinyxml2.dll ..\..\..\Output\Win32\Debug /y
call xcopy build-x86\Debug\tinyxml2.pdb ..\..\..\Output\Win32\Debug /y
call xcopy build-x86\RelWithDebInfo\tinyxml2.lib ..\..\..\Output\Win32\Release /y
call xcopy build-x86\RelWithDebInfo\tinyxml2.dll ..\..\..\Output\Win32\Release /y
call xcopy build-x86\RelWithDebInfo\tinyxml2.pdb ..\..\..\Output\Win32\Release /y
call rmdir /s /q build-x86
call git checkout master

::SQLite 
cd ..\..\database
call mkdir build-sqlite
cd build-sqlite
call nmake /f ..\sqlite\Makefile.msc TOP=..\sqlite USE_CRT_DLL=1 DEBUG=3
call mkdir ..\..\..\Includes\sqlite
call xcopy sqlite3.h ..\..\..\Includes\sqlite3 /y
call xcopy sqlite3ext.h ..\..\..\Includes\sqlite /y
call xcopy sqlite3.lib ..\..\..\Output\Win32\Debug /y
call xcopy sqlite3.dll ..\..\..\Output\Win32\Debug /y
call xcopy sqlite3.pdb ..\..\..\Output\Win32\Debug /y
call xcopy sqlite3.exe ..\..\..\Output\Win32\Debug /y
cd ..
call rmdir /s /q build-sqlite
call mkdir build-sqlite
cd build-sqlite
call nmake /f ..\sqlite\Makefile.msc TOP=..\sqlite USE_CRT_DLL=1
call xcopy sqlite3.lib ..\..\..\Output\Win32\Release /y
call xcopy sqlite3.dll ..\..\..\Output\Win32\Release /y
call xcopy sqlite3.pdb ..\..\..\Output\Win32\Release /y
call xcopy sqlite3.exe ..\..\..\Output\Win32\Release /y
cd ..
call rmdir /s /q build-sqlite

::SQLCipher 
cd ..\..\database\sqlcipher
call nmake /f Makefile-x86-debug.msc clean
call nmake /f Makefile-x86-debug.msc TOP=. DEBUG=2 USE_CRT_DLL=1
call tclsh .\tool\mkbuild-sqlite3h.tcl . > sqlite3.h
call mkdir ..\..\..\Includes\sqlcipher
call xcopy sqlite3.h ..\..\..\Includes\sqlcipher /y
call xcopy sqlcipher.lib ..\..\..\Output\Win32\Debug /y
call xcopy sqlcipher.dll ..\..\..\Output\Win32\Debug /y
call xcopy sqlcipher.pdb ..\..\..\Output\Win32\Debug /y
call nmake /f Makefile-x86-release.msc clean
call nmake /f Makefile-x86-release.msc TOP=. USE_CRT_DLL=1
call xcopy sqlcipher.lib ..\..\..\Output\Win32\Release /y
call xcopy sqlcipher.dll ..\..\..\Output\Win32\Release /y
call xcopy sqlcipher.pdb ..\..\..\Output\Win32\Release /y
call nmake /f Makefile-x86-release.msc clean

::ideviceinstaller libcnary libimobiledevice libimobiledevice-glue libplist libusbmuxd
cd ..\..\apple\libimobiledevice
call git checkout master
cd ..\libimobiledevice-glue
call git checkout master
cd ..\libplist
call git checkout master
cd ..\libusbmuxd
call git checkout master
cd ..\ideviceinstaller
call git checkout master
call rmdir /s /q Win32
call msbuild /P:Configuration=Debug ideviceinstaller.vcxproj
call msbuild /P:Configuration=Release ideviceinstaller.vcxproj
call rmdir /s /q Win32

::libiconv
cd ..\..\character-encoding\libiconv
call git checkout main
call rmdir /s /q Win32
call msbuild /P:Configuration=Debug libiconv.vcxproj
call msbuild /P:Configuration=Release libiconv.vcxproj
call rmdir /s /q Win32