MockNode = require('./mock_node')
MockDocument = require('./mock_document')
MockLocation = require('./mock_location')

class MockWindow extends MockNode
  constructor: ->
    super

    @timeouts = []
    @intervals = []
    @currentTime = 0
    @top = @
    @console =
      log: (args...) =>
        @emit 'console-log', args...

    @__defineGetter__ 'document', ->
      new MockDocument

    @__defineGetter__ 'location', ->
      new MockLocation

  postMessage: (data, origin) ->
    @emit 'message',
      data: data
      origin: origin
      source: @

  decodeURIComponent: decodeURIComponent
  encodeURIComponent: encodeURIComponent

  setTimeout: (callback, delay) ->
    @timeouts.push
      delay: @currentTime + delay
      callback: callback

  setInterval: (callback, delay) ->
    @intervals.push
      delay: @currentTime + delay
      callback: callback

  clearTimeout: (index) ->
    if timeout = @timeouts[index - 1]
      timeout.cleared = true

  clearInterval: (index) ->
    if interval = @intervals[index - 1]
      interval.cleared = true

  tick: (delay) ->
    @currentTime += delay

    for timeout in @timeouts
      unless timeout.callbacked || timeout.cleared
        if @currentTime >= timeout.delay
          timeout.callback()
          timeout.callbacked = true

    for interval in @intervals
      if @currentTime >= interval.delay
        interval.callback() unless interval.cleared

module.exports = MockWindow
