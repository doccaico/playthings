import std/[os, strformat]

import ./[utils]


const HELP_MSG = """
Usage:
    do.exe diary_search WORD"""

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 1:
    writeHelpAndExit stderr, HELP_MSG, 1
  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, HELP_MSG, 0

  const DIARY_DIR = r"C:\Users\doccaico\Dropbox\diary"
  const RG_OPT = "--color always --heading --line-number --ignore-case --sort=path"
  const LESS_OPT = "-R --silent"
  discard execShellCmd(fmt"""rg {RG_OPT} {argv[0]} {DIARY_DIR} | less {LESS_OPT}""")

when isMainModule:
  main(paramCount(), commandLineParams())
