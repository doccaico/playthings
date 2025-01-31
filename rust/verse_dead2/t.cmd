@echo off

REM setで設定した変数をローカル変数にする
setlocal

REM Creating a Newline variable (the two blank lines are required!)
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%

REM echo ハローワールド
echo a\nb\nc
echo a%NL%b%NL%c

endlocal

REM vim: ft=dosbatch fenc=cp932 ff=dos

