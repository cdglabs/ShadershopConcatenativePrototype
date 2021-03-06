module.exports = R = {}

for own key, value of React.DOM
  R[key] = value

R.cx = React.addons.classSet

R.create = (name, opts) ->
  opts.displayName = name
  R[name] = React.createClass(opts)

window.R = R

require("./mixins/DataForMixin")
require("./mixins/StartTranscludeMixin")

require("./rendering/CanvasView")
require("./rendering/GraphView")
require("./rendering/GridView")
require("./rendering/ShaderGraphView")
require("./ApplyRowView")
require("./BlockView")
require("./DraggingView")
require("./EditorView")
require("./MainGraphView")
require("./ParamView")