
window.init = ->
  window.addEventListener("pointermove", pointermove)
  window.addEventListener("pointerup", pointerup)

  for eventName in ["mousedown", "mousemove", "mouseup", "keydown"]
    window.addEventListener(eventName, refresh)
  refresh()


refresh = ->
  requestAnimationFrame ->
    refreshView()


updateHover = (e) ->
  el = e.target
  hoveredLink = null
  hoveredParam = null
  while el.nodeType == Node.ELEMENT_NODE
    if el.ssLink
      hoveredLink = el.ssLink
    if el.ssParam
      hoveredParam = el.ssParam
    el = el.parentNode

  unless editor.hoveredLink == hoveredLink && editor.hoveredParam == hoveredParam
    editor.hoveredLink = hoveredLink
    editor.hoveredParam = hoveredParam

pointermove = (e) ->
  editor.mousePosition = {x: e.clientX, y: e.clientY}
  editor.dragging?.onMove?(e)
  unless editor.dragging
    updateHover(e)

pointerup = (e) ->
  setTimeout(->
    editor.dragging = null
    refresh()
  , 1) # Can remove setTimeout once I get event order right
  updateHover(e)
