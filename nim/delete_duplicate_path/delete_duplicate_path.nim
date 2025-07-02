import std/[strutils, sets]
import winim/lean

const MaxLength = 32767
var
  name = "PATH"
  buffer = newWString(MaxLength)
  size = DWORD(len(buffer))

GetEnvironmentVariable(name, buffer, size)
let pathSets = toOrderedSet(split($$buffer, ';'))

var pathSeq: seq[string]
for path in pathSets.items:
  pathSeq.add path

# DEBUG
# for path in pathSeq:
#   echo path

let newPath = join(pathSeq, ";")
echo newPath
