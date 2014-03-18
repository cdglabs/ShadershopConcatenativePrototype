ObjectManager = require("../persistence/ObjectManager")


module.exports = class Fn
  constructor: (@title, @defaultParams, @compileString) ->
    ObjectManager.registerBuiltInObject("fn-"+@title, this)