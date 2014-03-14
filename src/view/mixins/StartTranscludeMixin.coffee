onceDragConsummated = require("../../util/onceDragConsummated")


module.exports = StartTranscludeMixin = {
  startTransclude: (e, apply, render) ->
    e.preventDefault()

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
        render: render
        transclusion: apply
        onUp: (e) ->
          overlay = document.querySelector(".draggingOverlay")
          overlay.style.display = "none"
          el = document.elementFromPoint(e.clientX, e.clientY)
          overlay.style.display = "block"

          paramSlotEl = el.closest (el) -> el.dataFor?.handleTransclusionDrop
          paramSlotEl?.dataFor.handleTransclusionDrop(apply)
      }
}