R = React.DOM
cx = React.addons.classSet

refreshView = do ->

  ChainView = React.createClass
    render: ->
      chain = @props.chain
      R.div {className: "chain"},
        R.div {className: "links"},
          chain.links.map (link) ->
            LinkRowView {link: link, chain: chain, key: link.id}

  EditorView = React.createClass
    cursor: ->
      editor.dragging?.cursor ? ""
    render: ->
      R.div {className: "editor", style: {cursor: @cursor()}},
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