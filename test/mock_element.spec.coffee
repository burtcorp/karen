{MockElement} = require('../lib/karen')

describe 'MockElement', ->
  def 'element', -> new MockElement('IMG')

  describe '#new', ->
    it 'sets tagName', ->
      @element.tagName.should.eq('IMG')

  describe '#addEventListener', ->
    it 'callbacks on event', (done) ->
      @element.addEventListener('event', done)
      @element.emit 'event'

  describe '#removeEventListener', ->
    it 'removes event listeners', (done) ->
      @element.addEventListener('event', done)
      @element.removeEventListener('event', done)
      @element.emit 'event'
      done()

  describe '#attachEvent', ->
    it 'callbacks on event', (done) ->
      @element.attachEvent('event', done)
      @element.emit 'event'

  describe '#detachEvent', ->
    it 'removes event listeners', (done) ->
      @element.attachEvent('event', done)
      @element.detachEvent('event', done)
      @element.emit 'event'
      done()

  describe '#define', ->
    beforeEach ->
      @element.define 'foo', -> 'bar'

    it 'callbacks first time', ->
      expect(@element.foo).to.equal('bar')

    it 'returns assigned value', ->
      @element.foo = 'BAR'
      expect(@element.foo).to.equal('BAR')

    it 'does not override when null', ->
      @element.foo = null
      expect(@element.foo).to.be.null

    it 'overrides when undefined', ->
      @element.foo = undefined
      expect(@element.foo).to.equal('bar')
