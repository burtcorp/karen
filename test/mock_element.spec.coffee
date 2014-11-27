{MockElement} = require('../lib/karen')

describe 'MockElement', ->
  def 'element', -> new MockElement

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
