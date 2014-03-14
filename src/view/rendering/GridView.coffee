R = React.DOM
cx = React.addons.classSet
CanvasView = require("./CanvasView")
Graph = require("./Graph")


module.exports = GridView = React.createClass
  drawFn: (canvas) ->
    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)
    graph.clear()
    graph.drawGrid()

  render: ->
    CanvasView {drawFn: @drawFn}