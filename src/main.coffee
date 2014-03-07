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



saveState = ->
  deconstructed = objectManager.deconstruct(editor)
  deconstructedString = JSON.stringify(deconstructed)
  window.localStorage.spaceShader = deconstructedString

loadState = ->
  deconstructedString = window.localStorage.spaceShader
  if !deconstructedString
    loadInitialEditor()
  else
    deconstructed = JSON.parse(deconstructedString)
    editor = objectManager.reconstruct(deconstructed)

loadInitialEditor = ->
  editor = new Editor()
  a = new Param()
  editor.xParam = a

  editor.root = a

window.reset = ->
  loadInitialEditor()
  saveState()
  window.location.reload()