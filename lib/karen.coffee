Evented = require('./evented')

class MockLocation
  search: ''
  href: 'http://localhost'
  pathname: '/'

class MockNavigator
  userAgent: ''

class MockScreen
  width: 0
  height: 0

class MockNode extends Evented
  constructor: (@type) ->
    super

    if @type?.toLowerCase() == 'iframe'
      @contentWindow = new MockWindow

    @attributes = {}

    @__defineGetter__ 'ownerDocument', -> new MockDocument
    @__defineGetter__ 'parentNode', -> new MockNode

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
    @emit 'append-child', node

  getBoundingClientRect:
    height: 0
    width: 0
    left: 0
    bottom: 0
    right: 0
    top: 0

  setAttribute: (name, value) ->
    @attributes[name] = value

  getAttribute: (name) ->
    @attributes[name]

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

    @__defineGetter__ 'defaultView', -> new MockWindow
    @__defineGetter__ 'parentWindow', -> new MockWindow

    @body = new MockNode('body')
    @head = new MockNode('head')
    @documentElement = new MockNode('documentElement')

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
    @navigator = new MockNavigator
    @screen = new MockScreen

  postMessage: (data, origin) ->
    @emit 'message',
      data: data
      origin: origin
      source: @

  decodeURIComponent: decodeURIComponent
  encodeURIComponent: encodeURIComponent

  setTimeout: (callback, delay) ->
    delay = Math.floor(delay)
    @timeouts.push
      timeout: true
      runAt: @currentTime + delay
      callback: callback

  setInterval: (callback, delay) ->
    delay = Math.floor(delay)
    @intervals.push
      interval: true
      delay: delay
      runAt: @currentTime + delay
      callback: callback

  clearTimeout: (index) ->
    if timeout = @timeouts[index - 1]
      timeout.cleared = true

  clearInterval: (index) ->
    if interval = @intervals[index - 1]
      interval.cleared = true

  tick: (ms, callback) ->
    ms = Math.floor(ms)

    nextToRun = =>
      candidates = []

      for item in @timeouts.concat(@intervals)
        continue if @currentTime + ms < item.runAt
        continue if item.cleared

        if item.interval
          candidates.push(item)
        else if item.timeout
          candidates.push(item) unless item.callbacked

      minItem = null
      minValue = null

      for candidate in candidates
        unless minItem && candidate.runAt >= minValue
          minItem = candidate
          minValue = candidate.runAt

      minItem

    asyncOrSync = (fn) ->
      if callback
        setTimeout(fn, 0)
      else
        fn()

    if current = nextToRun()
      asyncOrSync =>
        currentTime = @currentTime
        @currentTime = current.runAt

        tick = ms + currentTime - current.runAt

        if current.interval
          current.runAt += current.delay
        else
          current.callbacked = true

        current.callback()

        if tick >= 0
          @tick(tick, callback)
    else
      @currentTime += ms

      if callback
        callback()


module.exports = {MockWindow, MockDocument, MockNode, MockLocation, MockNavigator, MockScreen}
