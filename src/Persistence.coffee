Persistence = new class
  constructor: ->

  saveState: ->
    deconstructed = ObjectManager.deconstruct(editor)
    deconstructedString = JSON.stringify(deconstructed)
    window.localStorage.spaceShader = deconstructedString

  loadState: ->
    deconstructedString = window.localStorage.spaceShader
    if !deconstructedString
      loadInitialEditor()
    else
      deconstructed = JSON.parse(deconstructedString)
      editor = ObjectManager.reconstruct(deconstructed)

  loadInitialEditor: ->
    editor = new Editor()
    a = new Param()
    editor.xParam = a

    editor.root = a



window.reset = ->
  Persistence.loadInitialEditor()
  Persistence.saveState()
  window.location.reload()