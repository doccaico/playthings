# 2026/05/24 (Nim Compiler Version 2.2.10)
# nimble install regex puppy
# nim c -d:release --opt:size --threads:off --mm:arc --cc:vcc do.nim

import std/[os]

import ./[diary_search, gitup, shitaraba]


proc writeHelpAndExit(stdio: File, code: int) {.noreturn.} =
  stdio.writeLine "Usage:"
  stdio.writeLine "    do.exe diary_search"
  stdio.writeLine "    do.exe gitup"
  stdio.writeLine "    do.exe shitaraba"
  quit code

proc main(argc: int, argv: seq[string]) =
  if argc == 0:
    writeHelpAndExit stderr, 1
  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, 0
  case argv[0]
  of "diary_search": diary_search.main(argc - 1, argv[1..^1])
  of "gitup": gitup.main(argc - 1, argv[1..^1])
  of "shitaraba": shitaraba.main(argc - 1, argv[1..^1])
  else: writeHelpAndExit stderr, 1

when isMainModule:
  main(paramCount(), commandLineParams())
