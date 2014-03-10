ShaderGraphView = React.createClass
  drawFn: (canvas) ->
    {apply} = @props

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

  render: ->
    CanvasView {drawFn: @drawFn, ref: "canvas"}

  componentDidUpdate: ->
    @refs.canvas.draw()