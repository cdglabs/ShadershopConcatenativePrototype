CanvasView = React.createClass
  clear: ->
    canvas = @getDOMNode()
    ctx = canvas.getContext("2d")
    ctx.save()
    ctx.setTransform(1,0,0,1,0,0)
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.restore()

  draw: ->
    @clear()
    canvas = @getDOMNode()
    @props.drawFn(canvas)

  sizeCanvas: ->
    canvas = @getDOMNode()
    rect = canvas.getBoundingClientRect()
    if canvas.width != rect.width or canvas.height != rect.height
      canvas.width = rect.width
      canvas.height = rect.height
      return true
    return false

  handleResize: ->
    if @sizeCanvas()
      @draw()

  componentDidMount: ->
    @sizeCanvas()
    @draw()
    window.addEventListener("resize", @handleResize)

  componentWillUnmount: ->
    window.removeEventListener("resize", @handleResize)

  render: ->
    R.canvas {}


GridView = React.createClass
  drawFn: (canvas) ->
    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)
    graph.drawGrid()

  render: ->
    CanvasView {drawFn: @drawFn}


GraphView = React.createClass
  getDefaultProps: ->
    {spreadOffset: 0}

  drawFn: (canvas) ->
    {apply, spreadOffset, styleOpts} = @props

    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)

    s = apply.compileString()
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
    s = apply.compileString()
    drawOptions = _.extend {s, spreadOffset, axis: apply.axis}, styleOpts
    if _.isEqual drawOptions, @lastDropOptions_
      return
    @lastDropOptions_ = drawOptions

    @refs.canvas.draw()
