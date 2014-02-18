

mainGraph = null


window.init = ->
  canvas = document.querySelector("#c")
  mainGraph = new Graph(canvas, -10, 10, -10, 10)
  window.addEventListener("resize", resize)
  window.addEventListener("pointermove", pointermove)
  window.addEventListener("pointerup", pointerup)
  canvas.addEventListener("pointerdown", pointerdown)
  resize()


resize = ->
  canvas = document.querySelector("#c")
  rect = canvas.getBoundingClientRect()
  canvas.width = rect.width
  canvas.height = rect.height

  refresh()


refresh = ->
  refreshView()

  mainGraph.clear()
  mainGraph.drawGrid()
  editor.draw(mainGraph)



pointerdown = (e) ->
  e.preventDefault()
  document.activeElement.blur()

  console.log e
  # editor.pointerdown(e, mainGraph)





updateHover = (e) ->
  el = e.target
  hoveredLink = null
  hoveredParam = null
  while el.nodeType == Node.ELEMENT_NODE
    if el.ssLink
      hoveredLink = el.ssLink
    if el.ssParam
      hoveredParam = el.ssParam
    el = el.parentNode

  unless editor.hoveredLink == hoveredLink && editor.hoveredParam == hoveredParam
    editor.hoveredLink = hoveredLink
    editor.hoveredParam = hoveredParam
    refresh()

pointermove = (e) ->
  return if pointerManager.isPointerCaptured(e)
  updateHover(e)

pointerup = (e) ->
  updateHover(e)







