class Param
  constructor: (@value = 0) ->
    objectManager.assignId(this)
    @title = ""
    @axis = "result"

  compileString: ->
    if this == editor.xParam
      "x"
    else if this == editor.spreadParam()
      "(#{@value} + spreadOffset)"
    else
      ""+@value

  compileGlslString: ->
    if this == editor.xParam
      "x"
    else if this == editor.yParam
      "y"
    else
      floatString = ""+@value
      if floatString.indexOf(".") == -1
        floatString += "."
      return floatString


class Fn
  constructor: (@title, @defaultParams, @compileString, @compileGlslString) ->
    objectManager.registerBuiltInObject("fn-"+@title, this)

fnsToAdd = [
  new Fn "", [null, 0],
    (a, b) -> "#{b}"
    (a, b) -> "#{b}"
  new Fn "+", [0, 0],
    (a, b) -> "(#{a} + #{b})"
    (a, b) -> "(#{a} + #{b})"
  new Fn "-", [0, 0],
    (a, b) -> "(#{a} - #{b})"
    (a, b) -> "(#{a} - #{b})"
  new Fn "*", [1, 1],
    (a, b) -> "(#{a} * #{b})"
    (a, b) -> "(#{a} * #{b})"
  new Fn "/", [1, 1],
    (a, b) -> "(#{a} / #{b})"
    (a, b) -> "(#{a} / #{b})"
  new Fn "abs", [0],
    (a) -> "Math.abs(#{a})"
    (a) -> "abs(#{a})"
  new Fn "sqrt", [0],
    (a) -> "Math.sqrt(#{a})"
    (a) -> "sqrt(#{a})"
  new Fn "pow", [1, 1],
    (a, b) -> "Math.pow(Math.abs(#{a}), #{b})"
    (a, b) -> "pow(#{a}, #{b})"
  new Fn "sin", [0],
    (a) -> "Math.sin(#{a})"
    (a) -> "sin(#{a})"
  new Fn "cos", [0],
    (a) -> "Math.cos(#{a})"
    (a) -> "cos(#{a})"
  new Fn "fract", [0],
    (a) -> "(#{a} - Math.floor(#{a}))"
    (a) -> "fract(#{a})"
  new Fn "floor", [0],
    (a) -> "Math.floor(#{a})"
    (a) -> "floor(#{a})"
  new Fn "ceil", [0],
    (a) -> "Math.ceil(#{a})"
    (a) -> "ceil(#{a})"
  new Fn "min", [0, 0],
    (a, b) -> "Math.min(#{a}, #{b})"
    (a, b) -> "min(#{a}, #{b})"
  new Fn "max", [0, 0],
    (a, b) -> "Math.max(#{a}, #{b})"
    (a, b) -> "max(#{a}, #{b})"
]


class Apply
  constructor: (@fn) ->
    objectManager.assignId(this)
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
    @fn == fnsToAdd[0]



class ProvisionalApply
  constructor: ->
    objectManager.assignId(this)
    @params = [null]
    @possibleApplies = fnsToAdd.map (fn) ->
      new Apply(fn)
    @selectedApply = null

  setParam: (index, param) ->
    @params[index] = param
    for possibleApply in @possibleApplies
      possibleApply.setParam(index, param)

  effectiveApply: ->
    @selectedApply ? @params[0]

  compileString: ->
    @effectiveApply().compileString()

  compileGlslString: ->
    @effectiveApply().compileGlslString()










class Editor
  constructor: ->
    @root = null

    @xParam = null
    @yParam = null

    @hoveredParam = null
    @hoveredApply = null

    @cursor = null
    @mousePosition = {x: 0, y: 0}
    @dragging = null

    @outputSwitch = "Cartesian"
    @shaderView = false
    @contourView = false


  spreadParam: ->
    return null if @dragging
    return null if @hoveredParam == @xParam or @hoveredParam == @yParam
    return @hoveredParam


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






objectManager.registerClass("Param", Param)
objectManager.registerClass("Apply", Apply)
objectManager.registerClass("ProvisionalApply", ProvisionalApply)
objectManager.registerClass("Editor", Editor)




