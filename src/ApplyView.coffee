ApplyView = React.createClass
  mixins: [AnnotateMixin]
  annotate: ->
    {
      self: {
        apply: @props.apply
        cursor: if @props.apply instanceof Param then "" else "-webkit-grab"
      }
    }

  handleMouseDown: (e) ->
    return if e.target.closest(".param")?
    return if @props.isProvisional

    {apply} = @props
    e.preventDefault()

    return if apply instanceof Param

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
        apply: apply
        render: =>
          R.div {style: {width: rect.width, height: rect.height}},
            ApplyView {apply, isDraggingCopy: true}
        onMove: (e) =>
          insertAfterEl = null

          applyEls = document.querySelectorAll(".manager .apply")
          for applyEl in applyEls
            rect = applyEl.getBoundingClientRect()
            myHeight = 37
            if rect.bottom + myHeight * 1.5 > e.clientY > rect.top + myHeight / 2 and rect.left < e.clientX < rect.right
              insertAfterEl = applyEl

          editor.removeApply(apply)
          if insertAfterEl
            refApply = insertAfterEl.annotation.apply
            editor.insertApplyAfter(apply, refApply)
      }

  render: ->
    {apply, isDraggingCopy} = @props

    if !isDraggingCopy and apply == editor.dragging?.apply
      return R.div {className: "applyPlaceholder"}

    classNames = cx {
      apply: true
      hovered: apply == editor.hoveredApply
    }
    R.div {className: classNames, onMouseDown: @handleMouseDown},
      ApplyInternalsView {apply}


ApplyInternalsView = React.createClass
  render: ->
    {apply} = @props
    R.div {className: "applyInternals"},
      if apply instanceof Param
        ParamView {param: apply}
      else
        [
          R.div {className: "fnTitle"},
            apply.fn.title
          apply.params.map (param, i) ->
            return null if i == 0
            if param instanceof Param
              ParamView {param: param, key: "#{i}/#{param.id}", replaceSelf: (p) ->
                apply.setParam(i, p)
              }
            else
              R.div {className: "paramApply"},
                ApplyThumbnailView {apply: param}
        ]
      ApplyThumbnailView {apply}


ApplyThumbnailView = React.createClass
  mixins: [AnnotateMixin]
  annotate: ->
    {self: {hoverApply: @props.apply}}

  render: ->
    {apply} = @props

    graphViews = []

    if apply.params
      for param, i in apply.params
        if param instanceof Param and param != editor.xParam
          styleOpts = config.styles.param
        else
          styleOpts = config.styles.apply
        graphViews.push(GraphView {apply: param, styleOpts, key: i})

    if apply == editor.hoveredApply
      styleOpts = config.styles.hoveredApply
    else
      styleOpts = config.styles.selectedApply
    graphViews.push(GraphView {apply, styleOpts, key: "result"})

    R.div {className: "tinyGraph"},
      graphViews


PossibleApplyView = React.createClass
  mixins: [DataForMixin, AnnotateMixin]
  annotate: ->
    if @props.possibleApply.params.length > 1
      {self: {hoverParam: @props.possibleApply.params[1]}}
  handleHoverEnter: ->
    @props.apply.selectedApply = @props.possibleApply
  handleHoverLeave: ->
    @props.apply.selectedApply = null
  handleClick: ->
    editor.replaceApply(@props.possibleApply, @props.apply)
  render: ->
    {apply, possibleApply} = @props
    classNames = cx {
      possibleApply: true
      selectedPossibleApply: apply.selectedApply == possibleApply
    }
    R.div {className: classNames, onClick: @handleClick},
      ApplyInternalsView {apply: possibleApply}


ProvisionalApplyView = React.createClass
  render: ->
    {apply} = @props
    R.div {className: "provisionalApply"},
      apply.possibleApplies.map (possibleApply) ->
        PossibleApplyView {apply, possibleApply}



ApplyRowView = React.createClass
  toggleProvisionalApply: ->
    {apply} = @props
    nextApply = editor.nextApply(apply)
    if nextApply instanceof ProvisionalApply
      editor.removeApply(nextApply)
    else
      editor.insertApplyAfter(new ProvisionalApply(), apply)

  render: ->
    {apply} = @props
    R.div {className: "applyRow"},
      if apply instanceof ProvisionalApply
        ProvisionalApplyView {apply}
      else
        [
          ApplyView {apply}
          R.button {className: "addApplyButton", onClick: @toggleProvisionalApply}, "+"
        ]




