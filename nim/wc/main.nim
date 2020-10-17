import os

const
  Spaces: set[char]  = {'\n', ' '}

type
  State = enum
    Out = false
    In = true

proc main() =

  if paramCount() != 1:
    quit("FILENAME is required")
  let filename = commandLineParams()[0]

  let f = open(filename)
  defer: close(f)

  let text = readAll(f)

  var i: int = 0
  var count: int = 0
  var state: State = Out

  while i < text.len():

    if text[i] in Spaces:
      state = Out
    elif state == Out:
      state = In
      inc count

    inc i

  echo count

when isMainModule:
  main()
