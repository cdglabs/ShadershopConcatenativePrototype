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


LinkThumbnailView = React.createClass
  render: ->
    drawData = []
    if _.contains(@props.chain.links, @props.link)
      apply = editor.applyForChainLink(@props.chain, @props.link)
      if apply.params
        for param in apply.params
          if param instanceof Param and param != editor.xParam
            styleOpts = config.styles.param
          else
            styleOpts = config.styles.apply
          drawData.push({apply: param, styleOpts})
      if @props.link == editor.hoveredLink
        drawData.push({apply, styleOpts: config.styles.hoveredApply})
      else
        drawData.push({apply, styleOpts: config.styles.selectedApply})
    GraphView {drawData}


LinkView = React.createClass
  mixins: [AnnotateMixin]
  annotations: {
    self: -> {
      link: @props.link
      cursor: "-webkit-grab"
    }
    thumb: -> {hoverLink: @props.link}
  }

  handleMouseDown: (e) ->
    return if e.target.closest(".param")?

    {chain, link} = @props
    e.preventDefault()

    return if link instanceof StartLink

    el = @getDOMNode()
    rect = el.getBoundingClientRect()
    offset = {
      x: e.clientX - rect.left
      y: e.clientY - rect.top
    }

    editor.dragging = {
      cursor: "-webkit-grabbing"
    }

    onceDragConsummated e, =>
      editor.dragging = {
        cursor: "-webkit-grabbing"
        offset: offset
        link: link
        render: =>
          R.div {style: {width: rect.width, height: rect.height}},
            LinkView {chain, link, isDraggingCopy: true}
        onMove: (e) =>
          insertAfter = null

          linkEls = document.querySelectorAll(".chain .link")
          for linkEl in linkEls
            rect = linkEl.getBoundingClientRect()
            if rect.bottom + rect.height * 2 > e.clientY > rect.top + rect.height / 2 and rect.left < e.clientX < rect.right
              insertAfter = linkEl

          chain.removeLink(link)
          if insertAfter
            refLink = insertAfter.annotation.link
            chain.insertLinkAfter(link, refLink)
      }

  render: ->
    {chain, link} = @props
    if !@props.isDraggingCopy and link == editor.dragging?.link
      return R.div {className: "linkPlaceholder"}

    classNames = cx {
      link: true
      row: true
      hovered: link == editor.hoveredLink
    }
    R.div {className: classNames, onMouseDown: @handleMouseDown},
      if link instanceof StartLink
        ParamView {param: link.startParam, replaceSelf: (p) ->
          link.startParam = p
        }
      else
        [
          R.div {className: "linkTitle"},
            link.fn.title
          link.additionalParams.map (param, i) ->
            ParamView {param: param, key: "#{i}/#{param.id}", replaceSelf: (p) ->
              link.additionalParams[i] = p
            }
        ]
      R.div {className: "tinyGraph", ref: "thumb"},
        LinkThumbnailView {chain, link}

AddLinkView = React.createClass
  handleClickOn: (fn) ->
    =>
      {chain, link} = @props
      newLink = chain.appendLinkAfter(fn, link)
      link.addLinkVisible = false
  render: ->
    R.div {className: "addLink"},
      fnsToAdd.map (fn) =>
        R.div {className: "row", onClick: @handleClickOn(fn)},
          fn.title


LinkRowView = React.createClass
  toggleAddLink: ->
    {chain, link} = @props
    link.addLinkVisible = !link.addLinkVisible

  render: ->
    {chain, link} = @props
    R.div {className: "linkRow"},
      LinkView {chain, link}
      R.button {className: "addLinkButton", onClick: @toggleAddLink}, "+"
      if link.addLinkVisible
        AddLinkView {chain, link}