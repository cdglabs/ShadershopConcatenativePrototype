Apply = require("../model/Apply")
Param = require("../model/Param")


module.exports = class Compiler
  constructor: ->
    @substitutions = {}

  substitute: (param, value) ->
    return unless param
    @substitutions[param.__id] = value

  compile: (apply, lang="js") ->
    if apply instanceof Apply
      fn = apply.fn
      params = apply.allParams()

      paramCompileStrings = params.map (param) =>
        return null unless param?
        @compile(param, lang)

      return fn.compileString(paramCompileStrings...)

    else if apply instanceof Param
      param = apply
      return @substitutions[param.__id] ? toFloatString(param.value)


  # ===========================================================================
  # In Progress: New compile algorithm
  # ===========================================================================

  compileLine: (expr) ->
    if expr instanceof Apply
      fn = expr.fn
      params = expr.allParams()
      paramIds = params.map (param) -> param?.__id
      fn.compileString(paramIds...)
    else if expr instanceof Param
      return @substitutions[expr.__id] ? expr.value

  compile2: (expr) ->
    lines = []
    alreadyCompiledIds = {}

    recurse = (expr) =>
      return unless expr?
      id = expr.__id
      return if alreadyCompiledIds[id]
      line = @compileLine(expr)
      line = {name: id, value: line}
      lines.unshift(line)
      alreadyCompiledIds[id] = true

      if expr instanceof Apply
        for param in expr.allParams()
          recurse(param)

    recurse(expr)

    return lines





toFloatString = (v) ->
  floatString = ""+v
  if floatString.indexOf(".") == -1
    floatString += "."
  return floatString