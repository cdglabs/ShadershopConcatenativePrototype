Param = require("../model/Param")
onceDragConsummated = require("../util/onceDragConsummated")


R.create "ApplyView",
  handleMouseDown: (e) ->
    {apply, block, isDraggingCopy} = @props

    return if editor.dragging?

    # Deal with selection changing
    if key.shift
      editor.setRangeSelection(block, apply)
    else
      if editor.isApplySelected(block, apply)
        onceDragConsummated e, null, =>
          editor.setSingleSelection(block, apply)
      else
        editor.setSingleSelection(block, apply)

    if !apply.headParam()?
      # start of the block... TODO but should be reorderable in some cases.
      editor.dragging = {}
    else # if reorderable...
      el = @getDOMNode()
      rect = el.getMarginRect()
      myWidth = rect.width
      myHeight = rect.height
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
          placeholderHeight: myHeight
          render: =>
            R.div {style: {"min-width": myWidth, height: myHeight, overflow: "hidden", "background-color": "#fff"}},
              R.ApplyView {apply, isDraggingCopy: true}
          onMove: (e) =>
            insertAfterEl = null

            applyEls = document.querySelectorAll(".applyRow")
            for applyEl in applyEls
              continue if applyEl.querySelector(".applyPlaceholder")
              rect = applyEl.getBoundingClientRect()
              if rect.bottom + myHeight * 1.5 > e.clientY > rect.top + myHeight / 2 and rect.left < e.clientX < rect.right
                insertAfterEl = applyEl

            block.removeApply(apply)
            if insertAfterEl
              refApply = insertAfterEl.dataFor.props.apply
              refBlock = insertAfterEl.dataFor.props.block
              refBlock.insertApplyAfter(apply, refApply)
        }

  render: ->
    {apply, block, isDraggingCopy} = @props

    if !isDraggingCopy and apply == editor.dragging?.apply
      return R.div {className: "applyPlaceholder", style: {height: editor.dragging.placeholderHeight}}

    classNames = R.cx {
      apply: true
      hovered: apply == editor.hoveredApply
      isStart: apply.isStart?()
      isSelected: editor.isApplySelected(block, apply)
    }
    R.div {className: classNames, style: {cursor: "-webkit-grab"}, onMouseDown: @handleMouseDown},
      R.ApplyInternalsView {apply}


R.create "ApplyInternalsView",
  render: ->
    {apply} = @props
    R.div {className: "applyInternals"},
      R.div {className: "fnTitle"},
        apply.fn.title
      apply.allParams().map (param, paramIndex) ->
        return null if paramIndex == 0
        R.ParamSlotView {param, apply, paramIndex, key: paramIndex}
      R.ApplyThumbnailView {apply}


R.create "ParamSlotView",
  mixins: [R.DataForMixin]

  handleTransclusionDrop: (p) ->
    {param, apply, paramIndex} = @props
    # TODO controller
    apply.setParam(paramIndex, p)

  render: ->
    {param, apply, paramIndex} = @props
    R.div {className: "paramSlot"},
      if param instanceof Param
        R.ParamView {param: param}
      else
        R.ApplyThumbnailView {apply: param}


R.create "ApplyThumbnailView",
  mixins: [R.StartTranscludeMixin]
  handleMouseDown: (e) ->
    {apply} = @props
    render = =>
      R.ApplyThumbnailView {apply}
    @startTransclude(e, apply, render)

  handleMouseEnter: (e) ->
    # TODO controller
    editor.hoveredApply = @props.apply
  handleMouseLeave: (e) ->
    # TODO controller
    editor.hoveredApply = null

  render: ->
    {apply} = @props

    graphViews = []

    if !apply.isStart?()
      for param, i in apply.allParams()
        if param instanceof Param and param != editor.xParam
          styleOpts = config.styles.param
        else
          styleOpts = config.styles.apply
        graphViews.push(R.GraphView {apply: param, styleOpts, key: i})

    if apply == editor.hoveredApply
      styleOpts = config.styles.hoveredApply
    else
      styleOpts = config.styles.resultApply
    graphViews.push(R.GraphView {apply, styleOpts, key: "result"})

    R.div {className: "applyThumbnail", style: {cursor: "-webkit-grab"}, onMouseDown: @handleMouseDown, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      # if editor.shaderView
      #   ShaderGraphView {apply: apply}
      # else
      #   graphViews
      graphViews


R.create "PossibleApplyView",
  handleMouseEnter: ->
    {apply, block, possibleApply} = @props
    # TODO controller
    apply.choosePossibleApply(possibleApply)
    editor.hoveredParam = possibleApply.allParams()[1]
  handleMouseLeave: ->
    {apply, block, possibleApply} = @props
    # TODO controller
    apply.choosePossibleApply(null)
    editor.hoveredParam = null
  handleClick: ->
    {apply, block, possibleApply} = @props
    apply.removePossibleApplies()
    # TODO controller
    editor.hoveredParam = null
  render: ->
    {apply, block, possibleApply} = @props
    classNames = R.cx {
      possibleApply: true
      stagedPossibleApply: apply.isPossibleApplyChosen(possibleApply)
    }
    R.div {className: classNames, onClick: @handleClick, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      R.ApplyInternalsView {apply: possibleApply}


R.create "ProvisionalApplyView",
  render: ->
    {apply, block} = @props
    R.div {className: "provisionalApply"},
      apply.possibleApplies.map (possibleApply) ->
        R.PossibleApplyView {apply, block, possibleApply, key: possibleApply.__id}



R.create "ApplyRowView",
  mixins: [R.DataForMixin]

  toggleProvisionalApply: ->
    # TODO: This eventually wants to just be add, not toggle. As if you
    # pressed enter. You should remove it by dragging it out or pressing
    # delete.
    {apply, block} = @props
    nextApply = block.nextApply(apply)
    if nextApply?.hasPossibleApplies()
      block.removeApply(nextApply)
    else
      block.insertNewApplyAfter(apply)

  render: ->
    {apply, block} = @props
    if apply.hasPossibleApplies()
      R.div {className: "applyRow"},
        R.ProvisionalApplyView {apply, block}
    else
      R.div {className: "applyRow"},
        R.ApplyView {apply, block}
        R.button {className: "addApplyButton", onClick: @toggleProvisionalApply}, "+"




