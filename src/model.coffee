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
    @visible = true
    @addLinkVisible = false
    @id = _.uniqueId("l")

class StartLink
  constructor: (@startParam) ->








class Editor
  constructor: ->
    @params = []
    @chains = []
    @xParam = null

    @hoveredParams = []
    @hoveredLinks = []


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
    for chain in @chains
      for link in chain.links
        @drawChainLinkResult(graph, chain, link, {color: "#000", opacity: 0.02})

    for param in @hoveredParams
      @drawParam(graph, param, {color: "green"})

    for link in @hoveredLinks
      @drawChainLink(graph, chain, link)

  drawParam: (graph, param, styleOpts) ->
    graphFn = (xValue) =>
      env = @makeEnv(xValue)
      param.evaluate(env)
    graph.drawGraph(graphFn, styleOpts)

  drawChainLinkResult: (graph, chain, link, styleOpts) ->
    apply = @applyForChainLink(chain, link)
    graphFn = (xValue) =>
      env = @makeEnv(xValue)
      apply.evaluate(env)
    graph.drawGraph(graphFn, styleOpts)

  drawChainLink: (graph, chain, link) ->
    apply = @applyForChainLink(chain, link)
    if apply.params
      for param in apply.params
        graphFn = (xValue) =>
          env = @makeEnv(xValue)
          param.evaluate(env)
        styleOpts = {color: "#000", opacity: 0.1}
        graph.drawGraph(graphFn, styleOpts)

    styleOpts = {color: "#009"}
    graphFn = (xValue) =>
      env = @makeEnv(xValue)
      apply.evaluate(env)
    graph.drawGraph(graphFn, styleOpts)


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









