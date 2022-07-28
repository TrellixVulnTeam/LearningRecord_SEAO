@echo off

if "%PROCESSOR_ARCHITECTURE%"=="x86" goto x86
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto x64
exit

:x64
tools\python38\x64\python.exe init-submodules.py
exit
 
:x86
tools\python38\x86\python.exe init-submodules.py
exit