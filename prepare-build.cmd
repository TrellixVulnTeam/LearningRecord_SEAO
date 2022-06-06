@echo off

set use_proxy=0
set http_proxy_cmd=""
set https_proxy_cmd=""
if /I "%1"=="proxy" (
	set use_proxy=1
	set http_proxy_cmd= -e "http_proxy=http://%2"
	set https_proxy_cmd= -e "https_proxy=https://%2"
	echo "proxy=%2%"
)

cd tools

::cmake
call wget.exe%https_proxy_cmd% https://github.com/Kitware/CMake/releases/download/v3.21.1/cmake-3.21.1-windows-x86_64.zip -O ./cmake-3.21.1-windows-x86_64.zip
call 7z.exe x cmake-3.21.1-windows-x86_64.zip -o.
call rename cmake-3.21.1-windows-x86_64 cmake

::Strawberry Perl
call wget.exe%https_proxy_cmd% https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.zip -O ./strawberry-perl-5.32.1.1-64bit.zip
call 7z.exe x strawberry-perl-5.32.1.1-64bit.zip -o./strawberry

::NASM
call wget.exe%https_proxy_cmd% https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.zip -O ./nasm-2.15.05.zip
call 7z.exe x nasm-2.15.05.zip -o./nasm

::Yasm
call wget.exe%http_proxy_cmd% http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe -O ./yasm/yasm.exe

::Ninja
call wget.exe%https_proxy_cmd% https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-win.zip -O ./ninja-win.zip
call 7z.exe x ninja-win.zip -o./ninja

::jom
call wget.exe%http_proxy_cmd% http://download.qt.io/official_releases/jom/jom.zip -O ./jom.zip
call 7z.exe x jom.zip -o./jom

::groff and nroff
call wget.exe%http_proxy_cmd% http://downloads.sourceforge.net/gnuwin32/groff-1.20.1-bin.zip -O ./groff.zip
call 7z.exe x groff.zip -o./groff

::curl ca
call mkdir ca
call wget.exe%https_proxy_cmd% https://curl.se/ca/cacert.pem -O ./ca/cacert.pem

::MSYS2
::wget.exe%https_proxy_cmd% https://github.com/msys2/msys2-installer/releases/download/2021-07-25/msys2-x86_64-20210725.exe -O ./msys2-x86_64-20210725.exe

cd ..