@echo off

cd tools

::cmake
wget.exe https://github.com/Kitware/CMake/releases/download/v3.21.1/cmake-3.21.1-windows-x86_64.zip -O ./cmake-3.21.1-windows-x86_64.zip
7z.exe x cmake-3.21.1-windows-x86_64.zip -o.
rename cmake-3.21.1-windows-x86_64 cmake

::Strawberry Perl
wget.exe https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.zip -O ./strawberry-perl-5.32.1.1-64bit.zip
7z.exe x strawberry-perl-5.32.1.1-64bit.zip -o./strawberry

::NASM
wget.exe https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.zip -O ./nasm-2.15.05.zip
7z.exe x nasm-2.15.05.zip -o./nasm

::Yasm
wget.exe http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe -O ./yasm/yasm.exe

::Ninja
wget.exe https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-win.zip -O ./ninja-win.zip
7z.exe x ninja-win.zip -o./ninja

::jom
wget.exe http://download.qt.io/official_releases/jom/jom.zip -O ./jom.zip
7z.exe x jom.zip -o./jom

::curl ca
mkdir ca
wget.exe https://curl.se/ca/cacert.pem -O ./ca/cacert.pem

::MSYS2
::wget.exe https://github.com/msys2/msys2-installer/releases/download/2021-07-25/msys2-x86_64-20210725.exe -O ./msys2-x86_64-20210725.exe

SET PATH=%cd%\strawberry\perl\bin;%cd%\nasm;%cd%\jom;%cd%\cmake\bin;%cd%\yasm;%PATH%

::openssl
cd ..\C-C++\ThirdPartyLibrarys\crypto\openssl
git checkout OpenSSL_1_1_1k
perl Configure VC-WIN32 --prefix=%cd%\Win32\Debug --debug no-asm no-zlib no-tests CFLAGS=
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

.\buildconf.bat
cd .\winbuild
nmake /f Makefile.vc mode=dll clean
nmake /f Makefile.vc mode=dll VC=16 GEN_PDB=yes DEBUG=yes MACHINE=x86 WITH_DEVEL=../deps/Win32/Debug WITH_SSL=dll WITH_ZLIB=dll ENABLE_UNICODE=yes
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.exe ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.pdb ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\libcurl_debug.dll ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.lib ..\..\..\..\Output\Win32\Debug /y
xcopy ..\builds\libcurl-vc16-x86-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.pdb ..\..\..\..\Output\Win32\Debug /y
set CUR_PATH=%cd%
cd ..\..\..\..\Output\Win32\Debug
ren libcurl_debug.dll libcurl.dll
ren libcurl_debug.lib libcurl.lib
ren libcurl_debug.pdb libcurl.pdb
cd %CUR_PATH%

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