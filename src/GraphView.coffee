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
      graphFn = (xValue) ->
        env = editor.makeEnv(xValue)
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
    d.canvas {}