MainGraphView = React.createClass
  render: ->
    drawData = []

    drawData.push {apply: editor.root, styleOpts: config.styles.selectedApply}

    if apply = editor.hoveredApply
      if apply.params
        for param in apply.params
          if param instanceof Param and param != editor.xParam
            styleOpts = config.styles.param
          else
            styleOpts = config.styles.apply
          drawData.push({apply: param, styleOpts})
      drawData.push {apply, styleOpts: config.styles.hoveredApply}

    if param = editor.hoveredParam
      drawData.push {apply: param, styleOpts: config.styles.hoveredParam}

    GraphView {drawData, grid: true}