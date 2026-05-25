import std/[os, osproc, strutils, strformat]

import ./[utils]


const HELP_MSG = """
Usage:
    do.exe gitup DIR "Up"
    do.exe gitup     "Up""""

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 2:
    writeHelpAndExit stderr, HELP_MSG, 1
  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, HELP_MSG, 0

  var dirPath: string
  var commitMsg: string

  if argc == 2:
    if not dirExists(argv[0]):
      quit fmt"Does not exist: {argv[0]}", 1
    dirPath = argv[0]
    commitMsg = argv[1]
  else:
    dirPath = ""
    commitMsg = argv[0]

  if dirPath != "":
    setCurrentDir dirpath

  var ret = execCmdEx("git status --porcelain").output
  ret.stripLineEnd()
  if ret == "":
    quit "There is no need to update.", 0

  discard execCmd("git add .")
  discard execCmd(fmt"""git commit -m "{commitMsg}"""")
  stdout.writeLine execCmdEx("git push").output

when isMainModule:
  main(paramCount(), commandLineParams())
