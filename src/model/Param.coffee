ObjectManager = require("../persistence/ObjectManager")


module.exports = class Param
  constructor: (@value = 0) ->
    ObjectManager.assignId(this)
    @title = ""
    @axis = "result"