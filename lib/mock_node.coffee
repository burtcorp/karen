Evented = require('./evented')

class MockNode extends Evented
  constructor: ->
    super

  addEventListener: (event, listener) ->
    @on(event, listener)

  removeEventListener: (event, listener) ->
    @remove(event, listener)

  attachEvent: (event, listener) ->
    @on(event, listener)

  detachEvent: (event, listener) ->
    @remove(event, listener)

  style: {}

module.exports = MockNode
