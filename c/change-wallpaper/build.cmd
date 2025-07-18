@echo off

setlocal

set SRC=main.c
set EXE=change_wallpaper.exe

set CFLAGS=-std:c11 -nologo -utf-8 -Oi -fp:precise -MP -FC -GF 
set WARNINGS=-W4 -wd4100 -wd4101 -wd4127 -wd4146 -wd4505 -wd4456 -wd4457
set DEFS=-DUNICODE -D_UNICODE -D_CRT_SECURE_NO_WARNINGS
set LIBS=user32.lib shlwapi.lib
set LINKS=-link %LIBS% -debug -entry:wmainCRTStartup -incremental:no

if        "%1" == "--debug"    ( goto :DEBUG
) else if "%1" == "--asan"     ( goto :ASAN
) else if "%1" == "--release"  ( goto :RELEASE
) else (
  echo Usage : %0 [--debug^|--asan^|--release]
  goto :EOF
)

:DEBUG
    set CFLAGS=%CFlAGS% -Od -MDd -Zi %WARNINGS%
    set DEFS=%DEFS% -DDEBUG -D_DEBUG
    cl %CFLAGS% %DEFS% %SRC% -Fe%EXE% %LINKS%
goto :EOF

:ASAN
    set CFLAGS=%CFlAGS% -Od -MDd -Zi %WARNINGS% -fsanitize=address 
    set DEFS=%DEFS% -DDEBUG -D_DEBUG
    cl %CFLAGS% %DEFS% %SRC% -Fe%EXE% %LINKS%
goto :EOF

:RELEASE
    set CFLAGS=%CFlAGS% -O2 -MT %WARNINGS%
    set DEFS=%DEFS% -DNDEBUG -D_NDEBUG
    cl %CFLAGS% %DEFS% %SRC% -Fe%EXE% %LINKS%
goto :EOF

endlocal
