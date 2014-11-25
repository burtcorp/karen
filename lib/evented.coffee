class Evented
  constructor: ->
    @listeners = {}

  on: (event, listener) ->
    @listeners[event] ?= []
    @listeners[event].push(listener)

  emit: (event, args...) ->
    for listener in (@listeners[event] || [])
      listener(args...)

module.exports = Evented
