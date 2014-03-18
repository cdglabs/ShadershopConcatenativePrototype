R.create "OutputSwitchView",
  handleChange: (e) ->
    # TODO controller
    editor.outputSwitch = e.target.selectedOptions[0].value
    if editor.outputSwitch == "Cartesian"
      editor.shaderView = false
    else if editor.outputSwitch == "Color Map"
      editor.shaderView = true
      editor.contourView = false
    else if editor.outputSwitch == "Contour Map"
      editor.shaderView = true
      editor.contourView = true

  render: ->
    R.div {className: "outputSwitch"},
      R.select {value: editor.outputSwitch, onChange: @handleChange, ref: "select"},
        R.option {value: "Cartesian"}, "Cartesian"
        R.option {value: "Color Map"}, "Color Map"
        R.option {value: "Contour Map"}, "Contour Map"


R.create "EditorView",
  handleMouseDown: (e) ->
    if editor.dragging?
      unless editor.dragging.text
        e.preventDefault()
        document.activeElement?.blur()
        document.activeElement = document.body
    else
      editor.unsetSelection()

  render: ->
    classNames = R.cx {
      editor: true
      dragging: editor.dragging?
    }
    R.div {className: classNames, style: {cursor: editor.dragging?.cursor ? ""}, onMouseDown: @handleMouseDown},
      R.MainGraphView {}
      R.div {className: "manager"},
        R.BlockView {block: editor.rootBlock}
      R.OutputSwitchView {}
      R.div {className: "dragging"},
        R.DraggingView {}