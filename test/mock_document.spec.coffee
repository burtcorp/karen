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

  describe '#head', ->
    it 'returns a MockNode with type head', ->
      @document.head.type.should.equal('head')
