editor = null

window.init = ->
  loadState()
  window.addEventListener("pointermove", pointermove)
  window.addEventListener("pointerup", pointerup)

  for eventName in ["mousedown", "mousemove", "mouseup", "keydown", "scroll", "change"]
    window.addEventListener(eventName, refresh)
  refresh()


refresh = ->
  requestAnimationFrame ->
    refreshView()
    saveState()


pointermove = (e) ->
  editor.mousePosition = {x: e.clientX, y: e.clientY}
  editor.dragging?.onMove?(e)

pointerup = (e) ->
  editor.dragging?.onUp?(e)
  editor.dragging = null