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

    applies = @selectedBlock.appliesRange(@selectedApply1, @selectedApply2)
    return _.contains(applies, apply)

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



  createFn: ->
    return unless @selectedBlock
    @selectedBlock.createFn(@selectedApply1, @selectedApply2)