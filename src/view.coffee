R = React.DOM
cx = React.addons.classSet

refreshView = do ->

  ChainView = React.createClass
    render: ->
      chain = @props.chain
      R.div {className: "chain"},
        R.div {className: "links"},
          chain.links.map (link) ->
            LinkView {link: link, chain: chain, key: link.id}

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

  LinkView = React.createClass
    toggleAddLink: ->
      {chain, link} = @props
      link.addLinkVisible = !link.addLinkVisible

    componentDidMount: ->
      {chain, link} = @props

      thumbEl = @refs.thumb.getDOMNode()
      thumbEl.ssLink = link

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
      R.div {},
        R.div {className: classNames},
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
          R.button {className: "addLinkButton", onClick: @toggleAddLink}, "+"
        if link.addLinkVisible
          AddLinkView {chain, link}

  EditorView = React.createClass
    render: ->
      R.div {className: "editor"},
        R.div {className: "main"},
          MainGraphView {}
        R.div {className: "manager"},
          editor.chains.map (chain) ->
            ChainView {chain: chain}
        R.div {className: "dragging"},
          DraggingView {}

  return ->
    editorEl = document.querySelector("#editor")
    React.renderComponent(EditorView(), editorEl)