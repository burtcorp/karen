MockNode = require('../lib/mock_node')

describe 'MockNode', ->
  def 'node', -> new MockNode

  describe 'addEventListener', ->
    it 'callbacks on event', (done) ->
      @node.addEventListener('event', done)
      @node.emit 'event'

  describe 'removeEventListener', ->
    it 'removes event listeners', (done) ->
      @node.addEventListener 'event', ->
        done('should not callback, but did')
      @node.removeEventListener('event', done)
      @node.emit 'event'
      done()

  describe 'attachEvent', ->
    it 'callbacks on event', (done) ->
      @node.attachEvent('event', done)
      @node.emit 'event'

  describe 'detachEvent', ->
    it 'removes event listeners', (done) ->
      @node.attachEvent 'event', ->
        done('should not callback, but did')
      @node.detachEvent('event', done)
      @node.emit 'event'
      done()

  describe 'style', ->
    it 'allows for read/write styles', ->
      @node.style.background = 'red';
      @node.style.background.should.equal('red')
