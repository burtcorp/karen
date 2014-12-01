{MockWindow, MockDocument} = require('../lib/karen')

describe 'MockWindow', ->
  def 'window', -> new MockWindow

  describe '#top', ->
    it 'is itself', ->
      @window.top.should.equal(@window)

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

  describe '#document', ->
    it 'is a MockDocument', ->
      @window.document.should.be.an('object')

    it 'returns same object every time', ->
      @window.document.should.equal(@window.document)

  describe '#location', ->
    it 'returns a MockLocation', ->
      @window.location.should.be.an('object')

    it 'returns same object every time', ->
      @window.location.should.equal(@window.location)

  describe '#screen', ->
    it 'returns a MockScreen', ->
      @window.screen.should.be.an('object')

    it 'returns same object every time', ->
      @window.screen.should.equal(@window.screen)

  describe '#navigator', ->
    it 'returns a MockNavigator', ->
      @window.navigator.should.be.an('object')

    it 'returns same object every time', ->
      @window.navigator.should.equal(@window.navigator)

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
        done() if (++count) >= 3
      @window.setTimeout(doneCheck, 50)
      @window.setTimeout(doneCheck, 100)
      @window.setTimeout(doneCheck, 150)
      @window.tick(150)

    it 'does not run callback when ticking half before', (done) ->
      @window.tick(50)
      @window.setTimeout ->
        done('should not callback, but did')
      , 100
      @window.tick(50)
      done()

    it 'handles floats', (done) ->
      @window.setTimeout(done, 123.456)
      @window.setTimeout ->
        done('should not call this, but did')
      , 125
      @window.tick(123)
      @window.tick(1.999)

    it 'runs timeouts in correct order', (done) ->
      order = []

      @window.setTimeout =>
        order.push(1)

        @window.setTimeout ->
          order.push(2)
        , 100
      , 100

      @window.setTimeout ->
        order.push(3)
      , 300

      @window.tick 300, ->
        expect(order).to.eql([1, 2, 3])
        done()

    it 'supports nested timeouts', (done) ->
      @window.setTimeout =>
        @window.setTimeout(done, 100)
      , 100
      @window.tick(200)

    it 'is called async if callback', (done) ->
      called = false
      @window.setTimeout ->
        called = true
        done()
      , 100
      @window.tick 50, ->
      @window.tick 50, ->
      expect(called).to.be.false

    it 'is not called async unless callback', (done) ->
      called = false
      @window.setTimeout ->
        called = true
        done()
      , 100
      @window.tick(50)
      @window.tick(50)
      expect(called).to.be.true

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
      @window.tick(300)

    it 'does not run callback if delay has not passed', (done) ->
      @window.setInterval ->
        done('should not callback function, but did')
      , 100
      @window.tick(99)
      done()

    it 'runs multiple callbacks', (done) ->
      count = 0
      doneCheck = ->
        done() if (++count) >= 3
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

    it 'handles floats', (done) ->
      count = 0
      doneCheck = -> done() if (++count) >= 2
      @window.setInterval(doneCheck, 123.456)
      @window.setInterval ->
        done('should not call this, but did')
      , 249
      @window.tick(247)
      @window.tick(1.999)

    it 'runs intervals in correct order', (done) ->
      order = []

      @window.setInterval =>
        order.push(1)

        @window.setInterval ->
          order.push(2)
        , 100
      , 100

      @window.setInterval ->
        order.push(3)
      , 300

      @window.tick 300, ->
        expect(order).to.eql([1, 1, 2, 1, 3, 2, 2])
        done()

    it 'supports nested intervals', (done) ->
      @window.setInterval =>
        @window.setInterval(done, 100)
      , 100
      @window.tick(200)

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

  describe '#tick', ->
    it 'callbacks when done', (done) ->
      aDone = false
      bDone = false
      cDone = false

      @window.setTimeout ->
        aDone = true
      , 100

      @window.setTimeout ->
        bDone = true
      , 200

      @window.setTimeout ->
        cDone = true
      , 300

      @window.tick 300, ->
        done() if aDone && bDone && cDone

  describe '#tickAsync', ->
    it 'is called async', (done) ->
      called = false
      @window.setTimeout ->
        called = true
        done()
      , 100
      @window.tickAsync(50)
      @window.tickAsync(50)
      expect(called).to.be.false

    it 'is callbacks', (done) ->
      fn = ->
      @window.setTimeout(fn, 100)
      @window.tickAsync(50, done)

  describe '#setImmediate', ->
    it 'callbacks', (done) ->
      @window.setImmediate (foo, bar) ->
        expect(foo).to.equal('foo')
        expect(bar).to.equal('bar')
        done()
      , 'foo', 'bar'
