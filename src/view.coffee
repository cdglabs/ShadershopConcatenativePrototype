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
    render: ->
      d.div {className: "param"},
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
        d.div {className: "startParam row"},
          ParamView {param: chain.startParam}
        d.div {className: "links"},
          chain.links.map (link) ->
            LinkView {link: link, key: link.id}
        d.div {className: "addFns row"},
          d.select {onChange: @handleChange},
            d.option {value: "select"}, "Add..."
            fnsToAdd.map (fn) =>
              d.option {}, fn.title

  LinkView = React.createClass
    handleMouseDown: ->
      editor.selectedLink = @props.link
      refresh()
    render: ->
      link = @props.link
      classNames = cx {
        "link": true
        "row": true
        "selectedLink": link == editor.selectedLink
      }
      d.div {className: classNames, onMouseDown: @handleMouseDown},
        d.div {className: "additionalParams", style: {float: "right"}},
          link.additionalParams.map (param, i) ->
            ParamView {param: param, key: i}
        d.div {className: "linkTitle"},
          link.fn.title

  EditorView = React.createClass
    render: ->
      d.div {className: "editor"},
        d.div {className: "heading row"}, "Parameters"
        editor.params.map (param) ->
          d.div {className: "row", key: param.id},
            ParamView {param: param}
        d.div {className: "heading row"}, "Chain" # We'll assume just one chain for now
        editor.chains.map (chain) ->
          ChainView {chain: chain}

  return ->
    manager = document.querySelector("#manager")
    React.renderComponent(EditorView(), manager)