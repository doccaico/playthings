import std/[os, osproc, strformat, encodings, strutils, parseutils, unicode]

import puppy, regex


proc writeHelpAndExit(stdio: File, code: int) {.noreturn.} =
  stdio.writeLine "Usage:"
  stdio.writeLine "    do.exe shitaraba [genre] [id] [number]"
  quit code

proc convertEmoji(m: RegexMatch2, s: string): string =
  var res: int
  discard s[m.group(0)].parseInt(res)
  $Rune(res)

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 3:
    writeHelpAndExit stderr, 1

  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, 0

  let genre = argv[0]
  let id = argv[1]
  let number = argv[2]

  let response = get(
    fmt"https://jbbs.shitaraba.net/bbs/read.cgi/{genre}/{id}/{number}/l50",
    headers = @[("Content-Type", "text/html; charset=EUC-JP")]
  )

  let contents = response.body.convert(destEncoding="UTF-8", srcEncoding="EUC-JP")

  var name: seq[string]
  var date: seq[string]
  var post: seq[string]
  for m in findAll(contents, re2("<dt.+?<b>(\\w+?)</b>.+?：(.+?)</dt>.+?<dd>(.+?)</dd>", {regexMultiline, regexDotAll})):
    # name
    name.add contents[m.group(0)]
    # date
    date.add contents[m.group(1)].strip(leading = false)
    # post
    var body = contents[m.group(2)].strip().replace("<br>          <br>", "").replace("<br>", "")
    post.add body.replace(re2("&#(\\d+?);"), convertEmoji)

  # -- DEBUG --
  # echo name
  # echo date
  # echo post

  doAssert(name.len == date.len and name.len == post.len)

  const temp = r"C:\Users\doccaico\Downloads\temp.txt"
  var f: File
  if open(f, temp, fmWrite):
    for i in 0..<name.len:
      # colors
      # https://stackoverflow.com/questions/6297072/color-for-the-prompt-just-the-prompt-proper-in-cmd-exe-and-powershell
      f.writeLine fmt("[36m{name[i]}[0m: [32m{date[i]}[0m")
      f.writeLine post[i]
      f.writeLine ""
    close(f)
  discard execCmd(fmt"less -R --silent {temp}")
  removeFile(temp)

when isMainModule:
  main(paramCount(), commandLineParams())
