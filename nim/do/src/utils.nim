import std/[os]


proc stdoutMsgAndExit*(msg: string) {.noreturn.} =
  stdout.writeLine msg
  quit QuitSuccess

proc stderrMsgAndExit*(msg: string) {.noreturn.} =
  stderr.writeLine msg
  quit QuitFailure

proc rmdirIfExist*(path: string) =
  if fileExists(path):
    removeFile(path)

# proc viewHelpAndExit*(stdio: File, msg: string, code: int) {.noreturn.} =
#   const TEMP = r"C:\Users\doccaico\Downloads\temp.txt"
#   var f: File
#   if open(f, TEMP, fmWrite):
#     f.writeLine msg
#     close(f)
#   const LESS_OPT = "-R -i --silent"
#   discard execCmd(fmt"less {LESS_OPT} {TEMP}")
#   removeFile(TEMP)
#   quit code
