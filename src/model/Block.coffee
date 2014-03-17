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


