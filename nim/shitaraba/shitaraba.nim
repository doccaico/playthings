# l2026/05/23 (Nim Compiler Version 2.2.10)
# nimble install regex puppy
# nim c -d:release --opt:size --threads:off --mm:arc --cc:vcc shitaraba.nim

import std/[os, osproc, strformat, encodings, strutils, parseutils, paths, unicode, syncio, files]
import puppy, regex


proc writeHelpAndExit(stdio: File, code: int) =
  stdio.writeLine "A program to read shitaraba (https://jbbs.shitaraba.net/)."
  stdio.writeLine "    Usage: shitaraba.exe [genre] [id] [number]"
  stdio.writeLine "    Exsample: shitaraba.exe sports 12345 456789012"
  quit code

proc convertEmoji(m: RegexMatch2, s: string): string =
  var res: int
  discard s[m.group(0)].parseInt(res)
  $Rune(res)

let argc = paramCount()

if argc == 0 or argc > 3:
  writeHelpAndExit stderr, 1

if paramStr(1) == "-h" or paramStr(1) == "--help":
  writeHelpAndExit stdout, 0

let genre = paramStr(1)
let id = paramStr(2)
let number = paramStr(3)

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
  var body = contents[m.group(2)].replace(" ", "").replace("\n", "").replace("<br>", "\n").replace("<br><br>", "\n").strip(leading=false)
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
    f.writeLine fmt"[{name[i]}]: {date[i]}"
    f.writeLine post[i]
    f.writeLine ""
  close(f)

discard execCmd(fmt"less {temp}")

removeFile(Path(temp))
