Evented = require('./evented')

class MockLocation

class MockNode extends Evented
  constructor: (@type) ->
    super

    if @type?.toLowerCase() == 'iframe'
      @contentWindow = new MockWindow

  addEventListener: (event, listener) ->
    @on(event, listener)

  removeEventListener: (event, listener) ->
    @remove(event, listener)

  attachEvent: (event, listener) ->
    @on(event, listener)

  detachEvent: (event, listener) ->
    @remove(event, listener)

  style: {}

  createElement: (type) ->
    new MockNode(type)

  appendChild: (node) ->

class MockDocument extends MockNode
  constructor: ->
    super('document')

    cookies = {}

    @__defineGetter__ 'cookie', ->
      cookieString = []

      for name, value of cookies
        cookieString.push(name + '=' + value.value)

      cookieString.join('; ')

    @__defineSetter__ 'cookie', (value) ->
      [keyValue, options...] = value.split(';').map (part) -> part.trim()
      [key, value] = keyValue.split('=')

      cookies[key] =
        value: value

      for option in options
        [optionName, optionValue] = option.split('=')

        cookies[key][optionName] = optionValue

      @emit 'cookie', key, value, {path, domain} = cookies[key]

    @body = new MockNode('body')

class MockWindow extends MockNode
  constructor: ->
    super('window')

    @timeouts = []
    @intervals = []
    @currentTime = 0
    @top = @
    @console =
      log: (args...) =>
        @emit 'console-log', args...

    @document = new MockDocument
    @location = new MockLocation

  postMessage: (data, origin) ->
    @emit 'message',
      data: data
      origin: origin
      source: @

  decodeURIComponent: decodeURIComponent
  encodeURIComponent: encodeURIComponent

  setTimeout: (callback, delay) ->
    @timeouts.push
      runAt: @currentTime + delay
      callback: callback

  setInterval: (callback, delay) ->
    @intervals.push
      delay: delay
      runAt: @currentTime + delay
      callback: callback

  clearTimeout: (index) ->
    if timeout = @timeouts[index - 1]
      timeout.cleared = true

  clearInterval: (index) ->
    if interval = @intervals[index - 1]
      interval.cleared = true

  tick: (ms) ->
    for [1..ms]
      @currentTime += 1

      for interval in @intervals
        unless interval.cleared
          if interval.runAt == @currentTime
            interval.callback()
            interval.runAt = @currentTime + interval.delay

      for timeout in @timeouts
        unless timeout.callbacked || timeout.cleared
          if timeout.runAt == @currentTime
            timeout.callback()
            timeout.callbacked = true

module.exports = {MockWindow, MockDocument, MockNode, MockLocation}
