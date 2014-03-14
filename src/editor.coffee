require("./model/register")
Persistence = require("./persistence/Persistence")
Editor = require("./model/Editor")

Apply = require("./model/Apply")
Param = require("./model/Param")
builtInFns = require("./model/builtInFns")


editor = Persistence.loadState()

if !editor
  editor = new Editor()

  startApply = new Apply(builtInFns[0])

  editor.root = startApply


window.editor = editor
module.exports = editor