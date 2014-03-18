ObjectManager = require("../persistence/ObjectManager")
Param = require("./Param")
builtInFns = require("./builtInFns")


module.exports = class Apply
  constructor: (@fn = builtInFns.identityFn) ->
    ObjectManager.assignId(this)

    @params = @fn.defaultParams.map (paramValue) ->
      if paramValue?
        param = new Param(paramValue)
      else
        param = null

    @possibleApplies = null


  headParam: ->
    @params[0]

  tailParams: ->
    _.tail(@params)

  allParams: ->
    @params

  dependentParams: ->
    params = @allParams()
    dependencies = []
    for defaultParam, i in @fn.defaultParams
      dependencies.push(params[i]) if defaultParam?
    return dependencies

  setParam: (index, param) ->
    @params[index] = param
    @setPossibleAppliesHeads()


  initializePossibleApplies: ->
    @possibleApplies = builtInFns.map (fn) ->
      new Apply(fn)
    @setPossibleAppliesHeads()

  setPossibleAppliesHeads: ->
    return unless @possibleApplies?
    headParam = @headParam()
    for possibleApply in @possibleApplies
      possibleApply.setParam(0, headParam)

  choosePossibleApply: (possibleApply) ->
    if possibleApply?
      @fn = possibleApply.fn
      @params = possibleApply.params
    else
      @fn = builtInFns.identityFn
      @params = [@headParam()]

  isPossibleApplyChosen: (possibleApply) ->
    possibleApply.fn == @fn

  removePossibleApplies: ->
    @possibleApplies = null

  hasPossibleApplies: ->
    @possibleApplies?


  isStart: ->
    @fn == builtInFns.constantFn