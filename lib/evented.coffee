class Evented
  constructor: ->
    @listeners = {}

  on: (event, listener) ->
    @listeners[event] ?= []
    @listeners[event].push(listener)

  emit: (event, args...) ->
    for listener in (@listeners[event] || [])
      listener(args...)

  remove: (event, listener) ->
    index = (@listeners[event] || []).indexOf(listener)

    unless index == -1
      @listeners[event].splice(index, 1)

if module?
  module.exports = Evented
