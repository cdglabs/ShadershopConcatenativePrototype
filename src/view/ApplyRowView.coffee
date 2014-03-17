R = React.DOM
cx = React.addons.classSet
Param = require("../model/Param")
ProvisionalApply = require("../model/ProvisionalApply")
onceDragConsummated = require("../util/onceDragConsummated")
DataForMixin = require("./mixins/DataForMixin")
StartTranscludeMixin = require("./mixins/StartTranscludeMixin")
ParamView = require("./ParamView")
GraphView = require("./rendering/GraphView")


ApplyView = React.createClass
  handleMouseDown: (e) ->
    {apply, block, isDraggingCopy} = @props

    return if editor.dragging?

    # Deal with selection changing
    if key.shift
      editor.setRangeSelection(apply)
    else
      if editor.isApplySelected(apply)
        onceDragConsummated e, null, =>
          editor.setSingleSelection(apply)
      else
        editor.setSingleSelection(apply)

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
              ApplyView {apply, isDraggingCopy: true}
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

    classNames = cx {
      apply: true
      hovered: apply == editor.hoveredApply
      isStart: apply.isStart?()
      isSelected: editor.isApplySelected(apply)
    }
    R.div {className: classNames, style: {cursor: "-webkit-grab"}, onMouseDown: @handleMouseDown},
      ApplyInternalsView {apply}


ApplyInternalsView = React.createClass
  render: ->
    {apply} = @props
    R.div {className: "applyInternals"},
      R.div {className: "fnTitle"},
        apply.fn.title
      apply.allParams().map (param, paramIndex) ->
        return null if paramIndex == 0
        ParamSlotView {param, apply, paramIndex, key: paramIndex}
      ApplyThumbnailView {apply}


ParamSlotView = React.createClass
  mixins: [DataForMixin]

  handleTransclusionDrop: (p) ->
    {param, apply, paramIndex} = @props
    # TODO controller
    apply.setParam(paramIndex, p)

  render: ->
    {param, apply, paramIndex} = @props
    R.div {className: "paramSlot"},
      if param instanceof Param
        ParamView {param: param}
      else
        ApplyThumbnailView {apply: param}


ApplyThumbnailView = React.createClass
  mixins: [StartTranscludeMixin]
  handleMouseDown: (e) ->
    {apply} = @props
    render = =>
      ApplyThumbnailView {apply}
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
        graphViews.push(GraphView {apply: param, styleOpts, key: i})

    if apply == editor.hoveredApply
      styleOpts = config.styles.hoveredApply
    else
      styleOpts = config.styles.resultApply
    graphViews.push(GraphView {apply, styleOpts, key: "result"})

    R.div {className: "applyThumbnail", style: {cursor: "-webkit-grab"}, onMouseDown: @handleMouseDown, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      # if editor.shaderView
      #   ShaderGraphView {apply: apply}
      # else
      #   graphViews
      graphViews


PossibleApplyView = React.createClass
  handleMouseEnter: ->
    {apply, block, possibleApply} = @props
    # TODO controller
    apply.stagedApply = possibleApply
    editor.hoveredParam = possibleApply.allParams()[1]
  handleMouseLeave: ->
    {apply, block, possibleApply} = @props
    # TODO controller
    apply.stagedApply = null
    editor.hoveredParam = null
  handleClick: ->
    {apply, block, possibleApply} = @props
    block.replaceApply(possibleApply, apply)
    # TODO controller
    editor.hoveredParam = null
  render: ->
    {apply, block, possibleApply} = @props
    classNames = cx {
      possibleApply: true
      stagedPossibleApply: apply.stagedApply == possibleApply
    }
    R.div {className: classNames, onClick: @handleClick, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      ApplyInternalsView {apply: possibleApply}


ProvisionalApplyView = React.createClass
  render: ->
    {apply, block} = @props
    R.div {className: "provisionalApply"},
      apply.possibleApplies.map (possibleApply) ->
        PossibleApplyView {apply, block, possibleApply, key: possibleApply.__id}



module.exports = ApplyRowView = React.createClass
  mixins: [DataForMixin]

  toggleProvisionalApply: ->
    # TODO: This eventually wants to just be add, not toggle. As if you
    # pressed enter. You should remove it by dragging it out or pressing
    # delete.
    {apply, block} = @props
    nextApply = block.nextApply(apply)
    if nextApply instanceof ProvisionalApply
      block.removeApply(nextApply)
    else
      block.insertNewApplyAfter(apply)

  render: ->
    {apply, block} = @props
    if apply instanceof ProvisionalApply
      R.div {className: "applyRow"},
        ProvisionalApplyView {apply, block}
    else
      R.div {className: "applyRow"},
        ApplyView {apply, block}
        R.button {className: "addApplyButton", onClick: @toggleProvisionalApply}, "+"




