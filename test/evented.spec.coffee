Evented = require('../lib/evented')

describe 'Evented', ->
  subject ->
    new Evented

  it 'does nothing when no listener has been added', ->
    @subject.emit 'event'

  it 'emits single event with no arguments', (done) ->
    @subject.on 'event', done
    @subject.emit 'event'

  it 'emits multiple events with no arguments', (done) ->
    count = 0
    checkDone = ->
      done() if (++count) is 2

    @subject.on 'event', checkDone
    @subject.on 'event', checkDone
    @subject.emit 'event'

  it 'emits event with single argument', (done) ->
    @subject.on 'event', (argument) ->
      done() if argument == 'argument'

    @subject.emit 'event', 'argument'

  it 'emits event with multiple arguments', (done) ->
    @subject.on 'event', (argument1, argument2) ->
      done() if argument1 == 'argument-1' &&
                argument2 == 'argument-2'

    @subject.emit 'event', 'argument-1', 'argument-2'

  it 'handles multiple events', (done) ->
    count = 0
    checkDone = ->
      done() if (++count) is 2

    @subject.on 'eventa', checkDone
    @subject.on 'eventb', checkDone
    @subject.emit 'eventa'
    @subject.emit 'eventb'

  it 'does not emit events added before adding listener', (done) ->
    @subject.emit 'event'
    @subject.on 'event', ->
      done('should not emit event, but did')
    done()
