truncate = (value) ->
  s = value.toFixed(4)
  if s.indexOf(".") != -1
    s = s.replace(/\.?0*$/, "")
  return s



ContentEditableMixin = {
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





ParamValueView = React.createClass
  mixins: [ContentEditableMixin]

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
    return if @isFocused()

    e.preventDefault()

    {param} = @props
    e.preventDefault()
    originalX = e.clientX
    originalY = e.clientY
    originalValue = param.value

    editor.dragging = {
      cursor: @cursor()
      onMove: (e) ->
        editor.hoveredParam = param
        dx = e.clientX - originalX
        dy = -(e.clientY - originalY)
        d = if param.axis == "x" then dx else dy
        multiplier = 0.1
        param.value = originalValue + d * multiplier
      onUp: (e) ->
        editor.hoveredParam = null
    }


  handleInput: (e) ->
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
        else
          truncate(param.value)



ParamTitleView = React.createClass
  mixins: [ContentEditableMixin, TranscludeMixin]

  cursor: ->
    if @isFocused()
      "text"
    else
      "-webkit-grab"

  handleMouseDown: (e) ->
    return if @isFocused()
    {param} = @props
    render = =>
      ParamView {param}
    @startTransclude(e, param, render)

  handleInput: ->
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



ParamView = React.createClass
  handleClick: (e) ->
    {param} = @props
    if key.command
      if param.axis == "result"
        param.axis = "x"
      else
        param.axis = "result"
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
    editor.hoveredParam = @props.param
  handleMouseLeave: ->
    editor.hoveredParam = null
  render: ->
    classNames = cx {
      param: true
      hovered: editor.hoveredParam == @props.param
    }
    R.div {className: classNames, onClick: @handleClick, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      ParamTitleView {param: @props.param}
      ParamValueView {param: @props.param}