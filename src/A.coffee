AnnotateMixin = {
  componentDidMount: -> @updateAnnotations()
  componentDidUpdate: -> @updateAnnotations()
  updateAnnotations: ->
    return unless @annotations
    for own refName, annotateFn of @annotations
      if refName == "self"
        component = this
      else
        component = @refs?[refName]
      el = component?.getDOMNode()
      if el
        el.annotation = annotateFn.call(this)
}