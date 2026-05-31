import std/[os, osproc, strformat, streams]

import ./[utils]


const HELP_MSG = """
Usage:
    do.exe diary_search [OPTION] 検索キーワード
OPTION:
    -h, --help                 ヘルプメッセージを表示
REQUIRED:
    環境変数(DIARY_DIR)に日記が入っているディレクトリを設定すること"""

proc main*(argc: int, argv: seq[string]) =
  if argc == 1 and (argv[0] == "-h" or argv[0] == "--help"):
    printMsgAndExit stdout, HELP_MSG, QuitSuccess
  if argc != 1:
    printMsgAndExit stderr, HELP_MSG, QuitFailure

  let diaryDir = getEnv("DIARY_DIR")
  if diaryDir == "":
    printMsgAndExit stderr, "not found 'DIARY_DIR' in env variable", QuitFailure
  if not dirExists(diaryDir):
    printMsgAndExit stderr, fmt"'{diaryDir}' does not exist or is a file", QuitFailure

  let rgArgs = [
    "--color", "always",
    "--heading",
    "--line-number",
    "--ignore-case",
    "--sort=path",
    argv[0],
    diaryDir
  ]
  let rgOutput = execProcess("rg", args = rgArgs, options={poUsePath})
  if rgOutput == "":
    printMsgAndExit stdout, fmt"No matches found for '{argv[0]}'", QuitSuccess

  let tempDir = getEnv("TEMP")
  let tempPath = tempDir / fmt"nim_diary_search_{getCurrentProcessId()}.txt"
  try:
    writeFile(tempPath, rgOutput)
  except IOError:
    printMsgAndExit stderr, "failed to write temporary file", QuitFailure
  defer:
    if fileExists(tempPath):
      removeFile(tempPath)


  var lessProc = startProcess(
    "less", 
    args = ["-R", "-i", "--silent", tempPath], 
    options = {poUsePath, poParentStreams}
  )

  let exitCode = lessProc.waitForExit()
  lessProc.close()

  if exitCode != 0:
    printMsgAndExit stderr, "less exited with an error", QuitFailure

when isMainModule:
  main(paramCount(), commandLineParams())
