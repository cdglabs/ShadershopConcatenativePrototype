###
Intermediate Form


IExpr = IApply | IParam

IApply
  {
    type: "apply"
    original: Apply
    fn: Fn
    params: [IExpr]
  }

IParam
  {
    type: "param"
    original: Param
  }
###

Apply = require("./Apply")
Param = require("./Param")
editor = require("../editor")

module.exports = compile = (apply, lang="js") ->
  if apply instanceof Apply
    fn = apply.fn
    params = apply.allParams()

    paramCompileStrings = params.map (param) ->
      return null unless param?
      compile(param, lang)

    if lang == "js"
      fn.compileString(paramCompileStrings...)
    else if lang == "glsl"
      fn.compileGlslString(paramCompileStrings...)

  else if apply instanceof Param
    param = apply
    if param == editor.xParam
      return "x"
    else if param == editor.yParam and lang == "glsl"
      return "y"
    else if param == editor.spreadParam() and lang == "js"
      return "(#{param.value} + spreadOffset)"
    else
      if lang == "js"
        return ""+param.value
      else
        floatString = ""+param.value
        if floatString.indexOf(".") == -1
          floatString += "."
        return floatString