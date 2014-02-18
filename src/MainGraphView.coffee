MainGraphView = React.createClass
  render: ->
    drawData = []

    # Draw the result for each chain.
    for chain in editor.chains
      link = _.last(chain.links)
      apply = editor.applyForChainLink(chain, link)
      drawData.push {apply, styleOpts: config.styles.selectedApply}

    if link = editor.hoveredLink
      apply = editor.applyForChainLink(chain, link)
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