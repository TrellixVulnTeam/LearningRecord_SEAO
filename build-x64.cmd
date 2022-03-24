@echo off

SET PATH=%cd%\tools\strawberry\perl\bin;%cd%\tools\nasm;%cd%\tools\jom;%cd%\tools\cmake\bin;%cd%\tools\yasm;%cd%\tools\groff\bin;%PATH%

::openssl
cd C-C++\ThirdPartyLibrarys\crypto\openssl
git checkout OpenSSL_1_1_1k
perl Configure VC-WIN64A --prefix=%cd%\x64\Debug --debug no-asm no-zlib no-tests
nmake
nmake install
mkdir ..\..\..\Includes\OpenSSL_1_1_1k
xcopy %cd%\x64\Debug\include ..\..\..\Includes\OpenSSL_1_1_1k /s /e /y
xcopy %cd%\x64\Debug\bin ..\..\..\Output\x64\Debug /s /e /y
xcopy %cd%\x64\Debug\lib ..\..\..\Output\x64\Debug /s /e /y
nmake clean
rmdir /s /q x64\Debug
perl Configure VC-WIN64A --prefix=%cd%\x64\Release --release no-asm no-zlib no-tests
nmake
nmake install
xcopy %cd%\x64\Release\bin ..\..\..\Output\x64\Release /s /e /y
xcopy %cd%\x64\Release\lib ..\..\..\Output\x64\Release /s /e /y
nmake clean
rmdir /s /q x64
git checkout master

::zlib
cd ..\..\compression\zlib
nmake -f win32/Makefile.msc clean
nmake -f win32/Makefile.msc CFG=debug
mkdir ..\..\..\Includes\zlib
xcopy %cd%\zlib.h ..\..\..\Includes\zlib /y
xcopy %cd%\zconf.h ..\..\..\Includes\zlib /y
xcopy %cd%\zutil.h ..\..\..\Includes\zlib /y
xcopy %cd%\zlib.lib ..\..\..\Output\x64\Debug /y
xcopy %cd%\zlib.pdb ..\..\..\Output\x64\Debug /y
xcopy %cd%\zdll.lib ..\..\..\Output\x64\Debug /y
xcopy %cd%\zlib1.dll ..\..\..\Output\x64\Debug /y
xcopy %cd%\zlib1.pdb ..\..\..\Output\x64\Debug /y
nmake -f win32/Makefile.msc clean
nmake -f win32/Makefile.msc
xcopy %cd%\zlib.lib ..\..\..\Output\x64\Release /y
xcopy %cd%\zlib.pdb ..\..\..\Output\x64\Release /y
xcopy %cd%\zdll.lib ..\..\..\Output\x64\Release /y
xcopy %cd%\zlib1.dll ..\..\..\Output\x64\Release /y
xcopy %cd%\zlib1.pdb ..\..\..\Output\x64\Release /y
nmake -f win32/Makefile.msc clean

::curl
cd ..\..\network\curl
git checkout curl-7_79_1
mkdir deps
mkdir deps\x64
mkdir deps\x64\Debug
mkdir deps\x64\Debug\bin
mkdir deps\x64\Debug\lib
mkdir deps\x64\Debug\include
mkdir deps\x64\Release\bin
mkdir deps\x64\Release\lib
mkdir deps\x64\Release\include

xcopy ..\..\..\Output\x64\Debug\libcrypto-1_1-x64.dll %cd%\deps\x64\Debug\bin /y
xcopy ..\..\..\Output\x64\Debug\libcrypto-1_1-x64.pdb %cd%\deps\x64\Debug\lib /y
xcopy ..\..\..\Output\x64\Debug\libssl-1_1-x64.dll %cd%\deps\x64\Debug\bin /y
xcopy ..\..\..\Output\x64\Debug\libssl-1_1-x64.pdb %cd%\deps\x64\Debug\lib /y
xcopy ..\..\..\Output\x64\Debug\zlib1.dll %cd%\deps\x64\Debug\bin /y
xcopy ..\..\..\Output\x64\Debug\zlib1.pdb %cd%\deps\x64\Debug\lib /y
xcopy ..\..\..\Output\x64\Debug\libcrypto.lib %cd%\deps\x64\Debug\lib /y
xcopy ..\..\..\Output\x64\Debug\libssl.lib %cd%\deps\x64\Debug\lib /y
xcopy ..\..\..\Output\x64\Debug\zdll.lib %cd%\deps\x64\Debug\lib /y
xcopy ..\..\..\Includes\OpenSSL_1_1_1k %cd%\deps\x64\Debug\include /s /e /y
xcopy ..\..\..\Includes\zlib\zconf.h %cd%\deps\x64\Debug\include /y
xcopy ..\..\..\Includes\zlib\zlib.h %cd%\deps\x64\Debug\include /y
xcopy ..\..\..\Includes\zlib\zutil.h %cd%\deps\x64\Debug\include /y

xcopy ..\..\..\Output\x64\Release\libcrypto-1_1-x64.dll %cd%\deps\x64\Release\bin /y
xcopy ..\..\..\Output\x64\Release\libcrypto-1_1-x64.pdb %cd%\deps\x64\Release\lib /y
xcopy ..\..\..\Output\x64\Release\libssl-1_1-x64.dll %cd%\deps\x64\Release\bin /y
xcopy ..\..\..\Output\x64\Release\libssl-1_1-x64.pdb %cd%\deps\x64\Release\lib /y
xcopy ..\..\..\Output\x64\Release\zlib1.dll %cd%\deps\x64\Release\bin /y
xcopy ..\..\..\Output\x64\Release\zlib1.pdb %cd%\deps\x64\Release\lib /y
xcopy ..\..\..\Output\x64\Release\libcrypto.lib %cd%\deps\x64\Release\lib /y
xcopy ..\..\..\Output\x64\Release\libssl.lib %cd%\deps\x64\Release\lib /y
xcopy ..\..\..\Output\x64\Release\zdll.lib %cd%\deps\x64\Release\lib /y
xcopy ..\..\..\Includes\OpenSSL_1_1_1k %cd%\deps\x64\Release\include /s /e /y
xcopy ..\..\..\Includes\zlib\zconf.h %cd%\deps\x64\Release\include /y
xcopy ..\..\..\Includes\zlib\zlib.h %cd%\deps\x64\Release\include /y
xcopy ..\..\..\Includes\zlib\zutil.h %cd%\deps\x64\Release\include /y

set OS=Windows_NT
call .\buildconf.bat
set OS=
cd .\winbuild
nmake /f Makefile.vc mode=dll clean
nmake /f Makefile.vc mode=dll VC=16 GEN_PDB=yes DEBUG=yes MACHINE=x64 WITH_DEVEL=../deps/x64/Debug WITH_SSL=dll WITH_ZLIB=dll ENABLE_UNICODE=yes
xcopy ..\builds\libcurl-vc16-x64-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.exe ..\..\..\..\Output\x64\Debug /y
xcopy ..\builds\libcurl-vc16-x64-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.pdb ..\..\..\..\Output\x64\Debug /y
xcopy ..\builds\libcurl-vc16-x64-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\libcurl_debug.dll ..\..\..\..\Output\x64\Debug /y
xcopy ..\builds\libcurl-vc16-x64-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.lib ..\..\..\..\Output\x64\Debug /y
xcopy ..\builds\libcurl-vc16-x64-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl_debug.pdb ..\..\..\..\Output\x64\Debug /y

xcopy ..\builds\libcurl-vc16-x64-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\include ..\..\..\..\Includes /s /e /y

nmake /f Makefile.vc mode=dll clean
nmake /f Makefile.vc mode=dll VC=16 GEN_PDB=yes DEBUG=no MACHINE=x64 WITH_DEVEL=../deps/x64/Release WITH_SSL=dll WITH_ZLIB=dll ENABLE_UNICODE=yes
xcopy ..\builds\libcurl-vc16-x64-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.exe ..\..\..\..\Output\x64\Release /y
xcopy ..\builds\libcurl-vc16-x64-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\curl.pdb ..\..\..\..\Output\x64\Release /y
xcopy ..\builds\libcurl-vc16-x64-release-dll-ssl-dll-zlib-dll-ipv6-sspi\bin\libcurl.dll ..\..\..\..\Output\x64\Release /y
xcopy ..\builds\libcurl-vc16-x64-release-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl.lib ..\..\..\..\Output\x64\Release /y
xcopy ..\builds\libcurl-vc16-x64-release-dll-ssl-dll-zlib-dll-ipv6-sspi\lib\libcurl.pdb ..\..\..\..\Output\x64\Release /y

nmake /f Makefile.vc mode=dll clean
rmdir /s /q ..\deps
git checkout master