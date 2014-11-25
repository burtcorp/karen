Evented = require('./evented')

class MockLocation

class MockNode extends Evented
  constructor: (@type) ->
    super

    if @type && @type.toLowerCase() == 'iframe'
      @__defineGetter__ 'contentWindow', ->
        new MockWindow

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

    @__defineGetter__ 'body', ->
      new MockNode

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

module.exports = {MockWindow, MockDocument, MockNode, MockLocation}
