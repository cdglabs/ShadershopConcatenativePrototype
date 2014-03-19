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

    if editor.timeParam
      refresh()

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


# =============================================================================
# Temporary Debugging
# =============================================================================

key "d", (e) ->
  el = document.elementFromPoint(editor.mousePosition.x, editor.mousePosition.y)
  while el
    if el.dataFor
      window.debug = el.dataFor
      break
    el = el.parentNode


key "command+f", (e) ->
  e.preventDefault()
  editor.createFn()


do ->
  apply = editor.rootBlock.root
  Compiler = require("./execute/Compiler")
  compiler = new Compiler()
  compiler.substitute(editor.xParam, "x")
  console.log compiler.compile(apply, "glsl")


