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

      if lang == "js"
        fn.compileString(paramCompileStrings...)
      else if lang == "glsl"
        fn.compileGlslString(paramCompileStrings...)

    else if apply instanceof Param
      param = apply
      return @substitutions[param.__id] ? toFloatString(param.value)


toFloatString = (v) ->
  floatString = ""+v
  if floatString.indexOf(".") == -1
    floatString += "."
  return floatString