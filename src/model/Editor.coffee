Param = require("./Param")
ProvisionalApply = require("./ProvisionalApply")


module.exports = class Editor
  constructor: ->
    @root = null

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
  # Reordering Applies
  # ===========================================================================

  applies: ->
    applies = []
    apply = @root
    while apply?
      applies.unshift(apply)
      apply = apply.params[0]
    return applies

  nextApply: (refApply) ->
    # Returns a known apply such that apply.params[0] == refApply
    nextApply = @root
    while nextApply && nextApply.params[0] != refApply
      nextApply = nextApply.params[0]
    if nextApply instanceof Param
      return undefined
    else
      return nextApply

  removeApply: (apply) ->
    if @root == apply
      @root = apply.params[0]
    else
      nextApply = @nextApply(apply)
      if nextApply
        nextApply.setParam(0, apply.params[0])

  insertApplyAfter: (apply, refApply) ->
    if @root == refApply
      @root = apply
      apply.setParam(0, refApply)
    else
      nextApply = @nextApply(refApply)
      if nextApply
        nextApply.setParam(0, apply)
        apply.setParam(0, refApply)

  insertNewApplyAfter: (refApply) ->
    apply = new ProvisionalApply()
    @insertApplyAfter(apply, refApply)

  replaceApply: (apply, refApply) ->
    @insertApplyAfter(apply, refApply)
    @removeApply(refApply)


  # ===========================================================================
  # Selecting Applies
  # ===========================================================================

  isApplySelected: (refApply) ->
    if @selection1? and @selection2?
      applies = @applies()
      refIndex = applies.indexOf(refApply)
      return false if refIndex == -1
      selection1Index = applies.indexOf(@selection1)
      selection2Index = applies.indexOf(@selection2)
      return Math.min(selection1Index, selection2Index) <= refIndex <= Math.max(selection1Index, selection2Index)
    else if @selection1?
      return refApply == @selection1
    else
      return false

  unsetSelection: ->
    @selection1 = null
    @selection2 = null

  setSingleSelection: (refApply) ->
    @selection1 = refApply
    @selection2 = null

  setRangeSelection: (refApply) ->
    if @selection1
      @selection2 = refApply
    else
      @setSingleSelection(refApply)
