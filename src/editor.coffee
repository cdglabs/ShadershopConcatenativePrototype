require("./model/register")
Persistence = require("./persistence/Persistence")


Editor = require("./model/Editor")
Block = require("./model/Block")
Apply = require("./model/Apply")
Param = require("./model/Param")
builtInFns = require("./model/builtInFns")


editor = Persistence.loadState()

if !editor
  editor = new Editor()
  editor.rootBlock = new Block()

  startApply = new Apply(builtInFns[0])

  editor.rootBlock.root = startApply


window.editor = editor
module.exports = editor