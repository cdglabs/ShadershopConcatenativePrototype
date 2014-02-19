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
    scrubbing = false
    originalValue = param.value
    pointerManager.capture e,
      (e) ->
        dx = e.clientX - originalX
        dy = -(e.clientY - originalY)
        if scrubbing
          change = if scrubbing == "x" then dx else dy
          multiplier = 0.1
          param.value = originalValue + change * multiplier
          refresh()
        else
          if Math.abs(dx) > 4
            scrubbing = "x"
          if Math.abs(dy) > 4
            scrubbing = "y"


  handleInput: (e) ->
    @props.param.value = +@cleanAndGetValue()
    refresh()

  render: ->
    param = @props.param
    d.span {
      className: "paramValue"
      contentEditable:true
      onMouseDown: @handleMouseDown
      onDoubleClick: @focusAndSelect
      onInput: @handleInput
      onBlur: refresh
    },
      do =>
        if editor.xParam == param
          d.i {}, "x"
        else
          truncate(param.value)



ParamTitleView = React.createClass
  mixins: [ContentEditableMixin]

  handleMouseDown: (e) ->
    return if @isFocused()

    e.preventDefault()

    el = @getDOMNode()

    el = el.closest(".param")

    originalX = e.clientX
    originalY = e.clientY

    rect = el.getBoundingClientRect()
    originalGhostX = rect.left
    originalGhostY = rect.top

    ghost = el.cloneNode(true)

    ghost.style.position = "absolute"
    ghost.style.opacity = "0.5"
    ghost.style.pointerEvents = "none"
    document.body.appendChild(ghost)

    moveGhost = (x, y) ->
      ghost.style.top = y + "px"
      ghost.style.left = x + "px"

    moveGhost(originalGhostX, originalGhostY)

    editor.movingParam = @props.param

    pointerManager.capture e,
      (e) ->
        dx = e.clientX - originalX
        dy = e.clientY - originalY
        moveGhost(originalGhostX + dx, originalGhostY + dy)
      (e) ->
        document.body.removeChild(ghost)
        setTimeout((-> editor.movingParam = null), 1)


  handleInput: ->
    @props.param.title = @cleanAndGetValue()
    refresh()

  render: ->
    param = @props.param
    d.span {
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
      refresh()
  handleMouseUp: (e) ->
    return unless editor.movingParam
    @props.replaceSelf(editor.movingParam)
  render: ->
    classNames = cx {
      param: true
      hovered: editor.hoveredParam == @props.param
    }
    d.div {className: classNames, onClick: @handleClick, onMouseUp: @handleMouseUp},
      ParamTitleView {param: @props.param}
      ParamValueView {param: @props.param}