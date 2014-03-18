Graph = require("./Graph")
Param = require("../../model/Param")

editor = require("../../editor")
Compiler = require("../../execute/Compiler")
evaluate = require("../../execute/evaluate")


R.create "GraphView",
  getDefaultProps: ->
    {spreadOffset: 0}

  compile: ->
    {apply, spreadOffset, styleOpts} = @props
    compiler = new Compiler()
    compiler.substitute(editor.xParam, "x")
    if spreadParam = editor.spreadParam()
      compiler.substitute(spreadParam, spreadParam.value + spreadOffset)
    return compiler.compile(apply, "js")

  drawFn: (canvas) ->
    {apply, spreadOffset, styleOpts} = @props

    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)

    graph.clear()

    s = @compileString_ ? @compile()
    graphFn = evaluate("(function (x) { return #{s}; })")

    if apply instanceof Param && apply != editor.xParam
      if apply.axis == "x"
        graph.drawVerticalLine(graphFn(0), styleOpts)
      else if apply.axis == "result"
        graph.drawHorizontalLine(graphFn(0), styleOpts)
    else
      graph.drawGraph(graphFn, styleOpts)

  render: ->
    R.CanvasView {drawFn: @drawFn, ref: "canvas"}

  componentDidUpdate: ->
    {apply, spreadOffset, styleOpts} = @props

    # Optimization: Check if we need to redraw
    @compileString_ = @compile()
    drawOptions = _.extend {@compileString_, spreadOffset, axis: apply.axis}, styleOpts
    if _.isEqual drawOptions, @lastDrawOptions_
      return
    @lastDrawOptions_ = drawOptions


    @refs.canvas.draw()
