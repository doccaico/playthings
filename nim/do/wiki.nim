import std/[os, osproc, strformat, strutils]

import puppy


proc writeHelpAndExit(stdio: File, code: int) {.noreturn.} =
  stdio.writeLine "Usage:"
  stdio.writeLine "    do.exe wiki COUNT"
  quit code

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 1:
    writeHelpAndExit stderr, 1

  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, 0

  let url = fmt"""https://ja.wikipedia.org/w/api.php
?format=json
&action=query
&list=random
&rnnamespace=0
&rnfilterredir=nonredirects
&rnlimit={argv[0]}
""".replace("\n", "")

  let response = get(url)

  let ids = execCmdEx(
    fmt"""cmd /c "echo {response.body} | jq -r ".query.random[] | .id""""
  ).output.strip().split('\n')

  let titles = execCmdEx(
    fmt"""cmd /c "echo {response.body} | jq -r ".query.random[] | .title""""
  ).output.strip().split('\n')

  doAssert(ids.len == titles.len)

  const temp = r"C:\Users\doccaico\Downloads\temp.txt"
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
