import std/[os, osproc, strformat]


proc printMsgAndExit*(stdio: File, msg: string, code: int) {.noreturn.} =
  stdio.writeLine msg
  quit code

proc viewHelpAndExit*(stdio: File, msg: string, code: int) {.noreturn.} =
  const TEMP = r"C:\Users\doccaico\Downloads\temp.txt"
  var f: File
  if open(f, TEMP, fmWrite):
    f.writeLine msg
    close(f)
  const LESS_OPT = "-R -i --silent"
  discard execCmd(fmt"less {LESS_OPT} {TEMP}")
  removeFile(TEMP)
  quit code
