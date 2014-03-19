ObjectManager = require("../persistence/ObjectManager")
Apply = require("./Apply")


module.exports = class Block
  constructor: ->
    ObjectManager.assignId(this)
    @root = null

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
    apply = new Apply()
    apply.initializePossibleApplies()
    @insertApplyAfter(apply, refApply)

  replaceApply: (apply, refApply) ->
    @insertApplyAfter(apply, refApply)
    @removeApply(refApply)


  # ===========================================================================
  # Extracting out new Fn's
  # ===========================================================================

  appliesRange: (apply1, apply2) ->
    if apply1? and apply2?
      applies = @applies()
      index1 = applies.indexOf(apply1)
      index2 = applies.indexOf(apply2)
      startIndex = Math.min(index1, index2)
      endIndex = Math.max(index1, index2)
      return applies.slice(startIndex, endIndex + 1)
    else if apply1?
      return [apply1]
    else
      return []

  createFn: (apply1, apply2) ->
    appliesInRange = @appliesRange(apply1, apply2)

    appliesNotInRange = _.difference(@applies(), appliesInRange)
    paramsNotInRange = _.concatMap appliesNotInRange, (apply) ->
      apply.allParams()
    outsideExprs = _.union(appliesNotInRange, paramsNotInRange)
    # TODO: outsideExprs will also need to include the parameters *into* the
    # block. This can already be seen in how editor.xParam should be
    # considered outside. (Actually, maybe that is a bad example because maybe
    # the xParam should just be a view onto a constant. However, I think this
    # issue is still relevant if you were to make a Fn within a block and used
    # one of the parameters passed into the block.)

    # Ensure that the only apply from appliesInRange that is in outsideExprs
    # is the last one (ie its output). Otherwise we have a reference into the
    # new fn that is not its output.
    potentialConflicts = _.intersection(outsideExprs, appliesInRange)
    potentialConflicts = _.without(potentialConflicts, _.last(appliesInRange))
    if potentialConflicts.length > 0
      console.warn "Cannot create function, conflicts:", potentialConflicts
      return

    dependencies = _.concatMap appliesInRange, (apply) ->
      apply.dependentParams()
    dependencies = _.intersection(dependencies, outsideExprs)

    console.log "dependencies", dependencies

