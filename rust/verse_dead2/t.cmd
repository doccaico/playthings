@echo off

REM set�Őݒ肵���ϐ������[�J���ϐ��ɂ���
setlocal

REM Creating a Newline variable (the two blank lines are required!)
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%

REM echo �n���[���[���h
echo a\nb\nc
echo a%NL%b%NL%c

endlocal

REM vim: ft=dosbatch fenc=cp932 ff=dos

