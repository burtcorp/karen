{MockNode} = require('../lib/karen')

describe 'MockNode', ->
  def 'node', -> new MockNode

  describe '#addEventListener', ->
    it 'callbacks on event', (done) ->
      @node.addEventListener('event', done)
      @node.emit 'event'

  describe '#removeEventListener', ->
    it 'removes event listeners', (done) ->
      @node.addEventListener('event', done)
      @node.removeEventListener('event', done)
      @node.emit 'event'
      done()

  describe '#attachEvent', ->
    it 'callbacks on event', (done) ->
      @node.attachEvent('event', done)
      @node.emit 'event'

  describe '#detachEvent', ->
    it 'removes event listeners', (done) ->
      @node.attachEvent('event', done)
      @node.detachEvent('event', done)
      @node.emit 'event'
      done()

  describe '#style', ->
    it 'allows for read/write styles', ->
      @node.style.background = 'red';
      @node.style.background.should.equal('red')

  describe '#appendChild', ->
    it 'emits append-child event with node as argument', (done) ->
      child = {}
      @node.on 'append-child', (node) ->
        done() if node == child
      @node.appendChild(child)
