ObjectManager = require("../persistence/ObjectManager")
Param = require("./Param")
builtInFns = require("./builtInFns")


module.exports = class Apply
  constructor: (@fn) ->
    ObjectManager.assignId(this)
    @params = []
    @initializeDefaultParams() if @fn

  initializeDefaultParams: ->
    @params = @fn.defaultParams.map (paramValue) ->
      param = new Param(paramValue)

  setParam: (index, param) ->
    @params[index] = param

  compileString: ->
    paramCompileStrings = @params.map (param) ->
      param.compileString()
    @fn.compileString(paramCompileStrings...)

  compileGlslString: ->
    paramCompileStrings = @params.map (param) ->
      param.compileGlslString()
    @fn.compileGlslString(paramCompileStrings...)

  isStart: ->
    @fn == builtInFns[0]