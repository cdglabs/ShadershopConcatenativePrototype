R = React.DOM
cx = React.addons.classSet
ApplyRowView = require("./ApplyRowView")


module.exports = BlockView = React.createClass
  render: ->
    {block} = @props
    R.div {className: "block"},
      block.applies().map (apply) ->
        ApplyRowView {apply, block, key: apply.__id}