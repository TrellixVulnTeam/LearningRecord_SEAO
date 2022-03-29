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

::groff and nroff
wget.exe http://downloads.sourceforge.net/gnuwin32/groff-1.20.1-bin.zip -O ./groff.zip
7z.exe x groff.zip -o./groff

::curl ca
mkdir ca
wget.exe https://curl.se/ca/cacert.pem -O ./ca/cacert.pem

::MSYS2
::wget.exe https://github.com/msys2/msys2-installer/releases/download/2021-07-25/msys2-x86_64-20210725.exe -O ./msys2-x86_64-20210725.exe