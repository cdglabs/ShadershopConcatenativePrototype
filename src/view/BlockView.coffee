R.create "BlockView",
  render: ->
    {block} = @props
    R.div {className: "block"},
      block.applies().map (apply) ->
        R.ApplyRowView {apply, block, key: apply.__id}