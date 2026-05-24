import std/[os, osproc, strformat, strutils]


proc writeHelpAndExit(stdio: File, code: int) {.noreturn.} =
  stdio.writeLine "Usage:"
  stdio.writeLine "    do.exe wiki COUNT"
  quit code

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 1:
    writeHelpAndExit stderr, 1

  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, 0

  const temp = r"C:\Users\doccaico\Downloads\temp.txt"

  let cmd = fmt"""cmd /c "curl -L -s https://ja.wikipedia.org/w/api.php --get
    --data "format=json"
    --data "action=query"
    --data "list=random"
    --data "rnnamespace=0"
    --data "rnfilterredir=nonredirects"
    --data "rnlimit={argv[0]}"
    > {temp}"""".replace('\n', ' ')

  discard execCmd(cmd)

  let ids = execCmdEx(fmt"""jq -r ".query.random[] | .id" {temp}""").output.strip().split('\n')
  let titles = execCmdEx(fmt"""jq -r ".query.random[] | .title" {temp}""").output.strip().split('\n')

  removeFile(temp)

  doAssert(ids.len == titles.len)

  var f: File
  if open(f, temp, fmWrite):
    for i in 0..<ids.len:
      # colors
      # https://stackoverflow.com/questions/6297072/color-for-the-prompt-just-the-prompt-proper-in-cmd-exe-and-powershell
      f.writeLine fmt("[35m{i + 1}[0m:[36m{titles[i]}[0m: [32mhttps://ja.wikipedia.org/?curid={ids[i]}[0m")
    close(f)
  discard execCmd(fmt"less -R --silent {temp}")
  removeFile(temp)

when isMainModule:
  main(paramCount(), commandLineParams())
