DataForMixin = {
  componentDidMount: -> @updateDataForAnnotation()
  componentDidUpdate: -> @updateDataForAnnotation()
  updateDataForAnnotation: ->
    el = @getDOMNode()
    el.dataFor = this
}