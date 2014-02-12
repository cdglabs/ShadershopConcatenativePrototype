class Fn
  constructor: ->
    @visible = true


class FnX extends Fn
  constructor: -> super()
  title: "x"
  fn: (x) => x



class FnLinearMap extends Fn
  constructor: ->
    @offset = 0
    @multiplier = 1
    super()

  title: "lerp(…)"

  fn: (x) => (x * @multiplier) + @offset

  draw: (graph) ->
    graph.drawGraph(((x) => @offset), "rgba(0, 127, 0, 1.0)")
    graph.drawGraph(((x) => @offset + @multiplier), "rgba(0, 127, 0, 0.6)")

  pointerdown: (e, graph) ->
    hit = graph.hitDetect(e.clientY, [@offset, @offset + @multiplier])

    if hit == 0
      [x, y] = graph.getCoords([e.clientX, e.clientY])
      originalY = y
      originalOffset = @offset
      capturePointer e, (e) =>
        [x, y] = graph.getCoords([e.clientX, e.clientY])
        dy = y - originalY
        @offset = originalOffset + dy
        refresh()
    else if hit == 1
      [x, y] = graph.getCoords([e.clientX, e.clientY])
      originalY = y
      originalMultiplier = @offset + @multiplier
      capturePointer e, (e) =>
        [x, y] = graph.getCoords([e.clientX, e.clientY])
        dy = y - originalY
        @multiplier = originalMultiplier + dy - @offset
        refresh()



class FnAbs extends Fn
  constructor: ->
    @offset = 0
    super()

  title: "abs(…)"

  fn: (x) => Math.abs(x - @offset) + @offset

  draw: (graph) ->
    graph.drawGraph(((x) => @offset), "rgba(0, 127, 0, 1.0)")

  pointerdown: (e, graph) ->
    move = (e) =>
      [x, y] = graph.getCoords([e.clientX, e.clientY])
      @offset = y
      refresh()
    capturePointer e, move
    move(e)


class FnSin extends Fn
  constructor: ->
    super()
  title: "sin(…)"
  fn: (x) => Math.sin(x)