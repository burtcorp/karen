MockWindow = require('../lib/mock_window')
MockDocument = require('../lib/mock_document')

describe 'MockWindow', ->
  def 'window', -> new MockWindow

  describe '#top', ->
    it 'is itself', ->
      @window.top.should.equal(@window)

  describe '#document', ->
    it 'is a MockDocument', ->
      @window.document.should.be.an('object')

  describe '#console', ->
    describe '#log', ->
      it 'emits console-log event', (done) ->
        @window.on 'console-log', (argument1, argument2) ->
          done() if argument1 == 'log-1' &&
                    argument2 == 'log-2'

        @window.console.log('log-1', 'log-2')

  describe '#postMessage', ->
    it 'emits message event', ->
      origin = {}
      @window.on 'message', (event) ->
        event.data.should.equal('message')
        event.origin.should.equal(origin)
        event.source.should.be.an('object')
      @window.postMessage('message', origin)

  describe '#location', ->
    it 'returns a MockLocation', ->
      @window.location.should.be.an('object')

  describe 'encodeURIComponent', ->
    it 'returns encoded string', ->
      @window.encodeURIComponent('foo/bar').should.equal('foo%2Fbar')

  describe 'decodeURIComponent', ->
    it 'returns decoded string', ->
      @window.decodeURIComponent('foo%2Fbar').should.equal('foo/bar')

  describe '#setTimeout', ->
    it 'runs callback after delay', (done) ->
      @window.setTimeout(done, 100)
      @window.tick(100)

    it 'does not run callback if delay has not passed', (done) ->
      @window.setTimeout ->
        done('should not callback function, but did')
      , 100
      @window.tick(99)
      done()

    it 'runs multiple callbacks', (done) ->
      count = 0
      doneCheck = ->
        done() if (++count) >= 2
      @window.setTimeout(doneCheck, 50)
      @window.setTimeout(doneCheck, 100)
      @window.tick(100)

    it 'does not run callback when ticking half before', (done) ->
      @window.tick(50)
      @window.setTimeout ->
        done('should not callback, but did')
      , 100
      @window.tick(50)
      done()

  describe '#clearTimeout', ->
    it 'does nothing when given a non timeout object', ->
      @window.clearTimeout({})

    it 'does not run timeout if cleared', (done) ->
      timeout = @window.setTimeout ->
        done('should not callback, but did')
      , 100
      @window.clearTimeout(timeout)
      @window.tick(100)
      done()

  describe '#setInterval', ->
    it 'runs callback after delay', (done) ->
      @window.setInterval(done, 100)
      @window.tick(100)

    it 'runs callback after every delay', (done) ->
      count = 0
      doneCheck = -> done() if (++count) >= 3
      @window.setInterval(doneCheck, 100)
      @window.tick(100)
      @window.tick(100)
      @window.tick(100)

    it 'does not run callback if delay has not passed', (done) ->
      @window.setInterval ->
        done('should not callback function, but did')
      , 100
      @window.tick(99)
      done()

    it 'runs multiple callbacks', (done) ->
      count = 0
      doneCheck = ->
        done() if (++count) >= 2
      @window.setInterval(doneCheck, 50)
      @window.setInterval(doneCheck, 100)
      @window.tick(100)

    it 'does not run callback when ticking half before', (done) ->
      @window.tick(50)
      @window.setInterval ->
        done('should not callback, but did')
      , 100
      @window.tick(50)
      done()

  describe '#clearInterval', ->
    it 'does nothing when given a non timeout object', ->
      @window.clearInterval({})

    it 'does not run interval once cleared', (done) ->
      count = 0
      doneCheck = -> done() if (++count) >= 2
      interval = @window.setInterval(doneCheck, 100)
      @window.tick(100)
      @window.tick(100)
      @window.clearInterval(interval)
      @window.tick(100)
