R = React.DOM
cx = React.addons.classSet

refreshView = do ->

  EditorView = React.createClass
    render: ->
      R.div {className: "editor", style: {cursor: editor.dragging?.cursor ? ""}},
        MainGraphView {}
        R.div {className: "manager"},
          editor.applies().map (apply) ->
            ApplyRowView {apply, key: apply.__id}
        R.div {className: "dragging"},
          DraggingView {}

  return ->
    editorEl = document.querySelector("#editor")
    React.renderComponent(EditorView(), editorEl)