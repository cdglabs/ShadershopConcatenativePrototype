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
  constructor: (@title, @defaultParams, @compileString) ->

fnsToAdd = [
  new Fn "+", [0, 0],
    (a, b) -> "(#{a} + #{b})"
  new Fn "-", [0, 0],
    (a, b) -> "(#{a} - #{b})"
  new Fn "*", [1, 1],
    (a, b) -> "(#{a} * #{b})"
  new Fn "/", [1, 1],
    (a, b) -> "(#{a} / #{b})"
  new Fn "abs", [0],
    (a) -> "Math.abs(#{a})"
  new Fn "sin", [0],
    (a) -> "Math.sin(#{a})"
  new Fn "cos", [0],
    (a) -> "Math.cos(#{a})"
  new Fn "fract", [0],
    (a) -> "(#{a} - Math.floor(#{a}))"
  new Fn "floor", [0],
    (a) -> "Math.floor(#{a})"
  new Fn "ceil", [0],
    (a) -> "Math.ceil(#{a})"
  new Fn "min", [0, 0],
    (a, b) -> "Math.min(#{a}, #{b})"
  new Fn "max", [0, 0],
    (a, b) -> "Math.max(#{a}, #{b})"
]


class Apply
  constructor: (@fn) ->
    @id = _.uniqueId("a")
    @params = @fn.defaultParams.map (paramValue) ->
      new Param(paramValue)

  setParam: (index, param) ->
    @params[index] = param

  compileString: ->
    paramCompileStrings = @params.map (param) ->
      param.compileString()
    @fn.compileString(paramCompileStrings...)



class ProvisionalApply
  constructor: ->
    @id = _.uniqueId("a")
    @params = [null]
    @possibleApplies = fnsToAdd.map (fn) ->
      new Apply(fn)
    @selectedApply = null

  setParam: (index, param) ->
    @params[index] = param
    for possibleApply in @possibleApplies
      possibleApply.setParam(index, param)

  compileString: ->
    if @selectedApply
      @selectedApply.compileString()
    else
      @params[0].compileString()










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
        nextApply.setParam(0, apply.params[0])

  insertApplyAfter: (apply, refApply) ->
    if @root == refApply
      @root = apply
      apply.setParam(0, refApply)
    else
      nextApply = @nextApply(refApply)
      if nextApply
        nextApply.setParam(0, apply)
        apply.setParam(0, refApply)

  replaceApply: (apply, refApply) ->
    @insertApplyAfter(apply, refApply)
    @removeApply(refApply)





editor = new Editor()

do ->
  a = new Param()
  editor.xParam = a

  sin = new Apply(fnsToAdd[5])
  sin.setParam(0, a)
  plus = new Apply(fnsToAdd[0])
  plus.setParam(0, sin)

  editor.root = plus




