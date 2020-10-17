import random, os, strformat

when system.hostOS == "windows":
  const clear = "cmd /c cls"
elif system.hostOS == "macosx" or system.hostOS == "linux":
  const clear = r"printf '\33c\e[3J\33c'"
else:
  echo "unknown operating system"
  quit(QuitFailure)

const
  Width = 30
  Height = 30
  # The ratio of alive to dead cells.
  # For example, if this value is 0.25 and board size is 100 (Width*Height),
  # the number of living cells are 25 and The number of dead cells are 75.
  Ratio = 0.25
  # Milsecs.
  Wait = 100

type
  Board = array[Height+2, array[Width+2, int8]]

var board: Board

when not defined(release):

  proc echoBoardWithOutline() =
    for y in 0 .. Height + 1:
      for x in 0 .. Width + 1:
        stdout.write board[y][x]
      stdout.writeLine("")

  proc echoBoard() =
    for y in 1 .. Height:
      var count = 0
      for x in 1 .. Width:
        stdout.write board[y][x]
      stdout.writeLine("")

proc shuffleBoard() =
  for y in 1 .. Height:
    for x in 1 .. int(Ratio * Width):
      board[y][x] = 1
  for y in 1 .. Height:
    for x in 1 .. Width:
      var randomIndex = rand(1 .. Width)
      var tmp = board[y][x]
      board[y][x] = board[y][randomIndex]
      board[y][randomIndex] = tmp

proc outputBoard() =
  for y in 1 .. Height:
    for x in 1 .. Width:
      if board[y][x] == 1:
        stdout.write "*"
      else:
        stdout.write " "
    stdout.writeLine("")

proc countNeighbors(y, x: int): int8 =
  # top-left
  board[y-1][x-1] +
  # top-middle
  board[y-1][x] +
  # top-right
  board[y-1][x+1] +
  # left
  board[y][x-1] +
  # right
  board[y][x+1] +
  # bottom-left
  board[y+1][x-1] +
  # bottom-middle
  board[y+1][x] +
  # bottom-right
  board[y+1][x+1]

proc nextGeneration() =
  var neighbors: Board

  for y in 1 .. Height:
    for x in 1 .. Width:
      neighbors[y][x] = countNeighbors(y, x)

  for y in 1 .. Height:
    for x in 1 .. Width:
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
  for y in 1 .. Height:
    for x in 1 .. Width:
      if board[y][x] == 1:
        inc alive
      else:
        inc dead
  stdout.writeline(fmt"[INFO] Turn: {turn} Alive: {alive} Dead: {dead}")

proc main() =

  randomize()
  shuffleBoard()

  # echoBoard()
  # echoBoardWithOutline()

  var turn = 0
  while true:
    discard execShellCmd(clear)
    nextGeneration()
    outputBoard()
    outputInfo(turn)
    sleep(Wait)
    inc turn

when isMainModule and not defined(testing):
  main()
