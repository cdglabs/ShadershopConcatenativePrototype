LinkView = React.createClass
  componentDidMount: ->
    {chain, link} = @props

    thumbEl = @refs.thumb.getDOMNode()
    thumbEl.ssLink = link

  handleMouseDown: (e) ->
    return if e.target.closest(".param")?

    {chain, link} = @props
    e.preventDefault()

    chain.removeLink(link)

    el = @getDOMNode()
    rect = el.getBoundingClientRect()

    editor.dragging = {
      offset: {
        x: e.clientX - rect.left
        y: e.clientY - rect.top
      }
      render: =>
        R.div {style: {width: rect.width, height: rect.height}},
          LinkView {chain, link, isDraggingCopy: true}
    }

  renderThumbnail: ->
    drawData = []
    apply = editor.applyForChainLink(@props.chain, @props.link)
    if apply.params
      for param in apply.params
        if param instanceof Param and param != editor.xParam
          styleOpts = config.styles.param
        else
          styleOpts = config.styles.apply
        drawData.push({apply: param, styleOpts})
    if @props.link == editor.hoveredLink
      drawData.push({apply, styleOpts: config.styles.hoveredApply})
    else
      drawData.push({apply, styleOpts: config.styles.selectedApply})
    GraphView {drawData}

  render: ->
    {chain, link} = @props
    classNames = cx {
      link: true
      row: true
      hovered: editor.hoveredLink == link
    }
    R.div {className: classNames, onMouseDown: @handleMouseDown},
      R.div {className: "tinyGraph", style: {float: "right", margin: -7}, ref: "thumb"},
        @renderThumbnail()
      if link instanceof StartLink
        ParamView {param: link.startParam, replaceSelf: (p) ->
          link.startParam = p
        }
      else
        R.span {},
          R.span {className: "linkTitle", style: {marginRight: 6}},
            link.fn.title
          link.additionalParams.map (param, i) ->
            ParamView {param: param, key: "#{i}/#{param.id}", replaceSelf: (p) ->
              link.additionalParams[i] = p
            }


AddLinkView = React.createClass
  handleClickOn: (fn) ->
    =>
      {chain, link} = @props
      newLink = chain.appendLinkAfter(fn, link)
      link.addLinkVisible = false
  render: ->
    R.div {className: "addLink"},
      fnsToAdd.map (fn) =>
        R.div {className: "row", onClick: @handleClickOn(fn)},
          fn.title


LinkRowView = React.createClass
  toggleAddLink: ->
    {chain, link} = @props
    link.addLinkVisible = !link.addLinkVisible

  render: ->
    {chain, link} = @props
    R.div {className: "linkRow"},
      LinkView {chain, link}
      R.button {className: "addLinkButton", onClick: @toggleAddLink}, "+"
      if link.addLinkVisible
        AddLinkView {chain, link}