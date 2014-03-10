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

      void main() {
        gl_Position = vec4(vertexPosition, 1.0);
      }
    """

    fragmentSrc = """
      precision mediump float;

      uniform vec2 resolution;

      void main() {
        vec2 p = gl_FragCoord.xy / resolution;
        float x = mix(-10., 10., p.x);
        float y = mix(-10., 10., p.y);

        float outputValue = #{s};
        gl_FragColor = vec4(vec3(outputValue), 1);
      }
    """

    shader.setVertexSrc(vertexSrc)
    shader.setFragmentSrc(fragmentSrc)

    shader.setUniforms({
      resolution: [canvas.width, canvas.height]
    })

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

