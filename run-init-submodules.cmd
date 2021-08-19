@echo off
type nul> .gitmodules
for /f "delims=" %%i in (init-submodules.txt) do (%%i)
