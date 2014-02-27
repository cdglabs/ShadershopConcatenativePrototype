GridView = React.createClass
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
      @refreshGraph()

  refreshGraph: ->
    canvas = @getDOMNode()

    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)
    graph.clear()

    graph.drawGrid()

  componentDidMount: ->
    @sizeCanvas()
    @refreshGraph()
    window.addEventListener("resize", @handleResize)

  componentWillUnmount: ->
    window.removeEventListener("resize", @handleResize)

  render: ->
    R.canvas {}



GraphView = React.createClass
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
      @refreshGraph()

  refreshGraph: ->
    {apply, spreadOffset, styleOpts} = @props
    spreadOffset ?= 0

    canvas = @getDOMNode()

    s = apply.compileString()

    # Optimization: Check if we need to redraw
    drawOptions = _.extend {s, spreadOffset, axis: apply.axis}, styleOpts
    if _.isEqual drawOptions, @lastDropOptions_
      return
    @lastDropOptions_ = drawOptions


    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)
    graph.clear()

    graphFn = eval("(function (x) { var spreadOffset = #{spreadOffset}; return #{s}; })")

    if apply instanceof Param && apply != editor.xParam
      if apply.axis == "x"
        graph.drawVerticalLine(graphFn(0), styleOpts)
      else if apply.axis == "result"
        graph.drawHorizontalLine(graphFn(0), styleOpts)
    else
      graph.drawGraph(graphFn, styleOpts)


  componentDidMount: ->
    @sizeCanvas()
    @refreshGraph()
    window.addEventListener("resize", @handleResize)

  componentDidUpdate: ->
    @refreshGraph()

  componentWillUnmount: ->
    window.removeEventListener("resize", @handleResize)

  render: ->
    R.canvas {}

