GraphView = React.createClass
  refreshGraph: ->
    canvas = @getDOMNode()

    # Setup
    rect = canvas.getBoundingClientRect()
    canvas.width = rect.width
    canvas.height = rect.height
    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)

    graph.clear()
    for data in @props.drawData
      graphFn = (xValue) ->
        env = editor.makeEnv(xValue)
        data.apply.evaluate(env)
      graph.drawGraph(graphFn, data.styleOpts)

  componentDidMount: -> @refreshGraph()
  componentDidUpdate: -> @refreshGraph()
  render: ->
    d.canvas {}