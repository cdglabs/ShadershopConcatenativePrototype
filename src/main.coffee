
window.init = ->
  window.addEventListener("pointerdown", pointerdown)
  window.addEventListener("pointermove", pointermove)
  window.addEventListener("pointerup", pointerup)
  refresh()


refresh = ->
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
    refresh()

pointermove = (e) ->
  return if pointerManager.isPointerCaptured(e)
  updateHover(e)

pointerup = (e) ->
  updateHover(e)
  document.body.style.cursor = ""

pointerdown = (e) ->
  el = e.target
  while el.nodeType == Node.ELEMENT_NODE
    if cursor = el.style.cursor
      break
    el = el.parentNode

  document.body.style.cursor = cursor