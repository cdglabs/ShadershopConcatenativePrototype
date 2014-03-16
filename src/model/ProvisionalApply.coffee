ObjectManager = require("../persistence/ObjectManager")
Apply = require("./Apply")
builtInFns = require("./builtInFns")


module.exports = class ProvisionalApply extends Apply
  constructor: ->
    ObjectManager.assignId(this)
    @params = [null]
    @possibleApplies = builtInFns.map (fn) ->
      new Apply(fn)
    @selectedApply = null

  setParam: (index, param) ->
    @params[index] = param
    for possibleApply in @possibleApplies
      possibleApply.setParam(index, param)

  effectiveApply: ->
    @selectedApply ? @params[0]

  compileString: ->
    @effectiveApply().compileString()

  compileGlslString: ->
    @effectiveApply().compileGlslString()