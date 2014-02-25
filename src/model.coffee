class Param
  constructor: (@value = 0) ->
    @id = _.uniqueId("p")
    @title = ""
    @axis = "result"

  compileString: ->
    if this == editor.xParam
      "x"
    else if this == editor.spreadParam
      "(#{@value} + spreadOffset)"
    else
      ""+@value


class Fn
  constructor: (@title, @numParams, @compileString) ->

fnsToAdd = [
  new Fn "+", 2,
    (a, b) -> "(#{a} + #{b})"
  new Fn "-", 2,
    (a, b) -> "(#{a} - #{b})"
  new Fn "*", 2,
    (a, b) -> "(#{a} * #{b})"
  new Fn "/", 2,
    (a, b) -> "(#{a} / #{b})"
  new Fn "abs", 1,
    (a) -> "Math.abs(#{a})"
  new Fn "sin", 1,
    (a) -> "Math.sin(#{a})"
  new Fn "cos", 1,
    (a) -> "Math.cos(#{a})"
  new Fn "fract", 1,
    (a) -> "(#{a} - Math.floor(#{a}))"
  new Fn "floor", 1,
    (a) -> "Math.floor(#{a})"
  new Fn "ceil", 1,
    (a) -> "Math.ceil(#{a})"
  new Fn "min", 2,
    (a, b) -> "Math.min(#{a}, #{b})"
  new Fn "max", 2,
    (a, b) -> "Math.max(#{a}, #{b})"
]


class Apply
  constructor: (@fn, @params) ->
  compileString: ->
    paramCompileStrings = @params.map (param) ->
      param.compileString()
    @fn.compileString(paramCompileStrings...)








# class Chain
#   constructor: (startParam) ->
#     startLink = new StartLink(startParam)
#     @links = [startLink]

#   appendLink: (fn) ->
#     additionalParams = [0...fn.numParams-1].map -> new Param()
#     link = new Link(fn, additionalParams)
#     @links.push(link)
#     return link

#   appendLinkAfter: (fn, refLink) ->
#     additionalParams = [0...fn.numParams-1].map -> new Param()
#     link = new Link(fn, additionalParams)
#     i = @links.indexOf(refLink)
#     @links.splice(i+1, 0, link)
#     return link

#   insertLinkAfter: (link, refLink) ->
#     i = @links.indexOf(refLink)
#     @links.splice(i+1, 0, link)

#   removeLink: (refLink) ->
#     i = @links.indexOf(refLink)
#     if i != -1
#       @links.splice(i, 1)

# class Link
#   constructor: (@fn, @additionalParams) ->
#     @addLinkVisible = false
#     @id = _.uniqueId("l")

# class StartLink
#   constructor: (@startParam) ->








class Editor
  constructor: ->
    @root = null

    @xParam = null
    @spreadParam = null

    @hoveredParam = null
    @hoveredApply = null

    @cursor = null
    @mousePosition = {x: 0, y: 0}
    @dragging = null


  applies: ->
    applies = []
    apply = @root
    while true
      applies.unshift(apply)
      break if apply instanceof Param
      apply = apply.params[0]
    return applies

  nextApply: (refApply) ->
    # Returns a known apply such that apply.params[0] == refApply
    nextApply = @root
    while !(nextApply instanceof Param) && nextApply.params[0] != refApply
      nextApply = nextApply.params[0]
    if nextApply instanceof Param
      return undefined
    else
      return nextApply

  removeApply: (apply) ->
    if @root == apply
      @root = apply.params[0]
    else
      nextApply = @nextApply(apply)
      if nextApply
        nextApply.params[0] = apply.params[0]

  insertApplyAfter: (apply, refApply) ->
    if @root == refApply
      @root = apply
      apply.params[0] = refApply
    else
      nextApply = @nextApply(refApply)
      if nextApply
        nextApply.params[0] = apply
        apply.params[0] = refApply


  # # ===========================================================================
  # # Manipulating
  # # ===========================================================================

  # addChain: (startParam) ->
  #   chain = new Chain(startParam)
  #   @chains.push(chain)
  #   return chain


  # # ===========================================================================
  # # Rendering
  # # ===========================================================================

  # applyForChainLink: (chain, link) ->
  #   for l in chain.links
  #     if l instanceof StartLink
  #       apply = l.startParam
  #     else
  #       params = [apply].concat(l.additionalParams)
  #       apply = new Apply(l.fn, params)
  #     break if l == link
  #   return apply



editor = new Editor()

do ->
  a = new Param()
  editor.xParam = a

  sin = new Apply(fnsToAdd[5], [a])
  plus = new Apply(fnsToAdd[0], [sin, new Param()])

  editor.root = plus

  # chain = editor.addChain(a)




