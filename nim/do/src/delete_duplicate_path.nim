import std/[strutils, sets]
import winim/lean


const
  MAX_LENGTH = 32767
  ENV_PATH = "PATH"

proc main*() =
  var buffer = newWString(MAX_LENGTH)
  let size = DWORD(len(buffer))
  GetEnvironmentVariable(ENV_PATH, buffer, size)

  let pathSets = toOrderedSet(split($$buffer, ';'))

  var pathSeq: seq[string]
  for path in pathSets.items:
    pathSeq.add path

  # DEBUG
  # for path in pathSeq:
  #   echo path

  let newPath = join(pathSeq, ";")
  stdout.writeLine newPath

when isMainModule:
  main()
