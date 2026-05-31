import std/[os, osproc, strformat, encodings, strutils, parseutils, unicode]
import puppy, regex

import ./[utils]


const HELP_MSG = """
Usage:
    do.exe shitaraba GENRE ID NUMBER"""

proc convertEmoji(m: RegexMatch2, s: string): string =
  var res: int
  discard s[m.group(0)].parseInt(res)
  $Rune(res)

proc main*(argc: int, argv: seq[string]) =
  if argc == 0 or argc > 3:
    writeHelpAndExit stderr, HELP_MSG, 1

  if argv[0] == "-h" or argv[0] == "--help":
    writeHelpAndExit stdout, HELP_MSG, 0

  let (genre, id ,number) = (argv[0], argv[1], argv[2])

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

  # DEBUG
  # echo name
  # echo date
  # echo post

  doAssert(name.len == date.len and name.len == post.len)

  const TEMP = r"C:\Users\doccaico\Downloads\temp.txt"
  const LESS_OPT = "-R --silent"
  var f: File
  if open(f, TEMP, fmWrite):
    for i in 0..<name.len:
      f.writeLine fmt("[36m{name[i]}[0m: [32m{date[i]}[0m")
      f.writeLine post[i]
      f.writeLine ""
    close(f)
  discard execCmd(fmt"less {LESS_OPT} {TEMP}")
  removeFile(TEMP)

when isMainModule:
  main(paramCount(), commandLineParams())
