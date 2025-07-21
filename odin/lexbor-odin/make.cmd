@echo off

setlocal

set include=c:\Work\c\test-lexbor\include;%include%
set lib=.\lexbor\windows;%lib%

cl /nologo main.c lexbor.lib

endlocal

REM vim: ft=dosbatch fenc=cp932 ff=dos
