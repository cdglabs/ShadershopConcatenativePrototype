Param = require("./Param")
ProvisionalApply = require("./ProvisionalApply")


module.exports = class Editor
  constructor: ->
    @rootBlock = null

    @xParam = null
    @yParam = null

    @hoveredParam = null
    @hoveredApply = null

    @selection1 = null
    @selection2 = null

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


  isApplySelected: -> false
  unsetSelection: ->
  setSingleSelection: ->
  setRangeSelection: ->

  # isApplySelected: (refApply) ->
  #   if @selection1? and @selection2?
  #     applies = @applies()
  #     refIndex = applies.indexOf(refApply)
  #     return false if refIndex == -1
  #     selection1Index = applies.indexOf(@selection1)
  #     selection2Index = applies.indexOf(@selection2)
  #     return Math.min(selection1Index, selection2Index) <= refIndex <= Math.max(selection1Index, selection2Index)
  #   else if @selection1?
  #     return refApply == @selection1
  #   else
  #     return false

  # unsetSelection: ->
  #   @selection1 = null
  #   @selection2 = null

  # setSingleSelection: (refApply) ->
  #   @selection1 = refApply
  #   @selection2 = null

  # setRangeSelection: (refApply) ->
  #   if @selection1
  #     @selection2 = refApply
  #   else
  #     @setSingleSelection(refApply)
