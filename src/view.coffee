refreshView = do ->

  d = React.DOM

  dif = (cond, fn) ->
    if cond then fn() else null

  ParamValueView = React.createClass
    render: ->
      param = @props.param
      d.span {className: "paramValue"},
        param.value

  ParamTitleView = React.createClass
    render: ->
      param = @props.param
      d.span {className: "paramTitle"},
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
            LinkView {link: link}

  LinkView = React.createClass
    render: ->
      link = @props.link
      d.div {className: "link row"},
        link.fn.title

  EditorView = React.createClass
    render: ->
      d.div {className: "editor"},
        d.div {className: "heading row"}, "Parameters"
        editor.params.map (param) ->
          ParamView {param: param}
        d.div {className: "heading row"}, "Chain" # We'll assume just one chain for now
        editor.chains.map (chain) ->
          ChainView {chain: chain}

  return ->
    manager = document.querySelector("#manager")
    React.renderComponent(EditorView(), manager)