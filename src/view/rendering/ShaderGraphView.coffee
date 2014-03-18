Shader = require("./Shader")

editor = require("../../editor")
Compiler = require("../../execute/Compiler")


R.create "ShaderGraphView",
  drawFn: (canvas) ->
    {apply} = @props

    shader = canvas.shader ?= new Shader(canvas)

    compiler = new Compiler()
    compiler.substitute(editor.xParam, "x")
    compiler.substitute(editor.yParam, "y")
    s = compiler.compile(apply, "glsl")

    vertexSrc = """
      precision mediump float;

      attribute vec3 vertexPosition;

      void main() {
        gl_Position = vec4(vertexPosition, 1.0);
      }
    """

    colorMap = """
        float outputValue = compute(x, y);
        gl_FragColor = vec4(vec3(outputValue), 1);
    """

    contourMap = """
        float outputValue = contourMap(vec2(x, y));
        gl_FragColor = vec4(vec3(0.), outputValue);
    """

    fragmentSrc = """
      precision mediump float;

      uniform vec2 resolution;

      float compute(float x, float y) {
        #{s}
      }

      float contourMap(vec2 pos) {
        float samples = 5.;
        float numSamples = samples * samples;
        vec2 step = ((40. / resolution)) / samples;

        float count = 0.;
        float min = 0.;
        float processed = 0.;

        for (float i = 0.0; i < 5.; i++) {
          for (float  j = 0.0; j < 5.; j++) {
            float f = compute(pos.x + i*step.x, pos.y + j*step.y);
            float ff = floor(f);
            if (processed == 0.) {
              min = ff;
            } else {
              if (ff > min) {
                count++;
              } else if (ff < min) {
                min = ff;
                count = processed;
              }
            }
            processed++;
          }
        }

        float ns2 = numSamples / 2.;
        return (ns2 - abs(count - ns2)) / ns2;
      }

      void main() {
        vec2 p = gl_FragCoord.xy / resolution;
        float x = mix(-10., 10., p.x);
        float y = mix(-10., 10., p.y);

        #{if editor.contourView then contourMap else colorMap}
      }
    """

    shader.setVertexSrc(vertexSrc)
    shader.setFragmentSrc(fragmentSrc)

    shader.setUniforms({
      resolution: [canvas.width, canvas.height]
    })

    shader.draw()

  render: ->
    R.CanvasView {drawFn: @drawFn, ref: "canvas"}

  componentDidUpdate: ->
    @refs.canvas.draw()