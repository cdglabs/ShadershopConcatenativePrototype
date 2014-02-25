ApplyView = React.createClass
  mixins: [AnnotateMixin]
  annotations: {
    self: -> {
      apply: @props.apply
      cursor: "-webkit-grab"
    }
    thumb: -> {hoverApply: @props.apply}
  }

  handleMouseDown: (e) ->
    return if e.target.closest(".param")?

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
            if rect.bottom + rect.height * 2 > e.clientY > rect.top + rect.height / 2 and rect.left < e.clientX < rect.right
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
      if apply instanceof Param
        ParamView {param: apply}
      else
        [
          R.div {className: "fnTitle"},
            apply.fn.title
          _.tail(apply.params).map (param, i) ->
            ParamView {param: param, key: "#{i}/#{param.id}", replaceSelf: (p) ->
              apply.params[i] = p
            }
        ]
      R.div {className: "tinyGraph", ref: "thumb"},
        ApplyThumbnailView {apply}


ApplyThumbnailView = React.createClass
  render: ->
    {apply} = @props
    drawData = []
    if true # TODO: check if all its params are defined
      if apply.params
        for param in apply.params
          if param instanceof Param and param != editor.xParam
            styleOpts = config.styles.param
          else
            styleOpts = config.styles.apply
          drawData.push({apply: param, styleOpts})
      if apply == editor.hoveredApply
        drawData.push({apply, styleOpts: config.styles.hoveredApply})
      else
        drawData.push({apply, styleOpts: config.styles.selectedApply})
    GraphView {drawData}