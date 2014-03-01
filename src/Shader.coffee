###
opts
  canvas: Canvas DOM element
  vertex: glsl source string
  fragment: glsl source string
  uniforms: a hash of names to values, the type is inferred as follows:
    Number or [Number]: float
    [Number, Number]: vec2
    [Number, Number, Number]: vec3
    [Number, Number, Number, Number]: vec4
    DOMElement: Sampler2D (e.g. Image/Video/Canvas)
    TODO: a way to force an arbitrary type


to set uniforms,

###


class Shader
  constructor: (@canvas) ->
    @vertexSrc = null
    @fragmentSrc = null
    @uniforms = {}

    # =============================================
    # internal state
    # =============================================
    @gl_ = @canvas.getContext("experimental-webgl", {premultipliedAlpha: false})
    @program_ = @gl_.createProgram()

    @shaders_ = {} # maps gl.VERTEX_SHADER and gl.FRAGMENT_SHADER to their respective attached shaders
    @textures_ = [] # an array mapping texture unit indices to objects:
      # {
      #   i: index of texture unit (0 - 31)
      #   texture: gl texture, i.e. created by gl.createTexture()
      #   element: DOMElement
      # }


  setVertexSrc: (src) ->
    @vertexSrc = src
    @replaceShader_(@vertexSrc, @gl_.VERTEX_SHADER)

  setFragmentSrc: (src) ->
    @fragmentSrc = src
    @replaceShader_(@fragmentSrc, @gl_.FRAGMENT_SHADER)

  replaceShader_: (src, type) ->
    if @shaders_[type]
      @gl_.detachShader(@program_, @shaders_[type])

    shader = @gl_.createShader(type)
    @gl_.shaderSource(shader, src)
    @gl_.compileShader(shader)
    @gl_.attachShader(@program_, shader)
    @gl_.deleteShader(shader)
    @shaders_[type] = shader
    @linkAndUseShaders_()

  linkAndUseShaders_: ->
    if @vertexSrc and @fragmentSrc
      @gl_.linkProgram(@program_)
      @gl_.useProgram(@program_)
      @refreshUniforms_()

  setUniforms: (uniforms) ->
    @uniforms = uniforms
    @refreshUniforms_()

  refreshUniforms_: ->
    for own name, value of @uniforms
      @setUniform_(name, value)

  setUniform_: (name, value) ->
    # find the location for the uniform
    location = @gl_.getUniformLocation(@program_, name)

    # set the uniform based on value's type
    if _.isNumber(value)
      @gl_.uniform1fv(location, [value])

    else if _.isArray(value)
      switch value.length
        when 1 then @gl_.uniform1fv(location, value)
        when 2 then @gl_.uniform2fv(location, value)
        when 3 then @gl_.uniform3fv(location, value)
        when 4 then @gl_.uniform4fv(location, value)

    else if value.nodeName # looks like a DOM element
      texture = @getTexture(value)
      # draw the element into the texture
      @gl_.activeTexture(@gl_.TEXTURE0 + texture.i)
      @gl_.texImage2D(@gl_.TEXTURE_2D, 0, @gl_.RGBA, @gl_.RGBA, @gl_.UNSIGNED_BYTE, value)
      # set the uniform to point to the texture's index
      @gl_.uniform1i(location, texture.i)

    else if !value
      # value is falsy
      # TODO: delete the uniform
      # TODO: delete the texture from textures
      false

  draw: ->
    unless @initialized_
      @gl_.useProgram(@program_)
      @bufferAttribute_("vertexPosition", [
        -1.0, -1.0,
         1.0, -1.0,
        -1.0,  1.0,
        -1.0,  1.0,
         1.0, -1.0,
         1.0,  1.0
      ])
      @gl_.drawArrays(@gl_.TRIANGLES, 0, 6)

  bufferAttribute_: (attrib, data, size=2) ->
    location = @gl_.getAttribLocation(@program_, attrib)
    buffer = @gl_.createBuffer()
    @gl_.bindBuffer(@gl_.ARRAY_BUFFER, buffer)
    @gl_.bufferData(@gl_.ARRAY_BUFFER, new Float32Array(data), @gl_.STATIC_DRAW)
    @gl_.enableVertexAttribArray(location)
    @gl_.vertexAttribPointer(location, size, @gl_.FLOAT, false, 0, 0)




  # getTexture = (element) ->
  #   for t in textures
  #     if t.element == element
  #       return t

  #   # if we got here, we need to make a new texture
  #   i = textures.length # TODO: instead find the first empty texture (i.e. one that's been deleted)
  #   texture = gl.createTexture()
  #   textures[i] = {
  #     element: element,
  #     texture: texture
  #     i: i
  #   }
  #   gl.activeTexture(gl.TEXTURE0 + i)
  #   gl.bindTexture(gl.TEXTURE_2D, texture)

  #   # Set these things...
  #   gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
  #   gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  #   gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  #   gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
  #   gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

  #   return textures[i]
