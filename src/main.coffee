
window.init = ->
  window.addEventListener("pointermove", pointermove)
  window.addEventListener("pointerup", pointerup)

  for eventName in ["mousedown", "mousemove", "mouseup", "keydown"]
    window.addEventListener(eventName, refresh)
  refresh()


refresh = ->
  requestAnimationFrame ->
    updateHover()
    refreshView()


updateHover = ->
  if editor.dragging
    editor.spreadParam = null
    return

  el = document.elementFromPoint(editor.mousePosition.x, editor.mousePosition.y)

  editor.hoveredLink = null
  editor.hoveredParam = null
  editor.cursor = null

  while el?.nodeType == Node.ELEMENT_NODE
    editor.hoveredLink  ?= el.annotation?.hoverLink
    editor.hoveredParam ?= el.annotation?.hoverParam
    editor.cursor       ?= el.annotation?.cursor

    el = el.parentNode

  editor.spreadParam = editor.hoveredParam

pointermove = (e) ->
  editor.mousePosition = {x: e.clientX, y: e.clientY}
  editor.dragging?.onMove?(e)

pointerup = (e) ->
  setTimeout(->
    editor.dragging = null
    refresh()
  , 1) # Can remove setTimeout once I get event order right
