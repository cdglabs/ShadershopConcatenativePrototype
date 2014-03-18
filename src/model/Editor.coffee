Param = require("./Param")


module.exports = class Editor
  constructor: ->
    @rootBlock = null

    @xParam = null
    @yParam = null
    @timeParam = null

    @hoveredParam = null
    @hoveredApply = null

    @selectedBlock = null
    @selectedApply1 = null
    @selectedApply2 = null

    @cursor = null
    @mousePosition = {x: 0, y: 0}
    @dragging = null

    @outputSwitch = "Cartesian"
    @shaderView = false
    @contourView = false


  spreadParam: ->
    return null if @dragging
    return null if @hoveredParam == @xParam or @hoveredParam == @yParam
    return @hoveredParam


  # ===========================================================================
  # Selecting Applies
  # ===========================================================================

  isApplySelected: (block, apply) ->
    return false unless @selectedBlock == block

    if @selectedApply1? and @selectedApply2?
      applies = block.applies()
      refIndex = applies.indexOf(apply)
      index1 = applies.indexOf(@selectedApply1)
      index2 = applies.indexOf(@selectedApply2)
      return Math.min(index1, index2) <= refIndex <= Math.max(index1, index2)
    else if @selectedApply1?
      return apply == @selectedApply1
    else
      return false

  unsetSelection: ->
    @selectedBlock = null
    @selectedApply1 = null
    @selectedApply2 = null

  setSingleSelection: (block, apply) ->
    @selectedBlock = block
    @selectedApply1 = apply
    @selectedApply2 = null

  setRangeSelection: (block, apply) ->
    if @selectedApply1 and @selectedBlock == block
      @selectedApply2 = apply
    else
      @setSingleSelection(block, apply)
