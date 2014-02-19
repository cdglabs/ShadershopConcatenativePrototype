GraphView = React.createClass
  sizeCanvas: ->
    canvas = @getDOMNode()
    rect = canvas.getBoundingClientRect()
    canvas.width = rect.width
    canvas.height = rect.height

  handleResize: ->
    @sizeCanvas()
    @refreshGraph()

  refreshGraph: ->
    canvas = @getDOMNode()

    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)
    graph.clear()

    if @props.grid
      graph.drawGrid()

    for data in @props.drawData
      if data.apply instanceof Param && data.apply != editor.xParam
        if data.apply.axis == "x"
          graph.drawVerticalLine(data.apply.evaluate(), data.styleOpts)
        else if data.apply.axis == "result"
          graph.drawHorizontalLine(data.apply.evaluate(), data.styleOpts)
      else
        env = new Env()
        graphFn = (xValue) ->
          env.set(editor.xParam, xValue)
          data.apply.evaluate(env)
        graph.drawGraph(graphFn, data.styleOpts)

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