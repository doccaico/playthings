import std/[os, osproc, strformat, strutils]
import puppy

import ./[utils]


const HELP_MSG = """
Usage:
    do.exe wiki COUNT"""

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 1:
    writeHelpAndExit stderr, HELP_MSG, 1

  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, HELP_MSG, 0

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

  const TEMP = r"C:\Users\doccaico\Downloads\temp.txt"
  var f: File
  if open(f, TEMP, fmWrite):
    for i in 0..<ids.len:
      f.writeLine fmt"[35m{i + 1}[0m:[36m{titles[i]}[0m: [32mhttps://ja.wikipedia.org/?curid={ids[i]}[0m"
    close(f)
  const LESS_OPT = "-R --silent"
  discard execCmd(fmt"less {LESS_OPT} {TEMP}")
  removeFile(TEMP)

when isMainModule:
  main(paramCount(), commandLineParams())
