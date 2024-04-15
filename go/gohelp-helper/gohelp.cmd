@echo off

set URL_LIST=%USERPROFILE%\Dropbox\config\golang_std_url.txt

REM golang_std_url.txt から urlの最後の部分を抽出する
for /f "usebackq delims=" %%A in (`type %URL_LIST% ^| fzf`) do set STD=%%A

REM 関数名を決定してブラウザで開く先を決定する
for /f "usebackq delims=" %%A in (`gohelp-helper -d https://pkg.go.dev/%STD% ^| fzf`) do set URL=%%A

REM "func (b *Writer) Flush() error #Writer.Flush" のWriter.Flush部分を抽出する
for /f "tokens=2 delims=:#" %%A in ("%URL%") do set OPEN_URL=https://pkg.go.dev/%STD%#%%A

REM echo %OPEN_URL%
start %OPEN_URL%

REM vim: foldmethod=marker ft=dosbatch fenc=cp932 ff=dos
