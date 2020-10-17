import random, os, strformat

when system.hostOS == "windows":
  const clear = "cmd /c cls"
elif system.hostOS == "macosx" or system.hostOS == "linux":
  const clear = r"printf '\33c\e[3J\33c'"
else:
  echo "unknown operating system"
  quit(QuitFailure)

const
  width = 40
  height = 20
  # the number live cells in width
  liveCells = 20
  # milsecs.
  wait = 150

type
  Board = array[height, array[width, int8]]

var board: Board

when not defined(release):
  proc echoBoard() =
    for y in 0 ..< height:
      var count = 0
      for x in 0 ..< width:
        stdout.write board[y][x]
      stdout.writeLine("")

proc initBoard() =
  for y in 0 ..< height:
    for x in 0 ..< liveCells:
      board[y][x] = 1
    shuffle(board[y])

proc outputBoard() =
  for y in 0 ..< height:
    for x in 0 ..< width:
      if board[y][x] == 1:
        stdout.write "*"
      else:
        stdout.write " "
    stdout.writeLine("")

proc countNeighbors(y, x: int): int8 =
  # top
  if 0 < y:
    if 0 < x:
      # top-left
      result += board[y-1][x-1]
    if width - 1 > x:
      # top-right
      result += board[y-1][x+1]
    # top-middle
    result += board[y-1][x]

  # bottom
  if height - 1 > y:
    if 0 < x:
      # bottom-left
      result += board[y+1][x-1]
    if width - 1 > x:
      # bottom-right
      result += board[y+1][x+1]
    # bottom-middle
    result += board[y+1][x]

  # middle
  if 0 < x:
    # middle-left
    result += board[y][x-1]
  if width - 1 > x:
    # middle-left
    result += board[y][x+1]

proc nextGeneration() =
  var neighbors: Board

  for y in 0 ..< height:
    for x in 0 ..< width:
      neighbors[y][x] = countNeighbors(y, x)

  for y in 0 ..< height:
    for x in 0 ..< width:
      case neighbors[y][x]
        of 2:
          # Do nothing
          discard
        of 3:
          board[y][x] = 1
        else:
          board[y][x] = 0

proc outputInfo(turn: int) =
  var alive, dead = 0
  for y in 0 ..< height:
    for x in 0 ..< width:
      if board[y][x] == 1:
        inc alive
      else:
        inc dead
  stdout.writeline(fmt"[INFO] Turn: {turn} Alive: {alive} Dead: {dead}")

proc main() =

  randomize()
  initBoard()

  # echoBoard()

  var turn = 1
  while true:
    discard execShellCmd(clear)
    outputBoard()
    outputInfo(turn)
    sleep(wait)
    nextGeneration()
    inc turn

when isMainModule and not defined(testing):
  main()
