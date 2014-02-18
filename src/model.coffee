class Param
  constructor: (@value = 0) ->
    @id = _.uniqueId("p")
    @title = ""

  evaluate: (env) ->
    env.lookup(this) ? @value


class Env
  constructor: ->
    @paramValues = {}
  set: (param, value) ->
    @paramValues[param.id] = value
  lookup: (param) ->
    @paramValues[param.id]


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
  new Fn "fract", 1, (a) -> a - Math.floor(a)
  new Fn "floor", 1, (a) -> Math.floor(a)
]


class Apply
  constructor: (@fn, @params) ->
  evaluate: (env) ->
    paramValues = @params.map (param) ->
      param.evaluate(env)
    @fn.compute(paramValues...)
  # isEqualTo: (otherApply) ->
  #   return false unless otherApply instanceof Apply
  #   return false if @fn != otherApply.fn
  #   for param, i in @params
  #     otherParam = otherApply.params[i]
  #     return false if param instanceof Param and param != otherParam
  #     return false if !param.isEqualTo(otherParam)
  #   return true








class Chain
  constructor: (startParam) ->
    startLink = new StartLink(startParam)
    @links = [startLink]

  appendLink: (fn) ->
    additionalParams = [0...fn.numParams-1].map -> new Param()
    link = new Link(fn, additionalParams)
    @links.push(link)
    return link

  appendLinkAfter: (fn, refLink) ->
    additionalParams = [0...fn.numParams-1].map -> new Param()
    link = new Link(fn, additionalParams)
    i = @links.indexOf(refLink)
    @links.splice(i+1, 0, link)
    return link

class Link
  constructor: (@fn, @additionalParams) ->
    @addLinkVisible = false
    @id = _.uniqueId("l")

class StartLink
  constructor: (@startParam) ->








class Editor
  constructor: ->
    @params = []
    @chains = []
    @xParam = null

    @hoveredParam = null
    @hoveredLink = null


  # ===========================================================================
  # Manipulating
  # ===========================================================================

  addParam: ->
    param = new Param()
    @params.push param
    return param

  addChain: (startParam) ->
    chain = new Chain(startParam)
    @chains.push(chain)
    return chain


  # ===========================================================================
  # Rendering
  # ===========================================================================

  makeEnv: (xValue) ->
    env = new Env()
    if @xParam
      env.set(@xParam, xValue)
    return env

  applyForChainLink: (chain, link) ->
    for l in chain.links
      if l instanceof StartLink
        apply = l.startParam
      else
        params = [apply].concat(l.additionalParams)
        apply = new Apply(l.fn, params)
      break if l == link
    return apply


  # ===========================================================================
  # Direct Manipulating
  # ===========================================================================

  # hitDetect: (e, graph) ->
  #   params = @manipulableParams()
  #   paramValues = _.map params, (param) -> param.value

  #   foundIndex = graph.hitDetect(e.clientY, paramValues)

  #   if foundIndex?
  #     return params[foundIndex]
  #   else
  #     return null

  # pointerdown: (e, graph) ->
  #   param = @hitDetect(e, graph)
  #   return unless param

  #   setParam = (e) ->
  #     [x, y] = graph.getCoords([e.clientX, e.clientY])
  #     param.value = y
  #     refresh()
  #   setParam(e)
  #   capturePointer(e, setParam)









editor = new Editor()

do ->
  a = new Param()
  editor.xParam = a

  # b = editor.addParam()
  # b.value = 2

  chain = editor.addChain(a)

  # abs = chain.appendLink(fnsToAdd[4])
  # plu = chain.appendLink(fnsToAdd[0])
  # # plu.additionalParams[0] = b
  # sin = chain.appendLink(fnsToAdd[5])









