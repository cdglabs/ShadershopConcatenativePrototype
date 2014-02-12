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
  new Fn "cos", 1, (a) -> Math.cos(a)
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
  constructor: ->
    @param = new Param()
    @visible = false
    @value = 0 # Can be a number or "x"

class Chain
  constructor: (@startParam) ->
    @links = []

class ChainLink
  constructor: (@fn, @additionalParams) ->








class Editor
  constructor: ->
    @paramCharacters = []
    @chains = []


  # ===========================================================================
  # Manipulating
  # ===========================================================================

  addParamCharacter: ->
    paramCharacter = new ParamCharacter()
    @paramCharacters.push paramCharacter
    return paramCharacter

  addChain: (startParam) ->
    chain = new Chain(startParam)
    @chains.push(chain)
    return chain

  appendLink: (chain, fn) ->
    additionalParams = [0...fn.numParams-1].map =>
      @addParamCharacter().param
    link = new ChainLink(fn, additionalParams)
    chain.links.push(link)
    return link


  # ===========================================================================
  # Rendering
  # ===========================================================================

  makeEnv: (xValue) ->
    env = new Env()
    for paramCharacter in @paramCharacters
      value = paramCharacter.value
      value = xValue if value == "x"
      env.set(paramCharacter.param, value)
    return env

  draw: (graph) ->
    for chain in @chains
      apply = chain.startParam
      for link in chain.links
        params = [apply].concat(link.additionalParams)
        apply = new Apply(link.fn, params)
        graph.drawGraph (xValue) =>
          env = @makeEnv(xValue)
          apply.evaluate(env)

    for paramCharacter in @paramCharacters
      continue unless paramCharacter.visible
      graph.drawGraph (xValue) =>
        env = @makeEnv(xValue)
        paramCharacter.param.evaluate(env)




  # ===========================================================================
  # Direct Manipulating
  # ===========================================================================

  hitDetect: (e, graph) ->
    manipulableParamCharacters = _.filter _.values(@paramCharacters), (paramCharacter) ->
      paramCharacter.visible && _.isNumber(paramCharacter.value)

    manipulableParamCharacterValues = _.map manipulableParamCharacters, (paramCharacter) ->
      paramCharacter.value

    foundIndex = graph.hitDetect(e.clientY, manipulableParamCharacterValues)

    if foundIndex?
      return manipulableParamCharacters[foundIndex]
    else
      return null

  pointerdown: (e, graph) ->
    paramCharacter = @hitDetect(e, graph)
    return unless paramCharacter

    setParamCharacter = (e) ->
      [x, y] = graph.getCoords([e.clientX, e.clientY])
      paramCharacter.value = y
      refresh()
    setParamCharacter(e)
    capturePointer(e, setParamCharacter)



editor = new Editor()

do ->
  a = editor.addParamCharacter()
  a.value = "x"
  a.visible = true

  b = editor.addParamCharacter()
  b.value = 2
  b.visible = true

  chain = editor.addChain(a.param)

  abs = editor.appendLink(chain, fnsToAdd[4])
  plu = editor.appendLink(chain, fnsToAdd[0])
  plu.additionalParams[0] = b.param
  sin = editor.appendLink(chain, fnsToAdd[5])









