@echo off

setlocal

REM core
odin test tests\core\test_core_array.odin -file
odin test tests\core\test_core_array_obj.odin -file
odin test tests\core\test_core_avl.odin -file
odin test tests\core\test_core_mraw.odin -file

endlocal

REM vim: ft=dosbatch fenc=cp932 ff=dos
