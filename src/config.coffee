module.exports = window.config = config = {
  # In pixels:
  minGridSpacing: 70
  hitTolerance: 15
  snapTolerance: 5

  resolution: 0.5

  spreadOpacityMax: 0.2
  spreadOpacityMin: 0.02

  shaderOpacity: 1

  gridColor: "210,200,170"

  styles: {
    default: {strokeStyle: "#000", globalAlpha: 1, lineWidth: 2}
    param: {strokeStyle: "green", globalAlpha: 0.4}
    hoveredParam: {strokeStyle: "green", globalAlpha: 1}
    apply: {strokeStyle: "#000", globalAlpha: 0.1}
    hoveredApply: {strokeStyle: "#900"}
    resultApply: {strokeStyle: "#000"}
    spreadPositive: {strokeStyle: "#900"}
    spreadNegative: {strokeStyle: "#009"}
  }
}