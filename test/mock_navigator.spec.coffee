{MockNavigator} = require('../lib/karen')

describe 'MockNavigator', ->
  def 'navigator', -> new MockNavigator

  describe '#userAgent', ->
    it 'is empty', ->
      @navigator.userAgent.should.equal('')
