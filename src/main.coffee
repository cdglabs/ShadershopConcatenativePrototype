editor = null

window.init = ->
  loadState()
  window.addEventListener("pointermove", pointermove)
  window.addEventListener("pointerup", pointerup)

  for eventName in ["mousedown", "mousemove", "mouseup", "keydown", "scroll"]
    window.addEventListener(eventName, refresh)
  refresh()


refresh = ->
  requestAnimationFrame ->
    refreshView()
    saveState()



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
  editor.dragging?.onUp?(e)

  if p = editor.dragging?.transclusion
    closestDataFor(e.target, "handleTransclusionDrop")?(p)

  setTimeout(->
    editor.dragging = null
    refresh()
  , 1) # Can remove setTimeout once I get event order right



key "s", ->
  editor.shaderView = !editor.shaderView
  refresh()






