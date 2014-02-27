R = React.DOM
cx = React.addons.classSet

refreshView = do ->

  EditorView = React.createClass
    cursor: ->
      editor.dragging?.cursor ? editor.cursor ? ""
    render: ->
      R.div {className: "editor", style: {cursor: @cursor()}},
        MainGraphView {}
        R.div {className: "manager"},
          editor.applies().map (apply) ->
            ApplyRowView {apply, key: apply.id}
        R.div {className: "dragging"},
          DraggingView {}

  return ->
    editorEl = document.querySelector("#editor")
    React.renderComponent(EditorView(), editorEl)