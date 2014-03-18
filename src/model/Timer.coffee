module.exports = new class Timer
  constructor: ->
    @startMillis = Date.now()

  currentTime: ->
    millis = Date.now() - @startMillis
    return millis / 1000