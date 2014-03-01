ShaderGraphView = React.createClass
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
    {apply} = @props
    canvas = @getDOMNode()

    shader = canvas.shader ?= new Shader(canvas)

    s = apply.compileGlslString()

    vertexSrc = """
      precision mediump float;

      attribute vec3 vertexPosition;
      varying vec2 position;

      void main() {
        gl_Position = vec4(vertexPosition, 1.0);
        position = (vertexPosition.xy + 1.0) * 0.5;
      }
    """

    fragmentSrc = """
      precision mediump float;

      varying vec2 position;

      void main() {
        float x = mix(-10., 10., position.x);
        float y = mix(-10., 10., position.y);
        float outputValue = #{s};
        gl_FragColor = vec4(vec3(outputValue), 1);
      }
    """

    shader.setVertexSrc(vertexSrc)
    shader.setFragmentSrc(fragmentSrc)

    shader.draw()


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

