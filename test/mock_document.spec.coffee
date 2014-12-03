{MockDocument} = require('../lib/karen')

describe 'MockDocument', ->
  def 'document', -> new MockDocument

  describe '#cookie', ->
    it 'sets cookie string', ->
      @document.cookie = 'foo=bar; domain=.domain.com; path=/'
      @document.cookie = 'baz=qux; domain=.domain.com; path=/'
      @document.cookie.should.equal('foo=bar; baz=qux')

    it 'emits cookie event', (done) ->
      @document.on 'cookie', (name, value, options) ->
        name.should.equal('foo')
        value.should.equal('bar')
        options.domain.should.equal('.domain.com')
        options.path.should.equal('/')
        done()
      @document.cookie = 'foo=bar; domain=.domain.com; path=/'

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

  describe '#getElementsByTagName', ->
    it 'returns an empty array', ->
      @document.getElementsByTagName('div').should.eql([])
