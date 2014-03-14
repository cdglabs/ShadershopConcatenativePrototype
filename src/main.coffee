require("./util/domAddons")
editor = require("./editor")
Persistence = require("./persistence/Persistence")
EditorView = require("./view/EditorView")


console.log "made it here", editor


refresh = ->
  requestAnimationFrame ->
    refreshView()
    Persistence.saveState(editor)

refreshView = ->
  editorEl = document.querySelector("#editor")
  React.renderComponent(EditorView(), editorEl)


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