
window.init = ->
  window.addEventListener("pointerdown", pointerdown)
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
  unless pointerManager.isPointerCaptured(e) or editor.dragging
    updateHover(e)

pointerup = (e) ->
  setTimeout(->
    editor.dragging = null
    setDirty()
  , 1) # Can remove setTimeout once I get event order right
  updateHover(e)
  document.body.style.cursor = ""

pointerdown = (e) ->
  el = e.target
  while el.nodeType == Node.ELEMENT_NODE
    if cursor = el.style.cursor
      break
    el = el.parentNode

  document.body.style.cursor = cursor