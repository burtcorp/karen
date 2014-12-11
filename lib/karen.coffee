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

class MockLocation
  search: ''
  href: 'http://localhost'
  pathname: '/'

class MockNavigator
  userAgent: ''

class MockScreen
  width: 0
  height: 0

class MockElement extends Evented
  constructor: (@type) ->
    super()

  define: (name, callback) ->
    cache = @cache ?= {}

    Object.defineProperty @, name,
      get: ->
        if cache[name] == undefined
          cache[name] = callback()
        else
          cache[name]
      set: (value) ->
        cache[name] = value

  addEventListener: (event, listener) ->
    @on(event, listener)

  removeEventListener: (event, listener) ->
    @remove(event, listener)

  attachEvent: (event, listener) ->
    @on(event, listener)

  detachEvent: (event, listener) ->
    @remove(event, listener)

class MockNode extends MockElement
  constructor: (type) ->
    super

    if type?.toLowerCase() == 'iframe'
      @contentWindow = new MockWindow

    @attributes = {}

    @define 'ownerDocument', -> new MockDocument
    @define 'parentNode', -> new MockNode

    @children = []

  style: {}

  createElement: (type) ->
    new MockNode(type)

  appendChild: (node) ->
    @children.push(node)
    @emit 'append-child', node

  removeChild: (node) ->
    if node in @children
      @emit 'remove-child', node

  getBoundingClientRect: ->
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

  getElementsByTagName: -> []

  insertBefore: (other) ->

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

    @define 'defaultView', -> new MockWindow
    @define 'parentWindow', -> new MockWindow
    @define 'body', -> new MockNode('body')
    @define 'head', -> new MockNode('head')
    @define 'documentElement', -> new MockNode('documentElement')

  domain: 'localhost'

  readyState: 'complete'

  getElementById: -> null

class MockWindow extends MockElement
  constructor: ->
    super('window')

    @timeouts = []
    @intervals = []
    @currentTime = 0
    @top = @
    @console =
      log: (args...) =>
        @emit 'console-log', args...

    @define 'document', -> new MockDocument
    @define 'location', -> new MockLocation
    @define 'navigator', -> new MockNavigator
    @define 'screen', -> new MockScreen

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

  tickAsync: (ms, callback = ->) ->
    @tick(ms, callback)

  setImmediate: (callback, params...) ->
    setImmediate(callback, params...)

if module?
  module.exports = {
    Evented,
    MockWindow,
    MockDocument,
    MockElement,
    MockNode,
    MockLocation,
    MockNavigator,
    MockScreen
  }
