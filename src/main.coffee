

graph = null

state = do ->
  startFn = new FnX()
  return {
    fns: [startFn]
    selected: startFn
    fnsToAdd: [FnLinearMap, FnAbs, FnSin]
  }


window.init = ->
  canvas = document.querySelector("#c")
  graph = new Graph(canvas, -10, 10, -10, 10)
  window.addEventListener("resize", resize)
  canvas.addEventListener("pointerdown", pointerdown)
  resize()


resize = ->
  canvas = document.querySelector("#c")
  rect = canvas.getBoundingClientRect()
  canvas.width = rect.width
  canvas.height = rect.height

  refresh()


refresh = ->
  drawManager()

  graph.clear()
  graph.drawGrid()

  composedFn = (x) -> x

  for fn, i in state.fns
    composedFn = compose(fn.fn, composedFn)
    if fn.visible
      if fn == state.selected
        color = "#009"
      else
        color = "rgba(0,0,0,0.2)"
      graph.drawGraph(composedFn, color)

  state.selected?.draw?(graph)



pointerdown = (e) ->
  e.preventDefault()
  state.selected?.pointerdown?(e, graph)




capturePointer = (e, handleMove, handleUp) ->
  pointerId = e.pointerId
  move = (e) ->
    if e.pointerId = pointerId
      handleMove?(e)
  up = (e) ->
    handleUp?(e)
    window.removeEventListener("pointermove", move)
    window.removeEventListener("pointerup", up)
  window.addEventListener("pointermove", move)
  window.addEventListener("pointerup", up)








