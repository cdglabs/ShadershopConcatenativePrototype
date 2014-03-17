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

    resultApply = editor.rootBlock.root

    # Spread
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
          graphViews.push(GraphView {apply: resultApply, key: "spread" + (i*neg),styleOpts, spreadOffset})

    # Result
    graphViews.push(GraphView {apply: resultApply, key: "result", styleOpts: config.styles.resultApply})

    # Hovered Apply
    if apply = editor.hoveredApply
      if !apply.isStart?()
        for param, paramIndex in apply.allParams()
          if param instanceof Param and param != editor.xParam
            styleOpts = config.styles.param
          else
            styleOpts = config.styles.apply
          graphViews.push(GraphView {apply: param, key: "param"+paramIndex, styleOpts})
      graphViews.push(GraphView {apply, key: "hoveredApply", styleOpts: config.styles.hoveredApply})

    # Hovered Param
    if param = editor.hoveredParam
      graphViews.push(GraphView {apply: param, key: "hoveredParam", styleOpts: config.styles.hoveredParam})

    R.span {},
      GridView {}
      graphViews


MainShaderGraphView = React.createClass
  render: ->
    R.span {style: {opacity: config.shaderOpacity}},
      ShaderGraphView {apply: editor.hoveredApply ? editor.rootBlock.root}
      GridView {}


module.exports = MainGraphView = React.createClass
  render: ->
    R.div {className: "main"},
      if editor.shaderView
        MainShaderGraphView {}
      else
        MainCartesianGraphView {}