class PointerManager
  constructor: ->
    @capturedPointers = {}
    window.addEventListener("pointermove", @handleMove)
    window.addEventListener("pointerup", @handleUp)

  pointerId: (e) ->
    e.pointerId ? 1 # TODO: make this better

  isPointerCaptured: (e) ->
    pointerId = @pointerId(e)
    @capturedPointers[pointerId]

  capture: (e, handleMove, handleUp) ->
    pointerId = @pointerId(e)
    @capturedPointers[pointerId] = {handleMove, handleUp}

  uncapture: (e) ->
    pointerId = @pointerId(e)
    delete @capturedPointers[pointerId]

  handleMove: (e) =>
    captured = @isPointerCaptured(e)
    if captured
      captured.handleMove?(e)

  handleUp: (e) =>
    captured = @isPointerCaptured(e)
    if captured
      @uncapture(e)
      captured.handleUp?(e)


pointerManager = new PointerManager()