{MockEvent} = require('../lib/karen')

describe 'MockEvent', ->
  def 'event', -> new MockEvent('event')

  describe '#type', ->
    it 'returns the event type', ->
      expect(@event.type).to.equal('event')
