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

class MockDate
  constructor: (args...) ->
    if args.length == 0
      args = [MockDate.__now.getTime()]

    return new (Function.prototype.bind.apply(Date, [null].concat(args)))

MockDate.__now = new Date
MockDate.add = (ms) ->
  MockDate.__now.setTime(MockDate.__now.getTime() + ms)

class MockLocation
  search: ''
  href: 'http://localhost'
  pathname: '/'

class MockNavigator
  userAgent: ''

class MockScreen
  width: 2560
  height: 1440

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

  scrollTop: 0
  scrollLeft: 0
  scrollWidth: 1265
  scrollHeight: 2284
  clientWidth: 1265
  clientHeight: 2284

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

    hasExpired = (name) =>
      {expires} = cookies[name]

      exp = (new @defaultView.Date(expires)).getTime()
      now = (new @defaultView.Date()).getTime()

      now - exp > 0

    @__defineGetter__ 'cookie', ->
      cookieString = []

      for name, {value, expires} of cookies
        unless hasExpired(name)
          cookieString.push(name + '=' + value)

      cookieString.join('; ')

    @__defineSetter__ 'cookie', (value) ->
      [keyValue, options...] = value.split(';').map (part) -> part.trim()
      [key, value] = keyValue.split('=')

      cookies[key] =
        value: value

      for option in options
        [optionName, optionValue] = option.split('=')

        cookies[key][optionName] = optionValue

      @emit 'cookie', key, value, {expires, path, domain} = cookies[key]

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

  Date: MockDate

  scrollTo: (x, y) ->
    @pageXOffset = x
    @pageYOffset = y

    @document.documentElement.scrollLeft = x
    @document.documentElement.scrollTop = y

    @document.body.scrollLeft = x
    @document.body.scrollTop = y

  pageXOffset: 0
  pageYOffset: 0

  innerWidth: 1280
  innerHeight: 1086

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
      MockDate.add(current.runAt - @currentTime)

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
      MockDate.add(ms)

      @currentTime += ms

      if callback
        callback()

  tickAsync: (ms, callback = ->) ->
    @tick(ms, callback)

  setImmediate: (callback, params...) ->
    setImmediate(callback, params...)

api = {
  Evented
  MockWindow
  MockDocument
  MockElement
  MockNode
  MockLocation
  MockNavigator
  MockScreen
  MockDate
}

if module?
  module.exports = api
else if window?
  for key, value of api
    window[key] = value
