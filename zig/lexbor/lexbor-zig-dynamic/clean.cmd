@echo off

setlocal

rmdir /S /Q %USERPROFILE%\AppData\Local\zig
rmdir /S /Q .zig-cache
rmdir /S /Q zig-out

endlocal
