{Evented} = require('../lib/karen')

describe 'Evented', ->
  def 'evented', -> new Evented

  it 'does nothing when no listener has been added', ->
    @evented.emit 'event'

  it 'emits single event with no arguments', (done) ->
    @evented.on 'event', done
    @evented.emit 'event'

  it 'emits multiple events with no arguments', (done) ->
    count = 0
    checkDone = ->
      done() if (++count) is 2

    @evented.on 'event', checkDone
    @evented.on 'event', checkDone
    @evented.emit 'event'

  it 'emits event with single argument', (done) ->
    @evented.on 'event', (argument) ->
      done() if argument == 'argument'

    @evented.emit 'event', 'argument'

  it 'emits event with multiple arguments', (done) ->
    @evented.on 'event', (argument1, argument2) ->
      done() if argument1 == 'argument-1' &&
                argument2 == 'argument-2'

    @evented.emit 'event', 'argument-1', 'argument-2'

  it 'handles multiple events', (done) ->
    count = 0
    checkDone = ->
      done() if (++count) is 2

    @evented.on 'eventa', checkDone
    @evented.on 'eventb', checkDone
    @evented.emit 'eventa'
    @evented.emit 'eventb'

  it 'does not emit events added before adding listener', (done) ->
    @evented.emit 'event'
    @evented.on 'event', ->
      done('should not emit event, but did')
    done()

  describe '#remove', ->
    it 'removes event for specified listener', (done) ->
      @evented.on 'event', done
      @evented.remove 'event', done
      done()

    it 'does nothing if no such event', ->
      @evented.remove('event')

    it 'does nothing if no such listener', ->
      @evented.on 'event', ->
      @evented.remove 'event', ->
