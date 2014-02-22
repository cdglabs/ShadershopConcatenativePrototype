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
        s = data.apply.compileString()

        if editor.spreadParam and editor.spreadParam != editor.xParam and @props.grid
          spreadDistance = 0.5
          spreadNum = 5
          styleOpts = _.clone(data.styleOpts)
          styleOpts.opacity = 0.1
          for i in [0...spreadNum]
            for neg in [-1, 1]
              spreadOffset = spreadDistance * i * neg
              graphFn = eval("(function (x) { var spreadOffset = #{spreadOffset}; return #{s}; })")
              graph.drawGraph(graphFn, styleOpts)

        graphFn = eval("(function (x) { var spreadOffset = 0; return #{s}; })")
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