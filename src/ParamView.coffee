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
  mixins: [ContentEditableMixin, AnnotateMixin]
  annotate: ->
    {
      self: {cursor: @cursor()}
    }

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
        dx = e.clientX - originalX
        dy = -(e.clientY - originalY)
        d = if param.axis == "x" then dx else dy
        multiplier = 0.1
        param.value = originalValue + d * multiplier
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
      "data-cursor": @cursor()
    },
      do =>
        if editor.xParam == param
          R.i {}, "x"
        else
          truncate(param.value)



ParamTitleView = React.createClass
  mixins: [ContentEditableMixin, AnnotateMixin]
  annotate: ->
    {
      self: {cursor: @cursor()}
    }

  cursor: ->
    if @isFocused()
      "text"
    else
      "-webkit-grab"

  handleMouseDown: (e) ->
    return if @isFocused()

    e.preventDefault()

    el = @getDOMNode()
    rect = el.getBoundingClientRect()
    offset = {
      x: e.clientX - rect.left
      y: e.clientY - rect.top
    }

    editor.dragging = {
      cursor: "-webkit-grabbing"
    }

    onceDragConsummated e, =>
      editor.dragging = {
        cursor: "-webkit-grabbing"
        offset: offset
        render: =>
          ParamView {param: @props.param}
        param: @props.param
      }

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
      "data-cursor": @cursor()
    }, param.title



ParamView = React.createClass
  mixins: [AnnotateMixin]
  annotate: ->
    {
      self: {hoverParam: @props.param}
    }
  handleClick: (e) ->
    {param} = @props
    if key.command
      if param.axis == "result"
        param.axis = "x"
      else
        param.axis = "result"
    else if key.shift
      if param == editor.spreadParam
        editor.spreadParam = null
      else
        editor.spreadParam = param
  handleMouseUp: (e) ->
    return unless draggingParam = editor.dragging?.param
    @props.replaceSelf(draggingParam)
  render: ->
    classNames = cx {
      param: true
      hovered: editor.hoveredParam == @props.param
    }
    R.div {className: classNames, onClick: @handleClick, onMouseUp: @handleMouseUp},
      ParamTitleView {param: @props.param}
      ParamValueView {param: @props.param}