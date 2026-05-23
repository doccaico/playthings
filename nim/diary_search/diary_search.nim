# 2026/05/24 (Nim Compiler Version 2.2.10)
# nim c -d:release --opt:size --threads:off --mm:arc --cc:vcc diary_search.nim

import std/[os, osproc, strformat]


proc writeHelpAndExit(stdio: File, code: int) =
  stdio.writeLine "Usage: diary_search.exe WORD"
  quit code

const
  diary_directory = r"C:\Users\doccaico\Dropbox\diary"

let argc = paramCount()

if argc == 0 or argc > 1:
  writeHelpAndExit stderr, 1

if paramStr(1) == "-h" or paramStr(1) == "--help":
  writeHelpAndExit stdout, 0

let word = paramStr(1)

discard execCmd(fmt"""cmd /c "rg --color always --heading --line-number --ignore-case --sort=path {word} {diary_directory} | less -R"""")
