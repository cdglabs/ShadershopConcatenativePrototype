ObjectManager = require("../persistence/ObjectManager")


module.exports = class Fn
  constructor: (@title, @defaultParams, @compileString, @compileGlslString) ->
    ObjectManager.registerBuiltInObject("fn-"+@title, this)