truncate = (value) ->
  s = "" + value
  decimalPlace = s.indexOf(".")
  if decimalPlace
    s.substr(0, decimalPlace + 4)



ContentEditableMixin = {
  isFocused: ->
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

}





ParamValueView = React.createClass
  mixins: [ContentEditableMixin]

  shouldComponentUpdate: ->
    return !@isFocused()

  handleMouseDown: (e) ->
    return if @isFocused()

    e.preventDefault()

    {param} = @props
    e.preventDefault()
    originalX = e.clientX
    originalY = e.clientY
    originalValue = param.value
    pointerManager.capture e,
      (e) ->
        dx = e.clientX - originalX
        dy = -(e.clientY - originalY)
        d = if param.axis == "x" then dx else dy
        multiplier = 0.1
        param.value = originalValue + d * multiplier

  handleInput: (e) ->
    @props.param.value = +@cleanAndGetValue()

  render: ->
    param = @props.param
    cursor = if param.axis == "x" then "ew-resize" else "ns-resize"
    R.span {
      className: "paramValue"
      contentEditable:true
      onMouseDown: @handleMouseDown
      onDoubleClick: @focusAndSelect
      onInput: @handleInput
      style: {cursor}
    },
      do =>
        if editor.xParam == param
          R.i {}, "x"
        else
          truncate(param.value)



ParamTitleView = React.createClass
  mixins: [ContentEditableMixin]

  handleMouseDown: (e) ->
    return if @isFocused()

    e.preventDefault()

    el = @getDOMNode()
    rect = el.getBoundingClientRect()

    editor.dragging = {
      offset: {
        x: e.clientX - rect.left
        y: e.clientY - rect.top
      }
      render: =>
        R.div {style: {width: 400}},
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
    }, param.title



ParamView = React.createClass
  componentDidMount: ->
    @getDOMNode().ssParam = @props.param
  handleClick: (e) ->
    {param} = @props
    if key.command
      if param.axis == "result"
        param.axis = "x"
      else
        param.axis = "result"
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