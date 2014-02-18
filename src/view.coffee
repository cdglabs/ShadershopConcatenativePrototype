d = React.DOM
cx = React.addons.classSet

refreshView = do ->




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
    handleMouseDown: (e) ->
      el = @getDOMNode()
      return if el == document.activeElement # editing text

      e.preventDefault()

      el = el.closest(".param")

      originalX = e.clientX
      originalY = e.clientY

      rect = el.getBoundingClientRect()
      originalGhostX = rect.left
      originalGhostY = rect.top

      ghost = el.cloneNode(true)

      ghost.style.position = "absolute"
      ghost.style.opacity = "0.5"
      ghost.style.pointerEvents = "none"
      document.body.appendChild(ghost)

      moveGhost = (x, y) ->
        ghost.style.top = y + "px"
        ghost.style.left = x + "px"

      moveGhost(originalGhostX, originalGhostY)

      editor.movingParam = @props.param

      pointerManager.capture e,
        (e) ->
          dx = e.clientX - originalX
          dy = e.clientY - originalY
          moveGhost(originalGhostX + dx, originalGhostY + dy)
        (e) ->
          document.body.removeChild(ghost)
          setTimeout((-> editor.movingParam = null), 1)


    handleInput: ->
      el = @getDOMNode()
      newTitle = el.textContent
      if el.innerHTML != newTitle
        el.innerHTML = newTitle

      @props.param.title = newTitle
      refresh()
    handleDoubleClick: ->
      el = @getDOMNode()
      el.focus()

    render: ->
      param = @props.param
      d.span {className: "paramTitle", contentEditable: true, onMouseDown: @handleMouseDown, onDoubleClick: @handleDoubleClick, onInput: @handleInput},
        param.title

  ParamView = React.createClass
    componentDidMount: ->
      @getDOMNode().ssParam = @props.param
    handleMouseUp: (e) ->
      return unless editor.movingParam
      @props.replaceSelf(editor.movingParam)
    render: ->
      classNames = cx {
        param: true
        hovered: _.contains editor.hoveredParams, @props.param
      }
      d.div {className: classNames, onMouseUp: @handleMouseUp},
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
        newLink = chain.appendLinkAfter(fn, link)
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

      rowEl = @refs.row.getDOMNode()
      rowEl.ssLink = link

    renderThumbnail: ->
      drawData = []
      apply = editor.applyForChainLink(@props.chain, @props.link)
      if apply.params
        for param in apply.params
          if param instanceof Param and param != editor.xParam
            styleOpts = {color: "green", opacity: 0.4}
          else
            styleOpts = {color: "#000", opacity: 0.1}
          drawData.push({apply: param, styleOpts})
      drawData.push({apply, styleOpts: {color: "#000"}})
      GraphView {drawData}

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
            @renderThumbnail()
          if link instanceof StartLink
            ParamView {param: link.startParam, replaceSelf: (p) ->
              link.startParam = p
              refresh()
            }
          else
            d.span {},
              d.span {className: "linkTitle", style: {marginRight: 6}},
                link.fn.title
              link.additionalParams.map (param, i) ->
                ParamView {param: param, key: "#{i}/#{param.id}", replaceSelf: (p) ->
                  link.additionalParams[i] = p
                  refresh()
                }
          d.button {className: "addLinkButton", onClick: @toggleAddLink}, "+"
        if link.addLinkVisible
          AddLinkView {chain, link}

  EditorView = React.createClass
    render: ->
      d.div {className: "editor"},
        editor.chains.map (chain) ->
          ChainView {chain: chain}

  return ->
    manager = document.querySelector("#manager")
    React.renderComponent(EditorView(), manager)