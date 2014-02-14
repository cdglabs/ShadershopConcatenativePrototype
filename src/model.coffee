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
]


class Apply
  constructor: (@fn, @params) ->
  evaluate: (env) ->
    paramValues = @params.map (param) ->
      param.evaluate(env)
    @fn.compute(paramValues...)








class Chain
  constructor: (@startParam) ->
    @links = []

  appendLink: (fn) ->
    additionalParams = [0...fn.numParams-1].map -> new Param()
    link = new Link(fn, additionalParams)
    @links.push(link)
    return link

class Link
  constructor: (@fn, @additionalParams) ->
    @visible = true
    @id = _.uniqueId("l")








class Editor
  constructor: ->
    @params = []
    @chains = []
    @xParam = null

    @hoveredLink = null
    @selectedLink = null
    @hoveredParam = null


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

  draw: (graph) ->
    for param in @visibleParams()
      @drawParam(graph, param)

    for chain in @chains
      for link in chain.links
        @drawChainLink(graph, chain, link)

  drawParam: (graph, param) ->
    graphFn = (xValue) =>
      env = @makeEnv(xValue)
      param.evaluate(env)
    graph.drawGraph(graphFn, {color: "green"})

  drawChainLink: (graph, chain, link) ->
    apply = @applyForChainLink(chain, link)
    if link == @selectedLink
      styleOpts = {color: "#009"}
    else if link == @hoveredLink
      styleOpts = {color: "#bbf"}
    else
      styleOpts = {color: "#000", opacity: 0.2}
    graphFn = (xValue) =>
      env = @makeEnv(xValue)
      apply.evaluate(env)
    graph.drawGraph(graphFn, styleOpts)

  applyForChainLink: (chain, link) ->
    apply = chain.startParam
    for l in chain.links
      params = [apply].concat(l.additionalParams)
      apply = new Apply(l.fn, params)
      break if l == link
    return apply


  # ===========================================================================
  # Direct Manipulating
  # ===========================================================================

  visibleParams: ->
    result = @params
    if @selectedLink
      result = _.union result, @selectedLink.additionalParams
    if @hoveredParam
      result = _.union result, @hoveredParam
    return result

  manipulableParams: ->
    result = @visibleParams()
    result = _.reject result, (param) => param == @xParam
    return result

  hitDetect: (e, graph) ->
    params = @manipulableParams()
    paramValues = _.map params, (param) -> param.value

    foundIndex = graph.hitDetect(e.clientY, paramValues)

    if foundIndex?
      return params[foundIndex]
    else
      return null

  pointerdown: (e, graph) ->
    param = @hitDetect(e, graph)
    return unless param

    setParam = (e) ->
      [x, y] = graph.getCoords([e.clientX, e.clientY])
      param.value = y
      refresh()
    setParam(e)
    capturePointer(e, setParam)









editor = new Editor()

do ->
  a = editor.addParam()
  editor.xParam = a

  # b = editor.addParam()
  # b.value = 2

  chain = editor.addChain(a)

  # abs = chain.appendLink(fnsToAdd[4])
  # plu = chain.appendLink(fnsToAdd[0])
  # # plu.additionalParams[0] = b
  # sin = chain.appendLink(fnsToAdd[5])









