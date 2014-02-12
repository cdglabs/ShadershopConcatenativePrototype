drawManager = do ->

  d = React.DOM

  dif = (cond, fn) ->
    if cond then fn() else null

  FnView = React.createClass
    select: (e) ->
      return if e.target.matches("input, button")
      state.selected = @props.fn
      refresh()

    remove: ->
      {fn, i} = @props

      # Remove it from state.fns
      state.fns.splice(i, 1)

      # Fix state.selected if necessary
      if state.selected = fn
        if state.fns.length == i
          state.selected = state.fns[i-1]
        else
          state.selected = state.fns[i]

      refresh()

    setVisibility: (e) ->
      {fn, i} = @props
      fn.visible = e.target.checked
      refresh()

    render: ->
      {fn, i} = @props
      classNames = {
        fn: true
        selected: fn == state.selected
      }
      d.div {className: React.addons.classSet(classNames), onMouseDown: @select},
        dif i > 0, =>
          d.button {onClick: @remove, style: {marginRight: 6}},
            "X"
        d.input {type: "checkbox", onChange: @setVisibility, checked: fn.visible, style: {marginRight: 6}}
        d.span {},
          fn.title


  ManagerView = React.createClass

    handleChange: (e) ->
      i = e.target.selectedIndex
      e.target.selectedIndex = 0
      return if i == 0

      fnToAdd = state.fnsToAdd[i-1]
      fn = new fnToAdd()

      placeToAdd = state.fns.indexOf(state.selected) + 1
      state.fns.splice(placeToAdd, 0, fn)

      state.selected = fn
      refresh()

    render: ->
      d.div {},
        state.fns.map (fn, i) =>
          FnView {fn: fn, i: i}
        d.div {className: "fnsToAdd"},
          d.select {onChange: @handleChange},
            d.option {value: "select"}, "Add..."
            state.fnsToAdd.map (fnToAdd) =>
              d.option {}, fnToAdd.prototype.title

  return ->
    manager = document.querySelector("#manager")
    React.renderComponent(ManagerView(), manager)