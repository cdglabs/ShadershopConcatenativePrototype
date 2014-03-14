module.exports = onceDragConsummated = (downEvent, callback, notConsummatedCallback=null) ->
  consummated = false
  originalX = downEvent.clientX
  originalY = downEvent.clientY

  handleMove = (moveEvent) ->
    dx = moveEvent.clientX - originalX
    dy = moveEvent.clientY - originalY
    d  = Math.max(Math.abs(dx), Math.abs(dy))
    if d > 3
      consummated = true
      removeListeners()
      callback?(moveEvent)

  handleUp = (upEvent) ->
    if !consummated
      notConsummatedCallback?(upEvent)
    removeListeners()

  removeListeners = ->
    window.removeEventListener("mousemove", handleMove)
    window.removeEventListener("mouseup", handleUp)

  window.addEventListener("mousemove", handleMove)
  window.addEventListener("mouseup", handleUp)