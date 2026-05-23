# 2026/05/23 (Nim Compiler Version 2.2.10)
# nim c -d:release --opt:size --threads:off diary_search.nim

import std/[osproc, parseopt, strformat]


proc writeHelp(code: int) =
  stdout.writeLine "Usage: diary_search.exe [OPTION] WORD"
  stdout.writeLine ""
  stdout.writeLine "OPTION"
  stdout.writeLine "    -c, --color          Print in color. (default: off)"
  stdout.writeLine "    -h, --help           Display the help."
  quit code

const
  diary_directory = """C:\Users\doccaico\Dropbox\diary"""

var
  # Search word
  word = ""
  # Options
  color = false

for kind, key, val in getopt():
  case kind
  of cmdArgument:
    word = key
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h": writeHelp(0)
    of "color", "c": color = true
  of cmdEnd: assert(false) # cannot happen

if word == "":
  writeHelp(1)

if color:
  discard execCmd(fmt"""rg --heading --line-number --ignore-case --sort=path {word} {diary_directory}""")
else:
  discard execCmd(fmt"""cmd /c "rg --color never --heading --line-number --ignore-case --sort=path {word} {diary_directory} | less"""")
