import std/[os, strutils, sets]


proc run*() =
  let envPath = getEnv("PATH")
  if envPath == "":
    stderr.writeLine "not found 'PATH' in env variable"
    quit(QuitFailure)

  let pathSets = toOrderedSet(split($envPath, ';'))

  var pathSeq: seq[string]
  for path in pathSets.items:
    pathSeq.add path
    # echo path

  let newPath = join(pathSeq, ";")
  stdout.write newPath

when isMainModule:
  run()
