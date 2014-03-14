ObjectManager = require("./ObjectManager")


module.exports = Persistence = new class
  constructor: ->

  saveState: (editor) ->
    deconstructed = ObjectManager.deconstruct(editor)
    deconstructedString = JSON.stringify(deconstructed)
    window.localStorage.spaceShader = deconstructedString

  loadState: ->
    deconstructedString = window.localStorage.spaceShader
    if !deconstructedString
      return null
    else
      editor = null
      try
        deconstructed = JSON.parse(deconstructedString)
        editor = ObjectManager.reconstruct(deconstructed)
      return editor

  reset: ->
    delete window.localStorage.spaceShader