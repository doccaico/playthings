import std/dom

type
  CanvasRenderingContext* = ref object
    fillStyle* {.importc.}: cstring

{.push importcpp.}
proc getContext*(canvasElement: Element,
    contextType: cstring): CanvasRenderingContext
proc fillRect*(context: CanvasRenderingContext, x, y, width, height: int)
{.pop.}
