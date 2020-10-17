import std/[dom, random]
import ./canvas

const
  fps = 15
  frameTime = 1 / fps
  rectSize = 5
  colNum = 50
  rowNum = 50
  canvasWidth = colNum * rectSize
  canvasheight = rowNum * rectSize

  # If this value is 0.25 and board size is 100 (colNum*rowNum),
  # the number of living cells are 25 and The number of empty/dead cells are 75.
  ratio = 0.30

type
  Board* = array[rowNum+2, array[colNum+2, int8]]

var
  board*: Board
  prevTimestamp: float = 0.0;

proc shuffleBoard*() =
  for y in 1 .. rowNum:
    for x in 1 .. int(ratio * colNum):
      board[y][x] = 1
  for y in 1 .. rowNum:
    for x in 1 .. colNum:
      var randomIndex = rand(1 .. colNum)
      var tmp = board[y][x]
      board[y][x] = board[y][randomIndex]
      board[y][randomIndex] = tmp

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

proc nextGeneration*() =
  var neighbors: Board

  for y in 1 .. rowNum:
    for x in 1 .. colNum:
      neighbors[y][x] = countNeighbors(y, x)

  for y in 1 .. rowNum:
    for x in 1 .. colNum:
      case neighbors[y][x]
        of 2:
          # Do nothing
          discard
        of 3:
          board[y][x] = 1
        else:
          board[y][x] = 0


proc outputBoard(ctx :CanvasRenderingContext) =
  for y in 1 .. rowNum:
    for x in 1 .. colNum:
      if board[y][x] == 1:
        ctx.fillStyle = "#11d319"
        ctx.fillRect(rectSize * (x - 1), rectSize * (y - 1), rectSize, rectSize)
      else:
        ctx.fillStyle = "black"
        ctx.fillRect(rectSize * (x - 1), rectSize * (y - 1), rectSize, rectSize)


proc main(event: Event) =
  let canvas = dom.document.getElementById("canvas").EmbedElement
  canvas.width = canvasWidth
  canvas.height = canvasheight
  let ctx = canvas.getContext("2d")

  proc mainloop(ctx: CanvasRenderingContext) =
    discard
    nextGeneration()
    outputBoard(ctx)

  proc update(timestamp: float) =
    let elapsed = (timestamp - prevTimestamp) / 1000
    if elapsed <= frameTime:
      discard dom.window.requestAnimationFrame(update)
      return
    prevTimestamp = timestamp

    outputBoard(ctx)
    mainloop(ctx)

    discard dom.window.requestAnimationFrame(update)

  randomize()
  shuffleBoard()
  update(0.0)

dom.window.onload = main
