import std/[os, osproc, strutils, strformat]

import ./[utils]


const HELP_MSG = """
Usage:
    do.exe gitup [OPTION] DIR "Up"
    do.exe gitup [OPTION]     "Up"
OPTION:
    -h, --help                 ヘルプメッセージを表示"""

proc run*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 2:
    printMsgAndExit stderr, HELP_MSG, QuitFailure
  if argv[0] == "-h" or argv[0] == "--help":
    printMsgAndExit stdout, HELP_MSG, QuitSuccess

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

  var statusRes = execCmdEx("git status --porcelain")
  if statusRes.exitCode != 0:
     printMsgAndExit stderr, "not a git repository (or git command failed)", QuitFailure

  let statusOutput = statusRes.output.strip()
  if statusOutput == "":
    printMsgAndExit stdout, "There is no need to update.", QuitSuccess

  # git add
  if execCmd("git add .") != 0:
    printMsgAndExit stderr, "failed to run 'git add .'", QuitFailure

  # git commit
  let commitRes = execCmdEx(fmt"git commit -m {commitMsg.quoteShell}")
  if commitRes.exitCode != 0:
    stderr.writeLine commitRes.output
    printMsgAndExit stderr, "failed to run 'git commit'", QuitFailure

  # git push
  let pushRes = execCmdEx("git push")
  stdout.writeLine pushRes.output
  if pushRes.exitCode != 0:
    printMsgAndExit stderr, "failed to run 'git push'", QuitFailure

when isMainModule:
  run(commandLineParams())
