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
    return if editor.dragging?
    return if @props.isProvisional

    {apply} = @props

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

            editor.removeApply(apply)
            if insertAfterEl
              refApply = insertAfterEl.dataFor.props.apply
              editor.insertApplyAfter(apply, refApply)
        }

  render: ->
    {apply, isDraggingCopy} = @props

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
      apply.tailParams().map (param, paramIndex) ->
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
      styleOpts = config.styles.selectedApply
    graphViews.push(GraphView {apply, styleOpts, key: "result"})

    R.div {className: "applyThumbnail", style: {cursor: "-webkit-grab"}, onMouseDown: @handleMouseDown, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      # if editor.shaderView
      #   ShaderGraphView {apply: apply}
      # else
      #   graphViews
      graphViews


PossibleApplyView = React.createClass
  handleMouseEnter: ->
    # TODO controller
    @props.apply.selectedApply = @props.possibleApply
    editor.hoveredParam = @props.possibleApply.tailParams()[0]
  handleMouseLeave: ->
    # TODO controller
    @props.apply.selectedApply = null
    editor.hoveredParam = null
  handleClick: ->
    editor.replaceApply(@props.possibleApply, @props.apply)
    # TODO controller
    editor.hoveredParam = null
  render: ->
    {apply, possibleApply} = @props
    classNames = cx {
      possibleApply: true
      selectedPossibleApply: apply.selectedApply == possibleApply
    }
    R.div {className: classNames, onClick: @handleClick, onMouseEnter: @handleMouseEnter, onMouseLeave: @handleMouseLeave},
      ApplyInternalsView {apply: possibleApply}


ProvisionalApplyView = React.createClass
  render: ->
    {apply} = @props
    R.div {className: "provisionalApply"},
      apply.possibleApplies.map (possibleApply) ->
        PossibleApplyView {apply, possibleApply, key: possibleApply.__id}



module.exports = ApplyRowView = React.createClass
  mixins: [DataForMixin]

  toggleProvisionalApply: ->
    {apply} = @props
    nextApply = editor.nextApply(apply)
    if nextApply instanceof ProvisionalApply
      editor.removeApply(nextApply)
    else
      editor.insertNewApplyAfter(apply)

  render: ->
    {apply} = @props
    if apply instanceof ProvisionalApply
      R.div {className: "applyRow"},
        ProvisionalApplyView {apply}
    else
      R.div {className: "applyRow"},
        ApplyView {apply}
        R.button {className: "addApplyButton", onClick: @toggleProvisionalApply}, "+"




