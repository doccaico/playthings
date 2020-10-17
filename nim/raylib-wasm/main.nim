import raylib

when defined(emscripten):
  proc emscripten_set_main_loop(fn: proc() {.cdecl.}, a: cint, b: bool) {.importc.}

proc updateDrawFrame() {.cdecl.} =
  BeginDrawing()
  ClearBackground(RAYWHITE)
  DrawText("Hello, World", 190, 200, 20, LIGHTGRAY)
  EndDrawing()

const
  screenWidth = 800
  screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")

when defined(emscripten):
  emscripten_set_main_loop(updateDrawFrame, 0, true)
else:
  SetTargetFPS(60)
  while not WindowShouldClose():
    updateDrawFrame()

CloseWindow()
