Apply = require("../model/Apply")
Param = require("../model/Param")
evaluate = require("./evaluate")


module.exports = class Compiler
  constructor: ->
    @substitutions = {}

  substitute: (param, value) ->
    return unless param
    @substitutions[param.__id] = value


  # ===========================================================================
  # Compile algorithm
  # ===========================================================================

  getParamValue: (param) ->
    @substitutions[param.__id] ? param.value

  ensureString: (value) ->
    if _.isNumber(value)
      floatString = ""+value
      if floatString.indexOf(".") == -1
        floatString += "."
      return floatString
    else if _.isString(value)
      return value

  getId: (expr) ->
    expr?.__id

  getDependencies: (expr) ->
    if expr instanceof Param
      return []
    else if expr instanceof Apply
      return expr.dependentParams()

  computeOrdering: (expr) ->
    ordering = []
    alreadyIncludedIds = {}

    recurse = (expr) =>
      for dependency in @getDependencies(expr)
        recurse(dependency)

      id = @getId(expr)
      return if alreadyIncludedIds[id]
      ordering.push(expr)
      alreadyIncludedIds[id] = true

    recurse(expr)
    return ordering

  computeConstants: (ordering) ->
    constants = {} # id : value
    for expr in ordering
      id = @getId(expr)
      if expr instanceof Param
        value = @getParamValue(expr)
        if _.isNumber(value)
          constants[id] = value
      else
        dependencies = @getDependencies(expr)
        allConstants = _.all dependencies, (dependency) ->
          constants[dependency.__id]?
        if allConstants
          fn = expr.fn
          params = expr.allParams()
          paramValues = params.map (param) -> constants[param?.__id]
          compiled = fn.compileString(paramValues...)
          value = evaluate(compiled)
          constants[id] = value
    return constants

  generateLines: (ordering, constants) ->
    lines = []
    for expr in ordering
      id = @getId(expr)
      if constants[id]?
        compiled = constants[id]
      else if expr instanceof Param
        compiled = @getParamValue(expr)
      else if expr instanceof Apply
        fn = expr.fn
        params = expr.allParams()
        paramIds = params.map (param) => @getId(param)
        compiled = fn.compileString(paramIds...)
      compiled = @ensureString(compiled)
      lines.push({id, compiled})
    return lines

  convertLineToLang: (line, lang) ->
    if lang == "js"
      return "var #{line.id} = #{line.compiled};\n"
    else if lang == "glsl"
      return "float #{line.id} = #{line.compiled};\n"

  compile: (expr, lang) ->
    ordering = @computeOrdering(expr)
    constants = @computeConstants(ordering)
    lines = @generateLines(ordering, constants)

    strings = lines.map (line) => @convertLineToLang(line, lang)
    strings.push("return #{@getId(expr)};\n")
    string = strings.join("")

    return string

