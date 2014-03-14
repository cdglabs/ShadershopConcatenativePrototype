ObjectManager = require("../persistence/ObjectManager")


module.exports = class Param
  constructor: (@value = 0) ->
    ObjectManager.assignId(this)
    @title = ""
    @axis = "result"

  compileString: ->
    editor = require("../editor") # HACK
    if this == editor.xParam
      "x"
    else if this == editor.spreadParam()
      "(#{@value} + spreadOffset)"
    else
      ""+@value

  compileGlslString: ->
    editor = require("../editor") # HACK
    if this == editor.xParam
      "x"
    else if this == editor.yParam
      "y"
    else
      floatString = ""+@value
      if floatString.indexOf(".") == -1
        floatString += "."
      return floatString