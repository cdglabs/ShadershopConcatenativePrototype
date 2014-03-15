R = React.DOM
cx = React.addons.classSet
ApplyRowView = require("./ApplyRowView")
MainGraphView = require("./MainGraphView")
DraggingView = require("./DraggingView")


OutputSwitchView = React.createClass
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


module.exports = EditorView = React.createClass
  handleMouseDown: (e) ->
    if editor.dragging?
      e.preventDefault()
      document.activeElement?.blur()
    else
      editor.unsetSelection()

  render: ->
    classNames = cx {
      editor: true
      dragging: editor.dragging?
    }
    R.div {className: classNames, style: {cursor: editor.dragging?.cursor ? ""}, onMouseDown: @handleMouseDown},
      MainGraphView {}
      R.div {className: "manager"},
        editor.applies().map (apply) ->
          ApplyRowView {apply, key: apply.__id}
      OutputSwitchView {}
      R.div {className: "dragging"},
        DraggingView {}