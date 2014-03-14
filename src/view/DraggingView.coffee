R = React.DOM
cx = React.addons.classSet


module.exports = DraggingView = React.createClass
  render: ->
    R.div {},
      if editor.dragging?.render
        R.div {
          className: "draggingObject"
          style: {
            left: editor.mousePosition.x - editor.dragging.offset.x
            top:  editor.mousePosition.y - editor.dragging.offset.y
          }
        },
          editor.dragging.render()
      if editor.dragging
        R.div {className: "draggingOverlay"}