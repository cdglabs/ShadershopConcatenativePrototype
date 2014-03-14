R = React.DOM
cx = React.addons.classSet
lerp = require("../util/lerp")
Param = require("../model/Param")
GridView = require("./rendering/GridView")
GraphView = require("./rendering/GraphView")
ShaderGraphView = require("./rendering/ShaderGraphView")
config = require("../config")


MainCartesianGraphView = React.createClass
  render: ->
    graphViews = []

    if editor.spreadParam()
      spreadDistance = 0.5
      spreadNum = 5
      for i in [1...spreadNum]
        for neg in [-1, 1]
          if neg == -1
            styleOpts = _.clone(config.styles.spreadNegative)
          else
            styleOpts = _.clone(config.styles.spreadPositive)
          styleOpts.globalAlpha = lerp(i, 1, spreadNum, config.spreadOpacityMax, config.spreadOpacityMin)
          spreadOffset = spreadDistance * i * neg
          graphViews.push(GraphView {apply: editor.root, styleOpts, spreadOffset})

    graphViews.push(GraphView {apply: editor.root, styleOpts: config.styles.selectedApply})

    if apply = editor.hoveredApply
      if apply.params and !apply.isStart?()
        for param in apply.params
          if param instanceof Param and param != editor.xParam
            styleOpts = config.styles.param
          else
            styleOpts = config.styles.apply
          graphViews.push(GraphView {apply: param, styleOpts})
      graphViews.push(GraphView {apply, styleOpts: config.styles.hoveredApply})

    if param = editor.hoveredParam
      graphViews.push(GraphView {apply: param, styleOpts: config.styles.hoveredParam})

    R.span {},
      GridView {}
      graphViews


MainShaderGraphView = React.createClass
  render: ->
    R.span {style: {opacity: config.shaderOpacity}},
      ShaderGraphView {apply: editor.hoveredApply ? editor.root}
      GridView {}


module.exports = MainGraphView = React.createClass
  render: ->
    R.div {className: "main"},
      if editor.shaderView
        MainShaderGraphView {}
      else
        MainCartesianGraphView {}