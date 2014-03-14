editor = null

window.init = ->
  loadState()
  window.addEventListener("mousemove", handleWindowMouseMove)
  window.addEventListener("mouseup", handleWindowMouseUp)

  for eventName in ["mousedown", "mousemove", "mouseup", "keydown", "scroll", "change"]
    window.addEventListener(eventName, refresh)
  refresh()


refresh = ->
  requestAnimationFrame ->
    refreshView()
    saveState()


handleWindowMouseMove = (e) ->
  editor.mousePosition = {x: e.clientX, y: e.clientY}
  editor.dragging?.onMove?(e)

handleWindowMouseUp = (e) ->
  editor.dragging?.onUp?(e)
  editor.dragging = null