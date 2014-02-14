

mainGraph = null


window.init = ->
  canvas = document.querySelector("#c")
  mainGraph = new Graph(canvas, -10, 10, -10, 10)
  window.addEventListener("resize", resize)
  canvas.addEventListener("pointerdown", pointerdown)
  resize()


resize = ->
  canvas = document.querySelector("#c")
  rect = canvas.getBoundingClientRect()
  canvas.width = rect.width
  canvas.height = rect.height

  refresh()


refresh = ->
  refreshView()
  refreshTinyGraphs()

  mainGraph.clear()
  mainGraph.drawGrid()
  editor.draw(mainGraph)




refreshTinyGraphs = ->
  for canvas in document.querySelectorAll("canvas")
    continue unless drawData = canvas.drawData

    rect = canvas.getBoundingClientRect()
    canvas.width = rect.width
    canvas.height = rect.height

    graph = canvas.graph ?= new Graph(canvas, -10, 10, -10, 10)
    graph.clear()

    if drawData.chain? and drawData.link?
      editor.drawChainLink(graph, drawData.chain, drawData.link)




refreshOnNextTick = do ->
  willRefreshOnNextTick = false
  return ->
    return if willRefreshOnNextTick
    willRefreshOnNextTick
    setTimeout(->
      willRefreshOnNextTick = false
      refresh()
    , 1)




pointerdown = (e) ->
  e.preventDefault()
  document.activeElement.blur()
  editor.pointerdown(e, mainGraph)













