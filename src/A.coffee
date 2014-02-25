AnnotateMixin = {
  componentDidMount: -> @updateAnnotations()
  componentDidUpdate: -> @updateAnnotations()
  updateAnnotations: ->
    return unless @annotate
    annotations = @annotate()
    return unless annotations
    for own refName, annotation of annotations
      if refName == "self"
        component = this
      else
        component = @refs?[refName]
      el = component?.getDOMNode()
      if el
        el.annotation = annotation
}

DataForMixin = {
  componentDidMount: -> @updateDataForAnnotation()
  componentDidUpdate: -> @updateDataForAnnotation()
  updateDataForAnnotation: ->
    el = @getDOMNode()
    el.dataFor = this
}