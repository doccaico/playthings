@echo off

if        "%1" == "debug"       ( goto :DEBUG
) else if "%1" == "release"     ( goto :RELEASE
) else if "%1" == "debug-run"   ( goto :DEBUG_RUN
) else if "%1" == "release-run" ( goto :RELEASE_RUN
) else (
  echo Usage:
  echo     $ make.cmd [debug, release, debug-run, release-run]
  goto :EOF
)

:DEBUG
  odin build . -debug
goto :EOF

:RELEASE
  odin build . -o:speed
goto :EOF

:DEBUG_RUN
  odin run . -debug
goto :EOF

:RELEASE_RUN
  odin run . -o:speed
goto :EOF
