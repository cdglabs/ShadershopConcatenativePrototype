refreshView = do ->

  d = React.DOM
  cx = React.addons.classSet


  truncate = (value) ->
    s = "" + value
    decimalPlace = s.indexOf(".")
    if decimalPlace
      s.substr(0, decimalPlace + 4)


  ParamValueView = React.createClass
    render: ->
      param = @props.param
      d.span {className: "paramValue"},
        do =>
          if editor.xParam == param
            d.i {}, "x"
          else
            truncate(param.value)

  ParamTitleView = React.createClass
    handleInput: ->
      el = @refs.span.getDOMNode()
      newTitle = el.textContent
      if el.innerHTML != newTitle
        el.innerHTML = newTitle

      @props.param.title = newTitle
      refresh()
    render: ->
      param = @props.param
      d.span {className: "paramTitle", contentEditable: "true", onInput: @handleInput, ref: "span"},
        param.title

  ParamView = React.createClass
    handleMouseEnter: ->
      editor.hoveredParam = @props.param
      refresh()
    handleMouseLeave: ->
      editor.hoveredParam = null
      refresh()
    render: ->
      classNames = cx {
        param: true
        hovered: @props.param == editor.hoveredParam
      }
      d.div {className: classNames, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
        ParamTitleView {param: @props.param}
        ParamValueView {param: @props.param}


  ChainView = React.createClass
    handleChange: (e) ->
      i = e.target.selectedIndex
      e.target.selectedIndex = 0
      return if i == 0

      fn = fnsToAdd[i-1]
      @props.chain.appendLink(fn)
      refresh()

    render: ->
      chain = @props.chain
      d.div {className: "chain"},
        d.div {className: "links"},
          chain.links.map (link) ->
            LinkView {link: link, chain: chain, key: link.id}
        # d.div {className: "addFns row"},
        #   d.select {onChange: @handleChange},
        #     d.option {value: "select"}, "Add..."
        #     fnsToAdd.map (fn) =>
        #       d.option {}, fn.title

  AddLinkView = React.createClass
    handleClickOn: (fn) ->
      =>
        {chain, link} = @props
        chain.appendLinkAfter(fn, link)
        link.addLinkVisible = false
        refresh()
    render: ->
      d.div {className: "addLink"},
        fnsToAdd.map (fn) =>
          d.div {className: "row", onClick: @handleClickOn(fn)},
            fn.title

  LinkView = React.createClass
    handleMouseDown: ->
      # editor.selectedLink = @props.link
      # refresh()
    handleMouseEnter: ->
      editor.hoveredLink = @props.link
      refresh()
    handleMouseLeave: ->
      editor.hoveredLink = null
      refresh()
    toggleAddLink: ->
      {chain, link} = @props
      link.addLinkVisible = !link.addLinkVisible
      refresh()
    componentDidMount: ->
      {chain, link} = @props
      canvasEl = @refs.canvas.getDOMNode()
      canvasEl.drawData = {chain, link}
      refreshTinyGraphs()

    render: ->
      {chain, link} = @props
      classNames = cx {
        "link": true
        "row": true
        "selectedLink": link == editor.selectedLink
        "hoveredLink": link == editor.hoveredLink
      }
      d.div {},
        d.div {className: classNames, onMouseDown: @handleMouseDown, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
          d.div {className: "tinyGraph", style: {float: "right", margin: -7}},
            d.canvas {ref: "canvas"}
          if link instanceof StartLink
            ParamView {param: link.startParam}
          else
            d.span {},
              d.span {className: "linkTitle", style: {marginRight: 6}},
                link.fn.title
              link.additionalParams.map (param, i) ->
                ParamView {param: param, key: i}
          d.button {className: "addLinkButton", onClick: @toggleAddLink}, "+"
        if link.addLinkVisible
          AddLinkView {chain, link}

  EditorView = React.createClass
    render: ->
      d.div {className: "editor"},
        # d.div {className: "heading row"}, "Parameters"
        # editor.params.map (param) ->
        #   d.div {className: "row", key: param.id},
        #     ParamView {param: param}
        # d.div {className: "heading row"}, "Chain" # We'll assume just one chain for now
        editor.chains.map (chain) ->
          ChainView {chain: chain}

  return ->
    manager = document.querySelector("#manager")
    React.renderComponent(EditorView(), manager)