

graph = null


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
  graph.clear()
  graph.drawGrid()
  editor.draw(graph)
  refreshView()




pointerdown = (e) ->
  editor.pointerdown(e, graph)













