require("model/register")
Persistence = require("persistence/Persistence")
Editor = require("model/Editor")
Param = require("model/Param")


editor = Persistence.loadState()

if !editor
  editor = new Editor()
  a = new Param()
  editor.xParam = a

  editor.root = a


window.editor = editor
module.exports = editor