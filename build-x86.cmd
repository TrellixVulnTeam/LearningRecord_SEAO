@echo off

SET PATH=%cd%\tools\strawberry\perl\bin;%cd%\tools\nasm;%cd%\tools\jom;%cd%\tools\cmake\bin;%cd%\tools\yasm;%cd%\tools\groff\bin;%PATH%

::openssl
cd C-C++\ThirdPartyLibrarys\crypto\openssl
git checkout OpenSSL_1_1_1k
perl Configure VC-WIN32 --prefix=%cd%\Win32\Debug --debug no-asm no-zlib no-tests
nmake
nmake install
mkdir ..\..\..\Includes\OpenSSL_1_1_1k
xcopy %cd%\Win32\Debug\include ..\..\..\Includes\OpenSSL_1_1_1k /s /e /y
xcopy %cd%\Win32\Debug\bin ..\..\..\Output\Win32\Debug /s /e /y
xcopy %cd%\Win32\Debug\lib ..\..\..\Output\Win32\Debug /s /e /y
nmake clean
rmdir /s /q Win32\Debug
perl Configure VC-WIN32 --prefix=%cd%\Win32\Release --release no-asm no-zlib no-tests
nmake
nmake install
xcopy %cd%\Win32\Release\bin ..\..\..\Output\Win32\Release /s /e /y
xcopy %cd%\Win32\Release\lib ..\..\..\Output\Win32\Release /s /e /y
nmake clean
rmdir /s /q Win32
git checkout master

::zlib
cd ..\..\compression\zlib
nmake -f win32/Makefile.msc clean
nmake -f win32/Makefile.msc CFG=debug
mkdir ..\..\..\Includes\zlib
xcopy %cd%\zlib.h ..\..\..\Includes\zlib /y
xcopy %cd%\zconf.h ..\..\..\Includes\zlib /y
xcopy %cd%\zutil.h ..\..\..\Includes\zlib /y
xcopy %cd%\zlib.lib ..\..\..\Output\Win32\Debug /y
xcopy %cd%\zlib.pdb ..\..\..\Output\Win32\Debug /y
xcopy %cd%\zdll.lib ..\..\..\Output\Win32\Debug /y
xcopy %cd%\zlib1.dll ..\..\..\Output\Win32\Debug /y
xcopy %cd%\zlib1.pdb ..\..\..\Output\Win32\Debug /y
nmake -f win32/Makefile.msc clean
nmake -f win32/Makefile.msc
xcopy %cd%\zlib.lib ..\..\..\Output\Win32\Release /y
xcopy %cd%\zlib.pdb ..\..\..\Output\Win32\Release /y
xcopy %cd%\zdll.lib ..\..\..\Output\Win32\Release /y
xcopy %cd%\zlib1.dll ..\..\..\Output\Win32\Release /y
xcopy %cd%\zlib1.pdb ..\..\..\Output\Win32\Release /y
nmake -f win32/Makefile.msc clean

::libzip
cd ..\libzip
xcopy ..\zlib vstudio\zlib /e /y
rmdir /s /q vstudio\zlib\build
rmdir /s /q vstudio\zlib\installed
del lib\config.h
del lib\zipconf.h
del lib\zip_err_str.c
rmdir /s /q build
cd vstudio
vsbuild build "Visual Studio 16 2019" v142 Win32
xcopy ..\build\config.h ..\lib /y
xcopy ..\build\zipconf.h ..\lib /y
xcopy ..\build\lib\zip_err_str.c ..\lib /y
xcopy ..\build\lib\Debug\zip.lib ..\..\..\..\Output\Win32\Debug /y
xcopy ..\build\lib\Debug\zip.dll ..\..\..\..\Output\Win32\Debug /y
xcopy ..\build\lib\Debug\zip.pdb ..\..\..\..\Output\Win32\Debug /y
xcopy ..\build\lib\RelWithDebInfo\zip.lib ..\..\..\..\Output\Win32\Release /y
xcopy ..\build\lib\RelWithDebInfo\zip.dll ..\..\..\..\Output\Win32\Release /y
xcopy ..\build\lib\RelWithDebInfo\zip.pdb ..\..\..\..\Output\Win32\Release /y
rmdir /s /q ..\build
rmdir /s /q zlib\build
rmdir /s /q zlib\installed

::curl
cd ..\..\network\curl
git checkout curl-7_79_1
mkdir deps
mkdir deps\Win32
mkdir deps\Win32\Debug
mkdir deps\Win32\Debug\bin
mkdir deps\Win32\Debug\lib
mkdir deps\Win32\Debug\include
mkdir deps\Win32\Release\bin
mkdir deps\Win32\Release\lib
mkdir deps\Win32\Release\include

xcopy ..\..\..\Output\Win32\Debug\libcrypto-1_1.dll %cd%\deps\Win32\Debug\bin /y
xcopy ..\..\..\Output\Win32\Debug\libcrypto-1_1.pdb %cd%\deps\Win32\Debug\lib /y
xcopy ..\..\..\Output\Win32\Debug\libssl-1_1.dll %cd%\deps\Win32\Debug\bin /y
xcopy ..\..\..\Output\Win32\Debug\libssl-1_1.pdb %cd%\deps\Win32\Debug\lib /y
xcopy ..\..\..\Output\Win32\Debug\zlib1.dll %cd%\deps\Win32\Debug\bin /y
xcopy ..\..\..\Output\Win32\Debug\zlib1.pdb %cd%\deps\Win32\Debug\lib /y
xcopy ..\..\..\Output\Win32\Debug\libcrypto.lib %cd%\deps\Win32\Debug\lib /y
xcopy ..\..\..\Output\Win32\Debug\libssl.lib %cd%\deps\Win32\Debug\lib /y
xcopy ..\..\..\Output\Win32\Debug\zdll.lib %cd%\deps\Win32\Debug\lib /y
xcopy ..\..\..\Includes\OpenSSL_1_1_1k %cd%\deps\Win32\Debug\include /s /e /y
xcopy ..\..\..\Includes\zlib\zconf.h %cd%\deps\Win32\Debug\include /y
xcopy ..\..\..\Includes\zlib\zlib.h %cd%\deps\Win32\Debug\include /y
xcopy ..\..\..\Includes\zlib\zutil.h %cd%\deps\Win32\Debug\include /y

xcopy ..\..\..\Output\Win32\Release\libcrypto-1_1.dll %cd%\deps\Win32\Release\bin /y
xcopy ..\..\..\Output\Win32\Release\libcrypto-1_1.pdb %cd%\deps\Win32\Release\lib /y
xcopy ..\..\..\Output\Win32\Release\libssl-1_1.dll %cd%\deps\Win32\Release\bin /y
xcopy ..\..\..\Output\Win32\Release\libssl-1_1.pdb %cd%\deps\Win32\Release\lib /y
xcopy ..\..\..\Output\Win32\Release\zlib1.dll %cd%\deps\Win32\Release\bin /y
xcopy ..\..\..\Output\Win32\Release\zlib1.pdb %cd%\deps\Win32\Release\lib /y
xcopy ..\..\..\Output\Win32\Release\libcrypto.lib %cd%\deps\Win32\Release\lib /y
xcopy ..\..\..\Output\Win32\Release\libssl.lib %cd%\deps\Win32\Release\lib /y
xcopy ..\..\..\Output\Win32\Release\zdll.lib %cd%\deps\Win32\Release\lib /y
xcopy ..\..\..\Includes\OpenSSL_1_1_1k %cd%\deps\Win32\Release\include /s /e /y
xcopy ..\..\..\Includes\zlib\zconf.h %cd%\deps\Win32\Release\include /y
xcopy ..\..\..\Includes\zlib\zlib.h %cd%\deps\Win32\Release\include /y
xcopy ..\..\..\Includes\zlib\zutil.h %cd%\deps\Win32\Release\include /y

set OS=Windows_NT
call .\buildconf.bat
set OS=
cd .\winbuild
nmake /f Makefile.vc mode=dll clean
nmake /f Makefile.vc mode=dll VC=16 GEN_PDB=yes DEBUG=yes MACHINE=x86 WITH_DEVEL=../deps/Win32/Debug WITH_SSL=dll WITH_ZLIB=dll ENABLE_UNICODE=yes
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.exe ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.pdb ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\libcurl_debug.dll ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.lib ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.pdb ..\..\..\..\Output\Win32\Debug /y

xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\include ..\..\..\..\Includes /s /e /y

nmake /f Makefile.vc mode=dll clean
nmake /f Makefile.vc mode=dll VC=16 GEN_PDB=yes DEBUG=no MACHINE=x86 WITH_DEVEL=../deps/Win32/Release WITH_SSL=dll WITH_ZLIB=dll ENABLE_UNICODE=yes
xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.exe ..\..\..\..\Output\Win32\Release /y
xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.pdb ..\..\..\..\Output\Win32\Release /y
xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\libcurl.dll ..\..\..\..\Output\Win32\Release /y
xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl.lib ..\..\..\..\Output\Win32\Release /y
xcopy ..\builds\libcurl-vc16-x86-release-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl.pdb ..\..\..\..\Output\Win32\Release /y

nmake /f Makefile.vc mode=dll clean
rmdir /s /q ..\deps
git checkout master