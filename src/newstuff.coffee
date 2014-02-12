###
Need to capture:
  is it displayed always or a "constant"?
  is it the x-axis? if not, what is its current value?
  title
###

class Param
  constructor: ->
    @id = _.uniqueId("p")

###
title
number of parameters (at least 1?)
how to compute its result given its parameter values
###
class Fn
  constructor: (@title, @numParams, @evaluate) ->

fnsToAdd = [
  new Fn "+", 2, (a, b) -> a + b
  new Fn "-", 2, (a, b) -> a - b
  new Fn "*", 2, (a, b) -> a * b
  new Fn "/", 2, (a, b) -> a / b
  new Fn "abs", 1, (a) -> Math.abs(a)
  new Fn "sin", 1, (a) -> Math.sin(a)
]


###
its Fn
its parameters
###
class Apply
  constructor: (@fn, @params) ->
    @id = _.uniqueId("a")

  evaluate: (env) ->
    paramValues = @params.map (param) ->
      env.lookup(param)
    @fn.evaluate(paramValues)


class Env
  constructor: ->
    @paramValues = {}
  set: (param, value) ->
    @paramValues[param.id] = value
  lookup: (param) ->
    @paramValues[param.id]








class ParamCharacter
  constructor: (@param) ->
    @visible = true
    @value = 0 # or can be "x"


class ApplyCharacter
  constructor: (@apply) ->
    @visible = true


class Editor
  constructor: ->
    @paramCharacters = {}
    @applyCharacters = {}

  makeEnv: (xValue) ->
    env = new Env()
    for paramId, paramCharacter in @paramCharacters
      value = paramCharacter.value
      value = xValue if value == "x"
      env.set(paramCharacter.param, value)
    return env

  draw: (graph) ->
    for applyId, applyCharacter in @applyCharacters
      continue unless applyCharacter.visible
      graph.drawGraph (xValue) =>
        env = @makeEnv(xValue)
        applyCharacter.apply.evaluate(env)



















