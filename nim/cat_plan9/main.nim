import std/os

proc ctrlc() {.noconv.} =
  quit(130)

proc cat(f: File) =
  if f == stdin:
    while true:
      writeLine(stdout, readLine(f))
  else:
    write(stdout, readAll(f))

proc main() =

  setControlCHook(ctrlc)

  var f: File

  if paramCount() == 0:
    cat(stdin);
  else:
    for i in 1..paramCount():
      try:
        f = open(paramStr(i))
        cat(f)
      finally:
        close(f)

when isMainModule:
  main()
