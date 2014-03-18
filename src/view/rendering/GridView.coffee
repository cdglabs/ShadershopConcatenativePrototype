Graph = require("./Graph")


R.create "GridView",
  drawFn: (canvas) ->
    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)
    graph.clear()
    graph.drawGrid()

  render: ->
    R.CanvasView {drawFn: @drawFn}