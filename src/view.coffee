refreshView = do ->

  d = React.DOM
  cx = React.addons.classSet


  truncate = (value) ->
    s = "" + value
    decimalPlace = s.indexOf(".")
    if decimalPlace
      s.substr(0, decimalPlace + 4)

  setAdd = (list, value) ->
    if list.indexOf(value) == -1
      list.push(value)

  setRemove = (list, value) ->
    if (i = list.indexOf(value)) != -1
      list.splice(i, 1)








  ParamValueView = React.createClass
    handleMouseDown: (e) ->
      {param} = @props
      e.preventDefault()
      originalY = e.clientY
      originalValue = param.value
      pointerManager.capture e,
        (e) ->
          dy = e.clientY - originalY
          multiplier = -(mainGraph.yMax - mainGraph.yMin) / mainGraph.height()
          param.value = originalValue + dy * multiplier
          refresh()

    render: ->
      param = @props.param
      d.span {className: "paramValue", onMouseDown: @handleMouseDown},
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
    componentDidMount: ->
      @getDOMNode().ssParam = @props.param
    render: ->
      classNames = cx {
        param: true
        hovered: _.contains editor.hoveredParams, @props.param
      }
      d.div {className: classNames},
        ParamTitleView {param: @props.param}
        ParamValueView {param: @props.param}


  ChainView = React.createClass
    render: ->
      chain = @props.chain
      d.div {className: "chain"},
        d.div {className: "links"},
          chain.links.map (link) ->
            LinkView {link: link, chain: chain, key: link.id}

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
    toggleAddLink: ->
      {chain, link} = @props
      link.addLinkVisible = !link.addLinkVisible
      refresh()

    componentDidMount: ->
      {chain, link} = @props

      canvasEl = @refs.canvas.getDOMNode()
      canvasEl.drawData = {chain, link}

      rowEl = @refs.row.getDOMNode()
      rowEl.ssLink = link

      refreshTinyGraphs()

    render: ->
      {chain, link} = @props
      classNames = cx {
        link: true
        row: true
        hovered: _.contains editor.hoveredLinks, link
      }
      d.div {},
        d.div {className: classNames, ref: "row"},
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