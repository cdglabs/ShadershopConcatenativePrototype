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
    console.log apply1, apply2

    applies = @appliesRange(apply1, apply2)
    console.log "applies", applies

    dependencies = []
    for apply in applies
      for dependentParam in apply.dependentParams()
        dependencies.push(dependentParam)

    dependencies = _.unique(dependencies)
    dependencies = _.difference(dependencies, applies)

    console.log "dependencies", dependencies

