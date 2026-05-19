# 2026/05/19 (Nim Compiler Version 2.2.10)
# nim c -d:release gitup.nim

import std/[os, osproc, strutils, strformat]


const GIT = "git"

let exe = getAppFilename()
let argc = paramCount()

if argc == 0 or argc >= 3:
  echo fmt"""Usage: {exe} DIR_PATH "Up""""
  echo fmt"""       {exe}          "Up""""
  quit 1

if findExe(GIT) == "":
  quit fmt"You need '{GIT}'.", 1

var dirPath: string
var commitMsg: string

if dirExists(paramStr 1):
  dirPath = paramStr 1
  commitMsg = paramStr 2
else:
  dirPath = ""
  commitMsg = paramStr 1

if dirPath != "":
  setCurrentDir dirpath

var ret = execCmdEx("git status --porcelain").output
ret.stripLineEnd()
if ret == "":
  quit "There is no need to update.", 0

discard execCmd("git add .")
discard execCmd(fmt"""git commit -m "{commitMsg}"""")
echo execCmdEx("git push").output
