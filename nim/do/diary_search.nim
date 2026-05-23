import std/[osproc, strformat]


proc writeHelpAndExit(stdio: File, code: int) {.noreturn.} =
  stdio.writeLine "Usage:"
  stdio.writeLine "    do.exe diary_search WORD"
  quit code

const DIARY_DIR = r"C:\Users\doccaico\Dropbox\diary"

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 1:
    writeHelpAndExit stderr, 1
  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, 0

  let word = argv[0]

  discard execCmd(fmt"""cmd /c "rg --color always --heading --line-number --ignore-case --sort=path {word} {DIARY_DIR} | less -R --silent"""")

when isMainModule:
  main(paramCount(), commandLineParams())
