import std/[cmdline, os, strutils, unicode]

if paramCount() != 1:
  echo "Usage:"
  echo "\t" & getAppFilename() & " [NUMBER]"
  quit(1)

let numStr = paramStr(1)
var prefix: string
if numStr.len <= 2:
 prefix = ""
else:
 prefix = numStr[0 ..< 2]

var parsed: int
case prefix
of "0b", "0B":
  parsed = numStr.parseBinInt()
of "0o", "0O":
  parsed = numStr.parseOctInt()
of "0x", "0X":
  parsed = numStr.parseHexInt()
else:
  parsed = numStr.parseInt()

block: # Bin
  var ret: string
  var count: int = 1
  for c in parsed.toBin(64):
    ret.add c
    if count == 4:
      ret.add '_'
      count = 1
    else:
      inc count
  ret.removeSuffix('_')
  echo "[Bin] " & ret

block: # Oct
  var ret: string
  var count: int = 1
  for c in parsed.toOct(64):
    ret.add c
    if count == 4:
      ret.add '_'
      count = 1
    else:
      inc count
  ret.removeSuffix('_')
  echo "[Oct] " & ret

block: # Hex
  var ret: string
  var count: int = 1
  for c in parsed.toHex(64):
    ret.add c
    if count == 4:
      ret.add '_'
      count = 1
    else:
      inc count
  ret.removeSuffix('_')
  echo "[Hex] " & ret

block: # Dec
  let s = $parsed
  var ret: string
  var count: int = 1
  if s.len >= 4:
    for c in s.reversed():
      ret.add c
      if count == 3:
        ret.add ','
        count = 1
      else:
        inc count
    ret = ret.reversed()
  else:
    ret = s
  let spaces = ' '.repeat(79 - ret.len)
  echo "[Dec] " & spaces & ret

block: # Dec'
  let s = $parsed
  let spaces = ' '.repeat(78 - s.len)
  echo "[Dec'] " & spaces & s 
