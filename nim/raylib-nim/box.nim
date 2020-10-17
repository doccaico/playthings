import raylib


const
  screenWidth = 800
  screenHeight = 450
  ballDiameter = 30
  top = "top"
  bottom = "bottom"
  left = "left"
  right = "right"
  skipFramerate = 15

type
  Direction = enum
    topLeft
    topRight
    bottomLeft
    bottomRight

type
  Ball = object
    pos: Vector2
    direction: Direction
    speed: cfloat

proc initBall(pos: Vector2, direction: Direction, speed: cfloat): Ball =
  result.pos = pos
  result.direction = direction
  result.speed = speed

InitWindow(screenWidth, screenHeight, "box")
SetTargetFPS(60)

let startPos = Vector2(x: screenWidth / 2, y: screenHeight / 2)
let direction = bottomLeft
var ball = initBall(startPos, direction, 3.0)
var label: string

var inputWait = 0

while not WindowShouldClose():

  if inputWait == 0:
    if IsKeyDown(KEY_UP):
      if ball.speed != 6.0:
        ball.speed += 1.0
        inputWait = skipFramerate
    if IsKeyDown(KEY_DOWN):
      if ball.speed != 1.0:
        ball.speed -= 1.0
        inputWait = skipFramerate
  if inputWait > 0:
    inputWait -= 1

  if ball.direction == topLeft:
    ball.pos.x -= ball.speed
    ball.pos.y -= ball.speed
  if ball.direction == topRight:
    ball.pos.x += ball.speed
    ball.pos.y -= ball.speed
  if ball.direction == bottomLeft:
    ball.pos.x -= ball.speed
    ball.pos.y += ball.speed
  if ball.direction == bottomRight:
    ball.pos.x += ball.speed
    ball.pos.y += ball.speed

  BeginDrawing()
  ClearBackground(RAYWHITE)

  # top collision
  if ball.pos.y - ballDiameter <= 0:
    if ball.direction == topLeft:
      ball.direction = bottomLeft
    elif ball.direction == topRight:
      ball.direction = bottomRight
    label = top

  # bottom collision
  elif ball.pos.y + ballDiameter >= screenHeight:
    if ball.direction == bottomLeft:
      ball.direction = topLeft
    elif ball.direction == bottomRight:
      ball.direction = topRight
    label = bottom

  # left collision
  elif ball.pos.x - ballDiameter <= 0:
    if ball.direction == bottomLeft:
      ball.direction = bottomRight
    elif ball.direction == topLeft:
      ball.direction = topRight
    label = left

  # right collision
  elif ball.pos.x + ballDiameter >= screenWidth:
    if ball.direction == bottomRight:
      ball.direction = bottomLeft
    elif ball.direction == topRight:
      ball.direction = topLeft
    label = right

  DrawText("speed up: arrow up", 10, 10, 20, DARKGRAY)
  DrawText("speed down: arrow down", 10, 30, 20, DARKGRAY)
  DrawText("speed: " & $ball.speed, 10, 70, 20, DARKGRAY)
  DrawText("collision: " & $label, 10, 90, 20, DARKGRAY)
  DrawCircleV(ball.pos, ballDiameter, MAROON)
  EndDrawing()
CloseWindow()
