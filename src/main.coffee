
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
  return if editor.dragging
  el = document.elementFromPoint(editor.mousePosition.x, editor.mousePosition.y)
  hoveredLink = null
  hoveredParam = null
  cursor = null
  while el.nodeType == Node.ELEMENT_NODE
    if el.ssLink
      hoveredLink = el.ssLink
    if el.ssParam
      hoveredParam = el.ssParam
    if el.hasAttribute("data-cursor")
      cursor = el.getAttribute("data-cursor")
    el = el.parentNode

  editor.hoveredLink = hoveredLink
  editor.hoveredParam = hoveredParam
  editor.cursor = cursor

pointermove = (e) ->
  editor.mousePosition = {x: e.clientX, y: e.clientY}
  editor.dragging?.onMove?(e)

pointerup = (e) ->
  setTimeout(->
    editor.dragging = null
    refresh()
  , 1) # Can remove setTimeout once I get event order right
