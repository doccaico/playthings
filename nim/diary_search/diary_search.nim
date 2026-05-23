# 2026/05/23 (Nim Compiler Version 2.2.10)
# nim c -d:release --opt:size --threads:off diary_search.nim

import std/[osproc, parseopt, strformat, files, paths]


proc writeHelp(code: int) =
  stdout.writeLine "Usage: diary_search.exe [OPTION] WORD"
  stdout.writeLine ""
  stdout.writeLine "OPTION"
  stdout.writeLine "    -c, --color          Print in color. (default: off)"
  stdout.writeLine "    -h, --help           Display the help."
  quit code

const
  diary_directory = """C:\Users\doccaico\Dropbox\diary"""
  output_file = """C:\Users\doccaico\Downloads\output.txt"""

var
  # Search word
  word = ""
  # Options
  color = "--color never"

for kind, key, val in getopt():
  case kind
  of cmdArgument:
    word = key
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h": writeHelp(0)
    of "color", "c": color = ""
  of cmdEnd: assert(false) # cannot happen

if word == "":
  writeHelp(1)

if color == "":
  discard execCmd(fmt"""rg {color} --heading --line-number --ignore-case --sort=path {word} {diary_directory}""")
else:
  let output = execCmdEx(fmt"""rg {color} --heading --line-number --ignore-case --sort=path {word} {diary_directory}""").output
  writeFile(output_file, output)
  discard execCmd(fmt"""cmd /c "less {output_file}"""")
  removeFile(Path(output_file))
