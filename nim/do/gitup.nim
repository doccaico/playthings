import std/[os, osproc, strutils, strformat]


proc writeHelpAndExit(stdio: File, code: int) {.noreturn.} =
  stdio.writeLine "Usage:"
  stdio.writeLine "    do.exe gitup \"Up\""
  quit code

const GIT = "git"

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 2:
    writeHelpAndExit stderr, 1
  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, 0
  if findExe(GIT) == "":
    quit fmt"You need '{GIT}'.", 1

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
  echo execCmdEx("git push").output

when isMainModule:
  main(paramCount(), commandLineParams())
