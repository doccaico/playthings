@echo off
setlocal enabledelayedexpansion
cd /D "%~dp0"

:: build          -> debug mode (implicit)
:: build debug    -> debug mode
:: build asan     -> debug mode with asan
:: build release  -> release mode

:: Unpack Arguments
for %%a in (%*) do set "%%a=1"
set L=
if not "%release%"=="1" set "debug=1"
if "%debug%"=="1"   set "release=0" && set "L=[debug mode" && if not "%asan%"=="1" set L=!L!]
if "%asan%"=="1" set "release=0" && set "debug=1" && set "L=%L% with asan]"
if "%release%"=="1" set "debug=0" && set "L=[release mode]"
echo %L%

:: Unpack Command Line Build Arguments
set auto_compile_flags=
if "%asan%"=="1" set auto_compile_flags=%auto_compile_flags% -fsanitize=address

:: Compile/Link Line Definitions
set cl_common=   -std:c11 -nologo -utf-8 -Oi -fp:precise -MP -FC -GF 
set cl_warning=  -W4 -wd4100 -wd4101 -wd4127 -wd4146 -wd4505 -wd4456 -wd4457
set cl_def=      -DUNICODE -D_UNICODE -D_CRT_SECURE_NO_WARNINGS
set cl_lib=      user32.lib shlwapi.lib
set cl_debug=    call cl -Od -MDd -Zi %cl_common% -DDEBUG -D_DEBUG %cl_def% %auto_compile_flags%
set cl_release=  call cl -O2 -MT %cl_common% -DNDEBUG -D_NDEBUG %cl_def% %auto_compile_flags%
set cl_link=     -link %cl_lib% -entry:wmainCRTStartup -incremental:no
set cl_out=      -out:

:: Choose Compile/Link Lines
if "%debug%"=="1"   set compile=%cl_debug% && set compile_link=%cl_link%
if "%release%"=="1" set compile=%cl_release% && set compile_link=%cl_link%

:: Prep Directories
if not exist build mkdir build

:: Build Everything
pushd build
%compile% ..\src\main.c %compile_link% %cl_out%change_wallpaper.exe || exit /b 1
popd
