###
Need to capture:
  is it displayed always or a "constant"?
  is it the x-axis? if not, what is its current value?
  title
###

class Param
  constructor: ->
    @id = _.uniqueId("p")
  evaluate: (env) ->
    env.lookup(this)

###
title
number of parameters (at least 1?)
how to compute its result given its parameter values
###
class Fn
  constructor: (@title, @numParams, @compute) ->

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
      param.evaluate(env)
    @fn.compute(paramValues...)


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

  addParam: (param) ->
    @paramCharacters[param.id] = new ParamCharacter(param)

  addApply: (apply) ->
    @applyCharacters[apply.id] = new ApplyCharacter(apply)


  makeEnv: (xValue) ->
    env = new Env()
    for own paramId, paramCharacter of @paramCharacters
      value = paramCharacter.value
      value = xValue if value == "x"
      env.set(paramCharacter.param, value)
    return env

  draw: (graph) ->
    for own applyId, applyCharacter of @applyCharacters
      continue unless applyCharacter.visible
      graph.drawGraph (xValue) =>
        env = @makeEnv(xValue)
        applyCharacter.apply.evaluate(env)





editor = do ->
  a = new Param()
  b = new Param()
  applyAbs = new Apply(fnsToAdd[4], [a])
  applySin = new Apply(fnsToAdd[5], [applyAbs])
  applyPlu = new Apply(fnsToAdd[0], [applySin, b])

  editor = new Editor()

  aChar = editor.addParam(a)
  bChar = editor.addParam(b)

  editor.addApply(applyAbs)
  editor.addApply(applySin)
  editor.addApply(applyPlu)

  aChar.value = "x"
  bChar.value = 2

  return editor













