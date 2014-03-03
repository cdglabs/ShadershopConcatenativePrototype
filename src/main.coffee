
window.init = ->
  window.addEventListener("pointermove", pointermove)
  window.addEventListener("pointerup", pointerup)

  for eventName in ["mousedown", "mousemove", "mouseup", "keydown", "scroll"]
    window.addEventListener(eventName, refresh)
  refresh()


refresh = ->
  requestAnimationFrame ->
    updateHover()
    updateHover2()
    refreshView()


updateHover = ->
  if editor.dragging
    editor.spreadParam = null
    return

  el = document.elementFromPoint(editor.mousePosition.x, editor.mousePosition.y)

  editor.hoveredApply = null
  editor.hoveredParam = null
  editor.cursor = null

  while el?.nodeType == Node.ELEMENT_NODE
    editor.hoveredApply ?= el.annotation?.hoverApply
    editor.hoveredParam ?= el.annotation?.hoverParam
    editor.cursor       ?= el.annotation?.cursor

    el = el.parentNode

  editor.spreadParam = editor.hoveredParam


lastHoveredEls = []
updateHover2 = ->
  return if editor.dragging

  hoveredEls = []

  el = document.elementFromPoint(editor.mousePosition.x, editor.mousePosition.y)
  while el?.nodeType == Node.ELEMENT_NODE
    if el.dataFor?.handleHoverEnter
      hoveredEls.push(el)
    el = el.parentNode

  for lastHoveredEl in lastHoveredEls
    unless _.contains hoveredEls, lastHoveredEl
      lastHoveredEl.dataFor.handleHoverLeave?()

  for hoveredEl in hoveredEls
    unless _.contains lastHoveredEls, hoveredEl
      hoveredEl.dataFor.handleHoverEnter()

  lastHoveredEls = hoveredEls



closestDataFor = (el, property) ->
  while el?.nodeType == Node.ELEMENT_NODE
    if found = el.dataFor?[property]
      return found
    el = el.parentNode
  return undefined



pointermove = (e) ->
  editor.mousePosition = {x: e.clientX, y: e.clientY}
  editor.dragging?.onMove?(e)

pointerup = (e) ->
  if p = editor.dragging?.transclusion
    closestDataFor(e.target, "handleTransclusionDrop")?(p)

  setTimeout(->
    editor.dragging = null
    refresh()
  , 1) # Can remove setTimeout once I get event order right



key "s", ->
  editor.shaderView = !editor.shaderView
  refresh()