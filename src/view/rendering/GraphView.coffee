R = React.DOM
cx = React.addons.classSet
CanvasView = require("./CanvasView")
Graph = require("./Graph")
Param = require("../../model/Param")


module.exports = GraphView = React.createClass
  getDefaultProps: ->
    {spreadOffset: 0}

  drawFn: (canvas) ->
    {apply, spreadOffset, styleOpts} = @props

    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)

    graph.clear()

    s = @compileString_ ? apply.compileString()
    graphFn = eval("(function (x) { var spreadOffset = #{spreadOffset}; return #{s}; })")

    if apply instanceof Param && apply != editor.xParam
      if apply.axis == "x"
        graph.drawVerticalLine(graphFn(0), styleOpts)
      else if apply.axis == "result"
        graph.drawHorizontalLine(graphFn(0), styleOpts)
    else
      graph.drawGraph(graphFn, styleOpts)

  render: ->
    CanvasView {drawFn: @drawFn, ref: "canvas"}

  componentDidUpdate: ->
    {apply, spreadOffset, styleOpts} = @props

    # Optimization: Check if we need to redraw
    @compileString_ = apply.compileString()
    drawOptions = _.extend {@compileString_, spreadOffset, axis: apply.axis}, styleOpts
    if _.isEqual drawOptions, @lastDrawOptions_
      return
    @lastDrawOptions_ = drawOptions


    @refs.canvas.draw()
