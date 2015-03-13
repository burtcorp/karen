{MockDocument} = require('../lib/karen')

describe 'MockDocument', ->
  def 'window', -> @document.defaultView
  def 'document', -> new MockDocument

  describe '#cookie', ->
    it 'sets cookie string', ->
      @document.cookie = 'foo=bar; domain=.domain.com; path=/'
      @document.cookie = 'baz=qux; domain=.domain.com; path=/'
      @document.cookie.should.equal('foo=bar; baz=qux')

    it 'supports expires option', ->
      # NOTE: We need to set the current date to an even second (no
      # milliseconds) because when we set the cookie, we call
      # #toUTCString on it, which does not include milli seconds.
      @window.Date.__now = new Date(1426174881000)

      expires = new @window.Date()
      expires.setMinutes(expires.getMinutes() + 30)

      @document.cookie = 'foo=bar; expires=' + expires.toUTCString()
      @document.cookie = 'baz=qux;'
      @document.cookie.should.equal('foo=bar; baz=qux')
      @window.Date.add(30 * 60 * 1000 + 1)
      @document.cookie.should.equal('baz=qux')

    it 'emits cookie event', (done) ->
      expires = (new @window.Date).toUTCString()
      @document.on 'cookie', (name, value, options) ->
        name.should.equal('foo')
        value.should.equal('bar')
        options.domain.should.equal('.domain.com')
        options.path.should.equal('/')
        options.expires.should.equal(expires)
        done()
      @document.cookie = 'foo=bar; domain=.domain.com; path=/; expires=' + expires

  describe '#body', ->
    it 'returns a MockNode with type body', ->
      @document.body.type.should.equal('body')

    it 'returns same object every time', ->
      @document.body.should.equal(@document.body)

  describe '#head', ->
    it 'returns a MockNode with type head', ->
      @document.head.type.should.equal('head')

    it 'returns same object every time', ->
      @document.head.should.equal(@document.head)

  describe '#defaultView', ->
    it 'returns a MockWindow object', ->
      @document.defaultView.should.be.an('object')

    it 'returns same object every time', ->
      @document.defaultView.should.equal(@document.defaultView)

  describe '#parentWindow', ->
    it 'returns a MockWindow object', ->
      @document.parentWindow.should.be.an('object')

    it 'returns same object every time', ->
      @document.parentWindow.should.equal(@document.parentWindow)

  describe '#documentElement', ->
    it 'returns a MockNode with type documentElement', ->
      @document.documentElement.type.should.equal('documentElement')

    it 'returns same object every time', ->
      @document.documentElement.should.equal(@document.documentElement)

  describe '#domain', ->
    it 'returns localhost', ->
      @document.domain.should.equal('localhost')

  describe '#readyState', ->
    it 'is complete', ->
      @document.readyState.should.equal('complete')

  describe '#getElementById', ->
    it 'returns null', ->
      expect(@document.getElementById('id')).to.be.null
