lerp = (x, dMin, dMax, rMin, rMax) ->
  ratio = (x - dMin) / (dMax - dMin)
  ratio * (rMax - rMin) + rMin


compose = (f, g) ->
  (x) -> f(g(x))



Element::matches ?= Element::webkitMatchesSelector ? Element::mozMatchesSelector ? Element::oMatchesSelector

Element::closest = (selector) ->
  if _.isString(selector)
    fn = (el) -> el.matches(selector)
  else
    fn = selector

  if fn(this)
    return this
  else
    parent = @parentNode
    if parent? && parent.nodeType == Node.ELEMENT_NODE
      return parent.closest(fn)
    else
      return undefined