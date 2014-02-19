DraggingView = React.createClass
  render: ->
    if editor.dragging?.render
      R.div {
        className: "draggingObject"
        style: {
          left: editor.mousePosition.x - editor.dragging.offset.x
          top:  editor.mousePosition.y - editor.dragging.offset.y
        }
      }, editor.dragging.render()

    else
      R.div {}