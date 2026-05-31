# 2026/05/24 (Nim Compiler Version 2.2.10)
# nimble install regex puppy
# nim c -d:release --opt:size --threads:off --mm:arc --cc:vcc do.nim

import std/[os, strformat]

import ./[utils]

import ./[
  diary_search,            # less, rg
  # gitup,                   # git
  # shitaraba,               # less
  # delete_duplicate_path,
  # verse,                   # less
  # wiki,                    # less, jq
]


const HELP_MSG = """
Usage:
    do.exe [OPTION] COMMAND
OPTION:
    -h, --help                  ヘルプメッセージを表示
COMMAND:
    diary_search                日記を検索
    gitup                       GithubにPush
    shitaraba                   Shitarabaを閲覧
    delete_duplicate_path       環境変数PATHの重複を解消して表示
    verse                       聖書(新共同訳)を表示
    wiki                        ランダムWIKIのリストを表示"""

proc main(argc: int, argv: seq[string]) =
  if argc == 0:
    writeHelpAndExit stderr, HELP_MSG, QuitFailure
  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, HELP_MSG, QuitSuccess
  case argv[0]
  of "diary_search": diary_search.main(argc - 1, argv[1..^1])
  # of "gitup": gitup.main(argc - 1, argv[1..^1])
  # of "shitaraba": shitaraba.main(argc - 1, argv[1..^1])
  # of "delete_duplicate_path": delete_duplicate_path.main()
  # of "verse": verse.main(argc - 1, argv[1..^1])
  # of "wiki": wiki.main(argc - 1, argv[1..^1])
  else:
    stdin.writeLine fmt"unknown command '{argv[0]}'"
    writeHelpAndExit stderr, HELP_MSG, QuitFailure

when isMainModule:
  main(paramCount(), commandLineParams())
