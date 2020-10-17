import dom

type
  CanvasRenderingContext* = ref object
    fillStyle* {.importc.}: cstring

{.push importcpp.}
proc getContext*(canvasElement: Element,
    contextType: cstring): CanvasRenderingContext
proc fillRect*(context: CanvasRenderingContext, x, y, width, height: int)
{.pop.}

import dom

proc main(event: Event) =

  const width = 640
  const height = 480
  const rectsize = 50

  let canvas = dom.document.getElementById("canvas").EmbedElement
  canvas.width = width
  canvas.height = height

  let ctx = canvas.getContext("2d")

  # back
  ctx.fillStyle = "gray"
  ctx.fillRect(0, 0, width, height)

  ctx.fillStyle = "blue"
  ctx.fillRect((width div 2) - (rectsize div 2), rectsize*0, rectsize, rectsize)
  ctx.fillStyle = "yellow"
  ctx.fillRect((width div 2) - (rectsize div 2), rectsize*1, rectsize, rectsize)
  ctx.fillStyle = "red"
  ctx.fillRect((width div 2) - (rectsize div 2), rectsize*2, rectsize, rectsize)

window.onload = main
