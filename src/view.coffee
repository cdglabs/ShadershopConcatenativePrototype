R = React.DOM
cx = React.addons.classSet

refreshView = do ->

  EditorView = React.createClass
    cursor: ->
      editor.dragging?.cursor ? editor.cursor ? ""
    render: ->
      R.div {className: "editor", style: {cursor: @cursor()}},
        R.div {className: "main"},
          MainGraphView {}
        R.div {className: "manager"},
          editor.applies().map (apply) ->
            ApplyView {apply}
        R.div {className: "dragging"},
          DraggingView {}

  return ->
    editorEl = document.querySelector("#editor")
    React.renderComponent(EditorView(), editorEl)