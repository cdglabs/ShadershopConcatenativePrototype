onceDragConsummated = require("../util/onceDragConsummated")


truncate = (value) ->
  s = value.toFixed(4)
  if s.indexOf(".") != -1
    s = s.replace(/\.?0*$/, "")
  s = "0" if s == "-0"
  return s



R.ContentEditableMixin = {
  isFocused: ->
    return false unless @isMounted()
    @getDOMNode() == document.activeElement

  cleanAndGetValue: ->
    el = @getDOMNode()
    text = el.textContent
    if el.innerHTML != text
      el.innerHTML = text
    return text

  focus: ->
    @getDOMNode().focus()

  focusAndSelect: ->
    @focus()
    document.execCommand("selectAll", false, null)
    @forceUpdate() # Hack: So that cursor changes

}





R.create "ParamValueView",
  mixins: [R.ContentEditableMixin]

  shouldComponentUpdate: ->
    return !@isFocused()

  cursor: ->
    if @isFocused()
      "text"
    else if @props.param.axis == "x"
      "ew-resize"
    else
      "ns-resize"

  handleMouseDown: (e) ->
    if @isFocused()
      editor.dragging = {text: true}
      return

    {param} = @props
    originalX = e.clientX
    originalY = e.clientY
    originalValue = param.value

    editor.dragging = {
      cursor: @cursor()
      onMove: (e) =>
        editor.hoveredParam = param
        dx = e.clientX - originalX
        dy = -(e.clientY - originalY)
        d = if param.axis == "x" then dx else dy
        multiplier = 0.1
        # TODO controller
        param.value = originalValue + d * multiplier
      onUp: (e) =>
        # TODO controller
        editor.hoveredParam = null
    }

    onceDragConsummated e, null, =>
      @focusAndSelect()


  handleInput: (e) ->
    # TODO controller
    @props.param.value = +@cleanAndGetValue()

  render: ->
    param = @props.param
    R.span {
      className: "paramValue"
      contentEditable:true
      onMouseDown: @handleMouseDown
      onDoubleClick: @focusAndSelect
      onInput: @handleInput
      style: {cursor: @cursor()}
    },
      do =>
        if editor.xParam == param
          R.i {}, "x"
        else if editor.yParam == param
          R.i {}, "y"
        else if editor.timeParam == param
          R.i {}, "time"
        else
          truncate(param.value)



R.create "ParamTitleView",
  mixins: [R.ContentEditableMixin, R.StartTranscludeMixin]

  cursor: ->
    if @isFocused()
      "text"
    else
      "-webkit-grab"

  handleMouseDown: (e) ->
    if @isFocused()
      editor.dragging = {text: true}
      return

    {param} = @props
    render = =>
      R.ParamView {param}
    @startTransclude(e, param, render)
    onceDragConsummated e, null, =>
      @focusAndSelect()

  handleInput: ->
    # TODO controller
    @props.param.title = @cleanAndGetValue()

  render: ->
    param = @props.param
    R.span {
      className: "paramTitle"
      contentEditable: true
      onMouseDown: @handleMouseDown
      onDoubleClick: @focusAndSelect
      onInput: @handleInput
      style: {cursor: @cursor()}
    }, param.title



R.create "ParamView",
  handleMouseDown: (e) ->
    {param} = @props
    # TODO controller
    if key.command
      # if param.axis == "result"
      #   param.axis = "x"
      # else
      #   param.axis = "result"
      if editor.timeParam == param
        editor.timeParam = null
      else
        editor.timeParam = param
    else if key.shift
      if editor.xParam == param
        editor.xParam = null
      else
        editor.xParam = param
    else if key.option
      if editor.yParam == param
        editor.yParam = null
      else
        editor.yParam = param
  handleMouseEnter: ->
    # TODO controller
    editor.hoveredParam = @props.param
  handleMouseLeave: ->
    # TODO controller
    editor.hoveredParam = null
  render: ->
    classNames = R.cx {
      param: true
      hovered: editor.hoveredParam == @props.param
    }
    R.div {className: classNames, onMouseDown: @handleMouseDown, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      R.ParamTitleView {param: @props.param}
      R.ParamValueView {param: @props.param}