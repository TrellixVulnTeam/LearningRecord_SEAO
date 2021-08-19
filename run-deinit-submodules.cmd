@echo off
for /f "delims=" %%i in (deinit-submodules.txt) do (%%i)
