refreshView = do ->

  d = React.DOM


  truncate = (value) ->
    s = "" + value
    decimalPlace = s.indexOf(".")
    if decimalPlace
      s.substr(0, decimalPlace + 4)


  ParamValueView = React.createClass
    render: ->
      param = @props.param
      d.span {className: "paramValue"},
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
      param = @props.param
      d.div {className: "param row"},
        d.div {style: {float: "right"}},
          ParamValueView {param: param}
        ParamTitleView {param: param}


  ChainView = React.createClass
    render: ->
      chain = @props.chain
      d.div {className: "chain"},
        d.div {className: "startParam row"},
          ParamTitleView {param: chain.startParam}
        d.div {className: "links"},
          chain.links.map (link) ->
            LinkView {link: link, key: link.id}

  LinkView = React.createClass
    render: ->
      link = @props.link
      d.div {className: "link row"},
        d.div {className: "additionalParams", style: {float: "right"}},
          link.additionalParams.map (param, i) ->
            if _.contains editor.params, param
              ParamTitleView {param: param, key: i}
            else
              ParamValueView {param: param, key: i}
        link.fn.title

  EditorView = React.createClass
    render: ->
      d.div {className: "editor"},
        d.div {className: "heading row"}, "Parameters"
        editor.params.map (param) ->
          ParamView {param: param, key: param.id}
        d.div {className: "heading row"}, "Chain" # We'll assume just one chain for now
        editor.chains.map (chain) ->
          ChainView {chain: chain}

  return ->
    manager = document.querySelector("#manager")
    React.renderComponent(EditorView(), manager)