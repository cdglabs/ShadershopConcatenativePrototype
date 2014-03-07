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