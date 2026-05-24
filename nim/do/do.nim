# 2026/05/24 (Nim Compiler Version 2.2.10)
# nimble install regex puppy winim
# nim c -d:release --opt:size --threads:off --mm:arc --cc:vcc do.nim

import ./[
  diary_search,
  gitup,
  shitaraba,
  delete_duplicate_path,
  verse,
]


proc writeHelpAndExit(stdio: File, code: int) {.noreturn.} =
  stdio.writeLine "Usage:"
  stdio.writeLine "    do.exe KIND"
  stdio.writeLine "Kinds:"
  stdio.writeLine "    diary_search                日記を検索" # rg, less
  stdio.writeLine "    gitup                       GithubにPush" # git
  stdio.writeLine "    shitaraba                   Shitarabaを閲覧" # less
  stdio.writeLine "    delete_duplicate_path       環境変数PATHの重複を解消して表示"
  stdio.writeLine "    verse                       聖書(新共同訳)を表示" # less
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
  of "delete_duplicate_path": delete_duplicate_path.main()
  of "verse": verse.main(argc - 1, argv[1..^1])
  else: writeHelpAndExit stderr, 1

when isMainModule:
  import std/[os]
  main(paramCount(), commandLineParams())
