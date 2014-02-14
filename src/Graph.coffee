###

Need to snap to grid lines
  given a y value and a tolerance (pixels), find closest grid line (i.e. return a y value, either the same or snapped)

Need to see how close a point is to an object, for hit detection

###




config = {
  # In pixels:
  minGridSpacing: 70
  hitTolerance: 15
  snapTolerance: 5
}






ticks = (spacing, min, max) ->
  first = Math.ceil(min / spacing)
  last = Math.floor(max / spacing)
  (x * spacing for x in [first..last])


drawLine = (ctx, [x1, y1], [x2, y2]) ->
  ctx.beginPath()
  ctx.moveTo(x1, y1)
  ctx.lineTo(x2, y2)
  ctx.stroke()









class Graph
  constructor: (@canvas, @xMin, @xMax, @yMin, @yMax) ->
    @ctx = @canvas.getContext("2d")

  width: -> @canvas.width
  height: -> @canvas.height


  hitDetect: (targetBrowserY, yValues) ->
    minDistance = config.hitTolerance
    found = false
    for y, i in yValues
      browserY = @fromLocal([0, y])[1]
      distance = Math.abs(browserY - targetBrowserY)
      if distance < minDistance
        found = i
        minDistance = distance
    return found


  findSpacing: ->
    sizeX = @xMax - @xMin
    sizeY = @yMax - @yMin

    xMinSpacing = (sizeX / @width()) * config.minGridSpacing
    yMinSpacing = (sizeY / @height()) * config.minGridSpacing
    minSpacing = Math.max(xMinSpacing, yMinSpacing)

    ###
    need to determine:
      largeSpacing = {1, 2, or 5} * 10^n
      smallSpacing = divide largeSpacing by 4 (if 1 or 2) or 5 (if 5)
    largeSpacing must be greater than minSpacing
    ###
    div = 4
    largeSpacing = z = Math.pow(10, Math.ceil(Math.log(minSpacing) / Math.log(10)))
    if z / 5 > minSpacing
      largeSpacing = z / 5
    else if z / 2 > minSpacing
      largeSpacing = z / 2
      div = 5
    smallSpacing = largeSpacing / div

    return [largeSpacing, smallSpacing]


  getCoords: ([browserX, browserY]) ->
    # This takes in x/y as in e.clientX/Y and returns a point in local coordinates.
    rect = @canvas.getBoundingClientRect()
    x = lerp(browserX, rect.left, rect.right, @xMin, @xMax)
    y = lerp(browserY, rect.top, rect.bottom, @yMax, @yMin)
    return [x, y]

  fromLocal: ([x, y]) ->
    rect = @canvas.getBoundingClientRect()
    browserX = lerp(x, @xMin, @xMax, rect.left, rect.right)
    browserY = lerp(y, @yMin, @yMax, rect.bottom, rect.top)
    return [browserX, browserY]


  clear: ->
    @ctx.clearRect(0, 0, @width(), @height())

  drawGrid: ->
    @ctx.save()
    sizeX = @xMax - @xMin
    sizeY = @yMax - @yMin

    cxMin = 0
    cxMax = @width()
    cyMin = @height()
    cyMax = 0

    toLocal = ([cx, cy]) =>
      [lerp(cx, cxMin, cxMax, @xMin, @xMax), lerp(cy, cyMin, cyMax, @yMin, @yMax)]
    fromLocal = ([x, y]) =>
      [lerp(x, @xMin, @xMax, cxMin, cxMax), lerp(y, @yMin, @yMax, cyMin, cyMax)]

    labelDistance = 5
    color = "0,0,0"
    minorOpacity = 0.1
    majorOpacity = 0.2
    axesOpacity = 0.5
    labelOpacity = 1.0
    textHeight = 12

    minorColor = "rgba(#{color}, #{minorOpacity})"
    majorColor = "rgba(#{color}, #{majorOpacity})"
    axesColor = "rgba(#{color}, #{axesOpacity})"
    labelColor = "rgba(#{color}, #{labelOpacity})"

    [largeSpacing, smallSpacing] = @findSpacing()

    @ctx.lineWidth = 1


    # draw minor grid lines
    @ctx.strokeStyle = minorColor
    for x in ticks(smallSpacing, @xMin, @xMax)
      drawLine(@ctx, fromLocal([x, @yMin]), fromLocal([x, @yMax]))
    for y in ticks(smallSpacing, @yMin, @yMax)
      drawLine(@ctx, fromLocal([@xMin, y]), fromLocal([@xMax, y]))

    # draw major grid lines
    @ctx.strokeStyle = majorColor
    for x in ticks(largeSpacing, @xMin, @xMax)
      drawLine(@ctx, fromLocal([x, @yMin]), fromLocal([x, @yMax]))
    for y in ticks(largeSpacing, @yMin, @yMax)
      drawLine(@ctx, fromLocal([@xMin, y]), fromLocal([@xMax, y]))

    # draw axes
    @ctx.strokeStyle = axesColor
    drawLine(@ctx, fromLocal([0, @yMin]), fromLocal([0, @yMax]))
    drawLine(@ctx, fromLocal([@xMin, 0]), fromLocal([@xMax, 0]))

    # draw labels
    @ctx.font = "#{textHeight}px verdana"
    @ctx.fillStyle = labelColor
    @ctx.textAlign = "center"
    @ctx.textBaseline = "top"
    for x in ticks(largeSpacing, @xMin, @xMax)
      if x != 0
        text = parseFloat(x.toPrecision(12)).toString()
        [cx, cy] = fromLocal([x, 0])
        cy += labelDistance
        if cy < labelDistance
          cy = labelDistance
        if cy + textHeight + labelDistance > @height()
          cy = @height() - labelDistance - textHeight
        @ctx.fillText(text, cx, cy)
    @ctx.textAlign = "left"
    @ctx.textBaseline = "middle"
    for y in ticks(largeSpacing, @yMin, @yMax)
      if y != 0
        text = parseFloat(y.toPrecision(12)).toString()
        [cx, cy] = fromLocal([0, y])
        cx += labelDistance
        if cx < labelDistance
          cx = labelDistance
        if cx + @ctx.measureText(text).width + labelDistance > @width()
          cx = @width() - labelDistance - @ctx.measureText(text).width
        @ctx.fillText(text, cx, cy)

    @ctx.restore()


  drawGraph: (fn, styleOpts) ->
    @ctx.save()
    sizeX = @xMax - @xMin
    sizeY = @yMax - @yMin

    cxMin = 0
    cxMax = @width()
    cyMin = @height()
    cyMax = 0

    @ctx.lineWidth = styleOpts.lineWidth ? 2
    @ctx.strokeStyle = styleOpts.color ? "#006"
    @ctx.globalAlpha = styleOpts.opacity ? 1
    # @ctx.shadowColor = "rgba(0,0,0,0.65)"
    # @ctx.shadowBlur = 3

    @ctx.beginPath()

    resolution = 1
    for i in [0..(@width()/resolution)]
      cx = i * resolution
      x = lerp(cx, cxMin, cxMax, @xMin, @xMax)
      y = fn(x)
      cy = lerp(y, @yMin, @yMax, cyMin, cyMax)
      @ctx.lineTo(cx, cy)

    @ctx.stroke()
    @ctx.restore()

