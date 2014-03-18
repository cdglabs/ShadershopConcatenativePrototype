require("./util/domAddons")
editor = require("./editor")
Persistence = require("./persistence/Persistence")
R = require("view/R")


window.reset = ->
  Persistence.reset()
  location.reload()



willRefreshNextFrame = false
refresh = ->
  return if willRefreshNextFrame
  willRefreshNextFrame = true
  requestAnimationFrame ->
    refreshView()
    Persistence.saveState(editor)
    willRefreshNextFrame = false

refreshView = ->
  editorEl = document.querySelector("#editor")
  React.renderComponent(R.EditorView(), editorEl)


handleWindowMouseMove = (e) ->
  editor.mousePosition = {x: e.clientX, y: e.clientY}
  editor.dragging?.onMove?(e)

handleWindowMouseUp = (e) ->
  editor.dragging?.onUp?(e)
  editor.dragging = null


window.addEventListener("mousemove", handleWindowMouseMove)
window.addEventListener("mouseup", handleWindowMouseUp)

for eventName in ["mousedown", "mousemove", "mouseup", "keydown", "scroll", "change"]
  window.addEventListener(eventName, refresh)

refresh()

